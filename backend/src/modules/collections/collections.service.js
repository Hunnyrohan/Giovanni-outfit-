import { ApiError } from '../../utils/api-error.js';
import { deleteUploadedFile } from '../../utils/local-upload.js';
import { wardrobeRepository } from '../wardrobe/wardrobe.repository.js';
import { collectionsRepository } from './collections.repository.js';

const assertOwnedCollection = async (userId, id) => {
  const collection = await collectionsRepository.findCollectionByIdForUser(id, userId);

  if (!collection) {
    throw new ApiError(404, 'Collection not found');
  }

  return collection;
};

const assertOwnedWardrobeItem = async (userId, wardrobeItemId) => {
  const item = await wardrobeRepository.findItemByIdForUser(wardrobeItemId, userId);

  if (!item) {
    throw new ApiError(404, 'Wardrobe item not found');
  }

  return item;
};

export const createCollection = async (userId, payload, file) => {
  const data = { userId, ...payload };

  if (file) {
    data.coverImage = `/uploads/collections/${file.filename}`;
  }

  return collectionsRepository.createCollection(data);
};

export const getCollections = async (userId, query) => {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;

  const [collections, total] = await Promise.all([
    collectionsRepository.findManyForUser({
      userId,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    collectionsRepository.countForUser(userId),
  ]);

  return {
    collections,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.max(Math.ceil(total / limit), 1),
    },
  };
};

export const getCollectionById = async (userId, id) => {
  const collection = await collectionsRepository.findCollectionWithItems(id, userId);

  if (!collection) {
    throw new ApiError(404, 'Collection not found');
  }

  return collection;
};

export const updateCollection = async (userId, id, payload, file) => {
  if (Object.keys(payload).length === 0 && !file) {
    throw new ApiError(400, 'At least one field or a cover image must be provided to update the collection');
  }

  const existingCollection = await assertOwnedCollection(userId, id);

  const data = { ...payload };

  if (file) {
    data.coverImage = `/uploads/collections/${file.filename}`;
  }

  const updatedCollection = await collectionsRepository.updateCollection(id, data);

  if (file && existingCollection.coverImage) {
    await deleteUploadedFile(existingCollection.coverImage);
  }

  return updatedCollection;
};

export const deleteCollection = async (userId, id) => {
  const collection = await assertOwnedCollection(userId, id);

  await collectionsRepository.deleteCollection(id);

  if (collection.coverImage) {
    await deleteUploadedFile(collection.coverImage);
  }

  return {};
};

export const addItemToCollection = async (userId, collectionId, wardrobeItemId) => {
  await assertOwnedCollection(userId, collectionId);
  await assertOwnedWardrobeItem(userId, wardrobeItemId);

  const existingLink = await collectionsRepository.findCollectionItem(collectionId, wardrobeItemId);

  if (existingLink) {
    throw new ApiError(409, 'This wardrobe item is already in the collection');
  }

  const itemCount = await collectionsRepository.countItemsInCollection(collectionId);

  await collectionsRepository.createCollectionItem({
    collectionId,
    wardrobeItemId,
    order: itemCount,
  });

  return collectionsRepository.findCollectionWithItems(collectionId, userId);
};

export const removeItemFromCollection = async (userId, collectionId, wardrobeItemId) => {
  await assertOwnedCollection(userId, collectionId);

  const existingLink = await collectionsRepository.findCollectionItem(collectionId, wardrobeItemId);

  if (!existingLink) {
    throw new ApiError(404, 'This wardrobe item is not in the collection');
  }

  await collectionsRepository.deleteCollectionItem(collectionId, wardrobeItemId);

  return collectionsRepository.findCollectionWithItems(collectionId, userId);
};

export const reorderCollectionItems = async (userId, collectionId, orderedWardrobeItemIds) => {
  await assertOwnedCollection(userId, collectionId);

  const existingItems = await collectionsRepository.findManyItemsInCollection(collectionId);
  const existingByWardrobeItemId = new Map(existingItems.map((item) => [item.wardrobeItemId, item]));
  const uniqueOrderedIds = new Set(orderedWardrobeItemIds);

  const isSameItemSet =
    uniqueOrderedIds.size === orderedWardrobeItemIds.length &&
    uniqueOrderedIds.size === existingItems.length &&
    orderedWardrobeItemIds.every((wardrobeItemId) => existingByWardrobeItemId.has(wardrobeItemId));

  if (!isSameItemSet) {
    throw new ApiError(
      400,
      'orderedWardrobeItemIds must include exactly the wardrobe items currently in the collection, with no duplicates',
    );
  }

  const updates = orderedWardrobeItemIds.map((wardrobeItemId, index) => ({
    id: existingByWardrobeItemId.get(wardrobeItemId).id,
    order: index,
  }));

  await collectionsRepository.reorderItems(updates);

  return collectionsRepository.findCollectionWithItems(collectionId, userId);
};

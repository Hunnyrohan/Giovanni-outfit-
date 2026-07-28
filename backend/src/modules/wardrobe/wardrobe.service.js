import { ApiError } from '../../utils/api-error.js';
import { deleteUploadedFile } from '../../utils/local-upload.js';
import { wardrobeRepository } from './wardrobe.repository.js';

const assertOwnedItem = async (userId, id) => {
  const item = await wardrobeRepository.findItemByIdForUser(id, userId);

  if (!item) {
    throw new ApiError(404, 'Wardrobe item not found');
  }

  return item;
};

const buildListWhere = (query) => {
  const conditions = [];

  if (!query.includeArchived) {
    conditions.push({ isArchived: false });
  }

  if (query.category) {
    conditions.push({ category: query.category });
  }

  if (query.season) {
    conditions.push({ season: query.season });
  }

  if (query.occasion) {
    conditions.push({ occasion: { has: query.occasion } });
  }

  if (query.favorite !== undefined) {
    conditions.push({ isFavorite: query.favorite });
  }

  if (query.color) {
    conditions.push({
      OR: [
        { primaryColor: { equals: query.color, mode: 'insensitive' } },
        { colors: { has: query.color } },
      ],
    });
  }

  if (query.search) {
    conditions.push({
      OR: [
        { name: { contains: query.search, mode: 'insensitive' } },
        { tags: { has: query.search } },
      ],
    });
  }

  return conditions.length > 0 ? { AND: conditions } : {};
};

export const addWardrobeItem = async (userId, payload, file) => {
  if (!file) {
    throw new ApiError(400, 'Please upload an image for the wardrobe item');
  }

  const imageUrl = `/uploads/wardrobe/${file.filename}`;

  return wardrobeRepository.createItem({
    userId,
    imageUrl,
    ...payload,
  });
};

export const getWardrobeItems = async (userId, query) => {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;
  const where = buildListWhere(query);

  const [items, total] = await Promise.all([
    wardrobeRepository.findManyForUser({
      userId,
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    wardrobeRepository.countForUser(userId, where),
  ]);

  return {
    items,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.max(Math.ceil(total / limit), 1),
    },
  };
};

export const getWardrobeItemById = async (userId, id) => {
  return assertOwnedItem(userId, id);
};

export const updateWardrobeItem = async (userId, id, payload, file) => {
  if (Object.keys(payload).length === 0 && !file) {
    throw new ApiError(400, 'At least one field or an image must be provided to update the wardrobe item');
  }

  const existingItem = await assertOwnedItem(userId, id);

  const data = { ...payload };

  if (file) {
    data.imageUrl = `/uploads/wardrobe/${file.filename}`;
  }

  const updatedItem = await wardrobeRepository.updateItem(id, data);

  if (file) {
    await deleteUploadedFile(existingItem.imageUrl);
  }

  return updatedItem;
};

export const deleteWardrobeItem = async (userId, id) => {
  const item = await assertOwnedItem(userId, id);

  await wardrobeRepository.deleteItem(id);
  await deleteUploadedFile(item.imageUrl);

  return {};
};

export const setWardrobeItemFavorite = async (userId, id, isFavorite) => {
  await assertOwnedItem(userId, id);

  return wardrobeRepository.updateItem(id, { isFavorite });
};

export const getWardrobeStats = async (userId) => {
  const [totalItems, favoriteItems, itemsByCategoryRaw] = await Promise.all([
    wardrobeRepository.countTotalForUser(userId),
    wardrobeRepository.countFavoritesForUser(userId),
    wardrobeRepository.countByCategoryForUser(userId),
  ]);

  const itemsByCategory = itemsByCategoryRaw.reduce((accumulator, entry) => {
    accumulator[entry.category] = entry._count._all;
    return accumulator;
  }, {});

  return {
    totalItems,
    favoriteItems,
    itemsByCategory,
  };
};

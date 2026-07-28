import { ApiError } from '../../utils/api-error.js';
import { deleteUploadedFile } from '../../utils/local-upload.js';
import { wardrobeRepository } from '../wardrobe/wardrobe.repository.js';
import { savedOutfitsRepository } from './saved-outfits.repository.js';

const assertOwnedOutfit = async (userId, id) => {
  const outfit = await savedOutfitsRepository.findOutfitByIdForUser(id, userId);

  if (!outfit) {
    throw new ApiError(404, 'Saved outfit not found');
  }

  return outfit;
};

const assertOwnedWardrobeItems = async (userId, wardrobeItemIds) => {
  const uniqueIds = [...new Set(wardrobeItemIds)];

  const items = await Promise.all(
    uniqueIds.map((wardrobeItemId) => wardrobeRepository.findItemByIdForUser(wardrobeItemId, userId)),
  );

  const missingIndex = items.findIndex((item) => !item);

  if (missingIndex !== -1) {
    throw new ApiError(404, `Wardrobe item not found: ${uniqueIds[missingIndex]}`);
  }

  return uniqueIds;
};

const buildOutfitFields = ({ name, notes, occasion, season }) => {
  const data = {};

  if (name !== undefined) data.title = name;
  if (notes !== undefined) data.notes = notes;
  if (occasion !== undefined) data.occasion = occasion;
  if (season !== undefined) data.season = season;

  return data;
};

const buildListWhere = (query) => {
  const conditions = [];

  if (query.occasion) conditions.push({ occasion: query.occasion });
  if (query.season) conditions.push({ season: query.season });
  if (query.favorite !== undefined) conditions.push({ isFavorite: query.favorite });
  if (query.search) conditions.push({ title: { contains: query.search, mode: 'insensitive' } });

  return conditions.length > 0 ? { AND: conditions } : {};
};

export const createSavedOutfit = async (userId, payload, file) => {
  const { wardrobeItemIds, ...outfitFields } = payload;
  const uniqueIds = await assertOwnedWardrobeItems(userId, wardrobeItemIds);

  const data = {
    userId,
    ...buildOutfitFields(outfitFields),
  };

  if (file) {
    data.imageUrl = `/uploads/outfits/${file.filename}`;
  }

  const outfit = await savedOutfitsRepository.createOutfit(data);

  await savedOutfitsRepository.createManyOutfitItems(
    uniqueIds.map((wardrobeItemId) => ({ savedOutfitId: outfit.id, wardrobeItemId })),
  );

  return savedOutfitsRepository.findOutfitWithItems(outfit.id, userId);
};

export const getSavedOutfits = async (userId, query) => {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;
  const where = buildListWhere(query);

  const [outfits, total] = await Promise.all([
    savedOutfitsRepository.findManyForUser({
      userId,
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    savedOutfitsRepository.countForUser(userId, where),
  ]);

  return {
    outfits,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.max(Math.ceil(total / limit), 1),
    },
  };
};

export const getSavedOutfitById = async (userId, id) => {
  const outfit = await savedOutfitsRepository.findOutfitWithItems(id, userId);

  if (!outfit) {
    throw new ApiError(404, 'Saved outfit not found');
  }

  return outfit;
};

export const updateSavedOutfit = async (userId, id, payload, file) => {
  const { addWardrobeItemIds, removeWardrobeItemIds, ...outfitFields } = payload;
  const fieldsData = buildOutfitFields(outfitFields);

  const hasFieldsUpdate = Object.keys(fieldsData).length > 0;
  const hasAdd = Boolean(addWardrobeItemIds && addWardrobeItemIds.length > 0);
  const hasRemove = Boolean(removeWardrobeItemIds && removeWardrobeItemIds.length > 0);

  if (!hasFieldsUpdate && !hasAdd && !hasRemove && !file) {
    throw new ApiError(
      400,
      'At least one field, item change, or a cover image must be provided to update the saved outfit',
    );
  }

  const existingOutfit = await assertOwnedOutfit(userId, id);

  let uniqueAddIds = [];

  if (hasAdd) {
    uniqueAddIds = await assertOwnedWardrobeItems(userId, addWardrobeItemIds);
  }

  if (hasAdd || hasRemove) {
    const existingItems = await savedOutfitsRepository.findManyItemsInOutfit(id);
    const removeSet = new Set(hasRemove ? removeWardrobeItemIds : []);
    const finalIds = new Set(
      existingItems.map((item) => item.wardrobeItemId).filter((wardrobeItemId) => !removeSet.has(wardrobeItemId)),
    );

    uniqueAddIds.forEach((wardrobeItemId) => finalIds.add(wardrobeItemId));

    if (finalIds.size === 0) {
      throw new ApiError(400, 'A saved outfit must contain at least one wardrobe item');
    }
  }

  const data = { ...fieldsData };

  if (file) {
    data.imageUrl = `/uploads/outfits/${file.filename}`;
  }

  if (Object.keys(data).length > 0) {
    await savedOutfitsRepository.updateOutfit(id, data);
  }

  if (hasAdd) {
    await savedOutfitsRepository.createManyOutfitItems(
      uniqueAddIds.map((wardrobeItemId) => ({ savedOutfitId: id, wardrobeItemId })),
    );
  }

  if (hasRemove) {
    await savedOutfitsRepository.deleteOutfitItemsByWardrobeItemIds(id, removeWardrobeItemIds);
  }

  if (file && existingOutfit.imageUrl) {
    await deleteUploadedFile(existingOutfit.imageUrl);
  }

  return savedOutfitsRepository.findOutfitWithItems(id, userId);
};

export const deleteSavedOutfit = async (userId, id) => {
  const outfit = await assertOwnedOutfit(userId, id);

  await savedOutfitsRepository.deleteOutfit(id);

  if (outfit.imageUrl) {
    await deleteUploadedFile(outfit.imageUrl);
  }

  return {};
};

export const setSavedOutfitFavorite = async (userId, id, isFavorite) => {
  await assertOwnedOutfit(userId, id);

  return savedOutfitsRepository.updateOutfit(id, { isFavorite });
};

export const duplicateSavedOutfit = async (userId, id) => {
  const outfit = await savedOutfitsRepository.findOutfitWithItems(id, userId);

  if (!outfit) {
    throw new ApiError(404, 'Saved outfit not found');
  }

  const duplicated = await savedOutfitsRepository.createOutfit({
    userId,
    title: `${outfit.title} (copy)`,
    notes: outfit.notes,
    occasion: outfit.occasion,
    season: outfit.season,
    imageUrl: outfit.imageUrl,
  });

  if (outfit.items.length > 0) {
    await savedOutfitsRepository.createManyOutfitItems(
      outfit.items.map((item) => ({ savedOutfitId: duplicated.id, wardrobeItemId: item.wardrobeItemId })),
    );
  }

  return savedOutfitsRepository.findOutfitWithItems(duplicated.id, userId);
};

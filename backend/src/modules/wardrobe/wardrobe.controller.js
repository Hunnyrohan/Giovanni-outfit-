import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { toWardrobeItemDto } from './wardrobe.dto.js';
import {
  addWardrobeItem,
  deleteWardrobeItem,
  getWardrobeItemById,
  getWardrobeItems,
  getWardrobeStats,
  setWardrobeItemFavorite,
  updateWardrobeItem,
} from './wardrobe.service.js';

export const createWardrobeItem = asyncHandler(async (req, res) => {
  const item = await addWardrobeItem(req.user.id, req.body, req.file);

  return sendSuccess(res, 201, 'Wardrobe item added successfully', {
    item: toWardrobeItemDto(item),
  });
});

export const listWardrobeItems = asyncHandler(async (req, res) => {
  const { items, pagination } = await getWardrobeItems(req.user.id, req.validatedQuery);

  return sendSuccess(res, 200, 'Wardrobe items retrieved successfully', {
    items: items.map(toWardrobeItemDto),
    pagination,
  });
});

export const getWardrobeItem = asyncHandler(async (req, res) => {
  const item = await getWardrobeItemById(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Wardrobe item retrieved successfully', {
    item: toWardrobeItemDto(item),
  });
});

export const updateWardrobeItemController = asyncHandler(async (req, res) => {
  const item = await updateWardrobeItem(req.user.id, req.params.id, req.body, req.file);

  return sendSuccess(res, 200, 'Wardrobe item updated successfully', {
    item: toWardrobeItemDto(item),
  });
});

export const deleteWardrobeItemController = asyncHandler(async (req, res) => {
  await deleteWardrobeItem(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Wardrobe item deleted successfully', {});
});

export const updateWardrobeItemFavorite = asyncHandler(async (req, res) => {
  const item = await setWardrobeItemFavorite(req.user.id, req.params.id, req.body.isFavorite);

  return sendSuccess(res, 200, 'Wardrobe item favorite status updated successfully', {
    item: toWardrobeItemDto(item),
  });
});

export const getWardrobeStatsController = asyncHandler(async (req, res) => {
  const stats = await getWardrobeStats(req.user.id);

  return sendSuccess(res, 200, 'Wardrobe stats retrieved successfully', {
    stats,
  });
});

import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { toSavedOutfitDetailDto, toSavedOutfitSummaryDto } from './saved-outfits.dto.js';
import {
  createSavedOutfit,
  deleteSavedOutfit,
  duplicateSavedOutfit,
  getSavedOutfitById,
  getSavedOutfits,
  setSavedOutfitFavorite,
  updateSavedOutfit,
} from './saved-outfits.service.js';

export const createSavedOutfitController = asyncHandler(async (req, res) => {
  const outfit = await createSavedOutfit(req.user.id, req.body, req.file);

  return sendSuccess(res, 201, 'Saved outfit created successfully', {
    savedOutfit: toSavedOutfitDetailDto(outfit),
  });
});

export const listSavedOutfits = asyncHandler(async (req, res) => {
  const { outfits, pagination } = await getSavedOutfits(req.user.id, req.validatedQuery);

  return sendSuccess(res, 200, 'Saved outfits retrieved successfully', {
    savedOutfits: outfits.map(toSavedOutfitSummaryDto),
    pagination,
  });
});

export const getSavedOutfit = asyncHandler(async (req, res) => {
  const outfit = await getSavedOutfitById(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Saved outfit retrieved successfully', {
    savedOutfit: toSavedOutfitDetailDto(outfit),
  });
});

export const updateSavedOutfitController = asyncHandler(async (req, res) => {
  const outfit = await updateSavedOutfit(req.user.id, req.params.id, req.body, req.file);

  return sendSuccess(res, 200, 'Saved outfit updated successfully', {
    savedOutfit: toSavedOutfitDetailDto(outfit),
  });
});

export const deleteSavedOutfitController = asyncHandler(async (req, res) => {
  await deleteSavedOutfit(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Saved outfit deleted successfully', {});
});

export const updateSavedOutfitFavorite = asyncHandler(async (req, res) => {
  const outfit = await setSavedOutfitFavorite(req.user.id, req.params.id, req.body.isFavorite);

  return sendSuccess(res, 200, 'Saved outfit favorite status updated successfully', {
    savedOutfit: toSavedOutfitSummaryDto(outfit),
  });
});

export const duplicateSavedOutfitController = asyncHandler(async (req, res) => {
  const outfit = await duplicateSavedOutfit(req.user.id, req.params.id);

  return sendSuccess(res, 201, 'Saved outfit duplicated successfully', {
    savedOutfit: toSavedOutfitDetailDto(outfit),
  });
});

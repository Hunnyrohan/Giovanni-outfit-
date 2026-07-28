import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { toSavedOutfitSummaryDto } from '../saved_outfits/saved-outfits.dto.js';
import { toTryOnDto } from './virtual-wear.dto.js';
import {
  createTryOn,
  deleteTryOn,
  getResultImageStream,
  getTryOnStatus,
  listHistory,
  saveTryOnAsOutfit,
} from './virtual-wear.service.js';

export const createTryOnController = asyncHandler(async (req, res) => {
  const tryOn = await createTryOn(req.user.id, {
    wardrobeItemId: req.body.wardrobeItemId,
    personImageFile: req.file,
  });

  return sendSuccess(res, 202, 'Virtual try-on job created', { tryOn: toTryOnDto(tryOn) });
});

export const getTryOnStatusController = asyncHandler(async (req, res) => {
  const tryOn = await getTryOnStatus(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Try-on status retrieved', { tryOn: toTryOnDto(tryOn) });
});

export const listHistoryController = asyncHandler(async (req, res) => {
  const tryOns = await listHistory(req.user.id);

  return sendSuccess(res, 200, 'Try-on history retrieved', { tryOns: tryOns.map(toTryOnDto) });
});

export const deleteTryOnController = asyncHandler(async (req, res) => {
  await deleteTryOn(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Try-on deleted', {});
});

export const getResultImageController = asyncHandler(async (req, res) => {
  const upstreamResponse = await getResultImageStream(req.user.id, req.params.id);
  const buffer = Buffer.from(await upstreamResponse.arrayBuffer());

  res.setHeader('Content-Type', upstreamResponse.headers.get('content-type') || 'image/png');
  return res.status(200).send(buffer);
});

export const saveTryOnController = asyncHandler(async (req, res) => {
  const outfit = await saveTryOnAsOutfit(req.user.id, req.params.id, { title: req.body.title });

  return sendSuccess(res, 201, 'Saved to your outfits', { outfit: toSavedOutfitSummaryDto(outfit) });
});

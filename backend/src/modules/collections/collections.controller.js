import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { toCollectionDetailDto, toCollectionSummaryDto } from './collections.dto.js';
import {
  addItemToCollection,
  createCollection,
  deleteCollection,
  getCollectionById,
  getCollections,
  removeItemFromCollection,
  reorderCollectionItems,
  updateCollection,
} from './collections.service.js';

export const createCollectionController = asyncHandler(async (req, res) => {
  const collection = await createCollection(req.user.id, req.body, req.file);

  return sendSuccess(res, 201, 'Collection created successfully', {
    collection: toCollectionSummaryDto(collection),
  });
});

export const listCollections = asyncHandler(async (req, res) => {
  const { collections, pagination } = await getCollections(req.user.id, req.validatedQuery);

  return sendSuccess(res, 200, 'Collections retrieved successfully', {
    collections: collections.map(toCollectionSummaryDto),
    pagination,
  });
});

export const getCollection = asyncHandler(async (req, res) => {
  const collection = await getCollectionById(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Collection retrieved successfully', {
    collection: toCollectionDetailDto(collection),
  });
});

export const updateCollectionController = asyncHandler(async (req, res) => {
  const collection = await updateCollection(req.user.id, req.params.id, req.body, req.file);

  return sendSuccess(res, 200, 'Collection updated successfully', {
    collection: toCollectionSummaryDto(collection),
  });
});

export const deleteCollectionController = asyncHandler(async (req, res) => {
  await deleteCollection(req.user.id, req.params.id);

  return sendSuccess(res, 200, 'Collection deleted successfully', {});
});

export const addCollectionItem = asyncHandler(async (req, res) => {
  const collection = await addItemToCollection(req.user.id, req.params.id, req.body.wardrobeItemId);

  return sendSuccess(res, 201, 'Wardrobe item added to collection successfully', {
    collection: toCollectionDetailDto(collection),
  });
});

export const removeCollectionItem = asyncHandler(async (req, res) => {
  const collection = await removeItemFromCollection(req.user.id, req.params.id, req.params.wardrobeItemId);

  return sendSuccess(res, 200, 'Wardrobe item removed from collection successfully', {
    collection: toCollectionDetailDto(collection),
  });
});

export const reorderCollectionItemsController = asyncHandler(async (req, res) => {
  const collection = await reorderCollectionItems(req.user.id, req.params.id, req.body.orderedWardrobeItemIds);

  return sendSuccess(res, 200, 'Collection items reordered successfully', {
    collection: toCollectionDetailDto(collection),
  });
});

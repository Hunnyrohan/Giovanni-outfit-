import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { ApiError } from '../../utils/api-error.js';
import { deleteUploadedFile } from '../../utils/local-upload.js';
import * as aiServiceClient from '../../services/ai-service.client.js';
import { savedOutfitsRepository } from '../saved_outfits/saved-outfits.repository.js';
import { wardrobeRepository } from '../wardrobe/wardrobe.repository.js';
import { virtualWearRepository } from './virtual-wear.repository.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadRoot = path.resolve(__dirname, '../../../uploads');

const CATEGORY_TO_GARMENT_TYPE = {
  TOP: 'upper',
  OUTERWEAR: 'upper',
  BOTTOM: 'lower',
  DRESS: 'overall',
};

// Sub-categories with no sleeve fabric: masking the arms for these forces the
// AI Service to hallucinate sleeve content it has no reference for (see
// mask_generator.py's `upper_sleeveless` handling).
const SLEEVELESS_SUBCATEGORIES = new Set(['Crop top', 'Vest', 'Tank']);

const resolveGarmentType = (category, subCategory) => {
  const base = CATEGORY_TO_GARMENT_TYPE[category] || 'upper';
  if (base === 'upper' && SLEEVELESS_SUBCATEGORIES.has(subCategory)) {
    return 'upper_sleeveless';
  }
  return base;
};

const absoluteUploadPath = (relativeUrl) => {
  const uploadsMarker = '/uploads/';
  const markerIndex = relativeUrl.indexOf(uploadsMarker);
  const relativePath = markerIndex === -1 ? relativeUrl : relativeUrl.slice(markerIndex + uploadsMarker.length);
  return path.join(process.cwd(), 'uploads', relativePath);
};

const assertOwnedWardrobeItem = async (userId, wardrobeItemId) => {
  const item = await wardrobeRepository.findItemByIdForUser(wardrobeItemId, userId);

  if (!item) {
    throw new ApiError(404, 'Wardrobe item not found');
  }

  return item;
};

const assertOwnedTryOn = async (userId, id) => {
  const tryOn = await virtualWearRepository.findByIdForUser(id, userId);

  if (!tryOn) {
    throw new ApiError(404, 'Virtual try-on job not found');
  }

  return tryOn;
};

export const createTryOn = async (userId, { wardrobeItemId, personImageFile }) => {
  if (!personImageFile) {
    throw new ApiError(400, 'A person image is required');
  }

  const wardrobeItem = await assertOwnedWardrobeItem(userId, wardrobeItemId);
  const personImageUrl = `/uploads/virtual/${personImageFile.filename}`;

  let aiResponse;
  try {
    aiResponse = await aiServiceClient.createTryOnJob({
      personImagePath: personImageFile.path,
      garmentImagePath: absoluteUploadPath(wardrobeItem.imageUrl),
      garmentType: resolveGarmentType(wardrobeItem.category, wardrobeItem.subCategory),
    });
  } catch (error) {
    await deleteUploadedFile(personImageUrl);
    throw error;
  }

  return virtualWearRepository.createTryOn({
    userId,
    wardrobeItemId,
    personImageUrl,
    clothingImageUrl: wardrobeItem.imageUrl,
    provider: 'catvton',
    providerJobId: aiResponse.jobId,
    status: aiResponse.status,
  });
};

export const getTryOnStatus = async (userId, id) => {
  const tryOn = await assertOwnedTryOn(userId, id);

  if (tryOn.status === 'COMPLETED' || tryOn.status === 'FAILED') {
    return tryOn;
  }

  const aiResponse = await aiServiceClient.getTryOnJobStatus(tryOn.providerJobId);

  if (aiResponse.status === tryOn.status) {
    return tryOn;
  }

  return virtualWearRepository.updateTryOn(tryOn.id, {
    status: aiResponse.status,
    resultImageUrl: aiResponse.imageUrl || null,
    processingTime: aiResponse.processingTime ?? null,
    errorMessage: aiResponse.errorMessage || null,
  });
};

export const listHistory = async (userId) => virtualWearRepository.findManyForUser(userId);

export const deleteTryOn = async (userId, id) => {
  const tryOn = await assertOwnedTryOn(userId, id);

  if (tryOn.providerJobId) {
    await aiServiceClient.deleteTryOnJob(tryOn.providerJobId);
  }

  await virtualWearRepository.deleteTryOn(id);
  await deleteUploadedFile(tryOn.personImageUrl);

  return {};
};

export const getResultImageStream = async (userId, id) => {
  const tryOn = await assertOwnedTryOn(userId, id);

  if (!tryOn.resultImageUrl) {
    throw new ApiError(404, 'Result image is not available yet');
  }

  return aiServiceClient.fetchResultImage(tryOn.resultImageUrl);
};

export const saveTryOnAsOutfit = async (userId, id, { title }) => {
  const tryOn = await assertOwnedTryOn(userId, id);

  if (tryOn.status !== 'COMPLETED' || !tryOn.resultImageUrl) {
    throw new ApiError(400, 'Only a completed try-on can be saved');
  }

  // SavedOutfit.imageUrl is loaded elsewhere (Saved Outfits screen) as a
  // plain static image, the same way wardrobe/profile images are - no auth
  // header attached. The try-on proxy route requires a JWT, so on this one
  // explicit user action ("Save"), we make a single durable copy under
  // uploads/virtual/ to match that existing convention, rather than storing
  // our JWT-protected proxy path where nothing would ever be able to load it.
  const upstreamImage = await aiServiceClient.fetchResultImage(tryOn.resultImageUrl);
  const imageBuffer = Buffer.from(await upstreamImage.arrayBuffer());
  const savedImageDir = path.join(uploadRoot, 'virtual');
  await fs.mkdir(savedImageDir, { recursive: true });
  const savedImageFilename = `${tryOn.id}-saved.png`;
  await fs.writeFile(path.join(savedImageDir, savedImageFilename), imageBuffer);

  const outfit = await savedOutfitsRepository.createOutfit({
    userId,
    title: title || 'Virtual Try-On',
    imageUrl: `/uploads/virtual/${savedImageFilename}`,
  });

  if (tryOn.wardrobeItemId) {
    await savedOutfitsRepository.createManyOutfitItems([
      { savedOutfitId: outfit.id, wardrobeItemId: tryOn.wardrobeItemId },
    ]);
  }

  return outfit;
};

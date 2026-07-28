import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { setUploadFolder, upload } from '../../middleware/upload.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  createSavedOutfitController,
  deleteSavedOutfitController,
  duplicateSavedOutfitController,
  getSavedOutfit,
  listSavedOutfits,
  updateSavedOutfitController,
  updateSavedOutfitFavorite,
} from './saved-outfits.controller.js';
import {
  createSavedOutfitSchema,
  listSavedOutfitsSchema,
  savedOutfitIdSchema,
  setSavedOutfitFavoriteSchema,
  updateSavedOutfitSchema,
} from './saved-outfits.validation.js';

const router = Router();

router.use(verifyJWT);

/**
 * @openapi
 * /saved-outfits:
 *   get:
 *     summary: List the current user's saved outfits
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *       - in: query
 *         name: occasion
 *         schema: { type: string, enum: [CASUAL, FORMAL, BUSINESS, PARTY, SPORTS, TRAVEL, DATE, FESTIVAL, OTHER] }
 *       - in: query
 *         name: season
 *         schema: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *       - in: query
 *         name: favorite
 *         schema: { type: boolean }
 *     responses:
 *       200:
 *         description: Saved outfits retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/', validate(listSavedOutfitsSchema), listSavedOutfits);

/**
 * @openapi
 * /saved-outfits/{id}:
 *   get:
 *     summary: Get a single saved outfit with its full wardrobe item details
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Saved outfit retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Saved outfit not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/:id', validate(savedOutfitIdSchema), getSavedOutfit);

/**
 * @openapi
 * /saved-outfits:
 *   post:
 *     summary: Create a new saved outfit from existing wardrobe items
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [name, wardrobeItemIds]
 *             properties:
 *               name: { type: string }
 *               notes: { type: string }
 *               occasion: { type: string, enum: [CASUAL, FORMAL, BUSINESS, PARTY, SPORTS, TRAVEL, DATE, FESTIVAL, OTHER] }
 *               season: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *               wardrobeItemIds:
 *                 type: array
 *                 items: { type: string, format: uuid }
 *               coverImage: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: Saved outfit created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: A referenced wardrobe item was not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post(
  '/',
  setUploadFolder('outfits'),
  upload.single('coverImage'),
  validate(createSavedOutfitSchema),
  createSavedOutfitController,
);

/**
 * @openapi
 * /saved-outfits/{id}:
 *   patch:
 *     summary: Update a saved outfit's details, cover image, or wardrobe item membership
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name: { type: string }
 *               notes: { type: string }
 *               occasion: { type: string, enum: [CASUAL, FORMAL, BUSINESS, PARTY, SPORTS, TRAVEL, DATE, FESTIVAL, OTHER] }
 *               season: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *               addWardrobeItemIds:
 *                 type: array
 *                 items: { type: string, format: uuid }
 *               removeWardrobeItemIds:
 *                 type: array
 *                 items: { type: string, format: uuid }
 *               coverImage: { type: string, format: binary }
 *     responses:
 *       200:
 *         description: Saved outfit updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       400:
 *         description: Invalid update, or would leave the saved outfit with no wardrobe items
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       404:
 *         description: Saved outfit, or a referenced wardrobe item, not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch(
  '/:id',
  setUploadFolder('outfits'),
  upload.single('coverImage'),
  validate(updateSavedOutfitSchema),
  updateSavedOutfitController,
);

/**
 * @openapi
 * /saved-outfits/{id}:
 *   delete:
 *     summary: Delete a saved outfit (does not delete its underlying wardrobe items)
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Saved outfit deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Saved outfit not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id', validate(savedOutfitIdSchema), deleteSavedOutfitController);

/**
 * @openapi
 * /saved-outfits/{id}/favorite:
 *   patch:
 *     summary: Mark or unmark a saved outfit as a favorite
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [isFavorite]
 *             properties:
 *               isFavorite: { type: boolean }
 *     responses:
 *       200:
 *         description: Saved outfit favorite status updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Saved outfit not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch('/:id/favorite', validate(setSavedOutfitFavoriteSchema), updateSavedOutfitFavorite);

/**
 * @openapi
 * /saved-outfits/{id}/duplicate:
 *   post:
 *     summary: Duplicate an existing saved outfit, including its wardrobe item links
 *     tags: [Saved Outfits]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       201:
 *         description: Saved outfit duplicated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Saved outfit not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/:id/duplicate', validate(savedOutfitIdSchema), duplicateSavedOutfitController);

export default router;

import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { setUploadFolder, upload } from '../../middleware/upload.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  createWardrobeItem,
  deleteWardrobeItemController,
  getWardrobeItem,
  getWardrobeStatsController,
  listWardrobeItems,
  updateWardrobeItemController,
  updateWardrobeItemFavorite,
} from './wardrobe.controller.js';
import {
  createWardrobeItemSchema,
  listWardrobeItemsSchema,
  setFavoriteSchema,
  updateWardrobeItemSchema,
  wardrobeItemIdSchema,
} from './wardrobe.validation.js';

const router = Router();

router.use(verifyJWT);

/**
 * @openapi
 * /wardrobe:
 *   get:
 *     summary: List the current user's wardrobe items
 *     tags: [Wardrobe]
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
 *         name: category
 *         schema: { type: string, enum: [TOP, BOTTOM, DRESS, OUTERWEAR, SHOES, ACCESSORY, BAG, OTHER] }
 *       - in: query
 *         name: season
 *         schema: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *       - in: query
 *         name: occasion
 *         schema: { type: string, enum: [CASUAL, FORMAL, BUSINESS, PARTY, SPORTS, TRAVEL, DATE, FESTIVAL, OTHER] }
 *       - in: query
 *         name: color
 *         schema: { type: string }
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *       - in: query
 *         name: favorite
 *         schema: { type: boolean }
 *       - in: query
 *         name: includeArchived
 *         schema: { type: boolean }
 *     responses:
 *       200:
 *         description: Wardrobe items retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/', validate(listWardrobeItemsSchema), listWardrobeItems);

/**
 * @openapi
 * /wardrobe/stats:
 *   get:
 *     summary: Get wardrobe statistics for the current user
 *     tags: [Wardrobe]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Wardrobe stats retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/stats', getWardrobeStatsController);

/**
 * @openapi
 * /wardrobe/{id}:
 *   get:
 *     summary: Get a single wardrobe item by id
 *     tags: [Wardrobe]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Wardrobe item retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Wardrobe item not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/:id', validate(wardrobeItemIdSchema), getWardrobeItem);

/**
 * @openapi
 * /wardrobe:
 *   post:
 *     summary: Add a new wardrobe item
 *     tags: [Wardrobe]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [name, category, image]
 *             properties:
 *               name: { type: string }
 *               description: { type: string }
 *               category: { type: string, enum: [TOP, BOTTOM, DRESS, OUTERWEAR, SHOES, ACCESSORY, BAG, OTHER] }
 *               subCategory: { type: string }
 *               primaryColor: { type: string }
 *               colors: { type: string, description: "Comma-separated or JSON array" }
 *               brand: { type: string }
 *               size: { type: string }
 *               material: { type: string }
 *               season: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *               occasion: { type: string, description: "Comma-separated or JSON array" }
 *               tags: { type: string, description: "Comma-separated or JSON array" }
 *               image: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: Wardrobe item added successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       400:
 *         description: Validation failed or no image provided
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post(
  '/',
  setUploadFolder('wardrobe'),
  upload.single('image'),
  validate(createWardrobeItemSchema),
  createWardrobeItem,
);

/**
 * @openapi
 * /wardrobe/{id}:
 *   patch:
 *     summary: Update a wardrobe item, optionally replacing its image
 *     tags: [Wardrobe]
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
 *               description: { type: string }
 *               category: { type: string, enum: [TOP, BOTTOM, DRESS, OUTERWEAR, SHOES, ACCESSORY, BAG, OTHER] }
 *               subCategory: { type: string }
 *               primaryColor: { type: string }
 *               colors: { type: string }
 *               brand: { type: string }
 *               size: { type: string }
 *               material: { type: string }
 *               season: { type: string, enum: [SPRING, SUMMER, AUTUMN, WINTER, ALL_SEASON] }
 *               occasion: { type: string }
 *               tags: { type: string }
 *               isArchived: { type: boolean }
 *               image: { type: string, format: binary }
 *     responses:
 *       200:
 *         description: Wardrobe item updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Wardrobe item not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch(
  '/:id',
  setUploadFolder('wardrobe'),
  upload.single('image'),
  validate(updateWardrobeItemSchema),
  updateWardrobeItemController,
);

/**
 * @openapi
 * /wardrobe/{id}/favorite:
 *   patch:
 *     summary: Mark or unmark a wardrobe item as favorite
 *     tags: [Wardrobe]
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
 *         description: Wardrobe item favorite status updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Wardrobe item not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch('/:id/favorite', validate(setFavoriteSchema), updateWardrobeItemFavorite);

/**
 * @openapi
 * /wardrobe/{id}:
 *   delete:
 *     summary: Delete a wardrobe item
 *     tags: [Wardrobe]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Wardrobe item deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Wardrobe item not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id', validate(wardrobeItemIdSchema), deleteWardrobeItemController);

export default router;

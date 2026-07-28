import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { setUploadFolder, upload } from '../../middleware/upload.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  addCollectionItem,
  createCollectionController,
  deleteCollectionController,
  getCollection,
  listCollections,
  removeCollectionItem,
  reorderCollectionItemsController,
  updateCollectionController,
} from './collections.controller.js';
import {
  addCollectionItemSchema,
  collectionIdSchema,
  createCollectionSchema,
  listCollectionsSchema,
  removeCollectionItemSchema,
  reorderCollectionItemsSchema,
  updateCollectionSchema,
} from './collections.validation.js';

const router = Router();

router.use(verifyJWT);

/**
 * @openapi
 * /collections:
 *   get:
 *     summary: List the current user's collections
 *     tags: [Collections]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *     responses:
 *       200:
 *         description: Collections retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/', validate(listCollectionsSchema), listCollections);

/**
 * @openapi
 * /collections/{id}:
 *   get:
 *     summary: Get a single collection with its wardrobe items
 *     tags: [Collections]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Collection retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Collection not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/:id', validate(collectionIdSchema), getCollection);

/**
 * @openapi
 * /collections:
 *   post:
 *     summary: Create a new collection
 *     tags: [Collections]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [name]
 *             properties:
 *               name: { type: string }
 *               description: { type: string }
 *               coverImage: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: Collection created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       409:
 *         description: A collection with this name already exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post(
  '/',
  setUploadFolder('collections'),
  upload.single('coverImage'),
  validate(createCollectionSchema),
  createCollectionController,
);

/**
 * @openapi
 * /collections/{id}:
 *   patch:
 *     summary: Update a collection, optionally replacing its cover image
 *     tags: [Collections]
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
 *               coverImage: { type: string, format: binary }
 *     responses:
 *       200:
 *         description: Collection updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Collection not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch(
  '/:id',
  setUploadFolder('collections'),
  upload.single('coverImage'),
  validate(updateCollectionSchema),
  updateCollectionController,
);

/**
 * @openapi
 * /collections/{id}:
 *   delete:
 *     summary: Delete a collection (does not delete its wardrobe items)
 *     tags: [Collections]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Collection deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Collection not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id', validate(collectionIdSchema), deleteCollectionController);

/**
 * @openapi
 * /collections/{id}/items:
 *   post:
 *     summary: Add a wardrobe item to a collection
 *     tags: [Collections]
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
 *             required: [wardrobeItemId]
 *             properties:
 *               wardrobeItemId: { type: string, format: uuid }
 *     responses:
 *       201:
 *         description: Wardrobe item added to collection successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Collection or wardrobe item not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       409:
 *         description: Wardrobe item already in the collection
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/:id/items', validate(addCollectionItemSchema), addCollectionItem);

/**
 * @openapi
 * /collections/{id}/items/reorder:
 *   patch:
 *     summary: Reorder the wardrobe items within a collection
 *     tags: [Collections]
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
 *             required: [orderedWardrobeItemIds]
 *             properties:
 *               orderedWardrobeItemIds:
 *                 type: array
 *                 items: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Collection items reordered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       400:
 *         description: orderedWardrobeItemIds does not match the collection's current items
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.patch('/:id/items/reorder', validate(reorderCollectionItemsSchema), reorderCollectionItemsController);

/**
 * @openapi
 * /collections/{id}/items/{wardrobeItemId}:
 *   delete:
 *     summary: Remove a wardrobe item from a collection
 *     tags: [Collections]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: path
 *         name: wardrobeItemId
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Wardrobe item removed from collection successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Collection, or wardrobe item link, not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id/items/:wardrobeItemId', validate(removeCollectionItemSchema), removeCollectionItem);

export default router;

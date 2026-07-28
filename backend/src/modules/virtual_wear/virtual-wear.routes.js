import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { aiRateLimiter } from '../../middleware/rate-limit.middleware.js';
import { setUploadFolder, upload } from '../../middleware/upload.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  createTryOnController,
  deleteTryOnController,
  getResultImageController,
  getTryOnStatusController,
  listHistoryController,
  saveTryOnController,
} from './virtual-wear.controller.js';
import { createTryOnSchema, saveTryOnSchema, tryOnIdParamSchema } from './virtual-wear.validation.js';

const router = Router();

router.use(verifyJWT);

/**
 * @openapi
 * /virtual-tryon:
 *   post:
 *     summary: Create a Virtual Try-On job for a wardrobe item
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [wardrobeItemId, personImage]
 *             properties:
 *               wardrobeItemId: { type: string, format: uuid }
 *               personImage: { type: string, format: binary }
 *     responses:
 *       202:
 *         description: Virtual try-on job created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.post(
  '/',
  aiRateLimiter,
  setUploadFolder('virtual'),
  upload.single('personImage'),
  validate(createTryOnSchema),
  createTryOnController,
);

/**
 * @openapi
 * /virtual-tryon/history:
 *   get:
 *     summary: List the current user's virtual try-on history
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Try-on history retrieved
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/history', listHistoryController);

/**
 * @openapi
 * /virtual-tryon/{id}:
 *   get:
 *     summary: Get a virtual try-on job's status (polls the AI Service until terminal)
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Try-on status retrieved
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Try-on job not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *   delete:
 *     summary: Delete a virtual try-on job
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Try-on deleted
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/:id', validate(tryOnIdParamSchema), getTryOnStatusController);
router.delete('/:id', validate(tryOnIdParamSchema), deleteTryOnController);

/**
 * @openapi
 * /virtual-tryon/{id}/image:
 *   get:
 *     summary: Fetch the generated result image (proxied from the AI Service, never a raw file path)
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Image bytes
 *       404:
 *         description: Result not available yet
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/:id/image', validate(tryOnIdParamSchema), getResultImageController);

/**
 * @openapi
 * /virtual-tryon/{id}/save:
 *   post:
 *     summary: Save a completed try-on result into Saved Outfits
 *     tags: [Virtual Try-On]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title: { type: string }
 *     responses:
 *       201:
 *         description: Saved to your outfits
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.post('/:id/save', validate(saveTryOnSchema), saveTryOnController);

export default router;

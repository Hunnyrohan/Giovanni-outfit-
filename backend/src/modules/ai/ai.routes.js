import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { aiRateLimiter } from '../../middleware/rate-limit.middleware.js';
import { setUploadFolder, upload } from '../../middleware/upload.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  analyze,
  chat,
  deleteAllHistory,
  deleteHistoryItem,
  getHistory,
  getHistoryDetail,
  recommend,
} from './ai.controller.js';
import { analyzeSchema, chatIdParamSchema, chatSchema, recommendSchema } from './ai.validation.js';

const router = Router();

router.use(verifyJWT);

/**
 * @openapi
 * /ai/chat:
 *   post:
 *     summary: Send a message to the AI Stylist (creates a new conversation if chatId is omitted)
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [message]
 *             properties:
 *               chatId: { type: string, format: uuid }
 *               message: { type: string }
 *     responses:
 *       200:
 *         description: Message sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.post('/chat', aiRateLimiter, validate(chatSchema), chat);

/**
 * @openapi
 * /ai/analyze:
 *   post:
 *     summary: Analyze an uploaded outfit photo
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [image]
 *             properties:
 *               image: { type: string, format: binary }
 *               notes: { type: string }
 *     responses:
 *       201:
 *         description: Outfit analyzed successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.post(
  '/analyze',
  aiRateLimiter,
  setUploadFolder('outfits'),
  upload.single('image'),
  validate(analyzeSchema),
  analyze,
);

/**
 * @openapi
 * /ai/recommend:
 *   post:
 *     summary: Generate an outfit recommendation for an occasion
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               occasion: { type: string }
 *               notes: { type: string }
 *     responses:
 *       201:
 *         description: Recommendation generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.post('/recommend', aiRateLimiter, validate(recommendSchema), recommend);

/**
 * @openapi
 * /ai/history:
 *   get:
 *     summary: List the current user's chat history
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Chat history retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *   delete:
 *     summary: Delete all of the current user's chat history
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Chat history cleared successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 */
router.get('/history', getHistory);
router.delete('/history', deleteAllHistory);

/**
 * @openapi
 * /ai/history/{id}:
 *   get:
 *     summary: Get a single conversation with all its messages
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Conversation retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Conversation not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *   delete:
 *     summary: Delete a single conversation
 *     tags: [AI Stylist]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Conversation deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       404:
 *         description: Conversation not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/history/:id', validate(chatIdParamSchema), getHistoryDetail);
router.delete('/history/:id', validate(chatIdParamSchema), deleteHistoryItem);

export default router;

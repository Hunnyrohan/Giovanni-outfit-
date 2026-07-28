import { Router } from 'express';
import { getHealth } from '../common/health.controller.js';
import authRoutes from '../modules/auth/auth.routes.js';
import profileRoutes from '../modules/profile/profile.routes.js';
import wardrobeRoutes from '../modules/wardrobe/wardrobe.routes.js';
import collectionsRoutes from '../modules/collections/collections.routes.js';
import savedOutfitsRoutes from '../modules/saved_outfits/saved-outfits.routes.js';
import aiRoutes from '../modules/ai/ai.routes.js';
import virtualWearRoutes from '../modules/virtual_wear/virtual-wear.routes.js';

const router = Router();

/**
 * @openapi
 * /health:
 *   get:
 *     summary: Check API health
 *     tags:
 *       - System
 *     responses:
 *       200:
 *         description: API is healthy
 */
router.get('/health', getHealth);

router.use('/auth', authRoutes);
router.use('/profile', profileRoutes);
router.use('/wardrobe', wardrobeRoutes);
router.use('/collections', collectionsRoutes);
router.use('/saved-outfits', savedOutfitsRoutes);
router.use('/ai', aiRoutes);
router.use('/virtual-tryon', virtualWearRoutes);

export default router;

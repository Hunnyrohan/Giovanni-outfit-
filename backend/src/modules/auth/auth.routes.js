import { Router } from 'express';
import { verifyJWT } from '../../middleware/auth.middleware.js';
import { authRateLimiter } from '../../middleware/rate-limit.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import {
  getMe,
  getProfile,
  googleLogin,
  login,
  logout,
  refresh,
  register,
  twoFactorDisable,
  twoFactorEnable,
  twoFactorSetup,
  twoFactorVerify,
} from './auth.controller.js';
import {
  googleLoginSchema,
  loginSchema,
  refreshTokenSchema,
  registerSchema,
  twoFactorCodeSchema,
  twoFactorVerifySchema,
} from './auth.validation.js';

const router = Router();

/**
 * @openapi
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 */
router.post('/register', authRateLimiter, validate(registerSchema), register);

/**
 * @openapi
 * /auth/login:
 *   post:
 *     summary: Login with email and password
 *     tags: [Authentication]
 */
router.post('/login', authRateLimiter, validate(loginSchema), login);

/**
 * @openapi
 * /auth/google:
 *   post:
 *     summary: Login or register with Google ID token
 *     tags: [Authentication]
 */
router.post('/google', authRateLimiter, validate(googleLoginSchema), googleLogin);

/**
 * @openapi
 * /auth/refresh:
 *   post:
 *     summary: Rotate refresh token and return a new access token
 *     tags: [Authentication]
 */
router.post('/refresh', authRateLimiter, validate(refreshTokenSchema), refresh);

/**
 * @openapi
 * /auth/logout:
 *   post:
 *     summary: Logout the current user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 */
router.post('/logout', verifyJWT, logout);

/**
 * @openapi
 * /auth/me:
 *   get:
 *     summary: Get the current authenticated user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 */
router.get('/me', verifyJWT, getMe);
router.get('/profile', verifyJWT, getProfile);

/**
 * @openapi
 * /auth/2fa/setup:
 *   post:
 *     summary: Generate a TOTP secret for the authenticator app (not enabled until confirmed)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 */
router.post('/2fa/setup', verifyJWT, twoFactorSetup);

/**
 * @openapi
 * /auth/2fa/enable:
 *   post:
 *     summary: Confirm the authenticator code and turn on two-factor login
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 */
router.post('/2fa/enable', verifyJWT, validate(twoFactorCodeSchema), twoFactorEnable);

/**
 * @openapi
 * /auth/2fa/disable:
 *   post:
 *     summary: Turn off two-factor login (requires a valid authenticator code)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 */
router.post('/2fa/disable', verifyJWT, validate(twoFactorCodeSchema), twoFactorDisable);

/**
 * @openapi
 * /auth/2fa/verify:
 *   post:
 *     summary: Complete a two-factor login with the short-lived token from /auth/login
 *     tags: [Authentication]
 */
router.post('/2fa/verify', authRateLimiter, validate(twoFactorVerifySchema), twoFactorVerify);

export default router;

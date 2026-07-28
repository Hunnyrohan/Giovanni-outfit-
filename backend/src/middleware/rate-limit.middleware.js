import rateLimit from 'express-rate-limit';
import { env } from '../config/env.js';

export const apiRateLimiter = rateLimit({
  windowMs: env.rateLimitWindowMs,
  limit: env.rateLimitMaxRequests,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests. Please try again later.',
    errors: {},
  },
});

export const authRateLimiter = rateLimit({
  windowMs: env.rateLimitWindowMs,
  limit: 10,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  skipSuccessfulRequests: true,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again later.',
    errors: {},
  },
});

// AI calls are billed per-request against the Gemini API, so this limiter is
// tighter than the general API limiter regardless of success/failure.
export const aiRateLimiter = rateLimit({
  windowMs: env.rateLimitWindowMs,
  limit: 20,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many AI Stylist requests. Please try again later.',
    errors: {},
  },
});

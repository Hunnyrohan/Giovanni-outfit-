import { env } from '../config/env.js';
import { ApiError } from '../utils/api-error.js';
import { logger } from '../utils/logger.js';

const normalizePrismaError = (error) => {
  if (error?.code === 'P2002') {
    return new ApiError(409, 'A record with the provided unique value already exists', {
      target: error.meta?.target,
    });
  }

  if (error?.code === 'P2025') {
    return new ApiError(404, 'Requested record was not found');
  }

  return null;
};

export const notFoundHandler = (req, res, next) => {
  next(new ApiError(404, `Route ${req.originalUrl} not found`));
};

export const errorHandler = (err, req, res, next) => {
  let error = normalizePrismaError(err) || err;

  if (!(error instanceof ApiError)) {
    const statusCode = error.statusCode || 500;
    const message = error.message || 'Something went wrong';
    error = new ApiError(statusCode, message, error?.errors || {}, err.stack);
  }

  logger.error(error.message, {
    method: req.method,
    path: req.originalUrl,
    statusCode: error.statusCode,
    stack: env.nodeEnv === 'development' ? error.stack : undefined,
  });

  return res.status(error.statusCode).json({
    success: false,
    message: error.message,
    errors: error.errors || {},
    ...(env.nodeEnv === 'development' && { stack: error.stack }),
  });
};

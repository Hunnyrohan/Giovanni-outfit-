import { prisma } from '../config/prisma.js';
import { logger } from '../utils/logger.js';

export const connectDatabase = async () => {
  await prisma.$connect();
  logger.info('Database connected successfully');
};

export const disconnectDatabase = async () => {
  await prisma.$disconnect();
  logger.info('Database connection closed');
};

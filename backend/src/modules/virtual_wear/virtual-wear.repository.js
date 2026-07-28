import { prisma } from '../../config/prisma.js';

export const createVirtualWearRepository = (database = prisma) => ({
  createTryOn: (data) =>
    database.virtualTryOn.create({
      data,
    }),

  findByIdForUser: (id, userId) =>
    database.virtualTryOn.findFirst({
      where: { id, userId },
    }),

  findManyForUser: (userId) =>
    database.virtualTryOn.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    }),

  updateTryOn: (id, data) =>
    database.virtualTryOn.update({
      where: { id },
      data,
    }),

  deleteTryOn: (id) =>
    database.virtualTryOn.delete({
      where: { id },
    }),
});

export const virtualWearRepository = createVirtualWearRepository();

import { prisma } from '../../config/prisma.js';

export const createWardrobeRepository = (database = prisma) => ({
  createItem: (data) =>
    database.wardrobeItem.create({
      data,
    }),

  findItemByIdForUser: (id, userId) =>
    database.wardrobeItem.findFirst({
      where: { id, userId },
    }),

  findManyForUser: ({ userId, where, skip, take, orderBy }) =>
    database.wardrobeItem.findMany({
      where: { userId, ...where },
      skip,
      take,
      orderBy,
    }),

  countForUser: (userId, where) =>
    database.wardrobeItem.count({
      where: { userId, ...where },
    }),

  updateItem: (id, data) =>
    database.wardrobeItem.update({
      where: { id },
      data,
    }),

  deleteItem: (id) =>
    database.wardrobeItem.delete({
      where: { id },
    }),

  countTotalForUser: (userId) =>
    database.wardrobeItem.count({
      where: { userId },
    }),

  countFavoritesForUser: (userId) =>
    database.wardrobeItem.count({
      where: { userId, isFavorite: true },
    }),

  countByCategoryForUser: (userId) =>
    database.wardrobeItem.groupBy({
      by: ['category'],
      where: { userId },
      _count: { _all: true },
    }),
});

export const wardrobeRepository = createWardrobeRepository();

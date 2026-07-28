import { prisma } from '../../config/prisma.js';

export const createSavedOutfitsRepository = (database = prisma) => ({
  createOutfit: (data) =>
    database.savedOutfit.create({
      data,
    }),

  findOutfitByIdForUser: (id, userId) =>
    database.savedOutfit.findFirst({
      where: { id, userId },
    }),

  findManyForUser: ({ userId, where, skip, take, orderBy }) =>
    database.savedOutfit.findMany({
      where: { userId, ...where },
      skip,
      take,
      orderBy,
      include: {
        _count: { select: { items: true } },
      },
    }),

  countForUser: (userId, where) =>
    database.savedOutfit.count({
      where: { userId, ...where },
    }),

  findOutfitWithItems: (id, userId) =>
    database.savedOutfit.findFirst({
      where: { id, userId },
      include: {
        items: {
          orderBy: { createdAt: 'asc' },
          include: { wardrobeItem: true },
        },
      },
    }),

  updateOutfit: (id, data) =>
    database.savedOutfit.update({
      where: { id },
      data,
    }),

  deleteOutfit: (id) =>
    database.savedOutfit.delete({
      where: { id },
    }),

  createManyOutfitItems: (data) =>
    database.savedOutfitItem.createMany({
      data,
      skipDuplicates: true,
    }),

  deleteOutfitItemsByWardrobeItemIds: (savedOutfitId, wardrobeItemIds) =>
    database.savedOutfitItem.deleteMany({
      where: { savedOutfitId, wardrobeItemId: { in: wardrobeItemIds } },
    }),

  countItemsInOutfit: (savedOutfitId) =>
    database.savedOutfitItem.count({
      where: { savedOutfitId },
    }),

  findManyItemsInOutfit: (savedOutfitId) =>
    database.savedOutfitItem.findMany({
      where: { savedOutfitId },
      select: { wardrobeItemId: true },
    }),
});

export const savedOutfitsRepository = createSavedOutfitsRepository();

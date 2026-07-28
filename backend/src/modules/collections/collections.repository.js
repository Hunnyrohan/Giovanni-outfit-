import { prisma } from '../../config/prisma.js';

export const createCollectionsRepository = (database = prisma) => ({
  createCollection: (data) =>
    database.collection.create({
      data,
    }),

  findCollectionByIdForUser: (id, userId) =>
    database.collection.findFirst({
      where: { id, userId },
    }),

  findManyForUser: ({ userId, skip, take, orderBy }) =>
    database.collection.findMany({
      where: { userId },
      skip,
      take,
      orderBy,
      include: {
        _count: { select: { items: true } },
      },
    }),

  countForUser: (userId) =>
    database.collection.count({
      where: { userId },
    }),

  findCollectionWithItems: (id, userId) =>
    database.collection.findFirst({
      where: { id, userId },
      include: {
        items: {
          orderBy: { order: 'asc' },
          include: { wardrobeItem: true },
        },
      },
    }),

  updateCollection: (id, data) =>
    database.collection.update({
      where: { id },
      data,
    }),

  deleteCollection: (id) =>
    database.collection.delete({
      where: { id },
    }),

  findCollectionItem: (collectionId, wardrobeItemId) =>
    database.collectionItem.findUnique({
      where: { collectionId_wardrobeItemId: { collectionId, wardrobeItemId } },
    }),

  createCollectionItem: (data) =>
    database.collectionItem.create({
      data,
    }),

  deleteCollectionItem: (collectionId, wardrobeItemId) =>
    database.collectionItem.delete({
      where: { collectionId_wardrobeItemId: { collectionId, wardrobeItemId } },
    }),

  countItemsInCollection: (collectionId) =>
    database.collectionItem.count({
      where: { collectionId },
    }),

  findManyItemsInCollection: (collectionId) =>
    database.collectionItem.findMany({
      where: { collectionId },
      orderBy: { order: 'asc' },
    }),

  reorderItems: (updates) =>
    database.$transaction(
      updates.map(({ id, order }) =>
        database.collectionItem.update({
          where: { id },
          data: { order },
        }),
      ),
    ),
});

export const collectionsRepository = createCollectionsRepository();

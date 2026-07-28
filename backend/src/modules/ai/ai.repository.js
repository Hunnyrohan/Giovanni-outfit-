import { prisma } from '../../config/prisma.js';

export const createAiRepository = (database = prisma) => ({
  createChat: (userId, title) =>
    database.chat.create({
      data: { userId, title },
    }),

  findChatForUser: (chatId, userId) =>
    database.chat.findFirst({
      where: { id: chatId, userId },
    }),

  findChatWithMessages: (chatId, userId) =>
    database.chat.findFirst({
      where: { id: chatId, userId },
      include: {
        messages: { orderBy: { createdAt: 'asc' } },
      },
    }),

  listChatsForUser: (userId) =>
    database.chat.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
    }),

  updateChat: (chatId, data) =>
    database.chat.update({
      where: { id: chatId },
      data,
    }),

  deleteChat: (chatId) =>
    database.chat.delete({
      where: { id: chatId },
    }),

  deleteAllChatsForUser: (userId) =>
    database.chat.deleteMany({
      where: { userId },
    }),

  addMessage: (chatId, data) =>
    database.message.create({
      data: { chatId, ...data },
    }),

  createRecommendation: (data) =>
    database.recommendation.create({
      data,
    }),

  findWardrobeItemsForUser: (userId, take = 30) =>
    database.wardrobeItem.findMany({
      where: { userId, isArchived: false },
      select: { name: true, category: true, primaryColor: true },
      take,
      orderBy: { createdAt: 'desc' },
    }),
});

export const aiRepository = createAiRepository();

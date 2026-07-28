import { prisma } from '../../config/prisma.js';

export const getUserStats = async (userId) => {
  const [likesCount, collectionCount] = await Promise.all([
    prisma.wardrobeItem.count({
      where: { userId, isFavorite: true },
    }),
    prisma.collection.count({
      where: { userId },
    }),
  ]);

  return { likesCount, collectionCount };
};

export const updateUser = async (userId, data) => {
  return await prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true,
      name: true,
      email: true,
      gender: true,
      profilePicture: true,
      createdAt: true,
      updatedAt: true,
    },
  });
};

export const deleteUser = async (userId) => {
  return await prisma.user.delete({
    where: { id: userId },
  });
};

export const findUserPassword = async (userId) => {
  return await prisma.user.findUnique({
    where: { id: userId },
    select: { password: true },
  });
};

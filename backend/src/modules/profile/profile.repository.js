import { prisma } from '../../config/prisma.js';

const publicProfileSelect = {
  id: true,
  fullName: true,
  email: true,
  gender: true,
  profileImage: true,
  bio: true,
  phoneNumber: true,
  dateOfBirth: true,
  role: true,
  isEmailVerified: true,
  twoFactorEnabled: true,
  createdAt: true,
  updatedAt: true,
};

export const createProfileRepository = (database = prisma) => ({
  findProfileById: (id) =>
    database.user.findUnique({
      where: { id },
      select: publicProfileSelect,
    }),

  findPasswordHashById: (id) =>
    database.user.findUnique({
      where: { id },
      select: { password: true },
    }),

  updateProfile: (id, data) =>
    database.user.update({
      where: { id },
      data,
      select: publicProfileSelect,
    }),

  updatePasswordHash: (id, password) =>
    database.user.update({
      where: { id },
      data: { password, refreshTokenHash: null },
      select: { id: true },
    }),

  deleteUserById: (id) =>
    database.user.delete({
      where: { id },
    }),
});

export const profileRepository = createProfileRepository();

import { prisma } from '../../config/prisma.js';

const publicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  gender: true,
  profileImage: true,
  role: true,
  isEmailVerified: true,
  twoFactorEnabled: true,
  createdAt: true,
  updatedAt: true,
};

export const createAuthRepository = (database = prisma) => ({
  createUser: (data) =>
    database.user.create({
      data,
    }),

  findUserByEmail: (email) =>
    database.user.findUnique({
      where: { email },
    }),

  findUserByGoogleId: (googleId) =>
    database.user.findUnique({
      where: { googleId },
    }),

  findUserById: (id) =>
    database.user.findUnique({
      where: { id },
    }),

  findPublicUserById: (id) =>
    database.user.findUnique({
      where: { id },
      select: publicUserSelect,
    }),

  updateRefreshTokenHash: (userId, refreshTokenHash) =>
    database.user.update({
      where: { id: userId },
      data: { refreshTokenHash },
    }),

  connectGoogleAccount: (userId, data) =>
    database.user.update({
      where: { id: userId },
      data,
    }),

  clearRefreshTokenHash: (userId) =>
    database.user.update({
      where: { id: userId },
      data: { refreshTokenHash: null },
    }),

  setTwoFactorSecret: (userId, twoFactorSecret) =>
    database.user.update({
      where: { id: userId },
      data: { twoFactorSecret, twoFactorEnabled: false },
    }),

  enableTwoFactor: (userId) =>
    database.user.update({
      where: { id: userId },
      data: { twoFactorEnabled: true },
    }),

  disableTwoFactor: (userId) =>
    database.user.update({
      where: { id: userId },
      data: { twoFactorEnabled: false, twoFactorSecret: null },
    }),
});

export const authRepository = createAuthRepository();

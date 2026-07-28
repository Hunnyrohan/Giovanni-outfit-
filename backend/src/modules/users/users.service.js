import bcrypt from 'bcrypt';
import * as usersRepository from './users.repository.js';
import { ApiError } from '../../utils/api-error.js';
import { env } from '../../config/env.js';
import fs from 'fs';
import path from 'path';

export const getProfile = async (user) => {
  const stats = await usersRepository.getUserStats(user.id);
  
  return {
    ...user,
    likesCount: stats.likesCount.toString(),
    collectionCount: stats.collectionCount,
  };
};

export const updateProfile = async (userId, data) => {
  return await usersRepository.updateUser(userId, data);
};

export const updateAvatar = async (userId, file) => {
  if (!file) {
    throw new ApiError(400, 'Please upload an image file');
  }

  // File path accessible via URL
  const avatarUrl = `${env.nodeEnv === 'development' ? 'http://localhost:' + env.port : ''}/uploads/${file.filename}`;

  // Optionally, get old avatar to delete from local disk to save space
  
  return await usersRepository.updateUser(userId, { profilePicture: avatarUrl });
};

export const changePassword = async (userId, { currentPassword, newPassword }) => {
  const user = await usersRepository.findUserPassword(userId);
  
  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  const isMatch = await bcrypt.compare(currentPassword, user.password);
  if (!isMatch) {
    throw new ApiError(400, 'Incorrect current password');
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(newPassword, salt);

  await usersRepository.updateUser(userId, { password: hashedPassword });
  return true;
};

export const deactivateAccount = async (userId) => {
  await usersRepository.deleteUser(userId);
  return true;
};

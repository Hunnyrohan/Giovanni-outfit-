import bcrypt from 'bcrypt';
import fs from 'fs/promises';
import path from 'path';
import { env } from '../../config/env.js';
import { ApiError } from '../../utils/api-error.js';
import { profileRepository } from './profile.repository.js';

const uploadRoot = path.join(process.cwd(), 'uploads');

const deleteLocalUploadFile = async (fileUrl) => {
  if (!fileUrl) {
    return;
  }

  const uploadsMarker = '/uploads/';
  const markerIndex = fileUrl.indexOf(uploadsMarker);

  if (markerIndex === -1) {
    return;
  }

  const relativePath = fileUrl.slice(markerIndex + uploadsMarker.length);
  const absolutePath = path.join(uploadRoot, relativePath);

  try {
    await fs.unlink(absolutePath);
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }
};

const assertProfileExists = (profile) => {
  if (!profile) {
    throw new ApiError(404, 'User not found');
  }

  return profile;
};

export const getProfile = async (userId) => {
  const profile = await profileRepository.findProfileById(userId);

  return assertProfileExists(profile);
};

export const updateProfile = async (userId, payload) => {
  const profile = await profileRepository.updateProfile(userId, payload);

  return assertProfileExists(profile);
};

export const uploadProfilePicture = async (userId, file) => {
  if (!file) {
    throw new ApiError(400, 'Please upload an image file');
  }

  const currentProfile = await profileRepository.findProfileById(userId);
  assertProfileExists(currentProfile);

  const profileImage = `/uploads/profile/${file.filename}`;
  const updatedProfile = await profileRepository.updateProfile(userId, { profileImage });

  await deleteLocalUploadFile(currentProfile.profileImage);

  return updatedProfile;
};

export const removeProfilePicture = async (userId) => {
  const currentProfile = await profileRepository.findProfileById(userId);
  assertProfileExists(currentProfile);

  const updatedProfile = await profileRepository.updateProfile(userId, { profileImage: null });

  await deleteLocalUploadFile(currentProfile.profileImage);

  return updatedProfile;
};

export const changePassword = async (userId, { currentPassword, newPassword }) => {
  const user = await profileRepository.findPasswordHashById(userId);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  const isPasswordValid = await bcrypt.compare(currentPassword, user.password);

  if (!isPasswordValid) {
    throw new ApiError(401, 'Current password is incorrect', {
      currentPassword: 'Current password is incorrect',
    });
  }

  const hashedPassword = await bcrypt.hash(newPassword, env.bcryptSaltRounds);
  await profileRepository.updatePasswordHash(userId, hashedPassword);

  return {};
};

export const deleteAccount = async (userId, { password }) => {
  const user = await profileRepository.findPasswordHashById(userId);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    throw new ApiError(401, 'Password is incorrect', {
      password: 'Password is incorrect',
    });
  }

  const profile = await profileRepository.findProfileById(userId);
  await profileRepository.deleteUserById(userId);
  await deleteLocalUploadFile(profile?.profileImage);

  return {};
};

import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { toProfileDto } from './profile.dto.js';
import {
  changePassword,
  deleteAccount,
  getProfile as getProfileService,
  removeProfilePicture,
  updateProfile as updateProfileService,
  uploadProfilePicture,
} from './profile.service.js';

export const getProfile = asyncHandler(async (req, res) => {
  const profile = await getProfileService(req.user.id);

  return sendSuccess(res, 200, 'Profile retrieved successfully', {
    user: toProfileDto(profile),
  });
});

export const updateProfile = asyncHandler(async (req, res) => {
  const profile = await updateProfileService(req.user.id, req.body);

  return sendSuccess(res, 200, 'Profile updated successfully', {
    user: toProfileDto(profile),
  });
});

export const uploadPicture = asyncHandler(async (req, res) => {
  const profile = await uploadProfilePicture(req.user.id, req.file);

  return sendSuccess(res, 200, 'Profile picture updated successfully', {
    user: toProfileDto(profile),
  });
});

export const deletePicture = asyncHandler(async (req, res) => {
  const profile = await removeProfilePicture(req.user.id);

  return sendSuccess(res, 200, 'Profile picture removed successfully', {
    user: toProfileDto(profile),
  });
});

export const updatePassword = asyncHandler(async (req, res) => {
  await changePassword(req.user.id, req.body);

  return sendSuccess(res, 200, 'Password changed successfully', {});
});

export const deleteProfile = asyncHandler(async (req, res) => {
  await deleteAccount(req.user.id, req.body);

  return sendSuccess(res, 200, 'Account deleted successfully', {});
});

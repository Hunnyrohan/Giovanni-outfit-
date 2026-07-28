import { asyncHandler } from '../../utils/async-handler.js';
import { sendSuccess } from '../../utils/api-response.js';
import { env } from '../../config/env.js';
import { toAuthDto, toUserDto } from './auth.dto.js';
import {
  disableTwoFactor,
  enableTwoFactor,
  getCurrentUser,
  loginWithGoogle,
  loginUser,
  logoutUser,
  refreshAccessToken,
  registerUser,
  setupTwoFactor,
  verifyTwoFactorLogin,
} from './auth.service.js';

const refreshCookieOptions = {
  httpOnly: true,
  sameSite: 'strict',
  secure: env.nodeEnv === 'production',
  path: `${env.apiPrefix}/auth`,
};

const getCookieValue = (req, cookieName) => {
  const cookies = req.headers.cookie?.split(';') || [];
  const cookie = cookies.find((item) => item.trim().startsWith(`${cookieName}=`));
  return cookie ? decodeURIComponent(cookie.split('=').slice(1).join('=')) : undefined;
};

const setRefreshCookie = (res, refreshToken) => {
  res.cookie('refreshToken', refreshToken, refreshCookieOptions);
};

const clearRefreshCookie = (res) => {
  res.clearCookie('refreshToken', refreshCookieOptions);
};

const sendAuthSuccess = (res, statusCode, message, result) => {
  const data = toAuthDto(result);

  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

export const register = asyncHandler(async (req, res) => {
  const result = await registerUser(req.body);
  setRefreshCookie(res, result.refreshToken);

  return sendAuthSuccess(res, 201, 'User registered successfully', result);
});

export const login = asyncHandler(async (req, res) => {
  const result = await loginUser(req.body);

  if (result.requiresTwoFactor) {
    return sendSuccess(res, 200, 'Two-factor authentication required', {
      requiresTwoFactor: true,
      twoFactorToken: result.twoFactorToken,
    });
  }

  setRefreshCookie(res, result.refreshToken);

  return sendAuthSuccess(res, 200, 'Login successful', result);
});

export const twoFactorSetup = asyncHandler(async (req, res) => {
  const result = await setupTwoFactor(req.user.id);

  return sendSuccess(res, 200, 'Scan or enter this secret in your authenticator app', result);
});

export const twoFactorEnable = asyncHandler(async (req, res) => {
  const result = await enableTwoFactor(req.user.id, req.body);

  return sendSuccess(res, 200, 'Two-factor authentication enabled', result);
});

export const twoFactorDisable = asyncHandler(async (req, res) => {
  const result = await disableTwoFactor(req.user.id, req.body);

  return sendSuccess(res, 200, 'Two-factor authentication disabled', result);
});

export const twoFactorVerify = asyncHandler(async (req, res) => {
  const result = await verifyTwoFactorLogin(req.body);
  setRefreshCookie(res, result.refreshToken);

  return sendAuthSuccess(res, 200, 'Login successful', result);
});

export const googleLogin = asyncHandler(async (req, res) => {
  const result = await loginWithGoogle(req.body);
  setRefreshCookie(res, result.refreshToken);

  return sendAuthSuccess(res, 200, 'Google login successful', result);
});

export const refresh = asyncHandler(async (req, res) => {
  const refreshToken = req.body?.refreshToken || getCookieValue(req, 'refreshToken');
  const result = await refreshAccessToken(refreshToken);
  setRefreshCookie(res, result.refreshToken);

  return sendAuthSuccess(res, 200, 'Access token refreshed successfully', result);
});

export const logout = asyncHandler(async (req, res) => {
  await logoutUser(req.user.id);
  clearRefreshCookie(res);

  return sendSuccess(res, 200, 'Logout successful', {});
});

export const getMe = asyncHandler(async (req, res) => {
  const user = await getCurrentUser(req.user.id);

  return sendSuccess(res, 200, 'Current user retrieved successfully', {
    user: toUserDto(user),
  });
});

export const getProfile = asyncHandler(async (req, res) => {
  const user = await getCurrentUser(req.user.id);

  return sendSuccess(res, 200, 'Profile retrieved successfully', {
    user: toUserDto(user),
  });
});

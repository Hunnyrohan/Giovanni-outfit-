import bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import jwt from 'jsonwebtoken';
import { authenticator } from 'otplib';
import { env } from '../../config/env.js';
import { ApiError } from '../../utils/api-error.js';
import { authRepository } from './auth.repository.js';

const ACCESS_TOKEN_SUBJECT = 'stylesense-access-token';
const REFRESH_TOKEN_SUBJECT = 'stylesense-refresh-token';
// Short-lived token bridging the two steps of a 2FA login: proves the
// password check already passed without issuing real credentials yet.
const TWO_FACTOR_TOKEN_SUBJECT = 'stylesense-2fa-pending-token';
const TWO_FACTOR_ISSUER = 'StyleSense AI';
const googleClient = new OAuth2Client();

// Accept the previous/next 30s TOTP step to absorb clock skew between the
// server and the user's authenticator app.
authenticator.options = { window: 1 };

const signAccessToken = (user) =>
  jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
    },
    env.jwtAccessSecret,
    {
      expiresIn: env.jwtAccessExpiresIn,
      subject: ACCESS_TOKEN_SUBJECT,
    },
  );

const signRefreshToken = (user) =>
  jwt.sign(
    {
      id: user.id,
    },
    env.jwtRefreshSecret,
    {
      expiresIn: env.jwtRefreshExpiresIn,
      subject: REFRESH_TOKEN_SUBJECT,
    },
  );

const createTokenPair = async (user) => {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  const refreshTokenHash = await bcrypt.hash(refreshToken, env.bcryptSaltRounds);

  await authRepository.updateRefreshTokenHash(user.id, refreshTokenHash);

  return { accessToken, refreshToken };
};

const assertPasswordMatches = async (plainTextPassword, passwordHash) => {
  const isPasswordValid = await bcrypt.compare(plainTextPassword, passwordHash);

  if (!isPasswordValid) {
    throw new ApiError(401, 'Invalid email or password');
  }
};

export const registerUser = async (payload) => {
  const existingUser = await authRepository.findUserByEmail(payload.email);

  if (existingUser) {
    throw new ApiError(409, 'An account with this email already exists', {
      email: 'Email is already registered',
    });
  }

  const hashedPassword = await bcrypt.hash(payload.password, env.bcryptSaltRounds);
  const user = await authRepository.createUser({
    fullName: payload.fullName,
    email: payload.email,
    password: hashedPassword,
    gender: payload.gender,
    profileImage: payload.profileImage,
  });
  const tokens = await createTokenPair(user);

  return { user, ...tokens };
};

export const loginUser = async ({ email, password }) => {
  const user = await authRepository.findUserByEmail(email);

  if (!user) {
    throw new ApiError(401, 'Invalid email or password');
  }

  await assertPasswordMatches(password, user.password);

  if (user.twoFactorEnabled && user.twoFactorSecret) {
    return {
      requiresTwoFactor: true,
      twoFactorToken: signTwoFactorToken(user),
    };
  }

  const tokens = await createTokenPair(user);

  return { user, ...tokens };
};

const signTwoFactorToken = (user) =>
  jwt.sign({ id: user.id }, env.jwtAccessSecret, {
    expiresIn: '5m',
    subject: TWO_FACTOR_TOKEN_SUBJECT,
  });

const assertValidTotpCode = (code, secret) => {
  if (!authenticator.verify({ token: code, secret })) {
    throw new ApiError(401, 'Invalid authentication code', {
      code: 'The 6-digit code is incorrect or has expired',
    });
  }
};

export const setupTwoFactor = async (userId) => {
  const user = await authRepository.findUserById(userId);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  if (user.twoFactorEnabled) {
    throw new ApiError(400, 'Two-factor authentication is already enabled');
  }

  const secret = authenticator.generateSecret();
  await authRepository.setTwoFactorSecret(userId, secret);

  return {
    secret,
    otpauthUrl: authenticator.keyuri(user.email, TWO_FACTOR_ISSUER, secret),
  };
};

export const enableTwoFactor = async (userId, { code }) => {
  const user = await authRepository.findUserById(userId);

  if (!user || !user.twoFactorSecret) {
    throw new ApiError(400, 'Set up two-factor authentication first');
  }

  if (user.twoFactorEnabled) {
    throw new ApiError(400, 'Two-factor authentication is already enabled');
  }

  assertValidTotpCode(code, user.twoFactorSecret);
  await authRepository.enableTwoFactor(userId);

  return { twoFactorEnabled: true };
};

export const disableTwoFactor = async (userId, { code }) => {
  const user = await authRepository.findUserById(userId);

  if (!user || !user.twoFactorEnabled || !user.twoFactorSecret) {
    throw new ApiError(400, 'Two-factor authentication is not enabled');
  }

  assertValidTotpCode(code, user.twoFactorSecret);
  await authRepository.disableTwoFactor(userId);

  return { twoFactorEnabled: false };
};

export const verifyTwoFactorLogin = async ({ twoFactorToken, code }) => {
  let decodedToken;

  try {
    decodedToken = jwt.verify(twoFactorToken, env.jwtAccessSecret, {
      subject: TWO_FACTOR_TOKEN_SUBJECT,
    });
  } catch (error) {
    throw new ApiError(401, 'Two-factor session expired. Please log in again.');
  }

  const user = await authRepository.findUserById(decodedToken.id);

  if (!user || !user.twoFactorEnabled || !user.twoFactorSecret) {
    throw new ApiError(401, 'Two-factor authentication is not enabled for this account');
  }

  assertValidTotpCode(code, user.twoFactorSecret);

  const tokens = await createTokenPair(user);

  return { user, ...tokens };
};

const verifyGoogleIdToken = async (idToken) => {
  if (!env.googleClientId) {
    throw new ApiError(500, 'Google login is not configured', {
      GOOGLE_CLIENT_ID: 'Set GOOGLE_CLIENT_ID in backend/.env',
    });
  }

  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: env.googleClientId,
    });
    const payload = ticket.getPayload();

    if (!payload?.email || !payload?.sub) {
      throw new ApiError(401, 'Invalid Google account payload');
    }

    if (payload.email_verified === false) {
      throw new ApiError(401, 'Google account email is not verified');
    }

    return {
      googleId: payload.sub,
      email: payload.email.toLowerCase(),
      fullName: payload.name || payload.email.split('@')[0],
      profileImage: payload.picture,
    };
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }

    throw new ApiError(401, 'Invalid Google ID token');
  }
};

export const loginWithGoogle = async ({ idToken }) => {
  const googleProfile = await verifyGoogleIdToken(idToken);
  let user = await authRepository.findUserByGoogleId(googleProfile.googleId);

  if (!user) {
    const existingUser = await authRepository.findUserByEmail(googleProfile.email);

    if (existingUser) {
      user = await authRepository.connectGoogleAccount(existingUser.id, {
        googleId: googleProfile.googleId,
        authProvider: existingUser.authProvider === 'LOCAL' ? 'LOCAL_GOOGLE' : existingUser.authProvider,
        profileImage: existingUser.profileImage || googleProfile.profileImage,
        isEmailVerified: true,
        emailVerifiedAt: existingUser.emailVerifiedAt || new Date(),
      });
    } else {
      const generatedPassword = await bcrypt.hash(
        `google:${googleProfile.googleId}:${env.jwtRefreshSecret}`,
        env.bcryptSaltRounds,
      );

      user = await authRepository.createUser({
        fullName: googleProfile.fullName,
        email: googleProfile.email,
        password: generatedPassword,
        profileImage: googleProfile.profileImage,
        googleId: googleProfile.googleId,
        authProvider: 'GOOGLE',
        isEmailVerified: true,
        emailVerifiedAt: new Date(),
      });
    }
  }

  const tokens = await createTokenPair(user);

  return { user, ...tokens };
};

export const refreshAccessToken = async (refreshToken) => {
  if (!refreshToken) {
    throw new ApiError(401, 'Refresh token is required');
  }

  let decodedToken;

  try {
    decodedToken = jwt.verify(refreshToken, env.jwtRefreshSecret, {
      subject: REFRESH_TOKEN_SUBJECT,
    });
  } catch (error) {
    throw new ApiError(401, 'Invalid or expired refresh token');
  }

  const user = await authRepository.findUserById(decodedToken.id);

  if (!user || !user.refreshTokenHash) {
    throw new ApiError(401, 'Refresh token is no longer valid');
  }

  const isRefreshTokenValid = await bcrypt.compare(refreshToken, user.refreshTokenHash);

  if (!isRefreshTokenValid) {
    throw new ApiError(401, 'Refresh token is no longer valid');
  }

  const tokens = await createTokenPair(user);

  return { user, ...tokens };
};

export const logoutUser = async (userId) => {
  await authRepository.clearRefreshTokenHash(userId);
  return {};
};

export const getCurrentUser = async (userId) => {
  const user = await authRepository.findPublicUserById(userId);

  if (!user) {
    throw new ApiError(404, 'User not found');
  }

  return user;
};

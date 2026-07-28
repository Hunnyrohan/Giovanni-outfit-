import { z } from 'zod';

const passwordSchema = z
  .string({ message: 'Password is required' })
  .min(6, 'Password must be at least 6 characters')
  .max(72, 'Password must not exceed 72 characters');

const genderSchema = z
  .string()
  .transform((value) => value.toUpperCase())
  .pipe(z.enum(['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY']))
  .optional();

export const registerSchema = z.object({
  body: z
    .object({
      fullName: z.string().trim().min(2).max(80).optional(),
      name: z.string().trim().min(2).max(80).optional(),
      email: z
        .string({ message: 'Email is required' })
        .trim()
        .toLowerCase()
        .email('Email must be valid'),
      password: passwordSchema,
      gender: genderSchema,
      profileImage: z.string().url('Profile image must be a valid URL').optional(),
      profilePicture: z.string().url('Profile picture must be a valid URL').optional(),
    })
    .transform((value) => ({
      ...value,
      fullName: value.fullName || value.name,
      profileImage: value.profileImage || value.profilePicture,
    }))
    .refine((value) => Boolean(value.fullName), {
      path: ['fullName'],
      message: 'Full name is required',
    }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const loginSchema = z.object({
  body: z.object({
    email: z
      .string({ message: 'Email is required' })
      .trim()
      .toLowerCase()
      .email('Email must be valid'),
    password: z.string({ message: 'Password is required' }).min(1, 'Password is required'),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const googleLoginSchema = z.object({
  body: z
    .object({
      idToken: z.string().min(1, 'Google ID token is required').optional(),
      googleIdToken: z.string().min(1, 'Google ID token is required').optional(),
    })
    .transform((value) => ({
      idToken: value.idToken || value.googleIdToken,
    }))
    .refine((value) => Boolean(value.idToken), {
      path: ['idToken'],
      message: 'Google ID token is required',
    }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

const totpCodeSchema = z
  .string({ message: 'Authentication code is required' })
  .trim()
  .regex(/^\d{6}$/, 'Authentication code must be 6 digits');

export const twoFactorCodeSchema = z.object({
  body: z.object({
    code: totpCodeSchema,
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const twoFactorVerifySchema = z.object({
  body: z.object({
    twoFactorToken: z.string({ message: 'Two-factor token is required' }).min(1, 'Two-factor token is required'),
    code: totpCodeSchema,
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const refreshTokenSchema = z.object({
  body: z
    .object({
      refreshToken: z.string().min(1, 'Refresh token is required').optional(),
    })
    .optional()
    .default({}),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

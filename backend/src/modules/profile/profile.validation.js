import { z } from 'zod';

const genderSchema = z
  .string()
  .transform((value) => value.toUpperCase())
  .pipe(z.enum(['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY']))
  .optional();

const phoneNumberSchema = z
  .string()
  .trim()
  .regex(/^[+]?[0-9\s-]{7,20}$/, 'Phone number must be a valid number')
  .optional();

const dateOfBirthSchema = z.coerce
  .date({ message: 'Date of birth must be a valid date' })
  .refine((value) => value <= new Date(), {
    message: 'Date of birth cannot be in the future',
  })
  .optional();

const passwordSchema = z
  .string({ message: 'Password is required' })
  .min(6, 'Password must be at least 6 characters')
  .max(72, 'Password must not exceed 72 characters');

export const updateProfileSchema = z.object({
  body: z
    .object({
      fullName: z.string().trim().min(2).max(80).optional(),
      name: z.string().trim().min(2).max(80).optional(),
      bio: z.string().trim().max(500, 'Bio must not exceed 500 characters').optional(),
      gender: genderSchema,
      phoneNumber: phoneNumberSchema,
      dateOfBirth: dateOfBirthSchema,
    })
    .transform((value) => ({
      ...value,
      fullName: value.fullName || value.name,
      name: undefined,
    }))
    .refine((value) => Object.values(value).some((field) => field !== undefined), {
      message: 'At least one field must be provided to update the profile',
    }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const changePasswordSchema = z.object({
  body: z
    .object({
      currentPassword: z.string({ message: 'Current password is required' }).min(1, 'Current password is required'),
      newPassword: passwordSchema,
    })
    .refine((value) => value.currentPassword !== value.newPassword, {
      path: ['newPassword'],
      message: 'New password must be different from the current password',
    }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const deleteAccountSchema = z.object({
  body: z.object({
    password: z.string({ message: 'Password is required' }).min(1, 'Password is required'),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

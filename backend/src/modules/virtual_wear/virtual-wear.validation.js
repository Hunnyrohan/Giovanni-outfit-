import { z } from 'zod';

export const createTryOnSchema = z.object({
  body: z.object({
    wardrobeItemId: z.string().uuid('wardrobeItemId must be a valid id'),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const tryOnIdParamSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: z.object({
    id: z.string().uuid('id must be a valid id'),
  }),
});

export const saveTryOnSchema = z.object({
  body: z.object({
    title: z.string().trim().min(1).max(120).optional(),
  }),
  query: z.object({}).optional(),
  params: z.object({
    id: z.string().uuid('id must be a valid id'),
  }),
});

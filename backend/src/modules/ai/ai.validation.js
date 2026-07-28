import { z } from 'zod';

export const chatSchema = z.object({
  body: z.object({
    chatId: z.string().uuid('chatId must be a valid id').optional(),
    message: z
      .string({ message: 'Message is required' })
      .trim()
      .min(1, 'Message is required')
      .max(4000, 'Message must not exceed 4000 characters'),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const analyzeSchema = z.object({
  body: z.object({
    notes: z.string().trim().max(500, 'Notes must not exceed 500 characters').optional(),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const recommendSchema = z.object({
  body: z.object({
    occasion: z.string().trim().max(60, 'Occasion must not exceed 60 characters').optional(),
    notes: z.string().trim().max(500, 'Notes must not exceed 500 characters').optional(),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const chatIdParamSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: z.object({
    id: z.string().uuid('id must be a valid chat id'),
  }),
});

import { z } from 'zod';

const idParamSchema = z.object({
  id: z.string().uuid('Invalid collection id'),
});

const collectionItemParamsSchema = z.object({
  id: z.string().uuid('Invalid collection id'),
  wardrobeItemId: z.string().uuid('Invalid wardrobe item id'),
});

export const createCollectionSchema = z.object({
  body: z.object({
    name: z.string({ message: 'Name is required' }).trim().min(1, 'Name is required').max(80),
    description: z.string().trim().max(500).optional(),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const updateCollectionSchema = z.object({
  body: z.object({
    name: z.string().trim().min(1, 'Name is required').max(80).optional(),
    description: z.string().trim().max(500).optional(),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const collectionIdSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const listCollectionsSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
  }),
  params: z.object({}).optional(),
});

export const addCollectionItemSchema = z.object({
  body: z.object({
    wardrobeItemId: z.string({ message: 'wardrobeItemId is required' }).uuid('Invalid wardrobe item id'),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const removeCollectionItemSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: collectionItemParamsSchema,
});

export const reorderCollectionItemsSchema = z.object({
  body: z.object({
    orderedWardrobeItemIds: z
      .array(z.string().uuid('Invalid wardrobe item id'))
      .min(1, 'orderedWardrobeItemIds must contain at least one item'),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

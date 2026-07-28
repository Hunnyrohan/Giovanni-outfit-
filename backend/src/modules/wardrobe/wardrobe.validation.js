import { z } from 'zod';

const categoryEnum = z.enum(['TOP', 'BOTTOM', 'DRESS', 'OUTERWEAR', 'SHOES', 'ACCESSORY', 'BAG', 'OTHER']);
const seasonEnum = z.enum(['SPRING', 'SUMMER', 'AUTUMN', 'WINTER', 'ALL_SEASON']);
const occasionEnum = z.enum(['CASUAL', 'FORMAL', 'BUSINESS', 'PARTY', 'SPORTS', 'TRAVEL', 'DATE', 'FESTIVAL', 'OTHER']);

const parseListInput = (value) => {
  if (Array.isArray(value)) {
    return value;
  }

  if (typeof value !== 'string' || value.trim() === '') {
    return [];
  }

  try {
    const parsed = JSON.parse(value);
    if (Array.isArray(parsed)) {
      return parsed;
    }
  } catch (error) {
    // Not JSON — fall back to comma-separated parsing below.
  }

  return value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
};

const stringListSchema = z.preprocess(parseListInput, z.array(z.string().trim()));

const occasionListSchema = z
  .preprocess(parseListInput, z.array(z.string()))
  .transform((values) => values.map((value) => value.toUpperCase()))
  .pipe(z.array(occasionEnum));

const booleanInputSchema = z.preprocess((value) => {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true';
  }
  return value;
}, z.boolean());

const categoryInputSchema = z
  .string({ message: 'Category is required' })
  .trim()
  .transform((value) => value.toUpperCase())
  .pipe(categoryEnum);

const seasonInputSchema = z
  .string()
  .trim()
  .transform((value) => value.toUpperCase())
  .pipe(seasonEnum);

const idParamSchema = z.object({
  id: z.string().uuid('Invalid wardrobe item id'),
});

export const createWardrobeItemSchema = z.object({
  body: z.object({
    name: z.string({ message: 'Name is required' }).trim().min(1, 'Name is required').max(120),
    description: z.string().trim().max(1000).optional(),
    category: categoryInputSchema,
    subCategory: z.string().trim().max(80).optional(),
    primaryColor: z.string().trim().max(40).optional(),
    colors: stringListSchema.optional(),
    brand: z.string().trim().max(80).optional(),
    size: z.string().trim().max(20).optional(),
    material: z.string().trim().max(80).optional(),
    season: seasonInputSchema.optional(),
    occasion: occasionListSchema.optional(),
    tags: stringListSchema.optional(),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const updateWardrobeItemSchema = z.object({
  body: z.object({
    name: z.string().trim().min(1, 'Name is required').max(120).optional(),
    description: z.string().trim().max(1000).optional(),
    category: categoryInputSchema.optional(),
    subCategory: z.string().trim().max(80).optional(),
    primaryColor: z.string().trim().max(40).optional(),
    colors: stringListSchema.optional(),
    brand: z.string().trim().max(80).optional(),
    size: z.string().trim().max(20).optional(),
    material: z.string().trim().max(80).optional(),
    season: seasonInputSchema.optional(),
    occasion: occasionListSchema.optional(),
    tags: stringListSchema.optional(),
    isArchived: booleanInputSchema.optional(),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const wardrobeItemIdSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const listWardrobeItemsSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
    category: z
      .string()
      .trim()
      .transform((value) => value.toUpperCase())
      .pipe(categoryEnum)
      .optional(),
    season: z
      .string()
      .trim()
      .transform((value) => value.toUpperCase())
      .pipe(seasonEnum)
      .optional(),
    occasion: z
      .string()
      .trim()
      .transform((value) => value.toUpperCase())
      .pipe(occasionEnum)
      .optional(),
    color: z.string().trim().max(40).optional(),
    search: z.string().trim().max(120).optional(),
    favorite: booleanInputSchema.optional(),
    includeArchived: booleanInputSchema.optional(),
  }),
  params: z.object({}).optional(),
});

export const setFavoriteSchema = z.object({
  body: z.object({
    isFavorite: z.boolean({ message: 'isFavorite is required' }),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

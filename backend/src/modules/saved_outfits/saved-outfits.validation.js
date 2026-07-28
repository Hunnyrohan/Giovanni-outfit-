import { z } from 'zod';
import { parseListInput } from '../../utils/list-input.js';

const occasionEnum = z.enum(['CASUAL', 'FORMAL', 'BUSINESS', 'PARTY', 'SPORTS', 'TRAVEL', 'DATE', 'FESTIVAL', 'OTHER']);
const seasonEnum = z.enum(['SPRING', 'SUMMER', 'AUTUMN', 'WINTER', 'ALL_SEASON']);

const occasionInputSchema = z
  .string()
  .trim()
  .transform((value) => value.toUpperCase())
  .pipe(occasionEnum);

const seasonInputSchema = z
  .string()
  .trim()
  .transform((value) => value.toUpperCase())
  .pipe(seasonEnum);

const booleanInputSchema = z.preprocess((value) => {
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true';
  }
  return value;
}, z.boolean());

const wardrobeItemIdArraySchema = z.array(z.string().uuid('Invalid wardrobe item id'));

const wardrobeItemIdsSchema = z.preprocess(parseListInput, wardrobeItemIdArraySchema);

const requiredWardrobeItemIdsSchema = z.preprocess(
  parseListInput,
  wardrobeItemIdArraySchema.min(1, 'A saved outfit must contain at least one wardrobe item'),
);

const idParamSchema = z.object({
  id: z.string().uuid('Invalid saved outfit id'),
});

export const createSavedOutfitSchema = z.object({
  body: z.object({
    name: z.string({ message: 'Name is required' }).trim().min(1, 'Name is required').max(80),
    notes: z.string().trim().max(500).optional(),
    occasion: occasionInputSchema.optional(),
    season: seasonInputSchema.optional(),
    wardrobeItemIds: requiredWardrobeItemIdsSchema,
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const updateSavedOutfitSchema = z.object({
  body: z.object({
    name: z.string().trim().min(1, 'Name is required').max(80).optional(),
    notes: z.string().trim().max(500).optional(),
    occasion: occasionInputSchema.optional(),
    season: seasonInputSchema.optional(),
    addWardrobeItemIds: wardrobeItemIdsSchema.optional(),
    removeWardrobeItemIds: wardrobeItemIdsSchema.optional(),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const savedOutfitIdSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({}).optional(),
  params: idParamSchema,
});

export const listSavedOutfitsSchema = z.object({
  body: z.object({}).optional(),
  query: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
    occasion: z
      .string()
      .trim()
      .transform((value) => value.toUpperCase())
      .pipe(occasionEnum)
      .optional(),
    season: z
      .string()
      .trim()
      .transform((value) => value.toUpperCase())
      .pipe(seasonEnum)
      .optional(),
    search: z.string().trim().max(120).optional(),
    favorite: booleanInputSchema.optional(),
  }),
  params: z.object({}).optional(),
});

export const setSavedOutfitFavoriteSchema = z.object({
  body: z.object({
    isFavorite: z.boolean({ message: 'isFavorite is required' }),
  }),
  query: z.object({}).optional(),
  params: idParamSchema,
});

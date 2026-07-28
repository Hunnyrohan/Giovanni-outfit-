import { toWardrobeItemDto } from '../wardrobe/wardrobe.dto.js';

export const toSavedOutfitSummaryDto = (outfit) => ({
  id: outfit.id,
  name: outfit.title,
  title: outfit.title,
  notes: outfit.notes,
  occasion: outfit.occasion,
  season: outfit.season,
  coverImage: outfit.imageUrl,
  coverImageUrl: outfit.imageUrl,
  isFavorite: outfit.isFavorite,
  itemCount: outfit._count?.items ?? 0,
  createdAt: outfit.createdAt,
  updatedAt: outfit.updatedAt,
});

export const toSavedOutfitDetailDto = (outfit) => ({
  id: outfit.id,
  name: outfit.title,
  title: outfit.title,
  notes: outfit.notes,
  occasion: outfit.occasion,
  season: outfit.season,
  coverImage: outfit.imageUrl,
  coverImageUrl: outfit.imageUrl,
  isFavorite: outfit.isFavorite,
  itemCount: outfit.items?.length ?? 0,
  items: (outfit.items || []).map((outfitItem) => ({
    id: outfitItem.id,
    addedAt: outfitItem.createdAt,
    wardrobeItem: toWardrobeItemDto(outfitItem.wardrobeItem),
  })),
  createdAt: outfit.createdAt,
  updatedAt: outfit.updatedAt,
});

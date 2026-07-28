import { toWardrobeItemDto } from '../wardrobe/wardrobe.dto.js';

export const toCollectionSummaryDto = (collection) => ({
  id: collection.id,
  name: collection.name,
  description: collection.description,
  coverImage: collection.coverImage,
  coverImageUrl: collection.coverImage,
  itemCount: collection._count?.items ?? 0,
  createdAt: collection.createdAt,
  updatedAt: collection.updatedAt,
});

export const toCollectionDetailDto = (collection) => ({
  id: collection.id,
  name: collection.name,
  description: collection.description,
  coverImage: collection.coverImage,
  coverImageUrl: collection.coverImage,
  itemCount: collection.items?.length ?? 0,
  items: (collection.items || []).map((collectionItem) => ({
    id: collectionItem.id,
    order: collectionItem.order,
    addedAt: collectionItem.createdAt,
    wardrobeItem: toWardrobeItemDto(collectionItem.wardrobeItem),
  })),
  createdAt: collection.createdAt,
  updatedAt: collection.updatedAt,
});

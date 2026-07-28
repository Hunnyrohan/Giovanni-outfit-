import 'dart:io';

import '../entities/wardrobe_item_entity.dart';

abstract class WardrobeRepository {
  Future<List<WardrobeItemEntity>> getWardrobeItems();
  Future<List<WardrobeItemEntity>> getSavedOutfits();
  Future<List<WardrobeItemEntity>> getMarketplaceItems();
  Future<void> toggleFavorite(String id);
  Future<void> addToWardrobe(WardrobeItemEntity item);

  /// Creates a real wardrobe item on the backend from a captured photo.
  /// [category] must be a backend `ItemCategory` enum value (TOP, BOTTOM...);
  /// [subCategory] carries the display label the wardrobe chips filter by.
  Future<WardrobeItemEntity> addCapturedItem({
    required String name,
    required String category,
    String? subCategory,
    required File image,
  });
}

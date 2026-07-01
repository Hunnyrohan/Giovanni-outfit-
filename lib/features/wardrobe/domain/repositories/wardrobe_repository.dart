import '../entities/wardrobe_item_entity.dart';

abstract class WardrobeRepository {
  Future<List<WardrobeItemEntity>> getWardrobeItems();
  Future<List<WardrobeItemEntity>> getSavedOutfits();
  Future<List<WardrobeItemEntity>> getMarketplaceItems();
  Future<void> toggleFavorite(String id);
  Future<void> addToWardrobe(WardrobeItemEntity item);
}

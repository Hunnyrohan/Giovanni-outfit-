import '../../domain/entities/wardrobe_item_entity.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_local_datasource.dart';
import '../models/wardrobe_item_model.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeLocalDatasource localDatasource;

  WardrobeRepositoryImpl(this.localDatasource);

  @override
  Future<List<WardrobeItemEntity>> getWardrobeItems() async {
    return await localDatasource.getWardrobeItems();
  }

  @override
  Future<List<WardrobeItemEntity>> getSavedOutfits() async {
    return await localDatasource.getSavedOutfits();
  }

  @override
  Future<List<WardrobeItemEntity>> getMarketplaceItems() async {
    return await localDatasource.getMarketplaceItems();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await localDatasource.toggleFavorite(id);
  }

  @override
  Future<void> addToWardrobe(WardrobeItemEntity item) async {
    await localDatasource.addToWardrobe(WardrobeItemModel.fromEntity(item));
  }
}

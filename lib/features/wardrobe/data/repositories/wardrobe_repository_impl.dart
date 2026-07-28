import 'dart:io';

import '../../domain/entities/wardrobe_item_entity.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_local_datasource.dart';
import '../datasources/wardrobe_remote_datasource.dart';
import '../models/wardrobe_item_model.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeLocalDatasource localDatasource;
  final WardrobeRemoteDataSource remoteDataSource;

  WardrobeRepositoryImpl(this.localDatasource, this.remoteDataSource);

  @override
  Future<List<WardrobeItemEntity>> getWardrobeItems() async {
    final items = await remoteDataSource.getWardrobeItems();
    return items
        .map((item) => WardrobeItemModel.fromBackendJson(item as Map<String, dynamic>))
        .toList();
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

  @override
  Future<WardrobeItemEntity> addCapturedItem({
    required String name,
    required String category,
    String? subCategory,
    required File image,
  }) async {
    final json = await remoteDataSource.addWardrobeItem(
      name: name,
      category: category,
      subCategory: subCategory,
      image: image,
    );
    return WardrobeItemModel.fromBackendJson(json);
  }
}

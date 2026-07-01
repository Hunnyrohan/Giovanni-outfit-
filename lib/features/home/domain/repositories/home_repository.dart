import '../entities/recommended_outfit_entity.dart';

abstract class HomeRepository {
  Future<List<RecommendedOutfitEntity>> getRecommendedOutfits();
}

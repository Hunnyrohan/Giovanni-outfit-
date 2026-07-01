import '../entities/recommended_outfit_entity.dart';
import '../repositories/home_repository.dart';

class GetRecommendedOutfitsUseCase {
  const GetRecommendedOutfitsUseCase(this.repository);

  final HomeRepository repository;

  Future<List<RecommendedOutfitEntity>> call() {
    return repository.getRecommendedOutfits();
  }
}

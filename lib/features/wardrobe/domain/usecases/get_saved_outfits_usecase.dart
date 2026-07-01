import '../entities/wardrobe_item_entity.dart';
import '../repositories/wardrobe_repository.dart';

class GetSavedOutfitsUseCase {
  final WardrobeRepository repository;

  GetSavedOutfitsUseCase(this.repository);

  Future<List<WardrobeItemEntity>> call() async {
    return await repository.getSavedOutfits();
  }
}

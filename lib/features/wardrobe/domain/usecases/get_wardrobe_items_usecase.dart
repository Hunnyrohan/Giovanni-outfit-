import '../entities/wardrobe_item_entity.dart';
import '../repositories/wardrobe_repository.dart';

class GetWardrobeItemsUseCase {
  final WardrobeRepository repository;

  GetWardrobeItemsUseCase(this.repository);

  Future<List<WardrobeItemEntity>> call() async {
    return await repository.getWardrobeItems();
  }
}

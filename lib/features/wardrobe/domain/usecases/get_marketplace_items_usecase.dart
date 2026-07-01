import '../entities/wardrobe_item_entity.dart';
import '../repositories/wardrobe_repository.dart';

class GetMarketplaceItemsUseCase {
  final WardrobeRepository repository;

  GetMarketplaceItemsUseCase(this.repository);

  Future<List<WardrobeItemEntity>> call() async {
    return await repository.getMarketplaceItems();
  }
}

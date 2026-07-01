import '../entities/virtual_clothing_entity.dart';
import '../repositories/virtual_wear_repository.dart';

class GetVirtualClothesUseCase {
  const GetVirtualClothesUseCase(this.repository);

  final VirtualWearRepository repository;

  Future<List<VirtualClothingEntity>> call() {
    return repository.getVirtualClothes();
  }
}

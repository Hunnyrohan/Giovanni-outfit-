import '../entities/virtual_clothing_entity.dart';

abstract class VirtualWearRepository {
  Future<List<VirtualClothingEntity>> getVirtualClothes();
}

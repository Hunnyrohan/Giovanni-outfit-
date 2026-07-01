import '../../domain/entities/virtual_clothing_entity.dart';
import '../../domain/repositories/virtual_wear_repository.dart';
import '../datasources/virtual_wear_local_datasource.dart';

class VirtualWearRepositoryImpl implements VirtualWearRepository {
  const VirtualWearRepositoryImpl(this.localDatasource);

  final VirtualWearLocalDatasource localDatasource;

  @override
  Future<List<VirtualClothingEntity>> getVirtualClothes() {
    return localDatasource.getVirtualClothes();
  }
}

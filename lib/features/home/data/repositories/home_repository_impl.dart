import '../../domain/entities/recommended_outfit_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this.localDataSource);

  final HomeLocalDataSource localDataSource;

  @override
  Future<List<RecommendedOutfitEntity>> getRecommendedOutfits() {
    return localDataSource.getRecommendedOutfits();
  }
}

import '../../../../core/errors/failure.dart';
import '../entities/try_on_job_entity.dart';
import '../repositories/virtual_tryon_repository.dart';

class GetTryOnHistoryUseCase {
  final VirtualTryOnRepository repository;

  GetTryOnHistoryUseCase(this.repository);

  Future<Either<Failure, List<TryOnJobEntity>>> call() {
    return repository.getHistory();
  }
}

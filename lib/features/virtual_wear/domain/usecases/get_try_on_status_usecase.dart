import '../../../../core/errors/failure.dart';
import '../entities/try_on_job_entity.dart';
import '../repositories/virtual_tryon_repository.dart';

class GetTryOnStatusUseCase {
  final VirtualTryOnRepository repository;

  GetTryOnStatusUseCase(this.repository);

  Future<Either<Failure, TryOnJobEntity>> call(String jobId) {
    return repository.getStatus(jobId);
  }
}

import '../../../../core/errors/failure.dart';
import '../repositories/virtual_tryon_repository.dart';

class DeleteTryOnUseCase {
  final VirtualTryOnRepository repository;

  DeleteTryOnUseCase(this.repository);

  Future<Either<Failure, void>> call(String jobId) {
    return repository.deleteTryOn(jobId);
  }
}

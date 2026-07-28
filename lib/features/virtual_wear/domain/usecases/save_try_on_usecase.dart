import '../../../../core/errors/failure.dart';
import '../repositories/virtual_tryon_repository.dart';

class SaveTryOnUseCase {
  final VirtualTryOnRepository repository;

  SaveTryOnUseCase(this.repository);

  Future<Either<Failure, void>> call(String jobId, {String? title}) {
    return repository.saveToOutfits(jobId, title: title);
  }
}

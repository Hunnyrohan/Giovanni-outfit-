import '../../../../core/errors/failure.dart';
import '../repositories/profile_repository.dart';

class GetTwoFactorStatusUseCase {
  final ProfileRepository repository;

  GetTwoFactorStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.getTwoFactorEnabled();
  }
}

import '../../../../core/errors/failure.dart';
import '../repositories/profile_repository.dart';

class EnableTwoFactorUseCase {
  final ProfileRepository repository;

  EnableTwoFactorUseCase(this.repository);

  Future<Either<Failure, void>> call(String code) {
    return repository.enableTwoFactor(code);
  }
}

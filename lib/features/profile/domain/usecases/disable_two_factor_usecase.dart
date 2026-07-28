import '../../../../core/errors/failure.dart';
import '../repositories/profile_repository.dart';

class DisableTwoFactorUseCase {
  final ProfileRepository repository;

  DisableTwoFactorUseCase(this.repository);

  Future<Either<Failure, void>> call(String code) {
    return repository.disableTwoFactor(code);
  }
}

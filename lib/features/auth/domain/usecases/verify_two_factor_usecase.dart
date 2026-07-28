import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyTwoFactorUseCase {
  final AuthRepository repository;

  VerifyTwoFactorUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String twoFactorToken, String code) {
    return repository.verifyTwoFactor(twoFactorToken, code);
  }
}

import '../../../../core/errors/failure.dart';
import '../entities/two_factor_setup_entity.dart';
import '../repositories/profile_repository.dart';

class SetupTwoFactorUseCase {
  final ProfileRepository repository;

  SetupTwoFactorUseCase(this.repository);

  Future<Either<Failure, TwoFactorSetupEntity>> call() {
    return repository.setupTwoFactor();
  }
}

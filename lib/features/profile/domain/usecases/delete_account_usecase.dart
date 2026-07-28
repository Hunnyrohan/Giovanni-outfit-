import '../../../../core/errors/failure.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call({required String password}) {
    return repository.deleteAccount(password: password);
  }
}

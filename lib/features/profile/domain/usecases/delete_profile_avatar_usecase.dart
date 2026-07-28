import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class DeleteProfileAvatarUseCase {
  final ProfileRepository repository;

  DeleteProfileAvatarUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call() {
    return repository.deleteAvatar();
  }
}

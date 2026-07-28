import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call({
    String? fullName,
    String? bio,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return repository.updateProfile(
      fullName: fullName,
      bio: bio,
      gender: gender,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
    );
  }
}

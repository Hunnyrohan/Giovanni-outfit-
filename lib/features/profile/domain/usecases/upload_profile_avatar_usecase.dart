import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadProfileAvatarUseCase {
  final ProfileRepository repository;

  UploadProfileAvatarUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call(File imageFile) {
    return repository.uploadAvatar(imageFile);
  }
}

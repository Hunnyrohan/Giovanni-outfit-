import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfilePictureUseCase {
  final AuthRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(File imageFile) {
    return repository.updateProfilePicture(imageFile);
  }
}

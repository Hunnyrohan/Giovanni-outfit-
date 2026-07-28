import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> verifyTwoFactor(String twoFactorToken, String code);
  Future<Either<Failure, UserEntity>> googleLogin();
  Future<Either<Failure, UserEntity>> register(String name, String email, String password);
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, UserEntity>> updateProfilePicture(File imageFile);
  Future<Either<Failure, void>> logout();
}

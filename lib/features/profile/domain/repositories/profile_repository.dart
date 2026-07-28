import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/two_factor_setup_entity.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();

  Future<Either<Failure, UserProfileEntity>> updateProfile({
    String? fullName,
    String? bio,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
  });

  Future<Either<Failure, UserProfileEntity>> uploadAvatar(File imageFile);

  Future<Either<Failure, UserProfileEntity>> deleteAvatar();

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount({required String password});

  Future<Either<Failure, bool>> getTwoFactorEnabled();

  Future<Either<Failure, TwoFactorSetupEntity>> setupTwoFactor();

  Future<Either<Failure, void>> enableTwoFactor(String code);

  Future<Either<Failure, void>> disableTwoFactor(String code);
}

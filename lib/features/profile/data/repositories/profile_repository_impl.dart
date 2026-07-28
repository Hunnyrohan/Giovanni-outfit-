import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/two_factor_setup_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDataSource});

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() async {
    try {
      final json = await remoteDataSource.getProfile();
      return Right(UserProfileModel.fromJson(json));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile({
    String? fullName,
    String? bio,
    String? gender,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    try {
      final fields = <String, dynamic>{
        'fullName': ?fullName,
        'bio': ?bio,
        'gender': ?gender,
        'phoneNumber': ?phoneNumber,
        'dateOfBirth': ?dateOfBirth?.toIso8601String(),
      };

      final json = await remoteDataSource.updateProfile(fields);
      return Right(UserProfileModel.fromJson(json));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> uploadAvatar(
    File imageFile,
  ) async {
    try {
      final json = await remoteDataSource.uploadAvatar(imageFile);
      return Right(UserProfileModel.fromJson(json));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> deleteAvatar() async {
    try {
      final json = await remoteDataSource.deleteAvatar();
      return Right(UserProfileModel.fromJson(json));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Runs [action] and maps thrown data-layer exceptions onto Failures -
  /// shared by the security operations below, which have no entity payload.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _guard(() => remoteDataSource.changePassword(currentPassword, newPassword));
  }

  @override
  Future<Either<Failure, void>> deleteAccount({required String password}) {
    return _guard(() => remoteDataSource.deleteAccount(password));
  }

  @override
  Future<Either<Failure, bool>> getTwoFactorEnabled() {
    return _guard(() async {
      final json = await remoteDataSource.getProfile();
      return json['twoFactorEnabled'] == true;
    });
  }

  @override
  Future<Either<Failure, TwoFactorSetupEntity>> setupTwoFactor() {
    return _guard(() async {
      final data = await remoteDataSource.setupTwoFactor();
      final secret = data['secret'] as String?;
      final otpauthUrl = data['otpauthUrl'] as String?;
      if (secret == null || otpauthUrl == null) {
        throw const ServerException('Invalid two-factor setup response');
      }
      return TwoFactorSetupEntity(secret: secret, otpauthUrl: otpauthUrl);
    });
  }

  @override
  Future<Either<Failure, void>> enableTwoFactor(String code) {
    return _guard(() => remoteDataSource.enableTwoFactor(code));
  }

  @override
  Future<Either<Failure, void>> disableTwoFactor(String code) {
    return _guard(() => remoteDataSource.disableTwoFactor(code));
  }
}

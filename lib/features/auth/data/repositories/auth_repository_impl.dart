import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final loginData = await remoteDataSource.login(email, password);
      
      final String token = loginData['token'] as String;
      final Map<String, dynamic> userJson = loginData['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userJson);

      // Save token and cache user locally
      await localDataSource.saveToken(token);
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String name, String email, String password) async {
    try {
      final registerData = await remoteDataSource.register(name, email, password);

      final String token = registerData['token'] as String;
      final Map<String, dynamic> userJson = registerData['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userJson);

      // Save token and cache user locally
      await localDataSource.saveToken(token);
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    // Try to get cached user profile first, otherwise fetch from remote
    try {
      final cachedUser = await localDataSource.getCachedUser();
      // Fetch fresh profile in the background or just return cache.
      // For Clean Architecture, let's fetch from remote to be up-to-date.
      try {
        final userJson = await remoteDataSource.getProfile();
        final userModel = UserModel.fromJson(userJson);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } catch (_) {
        // If remote fails, return cached profile
        return Right(cachedUser.toEntity());
      }
    } on CacheException {
      // No cache, must fetch remote
      try {
        final userJson = await remoteDataSource.getProfile();
        final userModel = UserModel.fromJson(userJson);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
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
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

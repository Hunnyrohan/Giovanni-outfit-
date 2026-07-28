import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/try_on_job_entity.dart';
import '../../domain/repositories/virtual_tryon_repository.dart';
import '../datasources/virtual_tryon_remote_datasource.dart';
import '../models/try_on_job_model.dart';

class VirtualTryOnRepositoryImpl implements VirtualTryOnRepository {
  final VirtualTryOnRemoteDataSource remoteDataSource;

  VirtualTryOnRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TryOnJobEntity>> createTryOn({
    required String wardrobeItemId,
    required File personImage,
  }) async {
    try {
      final json = await remoteDataSource.createTryOn(
        wardrobeItemId: wardrobeItemId,
        personImage: personImage,
      );
      return Right(TryOnJobModel.fromJson(json));
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
  Future<Either<Failure, TryOnJobEntity>> getStatus(String jobId) async {
    try {
      final json = await remoteDataSource.getStatus(jobId);
      return Right(TryOnJobModel.fromJson(json));
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
  Future<Either<Failure, List<TryOnJobEntity>>> getHistory() async {
    try {
      final items = await remoteDataSource.getHistory();
      return Right(items.map((item) => TryOnJobModel.fromJson(item as Map<String, dynamic>)).toList());
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
  Future<Either<Failure, void>> deleteTryOn(String jobId) async {
    try {
      await remoteDataSource.deleteTryOn(jobId);
      return const Right(null);
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
  Future<Either<Failure, void>> saveToOutfits(String jobId, {String? title}) async {
    try {
      await remoteDataSource.saveToOutfits(jobId, title: title);
      return const Right(null);
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

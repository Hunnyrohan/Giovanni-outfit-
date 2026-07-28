import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/try_on_job_entity.dart';

abstract class VirtualTryOnRepository {
  Future<Either<Failure, TryOnJobEntity>> createTryOn({
    required String wardrobeItemId,
    required File personImage,
  });

  Future<Either<Failure, TryOnJobEntity>> getStatus(String jobId);

  Future<Either<Failure, List<TryOnJobEntity>>> getHistory();

  Future<Either<Failure, void>> deleteTryOn(String jobId);

  Future<Either<Failure, void>> saveToOutfits(String jobId, {String? title});
}

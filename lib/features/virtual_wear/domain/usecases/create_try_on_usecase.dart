import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../entities/try_on_job_entity.dart';
import '../repositories/virtual_tryon_repository.dart';

class CreateTryOnUseCase {
  final VirtualTryOnRepository repository;

  CreateTryOnUseCase(this.repository);

  Future<Either<Failure, TryOnJobEntity>> call({
    required String wardrobeItemId,
    required File personImage,
  }) {
    return repository.createTryOn(wardrobeItemId: wardrobeItemId, personImage: personImage);
  }
}

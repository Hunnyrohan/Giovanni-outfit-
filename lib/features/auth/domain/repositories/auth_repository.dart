import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String name, String email, String password);
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, void>> logout();
}

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Not an error: the password check passed but the account has two-factor
/// authentication enabled, so login must continue with a TOTP code plus
/// this short-lived token (see /auth/2fa/verify).
class TwoFactorRequiredFailure extends Failure {
  final String twoFactorToken;
  const TwoFactorRequiredFailure(this.twoFactorToken)
    : super('Two-factor authentication required');
}

// Simple Either implementation for Clean Architecture error handling
abstract class Either<L, R> {
  const Either();
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) => leftFn(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) => rightFn(value);
}

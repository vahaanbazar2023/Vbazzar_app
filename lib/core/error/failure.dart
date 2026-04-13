/// A [Failure] is a typed, displayable version of an [AppException].
/// Repositories return Either<Failure, T> or throw Failures.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network failure']);
}

class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure([super.message = 'Unauthorised']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('No internet connection');
}

/// Base class for all app exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode, super.code});
}

class UnauthorisedException extends AppException {
  const UnauthorisedException([super.message = 'Unauthorised'])
    : super(code: '401');
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found'])
    : super(code: '404');
}

class ServerException extends AppException {
  const ServerException([super.message = 'Internal server error'])
    : super(code: '500');
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NoInternetException extends AppException {
  const NoInternetException() : super('No internet connection');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('Request timed out');
}

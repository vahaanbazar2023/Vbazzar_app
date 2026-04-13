import 'package:dio/dio.dart';
import 'app_exceptions.dart';
import 'failure.dart';
import '../services/logger_service.dart';

class ErrorHandler {
  ErrorHandler._();

  static final _log = LoggerService.instance;

  /// Convert a raw exception to a typed [Failure] for the UI layer.
  static Failure handle(Object error) {
    _log.error('ErrorHandler caught: $error');

    if (error is DioException) return _fromDio(error);
    if (error is AppException) return _fromAppException(error);

    return ServerFailure(error.toString());
  }

  static Failure _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NoInternetFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure('Could not reach the server');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401) return const UnauthorisedFailure();
        if (status == 404) return const NotFoundFailure();
        if (status >= 500) return const ServerFailure();
        return NetworkFailure('HTTP $status');
      default:
        return NetworkFailure(e.message ?? 'Unknown network error');
    }
  }

  static Failure _fromAppException(AppException e) {
    if (e is UnauthorisedException) return const UnauthorisedFailure();
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is CacheException) return CacheFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is NoInternetException) return const NoInternetFailure();
    return ServerFailure(e.message);
  }
}

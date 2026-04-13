import 'package:dio/dio.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/services/logger_service.dart';
import '../models/login_request.dart';
import '../models/otp_response.dart';
import '../models/otp_verify_models.dart';
import '../models/complete_profile_models.dart';

/// Auth data source — V2 API calls
class AuthDataSource {
  NetworkService? _networkService;

  NetworkService get networkService {
    _networkService ??= NetworkService.to;
    return _networkService!;
  }

  AuthDataSource({NetworkService? networkService})
    : _networkService = networkService;

  /// POST /api/v2/auth/login — request OTP (creates user if new)
  Future<OtpResponse> sendOtp(LoginRequest request) async {
    try {
      LoggerService.to.info('Sending OTP to: ${request.phoneNumber}');

      final response = await networkService.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', 500);
      }

      return OtpResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v2/auth/verify-otp — verify OTP and obtain token
  Future<OtpVerifyResponse> verifyOtp(OtpVerifyRequest request) async {
    try {
      if (!request.isValid()) {
        throw ValidationException('Invalid OTP verification request');
      }

      LoggerService.to.info(
        'Verifying OTP for transaction: ${request.transactionId}',
      );

      final response = await networkService.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', 500);
      }

      return OtpVerifyResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v2/auth/complete-profile — fill required profile fields
  Future<CompleteProfileResponse> completeProfile(
    CompleteProfileRequest request,
  ) async {
    try {
      LoggerService.to.info('Completing profile for userId: ${request.userId}');

      final response = await networkService.put(
        ApiEndpoints.completeProfile,
        queryParameters: {'user_id': request.userId},
        data: request.toJson(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', 500);
      }

      return CompleteProfileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert DioException to a typed app exception
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          final message =
              data['message'] as String? ??
              data['error'] as String? ??
              'An error occurred';

          if (statusCode == 401) {
            return AuthException(message);
          } else if (statusCode == 400) {
            return ValidationException(message);
          } else if (statusCode == 500) {
            return ServerException(message);
          }

          return ApiException(message, statusCode);
        }

        return ApiException(
          'Request failed with status code: $statusCode',
          statusCode,
        );

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.unknown:
        return NetworkException(
          error.message ?? 'An unexpected error occurred',
        );

      default:
        return NetworkException('An unexpected error occurred');
    }
  }
}

// ─── Custom Exceptions ──────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/services/logger_service.dart';
import '../models/profile_models.dart';

class ProfileDataSource {
  NetworkService? _networkService;

  NetworkService get networkService {
    _networkService ??= NetworkService.to;
    return _networkService!;
  }

  ProfileDataSource({NetworkService? networkService})
    : _networkService = networkService;

  /// POST /api/v1/dashboard/profile — fetch user profile by user_id
  Future<ProfileResponse> fetchProfile(String userId) async {
    try {
      LoggerService.to.info('Fetching profile for userId: $userId');
      final response = await networkService.post(
        ApiEndpoints.profile,
        data: {'user_id': userId},
      );
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to fetch profile';
      LoggerService.to.error('fetchProfile DioException: $msg');
      throw Exception(msg);
    }
  }

  /// POST /api/v1/auth/logout — revoke token for the given user_id
  Future<LogoutResponse> logout(String userId) async {
    try {
      LoggerService.to.info('Logging out userId: $userId');
      final response = await networkService.post(
        ApiEndpoints.logout,
        data: {'user_id': userId},
      );
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return LogoutResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Logout failed';
      LoggerService.to.error('logout DioException: $msg');
      throw Exception(msg);
    }
  }
}

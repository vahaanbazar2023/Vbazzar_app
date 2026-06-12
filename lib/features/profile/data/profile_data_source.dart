import 'package:dio/dio.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/services/logger_service.dart';
import '../models/profile_models.dart';
import '../models/wallet_models.dart';

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

  /// POST /api/v1/dashboard/profile-update — update user profile
  Future<ProfileResponse> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      LoggerService.to.info('Updating profile for userId: $userId');
      final data = <String, dynamic>{'user_id': userId};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (pincode != null) data['pincode'] = pincode;

      final response = await networkService.post(
        ApiEndpoints.updateProfile,
        data: data,
      );
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to update profile';
      LoggerService.to.error('updateProfile DioException: $msg');
      throw Exception(msg);
    }
  }

  /// POST /api/v1/wallet/dashboard — fetch wallet dashboard with referral code & transactions
  Future<WalletDashboardResponse> fetchWalletDashboard(String userId) async {
    try {
      LoggerService.to.info('Fetching wallet dashboard for userId: $userId');
      final response = await networkService.post(
        ApiEndpoints.walletDashboard,
        data: {'user_id': userId},
      );
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return WalletDashboardResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to fetch wallet dashboard';
      LoggerService.to.error('fetchWalletDashboard DioException: $msg');
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
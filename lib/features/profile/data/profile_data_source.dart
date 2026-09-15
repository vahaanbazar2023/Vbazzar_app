import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  /// POST /api/v2/auth/complete-profile — update user profile
  Future<ProfileResponse> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String state,
    required String city,
  }) async {
    try {
      final requestData = {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'state': state,
        'city': city,
      };
      LoggerService.to.info(
        'Updating profile — '
        'URL: ${ApiEndpoints.completeProfile}  '
        'Body: $requestData',
      );
      debugPrint('🔄 complete-profile REQUEST: $requestData');
      final response = await networkService.put(
        ApiEndpoints.completeProfile,
        data: requestData,
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

  /// POST /api/v1/dashboard/auction-refund-initiate — initiate auction refund
  Future<Map<String, dynamic>> initiateRefund({
    required String userId,
    required String accHolderName,
    required String accountNumber,
    required String bankName,
    required String branchName,
    required String ifscCode,
    required String refundType,
  }) async {
    try {
      LoggerService.to.info('Initiating refund for userId: $userId');
      final response = await networkService.post(
        ApiEndpoints.auctionRefundInitiate,
        data: {
          'user_id': userId,
          'acc_holder_name': accHolderName,
          'account_number': accountNumber,
          'bank_name': bankName,
          'branch_name': branchName,
          'ifsc_code': ifscCode,
          'refund_type': refundType,
        },
      );
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      LoggerService.to.error(
        'initiateRefund DioException [${e.response?.statusCode}]: '
        'response=${e.response?.data}',
      );
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to initiate refund';
      throw Exception(msg);
    }
  }

  /// GET /api/v1/wallet/cash-out/eligibility
  Future<CashOutEligibility> fetchCashOutEligibility() async {
    try {
      final response = await networkService.get(
        ApiEndpoints.walletCashOutEligibility,
      );
      if (response.data == null) throw Exception('Empty response');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return CashOutEligibility.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to fetch cash-out eligibility';
      LoggerService.to.error('fetchCashOutEligibility DioException: $msg');
      throw Exception(msg);
    }
  }

  /// POST /api/v1/wallet/cash-out — request a cash-out
  Future<Map<String, dynamic>> requestCashOut(CashOutRequest request) async {
    try {
      final response = await networkService.post(
        ApiEndpoints.walletCashOut,
        data: request.toJson(),
      );
      if (response.data == null) throw Exception('Empty response');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to request cash-out';
      LoggerService.to.error('requestCashOut DioException: $msg');
      throw Exception(msg);
    }
  }

  /// GET /api/v1/wallet/cash-out/history
  Future<List<CashOutHistoryEntry>> fetchCashOutHistory() async {
    try {
      final response = await networkService.get(
        ApiEndpoints.walletCashOutHistory,
      );
      if (response.data == null) throw Exception('Empty response');
      final body = response.data as Map<String, dynamic>;
      // API wraps in data:{} — handle both flat list and nested object shapes
      final raw = body['data'];
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list =
            (raw['cash_out_requests'] as List<dynamic>?) ??
            (raw['history'] as List<dynamic>?) ??
            (raw['items'] as List<dynamic>?) ??
            [];
      } else {
        list = [];
      }
      return list
          .map((e) => CashOutHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to fetch cash-out history';
      LoggerService.to.error('fetchCashOutHistory DioException: $msg');
      throw Exception(msg);
    }
  }

  /// GET /api/v1/reward-coins/conversion-eligibility
  Future<CoinConversionEligibility> fetchCoinConversionEligibility() async {
    try {
      final response = await networkService.get(
        ApiEndpoints.rewardCoinsConversionEligibility,
      );
      if (response.data == null) throw Exception('Empty response');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return CoinConversionEligibility.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to fetch coin conversion eligibility';
      LoggerService.to.error(
        'fetchCoinConversionEligibility DioException: $msg',
      );
      throw Exception(msg);
    }
  }

  /// POST /api/v1/reward-coins/convert-to-wallet
  Future<Map<String, dynamic>> convertCoinsToWallet(int coinAmount) async {
    try {
      final response = await networkService.post(
        ApiEndpoints.rewardCoinsConvertToWallet,
        data: {'coins': coinAmount},
      );
      if (response.data == null) throw Exception('Empty response');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to convert coins';
      LoggerService.to.error('convertCoinsToWallet DioException: $msg');
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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/network_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final NetworkService _network = NetworkService.to;

  Future<String?> _getUserId() async {
    try {
      return await SecureStorageService.to.read(StorageKeys.userId);
    } catch (_) {
      return null;
    }
  }

  Future<DashboardData?> getDashboardHome() async {
    final userId = await _getUserId();
    try {
      final response = await _network.post(
        '/api/v1/dashboard/home',
        data: {if (userId != null) 'user_id': userId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        debugPrint('🏠 Dashboard raw response: $raw');
        if (raw is Map<String, dynamic> &&
            raw['status'] == 'success' &&
            raw['data'] != null) {
          final dataMap = raw['data'] as Map<String, dynamic>;
          debugPrint(
            '🏠 Dashboard feed items: ${(dataMap['feed'] as List?)?.length ?? 0}',
          );
          return DashboardData.fromJson(dataMap);
        }
        debugPrint(
          '🏠 Dashboard: unexpected structure - status=${raw['status']}, hasData=${raw['data'] != null}',
        );
      }
      return null;
    } on DioException catch (e) {
      print('❌ getDashboardHome error: ${e.message}');
      return null;
    }
  }
}

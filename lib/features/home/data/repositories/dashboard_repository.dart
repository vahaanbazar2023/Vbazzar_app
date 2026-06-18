import 'package:dio/dio.dart';
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
        '/api/v2/dashboard/home',
        data: {if (userId != null) 'user_id': userId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is Map<String, dynamic> &&
            raw['status'] == 'success' &&
            raw['data'] != null) {
          return DashboardData.fromJson(raw['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } on DioException catch (e) {
      print('❌ getDashboardHome error: ${e.message}');
      return null;
    }
  }
}

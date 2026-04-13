import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';
import '../../storage/storage_keys.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.instance.read(
      StorageKeys.authToken,
    );
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired — attempt refresh
      final refreshed = await _tryRefreshToken(err);
      if (refreshed != null) {
        handler.resolve(refreshed);
        return;
      }
      // Refresh failed — force logout
      await SecureStorageService.instance.deleteAll();
    }
    handler.next(err);
  }

  Future<Response?> _tryRefreshToken(DioException err) async {
    try {
      final refresh = await SecureStorageService.instance.read(
        StorageKeys.refreshToken,
      );
      if (refresh == null) return null;

      final dio = Dio(); // fresh instance to avoid interceptor loop
      final res = await dio.post(
        '${err.requestOptions.baseUrl}/auth/refresh',
        data: {'refresh_token': refresh},
      );

      final newToken = res.data['access_token'] as String?;
      if (newToken == null) return null;

      await SecureStorageService.instance.write(
        StorageKeys.authToken,
        newToken,
      );

      // Retry original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      return await dio.fetch(err.requestOptions);
    } catch (_) {
      return null;
    }
  }
}

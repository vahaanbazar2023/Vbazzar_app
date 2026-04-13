import 'package:dio/dio.dart';
import '../../../config/env.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/retry_interceptor.dart';

class DioClient {
  DioClient._();

  static late final Dio _dio;

  static Dio get instance => _dio;

  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.current.baseUrl,
        connectTimeout: Duration(milliseconds: Env.current.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: Env.current.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': Env.current.apiKey,
        },
      ),
    );

    // Log the base URL being used
    print('🌐 DioClient initialized with baseUrl: ${Env.current.baseUrl}');

    _dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(dio: _dio),
      LoggingInterceptor(),
    ]);
  }
}

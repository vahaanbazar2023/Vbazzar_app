import 'package:dio/dio.dart' hide Response, FormData;
import 'package:dio/dio.dart' as dio show Response, FormData;
import 'package:get/get.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_storage_service.dart';
import '../storage/storage_keys.dart';
import 'api_constants.dart';

class NetworkService extends GetxService {
  static NetworkService get to {
    try {
      return Get.find<NetworkService>();
    } catch (e) {
      // If not found, register it now and return
      print('⚠️ NetworkService not found - registering now as fallback');
      final service = NetworkService();
      Get.put<NetworkService>(service, permanent: true);
      print('✅ NetworkService registered via fallback');
      return service;
    }
  }

  late final Dio _dio;

  String get baseUrl => ApiConstants.baseUrl;

  NetworkService() {
    _initializeDio();
  }

  @override
  void onInit() {
    super.onInit();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': ApiConstants.apiKey,
        },
      ),
    );
    _setupInterceptors();
    print('🌐 NetworkService initialized with baseUrl: $baseUrl');
  }

  /// Get all secured API paths that require authentication
  List<String> get _securedPaths => [
    // Dashboard endpoints
    '/api/v1/dashboard/profile',
    '/api/v1/dashboard/profile-update',
    '/api/v1/dashboard/change-password',
    '/api/v1/dashboard/categories-home',
    '/api/v1/dashboard/auction-refund-initiate',
    '/api/v1/dashboard/categories-home',
    '/api/v1/auth/refresh-token',
    '/api/v1/auth/verify-otp',

    // Auction endpoints
    '/api/v1/auctions/auction-listings-pagination',
    '/api/v1/auctions/auction-listings',
    '/api/v1/auctions/vehicle-listings',
    '/api/v1/auctions/vehicle-listings-pagination',
    '/api/v1/auctions/auction-vehicle-bid',
    '/api/v1/auctions/auction-my-bids',
    '/api/v1/auctions/auction-my-wins',
    '/api/v1/auctions/winning-letter',
    '/api/v1/auctions/update-insurance-interest',
    '/api/v1/auctions/vehicle-search',
    '/api/v1/auctions/vehicle-excel-download',
    '/api/v1/approved-veh/appr-veh-categories',
    '/api/v1/approved-veh/appr-veh-listings',
    '/api/v1/approved-veh/appr-veh-submit',
    '/api/v1/approved-veh/appr-veh-user-interest',

    // Subscription endpoints
    '/api/v1/subscription/subscription-listing',
    '/api/v1/subscription/my-subscriptions',
    '/api/v1/subscription/profile-subscription-categories',

    // Location endpoints that require authentication
    '/api/v1/locations/regions',

    // Payment endpoints
    '/api/v1/payments/initiate',
    '/api/v1/payments/status',
    '/api/v1/payments/',
    '/api/v1/payments/success',
    '/api/v1/payments/failure',

    // Legacy paths for backward compatibility
    '/profile',
    '/api/v1/dashboard/',

    // Buy and Sell
    '/api/v1/sell-buy/vehicle-categories',
    '/api/v1/sell-buy/vehicle-brands',
    '/api/v1/sell-buy/vehicle-listings',
    '/api/v1/sell-buy/tyres',
    '/api/v1/sell-buy/sell-vehicle',
    '/api/v1/sell-buy/list-sell-vehicles',
    '/api/v1/sell-buy/update-sell-vehicles',
    '/api/v1/sell-buy/list-buy-vehicles',
    '/api/v1/sell-buy/list-buy-subscribed-vehicles',
    '/api/v1/sell-buy/vehical-category-form-fields',
    '/api/v1/sell-buy/vehical-category-filters',
    '/api/v1/sell-buy/vehical-category-list-by-filters',
    '/api/v1/sell-buy/vehicle-category-form-fields',
    '/api/v1/sell-buy/vehicle-category-filters',
    '/api/v1/sell-buy/vehicle-category-list-by-filters',
    '/api/v1/sell-buy/sb-vehicle-sold',
    '/api/v1/sell-buy/user-interest',

    // Payment v2
    '/api/v2/payments/initiate',
    '/api/v2/payments/',
    '/api/v2/payments/success',
    '/api/v2/payments/failure',
    '/api/v2/payments/get-checkout-details',

    // Auth v2
    '/api/v2/auth/complete-profile',

    // Insurance and Finance
    '/api/v1/insurance-finance/insurance-request',
    '/api/v1/insurance-finance/finance-request',
    '/api/v1/insurance-finance/vehicle-listings-quotes',

    // Inspection and valuation
    '/api/v1/inspection-valuation/my-inspections',
    '/api/v1/inspection-valuation/agent-valuation-form',
    '/api/v1/inspection-valuation/customer-inspection-form',
    '/api/v1/inspection-valuation/valuation-dropdown-options',
    '/api/v1/service-support/list-mechanics',
    '/api/v1/service-support/user-mechanic-subscription',

    // Spare parts
    '/api/v1/spares-fms/list-spares',
    '/api/v1/spares-fms/user-spare-interest',
    '/api/v1/spares-fms/list-shops',
    '/api/v1/spares-fms/user-shop-subscription',
    '/api/v1/spares-fms/user-spares-orders-listing',
  ];

  /// Check if a path requires authentication
  bool _requiresAuthentication(String path) {
    for (int i = 0; i < _securedPaths.length; i++) {
      final securedPath = _securedPaths[i];
      final containsMatch = path.contains(securedPath);
      final startsWithMatch = path.startsWith(securedPath);
      final matches = containsMatch || startsWithMatch;

      if (matches) {
        return true;
      }
    }
    return false;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if this is a secured path
          bool isSecuredPath = _requiresAuthentication(options.path);

          if (isSecuredPath) {
            try {
              String? token = await SecureStorageService.to.read(
                StorageKeys.authToken,
              );

              print('🔑 Secured path: ${options.path}');
              print(
                '🔑 Token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}',
              );

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
                print('✅ Authorization header added');
              } else {
                print('⚠️ No token found for secured path');
              }
            } catch (e) {
              print('❌ Error getting token: $e');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ Response ${response.statusCode}: ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          print(
            '❌ Error ${error.response?.statusCode}: ${error.requestOptions.path}',
          );

          if (error.response?.statusCode == 401) {
            // Check if this is a logout API call - don't handle 401 for logout
            final requestPath = error.requestOptions.path;
            if (!requestPath.contains('/api/v1/auth/logout')) {
              await _handleUnauthorized();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    final currentRoute = Get.currentRoute;
    const authRoutes = [
      '/login',
      '/login-with-otp',
      '/login-username',
      '/register',
      '/verify-otp',
      '/splash',
    ];

    if (authRoutes.contains(currentRoute)) {
      return;
    }

    print('🔒 401 Unauthorized detected - handling session expired');

    // Try to get AuthController and handle session expired
    try {
      if (Get.isRegistered<dynamic>(tag: 'AuthController')) {
        // AuthController exists, perform fallback
        await _handleSessionExpiredFallback();
      } else {
        await _handleSessionExpiredFallback();
      }
    } catch (e) {
      print(
        '🔒 AuthController not found, performing fallback session expired handling',
      );
      await _handleSessionExpiredFallback();
    }
  }

  Future<void> _handleSessionExpiredFallback() async {
    await SecureStorageService.to.delete(StorageKeys.authToken);
    await SecureStorageService.to.delete(StorageKeys.refreshToken);
    LocalStorageService.to.setBool('is_logged_in', false);

    Get.snackbar(
      'Session Expired',
      'Please login again to continue',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
    );

    Get.offAllNamed('/login-with-otp');
  }

  // ═══════════════════════════════════════════════════════════════
  // HTTP Methods
  // ═══════════════════════════════════════════════════════════════

  Future<dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<dio.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<dio.Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<dio.Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<dio.Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<dio.Response<T>> upload<T>(
    String path,
    dio.FormData formData, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: options,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    print('🌐 Base URL updated to: $newBaseUrl');
  }

  void clearCache() {
    _dio.interceptors.clear();
    _setupInterceptors();
    print('🗑️ Interceptors cleared and reset');
  }

  Dio get dioInstance => _dio;
}

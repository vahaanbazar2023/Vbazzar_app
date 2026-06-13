import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/payment_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment service — handles /payments/initiate & /payments/success|failure
//
// IMPORTANT: All payment API calls use the PRODUCTION base URL
// (https://api.prod.vahaanbazar.in) regardless of the app's default
// NetworkService base URL (which may point to staging).
// ─────────────────────────────────────────────────────────────────────────────

class PaymentService {
  /// Production base URL for all payment API calls.
  static const String _paymentBaseUrl = 'https://api.staging.vahaanbazar.in';

  /// Production API key for payment endpoints.
  static const String _paymentApiKey = '7B9F2K4R1M6Q3P8D';

  /// Dedicated Dio instance for payment APIs, configured with the production
  /// base URL and production API key.
  late final Dio _paymentDio;

  PaymentService() {
    _paymentDio = _createPaymentDio();
  }

  /// Creates a dedicated Dio instance for payment API calls.
  ///
  /// This ensures payment endpoints always hit the production server,
  /// even when the rest of the app is configured for staging.
  Dio _createPaymentDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _paymentBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': _paymentApiKey,
        },
      ),
    );

    // Add auth token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await SecureStorageService.to.read(
              StorageKeys.authToken,
            );
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              debugPrint('💳 Payment API: Token added to Authorization header');
            } else {
              debugPrint('⚠️ Payment API: No auth token found');
            }
          } catch (e) {
            debugPrint('⚠️ Payment API: Could not get auth token: $e');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ Payment API Response ${response.statusCode}: ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ Payment API Error ${error.response?.statusCode}: ${error.requestOptions.uri}',
          );
          handler.next(error);
        },
      ),
    );

    debugPrint('💳 PaymentService initialized with baseUrl: $_paymentBaseUrl');
    return dio;
  }

  /// Safely converts any dynamic response to Map<String, dynamic>.
  /// Dio may return Map<dynamic, dynamic> depending on content-type.
  Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    return {};
  }

  // ── Initiate payment ──────────────────────────────────────────────────────
  Future<InitiatePaymentRes> initiatePayment(InitiatePaymentReq req) async {
    try {
      debugPrint(
        '💳 Payment API: Initiating payment with request: ${req.toJson()}',
      );
      debugPrint(
        '💳 Payment API: Full URL: $_paymentBaseUrl${ApiEndpoints.paymentInitiate}',
      );

      final response = await _paymentDio.post(
        ApiEndpoints.paymentInitiate,
        data: req.toJson(),
      );

      debugPrint('📦 /payments/initiate raw response: ${response.data}');
      debugPrint('📦 response.data type: ${response.data.runtimeType}');
      return InitiatePaymentRes.fromJson(_safeMap(response.data));
    } on DioException catch (e) {
      debugPrint('❌ /payments/initiate DioException: ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ??
                'Payment initiation failed')
          : 'Payment initiation failed';
      return InitiatePaymentRes(
        status: 'error',
        code: e.response?.statusCode ?? 500,
        message: msg,
      );
    } catch (e) {
      debugPrint('❌ initiatePayment unexpected error: $e');
      return InitiatePaymentRes(
        status: 'error',
        code: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  // ── Report payment success to backend ─────────────────────────────────────
  Future<InitiatePaymentRes> reportPaymentSuccess(
    PaymentStatusCallback callback,
  ) async {
    try {
      debugPrint(
        '💳 Payment API: Reporting success for txnId: ${callback.txnId}',
      );
      debugPrint(
        '💳 Payment API: Full URL: $_paymentBaseUrl${ApiEndpoints.paymentSuccess}',
      );

      final response = await _paymentDio.post(
        ApiEndpoints.paymentSuccess,
        data: callback.toJson(),
      );
      return InitiatePaymentRes.fromJson(_safeMap(response.data));
    } on DioException catch (e) {
      debugPrint('❌ /payments/success DioException: ${e.message}');
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ??
                'Payment success report failed')
          : 'Payment success report failed';
      return InitiatePaymentRes(
        status: 'error',
        code: e.response?.statusCode ?? 500,
        message: msg,
      );
    } catch (e) {
      return InitiatePaymentRes(
        status: 'error',
        code: 500,
        message: 'Unexpected error: $e',
      );
    }
  }

  // ── Report payment failure to backend ─────────────────────────────────────
  Future<InitiatePaymentRes> reportPaymentFailure(
    PaymentStatusCallback callback,
  ) async {
    try {
      debugPrint(
        '💳 Payment API: Reporting failure for txnId: ${callback.txnId}',
      );
      debugPrint(
        '💳 Payment API: Full URL: $_paymentBaseUrl${ApiEndpoints.paymentFailure}',
      );

      final response = await _paymentDio.post(
        ApiEndpoints.paymentFailure,
        data: callback.toJson(),
      );
      return InitiatePaymentRes.fromJson(_safeMap(response.data));
    } on DioException catch (e) {
      debugPrint('❌ /payments/failure DioException: ${e.message}');
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ??
                'Payment failure report failed')
          : 'Payment failure report failed';
      return InitiatePaymentRes(
        status: 'error',
        code: e.response?.statusCode ?? 500,
        message: msg,
      );
    } catch (e) {
      return InitiatePaymentRes(
        status: 'error',
        code: 500,
        message: 'Unexpected error: $e',
      );
    }
  }
}

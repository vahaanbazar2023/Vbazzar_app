import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/api/api_constant.dart';
import '../../../core/services/network_service.dart';
import '../models/initiate_payment_model.dart';
import '../models/payment_status_callback.dart';

class PaymentApiService {
  static NetworkService get _networkService => Get.find<NetworkService>();

  static Future<InitiatePaymentRes> initiatePayment(
    InitiatePaymentReq request,
  ) async {
    try {
      print(
        '🚀 Payment API: Initiating payment with request: ${request.toJson()}',
      );

      final response = await _networkService.post(
        ApiConstants.paymentInitiateEndpoint,
        data: request.toJson(),
      );

      print('🚀 Payment API: Initiation response received: ${response.data}');

      final result = InitiatePaymentRes.fromJson(response.data);

      if (result.status != 'success') {
        print(
          '❌ Payment API: Initiation failed with status: ${result.status}, message: ${result.message}',
        );
      } else {
        print('✅ Payment API: Initiation successful');
      }

      return result;
    } catch (e) {
      print('❌ Payment API: Initiation error: $e');
      throw Exception('Payment initiation failed: $e');
    }
  }

  static Future<PaymentStatusCallbackRes> notifyPaymentSuccess(
    PaymentStatusCallback callback,
  ) async {
    try {
      final requestData = callback.toJson();

      final response = await _networkService.post(
        ApiConstants.paymentSuccessEndpoint,
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return PaymentStatusCallbackRes.fromJson(response.data);
    } catch (e) {
      throw Exception('Payment success notification failed: $e');
    }
  }

  static Future<PaymentStatusCallbackRes> notifyPaymentFailure(
    PaymentStatusCallback callback,
  ) async {
    try {
      final requestData = callback.toJson();

      final response = await _networkService.post(
        ApiConstants.paymentFailureEndpoint,
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return PaymentStatusCallbackRes.fromJson(response.data);
    } catch (e) {
      throw Exception('Payment failure notification failed: $e');
    }
  }
}

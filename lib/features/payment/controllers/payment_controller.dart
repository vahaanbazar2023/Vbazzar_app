import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import '../config/payu_config.dart';
import '../models/payment_models.dart';
import '../services/hash_service.dart';
import '../services/payment_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment controller — orchestrates PayU SDK checkout flow
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentStatus { idle, initiating, processing, success, failed, cancelled }

class PaymentController extends GetxController
    implements PayUCheckoutProProtocol {
  final PaymentService _service = PaymentService();

  // ── Observable state ──────────────────────────────────────────────────────
  final status = PaymentStatus.idle.obs;
  final errorMessage = ''.obs;
  final paymentData = Rxn<PaymentData>();

  // ── PayU SDK instance ─────────────────────────────────────────────────────
  late PayUCheckoutProFlutter _checkoutPro;

  // ── Completer for awaiting payment result ─────────────────────────────────
  Completer<bool>? _paymentCompleter;

  // ── Callbacks (set by caller before initiating) ───────────────────────────
  void Function(PaymentData data, PaymentStatusCallback callback)? onSuccess;
  void Function(String message, PaymentStatusCallback? callback)? onFailure;
  void Function()? onCancelled;

  @override
  void onInit() {
    super.onInit();
    _checkoutPro = PayUCheckoutProFlutter(this);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Initiates payment via backend, then opens PayU checkout.
  /// Returns true on success, false on failure/cancel.
  Future<bool> initiatePayment({
    required String userId,
    required String planCode,
    double? fromWallet,
    double? forPayment,
    String? referralCode,
  }) async {
    try {
      status.value = PaymentStatus.initiating;
      errorMessage.value = '';

      final req = InitiatePaymentReq(
        userId: userId,
        planCode: planCode,
        fromWallet: fromWallet,
        forPayment: forPayment,
        referralCode: referralCode,
      );

      final res = await _service.initiatePayment(req);

      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('📥 Initiate Payment API Response:');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('  Status: ${res.status}');
      debugPrint('  Code: ${res.code}');
      debugPrint('  Message: ${res.message}');
      if (res.data != null) {
        debugPrint('  TxnId: ${res.data!.txnId}');
        debugPrint('  Merchant Key: ${res.data!.merchantKey}');
        debugPrint('  Salt Key: ${res.data!.saltKey}');
        final formData = res.data!.payuFormData;
        debugPrint('  ── PayU Form Data ──');
        debugPrint('    key: ${formData.key}');
        debugPrint('    txnId: ${formData.txnId}');
        debugPrint('    amount: ${formData.amount}');
        debugPrint('    productInfo: ${formData.productInfo}');
        debugPrint('    firstname: ${formData.firstname}');
        debugPrint('    email: ${formData.email}');
        debugPrint('    phone: ${formData.phone}');
        debugPrint('    surl: ${formData.surl}');
        debugPrint('    furl: ${formData.furl}');
        debugPrint('    hash: ${formData.hash}');
        debugPrint('    udf1: ${formData.udf1}');
        debugPrint('    udf2: ${formData.udf2}');
        debugPrint('    udf3: ${formData.udf3}');
        debugPrint('    udf4: ${formData.udf4}');
        debugPrint('    udf5: ${formData.udf5}');
      }
      debugPrint('═══════════════════════════════════════════════════');

      if (!res.isSuccess || res.data == null) {
        status.value = PaymentStatus.failed;
        errorMessage.value = res.message;
        debugPrint('❌ Initiate Payment FAILED: ${res.message}');
        onFailure?.call(res.message, null);
        return false;
      }

      paymentData.value = res.data;

      // Configure PayUConfig with API-returned credentials
      PayUConfig.setMerchantKey(res.data!.merchantKey);
      PayUConfig.setSaltKey(res.data!.saltKey);
      HashService.merchantSalt = res.data!.saltKey;

      status.value = PaymentStatus.processing;

      // Build PayU payment params using SDK constant keys (matching working code)
      final payuParams = _buildPayUParams(res.data!);
      final payuConfig = _buildPayUConfig();

      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('📤 PayU Request Parameters:');
      debugPrint('═══════════════════════════════════════════════════');
      payuParams.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('═══════════════════════════════════════════════════');

      _paymentCompleter = Completer<bool>();

      await _checkoutPro.openCheckoutScreen(
        payUPaymentParams: payuParams,
        payUCheckoutProConfig: payuConfig,
      );

      return await _paymentCompleter!.future;
    } catch (e) {
      debugPrint('❌ PAYMENT ERROR: $e');
      status.value = PaymentStatus.failed;
      errorMessage.value = e.toString();
      onFailure?.call(e.toString(), null);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build PayU params using SDK constant keys (matches working code)
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _buildPayUParams(PaymentData data) {
    final formData = data.payuFormData;

    // Additional parameters (UDFs)
    final additionalParam = {
      PayUAdditionalParamKeys.udf1: formData.udf1,
      PayUAdditionalParamKeys.udf2: formData.udf2,
      PayUAdditionalParamKeys.udf3: formData.udf3,
      PayUAdditionalParamKeys.udf4: formData.udf4,
      PayUAdditionalParamKeys.udf5: formData.udf5,
    };

    // PayU SDK environment: "0" = Production, "1" = Test
    final environment = PayUConfig.isProduction ? "0" : "1";

    final params = <String, dynamic>{
      PayUPaymentParamKey.key: formData.key,
      PayUPaymentParamKey.amount: formData.amount,
      PayUPaymentParamKey.productInfo: formData.productInfo,
      PayUPaymentParamKey.firstName: formData.firstname,
      PayUPaymentParamKey.email: formData.email,
      PayUPaymentParamKey.phone: formData.phone,
      PayUPaymentParamKey.ios_surl: formData.surl,
      PayUPaymentParamKey.ios_furl: formData.furl,
      PayUPaymentParamKey.android_surl: formData.surl,
      PayUPaymentParamKey.android_furl: formData.furl,
      PayUPaymentParamKey.environment: environment,
      "transactionId": formData.txnId,
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.enableNativeOTP: true,
    };

    // PayU SDK REQUIRES userCredential to always be present.
    // Omitting it causes "Card can not be stored!, user_credentials is missing!"
    // Format MUST be "merchantKey:userIdentifier" (colon-separated).
    final email = formData.email;
    final phone = formData.phone;
    if (email.isNotEmpty) {
      params[PayUPaymentParamKey.userCredential] = '${formData.key}:$email';
    } else if (phone.isNotEmpty) {
      params[PayUPaymentParamKey.userCredential] = '${formData.key}:$phone';
    } else {
      // Fallback: use merchant key + txnId as unique user credential
      params[PayUPaymentParamKey.userCredential] =
          '${formData.key}:${formData.txnId}';
    }

    debugPrint(
      '🔧 PayU Environment: $environment (${PayUConfig.isProduction ? "PRODUCTION" : "TEST"})',
    );
    debugPrint('🔧 Merchant Key: ${formData.key}');
    debugPrint('🔧 Active Salt: ${PayUConfig.saltKey}');

    return params;
  }

  Map<String, dynamic> _buildPayUConfig() {
    final paymentModesOrder = [
      {"Wallets": "PHONEPE"},
      {"UPI": "TEZ"},
      {"Wallets": ""},
      {"EMI": ""},
      {"NetBanking": ""},
    ];

    final cartDetails = [
      {"GST": "5%"},
      {"Delivery Date": "25 Dec"},
      {"Status": "In Progress"},
    ];

    final customNotes = [
      {
        "custom_note": "Secure payment powered by PayU",
        "custom_note_category": [
          PayUPaymentTypeKeys.emi,
          PayUPaymentTypeKeys.card,
        ],
      },
      {
        "custom_note": "Choose your preferred payment method",
        "custom_note_category": null,
      },
    ];

    return {
      PayUCheckoutProConfigKeys.primaryColor: '#FF5C00',
      PayUCheckoutProConfigKeys.secondaryColor: '#FFFFFF',
      PayUCheckoutProConfigKeys.merchantName: 'Vahaan Bazar',
      PayUCheckoutProConfigKeys.showMerchantLogo: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.autoSelectOtp: true,
      PayUCheckoutProConfigKeys.autoApprove: true,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.cartDetails: cartDetails,
      PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
      PayUCheckoutProConfigKeys.customNotes: customNotes,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PayUCheckoutProProtocol callbacks
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void generateHash(Map response) {
    // Use HashService to compute hash (matching working code pattern)
    Map hashResponse = HashService.generateHash(response);
    _checkoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  void onPaymentSuccess(dynamic response) {
    status.value = PaymentStatus.success;

    final responseData = _extractResponseData(response);
    final callback = _buildCallback(responseData, 'success');

    _service.reportPaymentSuccess(callback);
    onSuccess?.call(paymentData.value!, callback);

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(true);
    }
  }

  @override
  void onPaymentFailure(dynamic response) {
    status.value = PaymentStatus.failed;

    final responseData = _extractResponseData(response);
    final callback = _buildCallback(responseData, 'failure');

    errorMessage.value =
        responseData['error_Message'] as String? ?? 'Payment failed';
    _service.reportPaymentFailure(callback);
    onFailure?.call(errorMessage.value, callback);

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }
  }

  @override
  void onPaymentCancel(Map? response) {
    status.value = PaymentStatus.cancelled;
    errorMessage.value = 'Payment cancelled by user';
    onCancelled?.call();

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }
  }

  @override
  void onError(Map? response) {
    status.value = PaymentStatus.failed;
    final errorMsg = response?['error'] as String? ?? 'Unknown payment error';
    errorMessage.value = errorMsg;
    debugPrint('❌ PayU onError: $response');
    onFailure?.call(errorMessage.value, null);

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _extractResponseData(dynamic response) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    if (response is String) {
      final map = <String, dynamic>{};
      for (final pair in response.split('&')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          map[parts[0]] = Uri.decodeComponent(parts[1]);
        }
      }
      return map;
    }
    return {};
  }

  PaymentStatusCallback _buildCallback(
    Map<String, dynamic> data,
    String paymentStatus,
  ) {
    final formData = paymentData.value?.payuFormData;
    final amount = formData?.amount ?? '0';
    return PaymentStatusCallback(
      key: (data['key'] as String?) ?? PayUConfig.merchantKey,
      txnId: (data['txnid'] as String?) ?? paymentData.value?.txnId ?? '',
      amount: amount,
      productInfo: (data['productinfo'] as String?) ?? formData?.productInfo ?? '',
      firstname: (data['firstname'] as String?) ?? formData?.firstname ?? '',
      email: (data['email'] as String?) ?? formData?.email ?? '',
      phone: (data['phone'] as String?) ?? formData?.phone ?? '',
      paymentStatus: paymentStatus,
      hash: (data['hash'] as String?) ?? formData?.hash ?? '',
      mode: (data['mode'] as String?) ?? '',
      bankRef: (data['bankref'] as String?) ?? '',
      pgType: (data['PG_TYPE'] as String?) ?? '',
      bankRefNum: (data['bank_ref_num'] as String?) ?? '',
      mihpayid: (data['mihpayid'] as String?) ?? '',
      udf1: (data['udf1'] as String?) ?? formData?.udf1 ?? '',
      udf2: (data['udf2'] as String?) ?? formData?.udf2 ?? '',
      udf3: (data['udf3'] as String?) ?? formData?.udf3 ?? '',
      udf4: (data['udf4'] as String?) ?? formData?.udf4 ?? '',
      udf5: (data['udf5'] as String?) ?? formData?.udf5 ?? '',
      error: (data['error'] as String?) ?? '',
      errorMessage: (data['error_Message'] as String?) ?? '',
      bankcode: (data['bankcode'] as String?) ?? '',
      bankmessage: (data['bankcode'] as String?) ?? '',
      cardhash: (data['cardhash'] as String?) ?? '',
      cardnum: (data['cardnum'] as String?) ?? '',
      paymentSource: (data['payment_source'] as String?) ?? '',
      payuMoneyId: (data['payuMoneyId'] as String?) ?? '',
      status: (data['status'] as String?) ?? '',
      surl: (data['surl'] as String?) ?? formData?.surl ?? '',
      furl: (data['furl'] as String?) ?? formData?.furl ?? '',
    );
  }

  /// Reset state for reuse
  void reset() {
    status.value = PaymentStatus.idle;
    errorMessage.value = '';
    paymentData.value = null;
    _paymentCompleter = null;
    onSuccess = null;
    onFailure = null;
    onCancelled = null;
  }
}
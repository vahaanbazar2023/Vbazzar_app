import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import '../models/payment_models.dart';

/// PayU Configuration for Vahaan Bazar PayU SDK Payment Module
/// Contains all PayU SDK configuration and test data
class PayUConfig {
  // Static variables to hold merchantKey and saltKey, set from controller
  static String merchantKey = '';
  static String saltKey = '';

  // Setters for controller to assign values
  static void setMerchantKey(String key) {
    merchantKey = key;
  }

  static void setSaltKey(String salt) {
    saltKey = salt;
  }

  // Environment Configuration
  static const bool isProduction = true; // Always production

  // API Configuration
  static const String baseUrl = 'https://api.prod.vahaanbazar.in';

  static const merchantAccessKey = ""; // Add Merchant Access Key - Optional
  static const sodexoSourceId = ""; // Add sodexo Source Id - Optional

  // This should be loaded securely from environment or secure storage
  static const String apiKey = '7B0F2K4R1MSS3P0D'; // Production API Key

  // PayU Environment string (test/production)
  static String get environment =>
      isProduction ? '0' : '1'; // 0 = production, 1 = test

  // PayU Colors and Branding
  static const Map<String, String> payUColors = {
    'primaryColor': '#FF5C00',
    'secondaryColor': '#FFFFFF',
    'buttonColor': '#FF6B35',
    'buttonTextColor': '#FFFFFF',
  };

  // PayU Configuration Options
  static const Map<String, dynamic> payUOptions = {
    'showExitConfirmationOnCheckoutScreen': true,
    'showExitConfirmationOnPaymentScreen': true,
    'autoSelectOtp': true,
    'autoApprove': true,
    'merchantName': 'Vahaan Bazar',
    'merchantLogo': 'https://vahaanbazar.in/logo.png',
  };

  /// Get environment specific API key
  static String getApiKey() {
    return apiKey;
  }

  /// Get base URL for current environment
  static String getBaseUrl() {
    return baseUrl;
  }

  /// Create PayU Payment Parameters from PaymentData
  static Map<String, dynamic> createPayUPaymentParamsFromData(
    PaymentData data,
  ) {
    // Additional parameters from API response
    var additionalParam = {
      PayUAdditionalParamKeys.udf1: data.payuFormData.udf1,
      PayUAdditionalParamKeys.udf2: data.payuFormData.udf2,
      PayUAdditionalParamKeys.udf3: data.payuFormData.udf3,
      PayUAdditionalParamKeys.udf4: data.payuFormData.udf4,
      PayUAdditionalParamKeys.udf5: data.payuFormData.udf5,
    };

    var payUPaymentParams = {
      PayUPaymentParamKey.key: data.payuFormData.key,
      PayUPaymentParamKey.amount: data.payuFormData.amount,
      PayUPaymentParamKey.productInfo: data.payuFormData.productInfo,
      PayUPaymentParamKey.firstName: data.payuFormData.firstname,
      PayUPaymentParamKey.email: data.payuFormData.email,
      PayUPaymentParamKey.phone: data.payuFormData.phone,
      PayUPaymentParamKey.ios_surl: data.payuFormData.surl,
      PayUPaymentParamKey.ios_furl: data.payuFormData.furl,
      PayUPaymentParamKey.android_surl: data.payuFormData.surl,
      PayUPaymentParamKey.android_furl: data.payuFormData.furl,
      PayUPaymentParamKey.environment:
          "0", // Production environment
      PayUPaymentParamKey.userCredential: null, // null like working example
      "transactionId":
          data.payuFormData.txnId, // Use string key for transaction ID
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.enableNativeOTP: true,
    };

    return payUPaymentParams;
  }

  /// Create PayU Checkout Configuration
  static Map<String, dynamic> createPayUConfigParams() {
    var paymentModesOrder = [
      {"Wallets": "PHONEPE"},
      {"UPI": "TEZ"},
      {"Wallets": ""},
      {"EMI": ""},
      {"NetBanking": ""},
    ];

    var cartDetails = [
      {"GST": "5%"},
      {"Delivery Date": "25 Dec"},
      {"Status": "In Progress"},
    ];

    var customNotes = [
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

    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: payUColors['primaryColor'],
      PayUCheckoutProConfigKeys.secondaryColor: payUColors['secondaryColor'],
      PayUCheckoutProConfigKeys.merchantName: payUOptions['merchantName'],
      PayUCheckoutProConfigKeys.showMerchantLogo: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen:
          payUOptions['showExitConfirmationOnCheckoutScreen'],
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen:
          payUOptions['showExitConfirmationOnPaymentScreen'],
      PayUCheckoutProConfigKeys.cartDetails: cartDetails,
      PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.customNotes: customNotes,
      PayUCheckoutProConfigKeys.autoSelectOtp: payUOptions['autoSelectOtp'],
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.autoApprove: payUOptions['autoApprove'],
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
    };

    return payUCheckoutProConfig;
  }

  /// Generate unique transaction ID
  static String generateTransactionId({String? prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0');
    final txnId = '${prefix ?? 'VB'}_${timestamp}_$randomSuffix';
    return txnId;
  }

  /// Check if environment is production
  static bool isProductionEnvironment() {
    return isProduction;
  }
}
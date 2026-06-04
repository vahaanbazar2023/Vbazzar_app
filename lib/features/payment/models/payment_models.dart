// ─────────────────────────────────────────────────────────────────────────────
// Payment initiation request / response models
// ─────────────────────────────────────────────────────────────────────────────

class InitiatePaymentReq {
  final String userId;
  final String planCode;
  final double? fromWallet;
  final double? forPayment;
  final String? referralCode;

  const InitiatePaymentReq({
    required this.userId,
    required this.planCode,
    this.fromWallet,
    this.forPayment,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'plan_code': planCode,
    };
    if (fromWallet != null && fromWallet! > 0) {
      map['from_wallet'] = fromWallet;
    }
    if (forPayment != null) {
      map['for_payment'] = forPayment;
    }
    if (referralCode != null && referralCode!.isNotEmpty) {
      map['referral_code'] = referralCode;
    }
    return map;
  }
}

class InitiatePaymentRes {
  final String status;
  final int code;
  final String message;
  final PaymentData? data;

  const InitiatePaymentRes({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  /// Safely converts any dynamic map to Map<String, dynamic>.
  static Map<String, dynamic> _safeMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  /// Safely converts any value to String.
  static String _safeString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  /// Safely converts any value to int.
  static int _safeInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory InitiatePaymentRes.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentRes(
      status: _safeString(json['status']),
      code: _safeInt(json['code']),
      message: _safeString(json['message']),
      data: json['data'] != null
          ? PaymentData.fromJson(_safeMap(json['data']))
          : null,
    );
  }

  bool get isSuccess => status == 'success' && data != null;
}

class PaymentData {
  final String paymentId;
  final String txnId;
  final PayuFormData payuFormData;
  final String paymentUrl;
  final String merchantKey;
  final String saltKey;

  const PaymentData({
    required this.paymentId,
    required this.txnId,
    required this.payuFormData,
    required this.paymentUrl,
    required this.merchantKey,
    required this.saltKey,
  });

  /// Safely converts any dynamic map to Map<String, dynamic>.
  static Map<String, dynamic> _safeMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  /// Safely converts any value to String.
  static String _safeString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentId: _safeString(json['payment_id']),
      txnId: _safeString(json['txn_id']),
      payuFormData: PayuFormData.fromJson(_safeMap(json['payu_form_data'])),
      paymentUrl: _safeString(json['payment_url']),
      merchantKey: _safeString(json['merchant_key']),
      saltKey: _safeString(json['salt_key']),
    );
  }
}

class PayuFormData {
  final String key;
  final String txnId;
  final String amount;
  final String productInfo;
  final String firstname;
  final String email;
  final String phone;
  final String surl;
  final String furl;
  final String serviceProvider;
  final String udf1;
  final String udf2;
  final String udf3;
  final String udf4;
  final String udf5;
  final String hash;

  const PayuFormData({
    required this.key,
    required this.txnId,
    required this.amount,
    required this.productInfo,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.surl,
    required this.furl,
    required this.serviceProvider,
    required this.udf1,
    required this.udf2,
    required this.udf3,
    required this.udf4,
    required this.udf5,
    required this.hash,
  });

  /// Safely converts any value to String.
  static String _safeString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  factory PayuFormData.fromJson(Map<String, dynamic> json) {
    return PayuFormData(
      key: _safeString(json['key']),
      txnId: _safeString(json['txnid']),
      amount: _safeString(json['amount'], '0'),
      productInfo: _safeString(json['productinfo']),
      firstname: _safeString(json['firstname']),
      email: _safeString(json['email']),
      phone: _safeString(json['phone']),
      surl: _safeString(json['surl']),
      furl: _safeString(json['furl']),
      serviceProvider: _safeString(json['service_provider'], 'payu_paisa'),
      udf1: _safeString(json['udf1']),
      udf2: _safeString(json['udf2']),
      udf3: _safeString(json['udf3']),
      udf4: _safeString(json['udf4']),
      udf5: _safeString(json['udf5']),
      hash: _safeString(json['hash']),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment callback model (sent to backend after PayU returns)
// ─────────────────────────────────────────────────────────────────────────────

class PaymentStatusCallback {
  final String key;
  final String txnId;
  final String amount;
  final String productInfo;
  final String firstname;
  final String email;
  final String phone;
  final String paymentStatus;
  final String hash;
  final String mode;
  final String bankRef;
  final String pgType;
  final String bankRefNum;
  final String mihpayid;
  final String udf1;
  final String udf2;
  final String udf3;
  final String udf4;
  final String udf5;
  final String error;
  final String errorMessage;
  final String bankcode;
  final String bankmessage;
  final String cardhash;
  final String cardnum;
  final String paymentSource;
  final String payuMoneyId;
  final String status;
  final String surl;
  final String furl;

  const PaymentStatusCallback({
    required this.key,
    required this.txnId,
    required this.amount,
    required this.productInfo,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.paymentStatus,
    required this.hash,
    this.mode = '',
    this.bankRef = '',
    this.pgType = '',
    this.bankRefNum = '',
    this.mihpayid = '',
    this.udf1 = '',
    this.udf2 = '',
    this.udf3 = '',
    this.udf4 = '',
    this.udf5 = '',
    this.error = '',
    this.errorMessage = '',
    this.bankcode = '',
    this.bankmessage = '',
    this.cardhash = '',
    this.cardnum = '',
    this.paymentSource = '',
    this.payuMoneyId = '',
    this.status = '',
    this.surl = '',
    this.furl = '',
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'txnid': txnId,
      'amount': amount,
      'productinfo': productInfo,
      'firstname': firstname,
      'email': email,
      'phone': phone,
      'payment_status': paymentStatus,
      'hash': hash,
      'mode': mode,
      'bankcode': bankcode,
      'bankmessage': bankmessage,
      'cardhash': cardhash,
      'cardnum': cardnum,
      'PG_TYPE': pgType,
      'bank_ref_num': bankRefNum,
      'mihpayid': mihpayid,
      'bankref': bankRef,
      'payment_source': paymentSource,
      'payuMoneyId': payuMoneyId,
      'status': status,
      'error': error,
      'error_Message': errorMessage,
      'udf1': udf1,
      'udf2': udf2,
      'udf3': udf3,
      'udf4': udf4,
      'udf5': udf5,
      'surl': surl,
      'furl': furl,
    };
  }
}

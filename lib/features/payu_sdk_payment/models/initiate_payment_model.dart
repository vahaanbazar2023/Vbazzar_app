class InitiatePaymentReq {
  final String userId;
  final String planCode;

  InitiatePaymentReq({required this.userId, required this.planCode});

  Map<String, dynamic> toJson() {
    return {"user_id": userId, "plan_code": planCode};
  }

  factory InitiatePaymentReq.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentReq(
      userId: json["user_id"] ?? "",
      planCode: json["plan_code"] ?? "",
    );
  }
}

class InitiatePaymentRes {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final PaymentData? data;
  final dynamic error;

  InitiatePaymentRes({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  // Add success getter for backward compatibility
  bool get success => status == "success" && code == 200;

  factory InitiatePaymentRes.fromJson(Map<String, dynamic> json) {
    return InitiatePaymentRes(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      timestamp: json["timestamp"] ?? "",
      data: json["data"] != null ? PaymentData.fromJson(json["data"]) : null,
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "timestamp": timestamp,
      "data": data?.toJson(),
      "error": error,
    };
  }
}

class PaymentData {
  final String paymentId;
  final String txnId;
  final PayuFormData payuFormData;
  final String paymentUrl;
  final String merchantKey;
  final String saltKey;

  PaymentData({
    required this.paymentId,
    required this.txnId,
    required this.payuFormData,
    required this.paymentUrl,
    required this.merchantKey,
    required this.saltKey,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentId: json["payment_id"] ?? "",
      txnId: json["txn_id"] ?? "",
      payuFormData: PayuFormData.fromJson(json["payu_form_data"]),
      paymentUrl: json["payment_url"] ?? "",
      merchantKey: json["merchant_key"] ?? "",
      saltKey: json["salt_key"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "payment_id": paymentId,
      "txn_id": txnId,
      "payu_form_data": payuFormData.toJson(),
      "payment_url": paymentUrl,
      "merchant_key": merchantKey,
      "salt_key": saltKey,
    };
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

  PayuFormData({
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

  factory PayuFormData.fromJson(Map<String, dynamic> json) {
    return PayuFormData(
      key: json["key"] ?? "",
      txnId: json["txnid"] ?? "",
      amount: json["amount"] ?? "",
      productInfo: json["productinfo"] ?? "",
      firstname: json["firstname"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      surl: json["surl"] ?? "",
      furl: json["furl"] ?? "",
      serviceProvider: json["service_provider"] ?? "",
      udf1: json["udf1"] ?? "",
      udf2: json["udf2"] ?? "",
      udf3: json["udf3"] ?? "",
      udf4: json["udf4"] ?? "",
      udf5: json["udf5"] ?? "",
      hash: json["hash"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "txnid": txnId,
      "amount": amount,
      "productinfo": productInfo,
      "firstname": firstname,
      "email": email,
      "phone": phone,
      "surl": surl,
      "furl": furl,
      "service_provider": serviceProvider,
      "udf1": udf1,
      "udf2": udf2,
      "udf3": udf3,
      "udf4": udf4,
      "udf5": udf5,
      "hash": hash,
    };
  }
}
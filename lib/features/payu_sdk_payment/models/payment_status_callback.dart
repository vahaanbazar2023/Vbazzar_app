class PaymentStatusCallback {
  final String key;
  final String txnid;
  final String amount;
  final String productinfo;
  final String firstname;
  final String email;
  final String phone;
  final String paymentStatus;
  final String hash;

  // Optional values (nullable, can be empty string too)
  final String? mode;
  final String? bankref;
  final String? pgType;
  final String? bankRefNum;
  final String? mihpayid;
  final String? udf1;
  final String? udf2;
  final String? udf3;
  final String? udf4;
  final String? udf5;
  final String? error;
  final String? errorMessage;
  final String?
  chasisNumber; // Additional field for customer subscription plans

  PaymentStatusCallback({
    required this.key,
    required this.txnid,
    required this.amount,
    required this.productinfo,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.paymentStatus,
    required this.hash,
    this.mode,
    this.bankref,
    this.pgType,
    this.bankRefNum,
    this.mihpayid,
    this.udf1,
    this.udf2,
    this.udf3,
    this.udf4,
    this.udf5,
    this.error,
    this.errorMessage,
    this.chasisNumber,
  });

  factory PaymentStatusCallback.fromJson(Map<String, dynamic> json) {
    return PaymentStatusCallback(
      key: json["key"] ?? "",
      txnid: json["txnid"] ?? "",
      amount: json["amount"] ?? "",
      productinfo: json["productinfo"] ?? "",
      firstname: json["firstname"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      paymentStatus: json["payment_status"] ?? "",
      hash: json["hash"] ?? "",
      mode: json["mode"],
      bankref: json["bankref"],
      pgType: json["PG_TYPE"],
      bankRefNum: json["bank_ref_num"],
      mihpayid: json["mihpayid"],
      udf1: json["udf1"],
      udf2: json["udf2"],
      udf3: json["udf3"],
      udf4: json["udf4"],
      udf5: json["udf5"],
      error: json["error"],
      errorMessage: json["error_Message"],
      chasisNumber: json["chasis_number"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "txnid": txnid,
      "amount": amount,
      "productinfo": productinfo,
      "firstname": firstname,
      "email": email,
      "phone": phone,
      "payment_status": paymentStatus,
      "hash": hash,
      "mode": mode ?? "",
      "bankref": bankref ?? "",
      "PG_TYPE": pgType ?? "",
      "bank_ref_num": bankRefNum ?? "",
      "mihpayid": mihpayid ?? "",
      "udf1": udf1 ?? "",
      "udf2": udf2 ?? "",
      "udf3": udf3 ?? "",
      "udf4": udf4 ?? "",
      "udf5": udf5 ?? "",
      "error": error ?? "",
      "error_Message": errorMessage ?? "",
      "chasis_number": chasisNumber ?? "",
    };
  }
}

class PaymentStatusCallbackRes {
  final bool success;
  final String message;
  final String paymentId;
  final String transactionStatus;

  PaymentStatusCallbackRes({
    required this.success,
    required this.message,
    required this.paymentId,
    required this.transactionStatus,
  });

  factory PaymentStatusCallbackRes.fromJson(Map<String, dynamic> json) {
    return PaymentStatusCallbackRes(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      paymentId: json["payment_id"] ?? "",
      transactionStatus: json["transaction_status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "payment_id": paymentId,
      "transaction_status": transactionStatus,
    };
  }
}
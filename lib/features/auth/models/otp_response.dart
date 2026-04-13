/// V2 Login response — returned from POST /api/v2/auth/login
class OtpResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final OtpData? data;
  final dynamic error;

  const OtpResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      data: json['data'] != null
          ? OtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

/// V2 OTP data from login response
class OtpData {
  final String userId;
  final String transactionId;
  final String message;
  final bool isNewUser;

  const OtpData({
    required this.userId,
    required this.transactionId,
    required this.message,
    required this.isNewUser,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      userId: json['user_id'] as String? ?? '',
      transactionId: json['transaction_id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}

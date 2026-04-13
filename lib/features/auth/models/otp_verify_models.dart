/// V2 OTP Verification Request — POST /api/v2/auth/verify-otp
class OtpVerifyRequest {
  final String userId;
  final String phoneNumber;
  final String otpCode;
  final String transactionId;
  final String? fcmToken;

  const OtpVerifyRequest({
    required this.userId,
    required this.phoneNumber,
    required this.otpCode,
    required this.transactionId,
    this.fcmToken,
  });

  bool isValid() {
    return userId.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        otpCode.isNotEmpty &&
        transactionId.isNotEmpty &&
        otpCode.length >= 4 &&
        otpCode.length <= 8;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'phone_number': phoneNumber,
      'otp_code': otpCode,
      'transaction_id': transactionId,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken!;
    }
    return json;
  }

  @override
  String toString() =>
      'OtpVerifyRequest(userId: $userId, phone: ${_mask(phoneNumber)}, txId: $transactionId)';

  String _mask(String s) {
    if (s.length <= 4) return '****';
    return '${s.substring(0, 2)}****${s.substring(s.length - 2)}';
  }
}

/// V2 OTP Verification Response — wraps the full API envelope
class OtpVerifyResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final OtpVerifyData? data;
  final dynamic error;

  const OtpVerifyResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200 && data != null;

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      data: json['data'] != null
          ? OtpVerifyData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

/// Data payload from V2 verify-otp response
class OtpVerifyData {
  final String userId;
  final String token;
  final String tokenType;
  final int? expiresIn;
  final String userType;
  final bool isNewUser;
  final bool profileCompleted;

  const OtpVerifyData({
    required this.userId,
    required this.token,
    required this.tokenType,
    this.expiresIn,
    required this.userType,
    required this.isNewUser,
    required this.profileCompleted,
  });

  factory OtpVerifyData.fromJson(Map<String, dynamic> json) {
    return OtpVerifyData(
      userId: json['user_id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int?,
      userType: json['user_type'] as String? ?? '',
      isNewUser: json['is_new_user'] as bool? ?? false,
      profileCompleted: json['profile_completed'] as bool? ?? false,
    );
  }
}

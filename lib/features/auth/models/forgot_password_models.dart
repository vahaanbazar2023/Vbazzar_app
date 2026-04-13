class ForgotPasswordRequest {
  final String usernamePhone;

  ForgotPasswordRequest({required this.usernamePhone});

  Map<String, dynamic> toJson() => {'username_phone': usernamePhone};
}

class ForgotPasswordResponse {
  final String status;
  final int code;
  final String message;
  final ForgotPasswordData? data;

  ForgotPasswordResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ForgotPasswordData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
}

class ForgotPasswordData {
  final String transactionId;

  ForgotPasswordData({required this.transactionId});

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      transactionId: json['transaction_id'] as String? ?? '',
    );
  }
}

class ResetPasswordRequest {
  final String usernamePhone;
  final String newPassword;
  final String transactionId;
  final String otpCode;

  ResetPasswordRequest({
    required this.usernamePhone,
    required this.newPassword,
    required this.transactionId,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() => {
    'username_phone': usernamePhone,
    'new_password': newPassword,
    'transaction_id': transactionId,
    'otp_code': otpCode,
  };
}

class ResetPasswordResponse {
  final String status;
  final int code;
  final String message;
  final ResetPasswordData? data;

  ResetPasswordResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ResetPasswordData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
}

class ResetPasswordData {
  final String username;
  final int userId;

  ResetPasswordData({required this.username, required this.userId});

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) {
    return ResetPasswordData(
      username: json['username'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
    );
  }
}

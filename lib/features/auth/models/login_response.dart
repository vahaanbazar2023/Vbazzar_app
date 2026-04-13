class LoginResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final LoginData? data;
  final dynamic error;

  const LoginResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] as String,
      code: json['code'] as int,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      data: json['data'] != null
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'timestamp': timestamp,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class LoginData {
  final String userId;
  final String username;
  final String userType;
  final String token;
  final String? tokenExpiresAt;

  const LoginData({
    required this.userId,
    required this.username,
    required this.userType,
    required this.token,
    this.tokenExpiresAt,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      userType: json['user_type'] as String,
      token: json['token'] as String,
      tokenExpiresAt: json['token_expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'user_type': userType,
      'token': token,
      'token_expires_at': tokenExpiresAt,
    };
  }
}

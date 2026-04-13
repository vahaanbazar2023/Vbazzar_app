class RegisterRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String phoneNumber;
  final String email;
  final String state;
  final String city;
  final String password;
  final String userType;
  final String? fcmToken;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.state,
    required this.city,
    required this.password,
    this.userType = 'CUSTOMER',
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'phone_number': phoneNumber,
      'email': email,
      'state': state,
      'city': city,
      'password': password,
      'user_type': userType,
    };
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      json['fcm_token'] = fcmToken!;
    }
    return json;
  }
}

class RegisterResponse {
  final String status;
  final int code;
  final String message;
  final RegisterData? data;
  final dynamic error;

  RegisterResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.error,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? RegisterData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }

  bool get isSuccess => status == 'success' && code == 200;
}

class RegisterData {
  final RegisterUser user;
  final String transactionId;

  RegisterData({required this.user, required this.transactionId});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: RegisterUser.fromJson(json['user'] as Map<String, dynamic>),
      transactionId: json['transaction_id'] as String? ?? '',
    );
  }
}

class RegisterUser {
  final String username;
  final String createdAt;

  RegisterUser({required this.username, required this.createdAt});

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      username: json['username'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

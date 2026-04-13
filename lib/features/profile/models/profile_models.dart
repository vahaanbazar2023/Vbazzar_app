/// Profile data model mapped from /api/v1/dashboard/profile response
class ProfileData {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String state;
  final String city;
  final String registrationStatus;
  final String createdAt;

  const ProfileData({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.state,
    required this.city,
    required this.registrationStatus,
    required this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : username;
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      userType: json['user_type'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      registrationStatus: json['registration_status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// Full envelope response for profile API
class ProfileResponse {
  final String status;
  final int code;
  final String message;
  final ProfileData? data;
  final dynamic error;

  const ProfileResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200 && data != null;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? ProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

/// Full envelope response for logout API
class LogoutResponse {
  final String status;
  final int code;
  final String message;

  const LogoutResponse({
    required this.status,
    required this.code,
    required this.message,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

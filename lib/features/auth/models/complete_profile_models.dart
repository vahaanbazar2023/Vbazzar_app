/// V2 Complete Profile Request — POST /api/v2/auth/complete-profile
class CompleteProfileRequest {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String state;
  final String city;

  const CompleteProfileRequest({
    required this.userId,
    required this.firstName,
    this.lastName = '',
    required this.email,
    required this.state,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'state': state,
      'city': city,
    };
  }
}

/// V2 Complete Profile Response envelope
class CompleteProfileResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final CompleteProfileData? data;
  final dynamic error;

  const CompleteProfileResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory CompleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return CompleteProfileResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      // API returns data as a plain string on success, or a map — handle both
      data: json['data'] is Map<String, dynamic>
          ? CompleteProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

/// Data payload from complete-profile response
class CompleteProfileData {
  final String userId;
  final bool profileCompleted;
  final String message;

  const CompleteProfileData({
    required this.userId,
    required this.profileCompleted,
    required this.message,
  });

  factory CompleteProfileData.fromJson(Map<String, dynamic> json) {
    return CompleteProfileData(
      userId: json['user_id'] as String? ?? '',
      profileCompleted: json['profile_completed'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

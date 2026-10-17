/// V2 Login request — phone number + OTP flow (login = registration)
class LoginRequest {
  final String phoneNumber;
  final String fcmToken;
  final String userType;

  /// App language the user picked (en, hi, te, kn, ml, ta) — lets the backend segment users.
  final String? language;

  const LoginRequest({
    required this.phoneNumber,
    required this.fcmToken,
    this.userType = 'CUSTOMER',
    this.language,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'user_type': userType,
      if (language != null && language!.isNotEmpty) 'language': language,
    };
  }
}

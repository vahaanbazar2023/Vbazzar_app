/// V2 Login request — phone number + OTP flow (login = registration)
class LoginRequest {
  final String phoneNumber;
  final String fcmToken;
  final String userType;

  const LoginRequest({
    required this.phoneNumber,
    required this.fcmToken,
    this.userType = 'CUSTOMER',
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'user_type': userType,
    };
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/network/endpoints/api_endpoints.dart';
import 'package:vahaan_mobile_2_0/core/network/network_service.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/login_request.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/otp_verify_models.dart';

void main() {
  group('login request carries the app language', () {
    test('login includes language when set', () {
      const r = LoginRequest(
        phoneNumber: '9876543210',
        fcmToken: 't',
        language: 'hi',
      );
      expect(r.toJson()['language'], 'hi');
      expect(r.toJson()['phone_number'], '9876543210');
      expect(r.toJson()['user_type'], 'CUSTOMER');
    });

    test('login without a language is exactly the old payload', () {
      const r = LoginRequest(phoneNumber: '9876543210', fcmToken: 't');
      expect(r.toJson().keys.toSet(), {
        'phone_number',
        'fcm_token',
        'user_type',
      });
      expect(
        const LoginRequest(
          phoneNumber: '1',
          fcmToken: 't',
          language: '',
        ).toJson().containsKey('language'),
        isFalse,
      );
    });

    test('verify-otp includes language when set, and not otherwise', () {
      const with_ = OtpVerifyRequest(
        userId: 'VB0000001',
        phoneNumber: '9876543210',
        otpCode: '123456',
        transactionId: 'tx',
        language: 'te',
      );
      expect(with_.toJson()['language'], 'te');
      const without = OtpVerifyRequest(
        userId: 'VB0000001',
        phoneNumber: '9876543210',
        otpCode: '123456',
        transactionId: 'tx',
      );
      expect(without.toJson().keys.toSet(), {
        'user_id',
        'phone_number',
        'otp_code',
        'transaction_id',
      });
    });
  });

  test('the language endpoint is sent with the Bearer token', () {
    expect(
      NetworkService().requiresAuthenticationForTest(ApiEndpoints.userLanguage),
      isTrue,
    );
  });
}

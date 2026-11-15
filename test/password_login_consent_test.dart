import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/network/endpoints/api_endpoints.dart';
import 'package:vahaan_mobile_2_0/core/network/network_service.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/forgot_password_models.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/otp_verify_models.dart';

OtpVerifyRequest _verify({bool? terms, bool? marketing}) => OtpVerifyRequest(
  userId: 'VB0000001',
  phoneNumber: '9876543210',
  otpCode: '123456',
  transactionId: 'tx',
  termsAccepted: terms,
  marketingOptIn: marketing,
);

void main() {
  group('verify-otp carries the consent given on the login screen', () {
    test('ticked agreement and offers are sent with the app as source', () {
      final json = _verify(terms: true, marketing: true).toJson();
      expect(json['terms_accepted'], isTrue);
      expect(json['marketing_opt_in'], isTrue);
      expect(json['consent_source'], 'app');
    });

    test('agreement alone sends no marketing answer', () {
      final json = _verify(terms: true).toJson();
      expect(json['terms_accepted'], isTrue);
      expect(json.containsKey('marketing_opt_in'), isFalse);
    });

    test('nothing ticked is exactly the old payload', () {
      final json = _verify().toJson();
      expect(json.keys.toSet(), {
        'user_id',
        'phone_number',
        'otp_code',
        'transaction_id',
      });
      // An unticked agreement is never sent as a refusal.
      expect(
        _verify(terms: false).toJson().containsKey('terms_accepted'),
        isFalse,
      );
    });
  });

  group('password sign-in and reset', () {
    test('use the v1 endpoints', () {
      expect(ApiEndpoints.passwordLogin, '/api/v1/auth/login');
      expect(
        ApiEndpoints.forgotPasswordSendOtp,
        '/api/v1/auth/forgot-password/send-otp',
      );
      expect(
        ApiEndpoints.forgotPasswordReset,
        '/api/v1/auth/forgot-password/reset',
      );
    });

    test('are sent without a Bearer token (the user is not signed in yet)', () {
      final net = NetworkService();
      for (final p in [
        ApiEndpoints.passwordLogin,
        ApiEndpoints.forgotPasswordSendOtp,
        ApiEndpoints.forgotPasswordReset,
        ApiEndpoints.login,
      ]) {
        expect(net.requiresAuthenticationForTest(p), isFalse, reason: p);
      }
    });

    test('reset request matches what the backend expects', () {
      final json = ResetPasswordRequest(
        usernamePhone: '9876543210',
        newPassword: 'secret123',
        transactionId: 'tx',
        otpCode: '123456',
      ).toJson();
      expect(json, {
        'username_phone': '9876543210',
        'new_password': 'secret123',
        'transaction_id': 'tx',
        'otp_code': '123456',
      });
    });
  });
}

import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/services/logger_service.dart';
import '../data/auth_data_source.dart';
import '../models/referral_validation.dart';
import '../models/login_request.dart';
import '../models/otp_response.dart';
import '../models/otp_verify_models.dart';
import '../models/complete_profile_models.dart';
import '../models/forgot_password_models.dart';
import 'dart:async';
import '../services/profile_gate.dart';

/// Auth repository — V2 unified login+registration flow
class AuthRepository {
  final AuthDataSource _dataSource;
  final SecureStorageService _secureStorage;

  AuthRepository({
    AuthDataSource? dataSource,
    SecureStorageService? secureStorage,
  }) : _dataSource = dataSource ?? AuthDataSource(),
       _secureStorage = secureStorage ?? SecureStorageService.to;

  /// The language chosen on the language-selection screen (null if none saved).
  /// Sent with login so the backend knows which language each user speaks.
  String? _savedLanguage() {
    try {
      final code = LocalStorageService.to.getString(StorageKeys.languageCode);
      return code.isEmpty ? null : code;
    } catch (_) {
      return null; // never let language tracking get in the way of logging in
    }
  }

  /// Is this referral code valid? (API key only; used on the login screen)
  Future<ReferralValidation> validateReferralCode(String code) =>
      _dataSource.validateReferralCode(code);

  /// POST /api/v2/auth/login — sends OTP (creates user if new)
  Future<OtpResponse> sendOtp({
    required String phone,
    required String fcmToken,
    String? language,
  }) async {
    final request = LoginRequest(
      phoneNumber: phone,
      fcmToken: fcmToken,
      language: language ?? _savedLanguage(),
    );
    return _dataSource.sendOtp(request);
  }

  /// POST /api/v2/auth/verify-otp — verify OTP, returns token + profileCompleted
  Future<OtpVerifyResponse> verifyOtp({
    required String userId,
    required String phone,
    required String otpCode,
    required String transactionId,
    String? fcmToken,
    String? referralCode,
    String? contentType,
    String? contentId,
    String? language,
    bool? termsAccepted,
    bool? marketingOptIn,
  }) async {
    final request = OtpVerifyRequest(
      userId: userId,
      phoneNumber: phone,
      otpCode: otpCode,
      transactionId: transactionId,
      fcmToken: fcmToken,
      referralCode: referralCode,
      contentType: contentType,
      contentId: contentId,
      language: language ?? _savedLanguage(),
      termsAccepted: termsAccepted,
      marketingOptIn: marketingOptIn,
    );

    final response = await _dataSource.verifyOtp(request);

    if (response.isSuccess && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  /// POST /api/v1/auth/login — sign in with username (or mobile number) + password.
  /// Returns null on success, otherwise the message to show.
  Future<String?> loginWithPassword({
    required String usernamePhone,
    required String password,
    String? fcmToken,
  }) async {
    final body = await _dataSource.loginWithPassword(
      usernamePhone: usernamePhone,
      password: password,
      fcmToken: fcmToken,
    );
    final data = body['data'];
    final token = data is Map ? data['token']?.toString() ?? '' : '';
    if (body['status'] != 'success' || token.isEmpty) {
      final message = body['message']?.toString() ?? '';
      return message.isNotEmpty ? message : 'Login failed';
    }
    final map = data as Map;
    // Same "profile completed" flag as OTP sign-in. The server sends it as `profile_completed`;
    // an older server doesn't, so then we ask for the profile once and remember the answer.
    final completed = map['profile_completed'];
    await Future.wait([
      _secureStorage.write(StorageKeys.authToken, token),
      _secureStorage.write(
        StorageKeys.userId,
        map['user_id']?.toString() ?? '',
      ),
      _secureStorage.write(
        StorageKeys.userType,
        map['user_type']?.toString() ?? '',
      ),
      if (completed is bool)
        _secureStorage.write(
          StorageKeys.profileCompleted,
          completed.toString(),
        ),
    ]);
    if (completed is! bool) {
      unawaited(ProfileGate.rememberServerStatus());
    }
    LoggerService.to.info('Auth data saved for user: ${map['user_id']}');
    return null;
  }

  /// Text a password-reset code to the account's mobile number.
  Future<ForgotPasswordResponse> sendPasswordResetOtp(String usernamePhone) =>
      _dataSource.sendPasswordResetOtp(usernamePhone);

  /// Set a new password with the reset code.
  Future<ResetPasswordResponse> resetPassword({
    required String usernamePhone,
    required String otpCode,
    required String transactionId,
    required String newPassword,
  }) => _dataSource.resetPassword(
    ResetPasswordRequest(
      usernamePhone: usernamePhone,
      newPassword: newPassword,
      transactionId: transactionId,
      otpCode: otpCode,
    ),
  );

  /// POST /api/v2/auth/complete-profile — fill required fields after OTP
  Future<CompleteProfileResponse> completeProfile(
    CompleteProfileRequest request,
  ) async {
    return _dataSource.completeProfile(request);
  }

  /// Save auth token, userId, userType to secure storage
  Future<void> _saveAuthData(OtpVerifyData data) async {
    await Future.wait([
      _secureStorage.write(StorageKeys.authToken, data.token),
      _secureStorage.write(StorageKeys.userId, data.userId),
      _secureStorage.write(StorageKeys.userType, data.userType),
      _secureStorage.write(
        StorageKeys.profileCompleted,
        data.profileCompleted.toString(),
      ),
    ]);
    LoggerService.to.info('Auth data saved for user: ${data.userId}');
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    return _secureStorage.read(StorageKeys.authToken);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return _secureStorage.read(StorageKeys.userId);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Mark profile as completed in secure storage
  Future<void> markProfileCompleted() async {
    await _secureStorage.write(StorageKeys.profileCompleted, 'true');
  }

  /// Logout and clear all auth data
  Future<void> logout() async {
    await Future.wait([
      _secureStorage.delete(StorageKeys.authToken),
      _secureStorage.delete(StorageKeys.userId),
      _secureStorage.delete(StorageKeys.userType),
      _secureStorage.delete(StorageKeys.profileCompleted),
      _secureStorage.delete(StorageKeys.profileRequiredAfterPayment),
    ]);
  }
}

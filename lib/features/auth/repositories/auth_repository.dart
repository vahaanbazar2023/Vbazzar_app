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
    );

    final response = await _dataSource.verifyOtp(request);

    if (response.isSuccess && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

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

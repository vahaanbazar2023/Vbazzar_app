import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';

/// Tells the backend which language the user switched to (Profile → Language) so users can be
/// segmented by language. Best-effort: it never blocks, throws or changes the in-app language.
///
/// The language chosen BEFORE login is not sent here — it travels with login / verify-otp.
class LanguageSyncService {
  LanguageSyncService._();

  static bool _syncedThisSession = false;

  /// Once per app start, for users who are already logged in: tell the backend the language this
  /// device uses. Without it, anyone who picked a language before this feature existed would stay
  /// "unknown" on the server until they switched language again.
  static Future<void> syncSavedLanguageOnce() async {
    if (_syncedThisSession) return;
    try {
      final code = LocalStorageService.to.getString(StorageKeys.languageCode);
      if (code.isEmpty) return;
      _syncedThisSession = true;
      await push(code);
    } catch (e) {
      LoggerService.to.error('LanguageSyncService.syncSavedLanguageOnce failed: $e');
    }
  }

  static Future<void> push(String languageCode) async {
    try {
      final token = await SecureStorageService.to.read(StorageKeys.authToken);
      if (token == null || token.isEmpty) return; // not logged in yet
      await NetworkService.to.put(
        ApiEndpoints.userLanguage,
        data: {'language': languageCode},
      );
    } catch (e) {
      LoggerService.to.error('LanguageSyncService.push failed: $e');
    }
  }
}

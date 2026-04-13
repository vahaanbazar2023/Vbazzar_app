class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userType = 'user_type';
  static const String tokenExpiresAt = 'token_expires_at';
  static const String profileCompleted = 'profile_completed';

  // User prefs (local storage)
  static const String hasSeenIntro = 'has_seen_intro';
  static const String isOnboardingDone = 'is_onboarding_done';
  static const String isDarkMode = 'is_dark_mode';
  static const String selectedLanguage = 'selected_language';
  static const String languageCode = 'language_code';
  static const String isFirstLaunch = 'is_first_launch';
}

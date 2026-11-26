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
  static const String profileRequiredAfterPayment =
      'profile_required_after_payment';

  // User prefs (local storage)
  static const String hasSeenIntro = 'has_seen_intro';
  static const String isOnboardingDone = 'is_onboarding_done';

  /// Set once the first-run Home tour has been finished or skipped.
  static const String hasSeenHomeTour = 'has_seen_home_tour';

  /// Per-screen first-visit tours (see TourScope). Listed so "Replay app
  /// tour" can reset them all.
  static const List<String> screenTourIds = [
    'auction_type',
    'auction_category',
    'auction_listing',
    'auction_detail',
    'buy_sell_home',
    'buy_listing',
    'buy_detail',
    'approved_landing',
    'approved_category',
    'approved_listing',
    'approved_detail',
  ];
  static String screenTourSeen(String id) => 'tour_seen_$id';
  static const String isDarkMode = 'is_dark_mode';
  static const String selectedLanguage = 'selected_language';
  static const String languageCode = 'language_code';

  /// Set once the user picks a language on this app (2.0.0+). A new key on purpose: data left by the old
  /// Vahaan Bazar app (same package, kept on update) never has it, so every user picks a language once.
  static const String languageConfirmed = 'language_confirmed_v2';
  static const String isFirstLaunch = 'is_first_launch';
}

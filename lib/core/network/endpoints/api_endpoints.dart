class ApiEndpoints {
  ApiEndpoints._();

  static const String subscriptionPrefix = '/api/v1/subscription';

  // ─── Auth ────────────────────────────────────────────────────
  static const String login = '/api/v2/auth/login';
  static const String verifyOtp = '/api/v2/auth/verify-otp';
  static const String completeProfile = '/api/v2/auth/complete-profile';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh-token';

  // ─── User / Profile ──────────────────────────────────────────
  static const String profile = '/api/v1/dashboard/profile';
  static const String updateProfile = '/api/v1/dashboard/profile-update';
  static const String changePassword = '/api/v1/dashboard/change-password';

  // ─── Dashboard ───────────────────────────────────────────────
  static const String categoriesHome = '/api/v1/dashboard/categories-home';


  // ─── Subscription ───────────────────────────────────────────────
  static const String mySubscriptions = '$subscriptionPrefix/my-subscriptions';
  static const String subscriptionListing = '$subscriptionPrefix/subscription-listing';
  static const String walletEligibility = '/api/v1/wallet/eligibility';

  // ─── Vehicles ────────────────────────────────────────────────
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';

  // ─── Notifications ───────────────────────────────────────────
  static const String notifications = '/notifications';
}

import 'package:get/get.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/splash/splash_binding.dart';
import '../features/introduction/views/intro_screen.dart';
import '../features/introduction/intro_binding.dart';
import '../features/language/views/language_selection_screen.dart';
import '../features/language/bindings/language_binding.dart';
import '../features/auth/views/login_with_otp.dart';
import '../features/auth/views/verify_otp.dart';
import '../features/auth/views/complete_profile_screen.dart';
import '../features/auth/auth_binding.dart';
import '../features/main_shell/views/main_shell_screen.dart';
import '../features/main_shell/bindings/main_shell_binding.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/profile/profile_binding.dart';
import '../features/subscription/views/subscription_screen.dart';
import '../features/subscription/views/subscription_confirm_screen.dart';
import '../features/auction/views/auction_type_screen.dart';
import '../features/auction/views/autction_tab.dart';
import '../features/auction/views/acution_vechile_listing.dart';
import '../features/auction/views/acution_vechile_detail.dart';
import '../features/auction/auction_binding.dart';
import '../features/auction/vehicle_listing_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.introduction,
      page: () => const IntroScreen(),
      binding: IntroBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
      binding: LanguageBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginWithOtp(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.loginWithOtp,
      page: () => const LoginWithOtp(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOTP(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellScreen(),
      binding: MainShellBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return SubscriptionScreen(
          subscriptionSource: args['source'] as String? ?? 'SUBT001',
          title: args['title'] as String? ?? 'Choose a Plan',
          subtitle:
              args['subtitle'] as String? ??
              'Select the subscription plan that suits you best',
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscriptionConfirm,
      page: () => const SubscriptionConfirmScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.auctionType,
      page: () => const AuctionTypeScreen(),
      binding: AuctionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.auctionListings,
      page: () => const AuctionTab(),
      binding: AuctionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vehicleListings,
      page: () => const AuctionVehicleListingScreen(),
      binding: VehicleListingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vehicleDetail,
      page: () => const AuctionVehicleDetailScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

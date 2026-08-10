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
import '../features/profile/views/manage_profile_view.dart';
import '../features/profile/views/wallet_dashboard_view.dart';
import '../features/profile/views/initiate_refund_view.dart';
import '../features/profile/controllers/initiate_refund_controller.dart';
import '../features/profile/profile_binding.dart';
import '../features/subscription/views/subscription_screen.dart';
import '../features/subscription/views/subscription_confirm_screen.dart';
import '../features/subscription/views/my_subscription_screen.dart';
import '../features/subscription/views/wallet_payment_screen.dart';
import '../features/subscription/controllers/subscription_controller.dart';
import '../features/subscription/controllers/subscription_confirm_controller.dart';
import '../features/subscription/models/subscription_plan.dart';
import '../features/payment/controllers/payment_controller.dart';
import '../features/auction/views/auction_type_screen.dart';
import '../features/auction/views/auction_category_screen.dart';
import '../features/auction/views/autction_tab.dart';
import '../features/auction/views/acution_vechile_listing.dart';
import '../features/auction/views/acution_vechile_detail.dart';
import '../features/auction/views/my_bids_view.dart';
import '../features/auction/views/my_wins_view.dart';
import '../features/auction/auction_binding.dart';
import '../features/auction/controllers/auction_category_controller.dart';
import '../features/auction/vehicle_listing_binding.dart';
import '../features/auction/controllers/my_bids_wins_controller.dart';
import 'app_routes.dart';
import '../features/buy_and_sell/views/buy_sell_home_view.dart';
import '../features/buy_and_sell/views/sell_view.dart';
import '../features/buy_and_sell/views/buy_vehicle_listings_view.dart';
import '../features/buy_and_sell/views/buy_vehicle_details_view.dart';
import '../features/buy_and_sell/buy_sell_binding.dart';
import '../features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../features/buy_and_sell/data/repositories/buy_sell_repository_impl.dart';
import '../features/approved_vehicles/approved_vehicle_binding.dart';
import '../features/approved_vehicles/views/buy_sell_landing_screen.dart';
import '../features/approved_vehicles/views/category_selection_screen.dart';
import '../features/approved_vehicles/views/vehicle_listings_screen.dart';
import '../features/approved_vehicles/views/vehicle_detail_screen.dart';
import '../features/approved_vehicles/views/sell_vehicle_form_screen.dart';
import '../features/approved_vehicles/views/my_bookings_screen.dart';
import '../features/spare_and_fms/spare_fms_binding.dart';
import '../features/spare_and_fms/views/spare_fms_home_view.dart';
import '../features/spare_and_fms/views/fms_detail_view.dart';
import '../features/spare_and_fms/views/shop_list_view.dart';
import '../features/spare_and_fms/views/spare_orders_view.dart';
import '../features/insurance_and_finance/insurance_finance_binding.dart';
import '../features/insurance_and_finance/views/insurance_finance_view.dart';
import '../features/insurance_and_finance/views/my_quotes_view.dart';
import '../features/service_support/bindings/service_support_binding.dart';
import '../features/service_support/views/service_support_view.dart';
import '../features/service_support/views/service_provider_list_view.dart';
import '../features/inspection_valuation/bindings/inspection_valuation_binding.dart';
import '../features/inspection_valuation/views/inspection_home_view.dart';
import '../features/inspection_valuation/views/customer_valuation_form_view.dart';
import '../features/inspection_valuation/views/agent_valuation_form_view.dart';
import '../features/inspection_valuation/views/my_inspections_view.dart';
import '../features/inspection_valuation/views/inspection_detail_view.dart';
import '../features/search/views/search_screen.dart';

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
      name: AppRoutes.manageProfile,
      page: () => const ManageProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.walletDashboard,
      page: () => const WalletDashboardView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final source =
            (args['subscription_source'] ?? args['source'] ?? 'SUBT001')
                as String;
        final prebuiltPlan = args['prebuilt_plan'] as SubscriptionPlan?;
        final knownKeys = {
          'subscription_source',
          'source',
          'title',
          'subtitle',
          'prebuilt_plan',
        };
        final extraArgs = Map<String, dynamic>.fromEntries(
          args.entries.where((e) => !knownKeys.contains(e.key)),
        );
        return SubscriptionScreen(
          subscriptionSource: source,
          title: args['title'] as String? ?? 'Choose a Plan',
          subtitle:
              args['subtitle'] as String? ??
              'Select the subscription plan that suits you best',
          prebuiltPlan: prebuiltPlan,
          extraArgs: extraArgs,
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscriptionConfirm,
      page: () => const SubscriptionConfirmScreen(),
      binding: BindingsBuilder(() {
        Get.put(PaymentController());
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        // Extract extra args (anything beyond plan/source) to carry through
        // to post-payment handlers (e.g. pending_vehicle_id for inspection).
        final knownKeys = {'plan', 'source'};
        final extraArgs = Map<String, dynamic>.fromEntries(
          args.entries.where((e) => !knownKeys.contains(e.key)),
        );
        Get.lazyPut(
          () => SubscriptionConfirmController(
            planArg: args['plan'] as dynamic,
            sourceArg: args['source'] as String?,
            extraArgs: extraArgs,
          ),
        );
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.mySubscriptions,
      page: () => const MySubscriptionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MySubscriptionController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.auctionType,
      page: () => const AuctionTypeScreen(),
      binding: AuctionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.auctionCategory,
      page: () => const AuctionCategoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuctionCategoryController());
      }),
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
    GetPage(
      name: AppRoutes.myBids,
      page: () => const MyBidsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyBidsController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myWins,
      page: () => const MyWinsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyWinsController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.walletPayment,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        // Pass all extra args through so INSPECTION/SUBT003 etc. keep
        // pending_vehicle_id and category_code for post-payment navigation.
        final knownKeys = {'plan', 'source'};
        final extraArgs = Map<String, dynamic>.fromEntries(
          args.entries.where((e) => !knownKeys.contains(e.key)),
        );
        return WalletPaymentScreen(
          plan: args['plan'],
          source: args['source'] ?? '',
          extraArgs: extraArgs,
        );
      },
      binding: BindingsBuilder(() {
        Get.put(PaymentController());
      }),
      transition: Transition.rightToLeft,
    ),
    // ── Buy & Sell ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.buySellHome,
      page: () => const BuySellHomeView(),
      binding: BuySellBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.sellVehicle,
      page: () => const SellVehicleView(),
      binding: BuySellBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.buyVehicleListings,
      page: () => const BuyVehicleListingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => BuyVehicleController(repository: BuySellRepositoryImpl()),
        );
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.buyVehicleDetail,
      page: () => const BuyVehicleDetailsView(),
      transition: Transition.rightToLeft,
    ),
    // ── Approved Vehicles ─────────────────────────────────────
    GetPage(
      name: AppRoutes.approvedVehicleBuySell,
      page: () => const BuySellLandingScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleCategory,
      page: () => const CategorySelectionScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleListings,
      page: () => const VehicleListingsScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleDetail,
      page: () => const VehicleDetailScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleSellForm,
      page: () => const SellVehicleFormScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleMyBookings,
      page: () => const MyBookingsScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.approvedVehicleMyInspections,
      page: () => const MyBookingsScreen(),
      binding: ApprovedVehicleBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Spare & FMS ──────────────────────────────────────────
    GetPage(
      name: AppRoutes.spareFms,
      page: () => const SpareFmsHomeView(),
      binding: SpareFmsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.spareDetail,
      page: () => const FmsDetailView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.shopList,
      page: () => const ShopListView(),
      binding: SpareFmsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.spareOrders,
      page: () => const SpareOrdersView(),
      binding: SpareFmsBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Initiate Refund ──────────────────────────────────────
    GetPage(
      name: AppRoutes.initiateRefund,
      page: () => const InitiateRefundView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => InitiateRefundController());
      }),
      transition: Transition.rightToLeft,
    ),
    // ── Insurance & Finance ─────────────────────────────────
    GetPage(
      name: AppRoutes.insuranceFinance,
      page: () => const InsuranceFinanceView(),
      binding: InsuranceFinanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myQuotes,
      page: () => const MyQuotesView(),
      binding: InsuranceFinanceBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Service Support ────────────────────────────────────────
    GetPage(
      name: AppRoutes.serviceSupport,
      page: () => const ServiceSupportView(),
      binding: ServiceSupportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.serviceSupportListView,
      page: () => const ServiceProviderListView(),
      binding: ServiceSupportBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Inspection & Valuation ─────────────────────────────────
    GetPage(
      name: AppRoutes.inspectionHome,
      page: () => const InspectionHomeView(),
      binding: InspectionValuationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerValuationForm,
      page: () => const CustomerValuationFormView(),
      binding: InspectionValuationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.agentValuationForm,
      page: () => const AgentValuationFormView(),
      binding: InspectionValuationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myInspections,
      page: () => const MyInspectionsView(),
      binding: InspectionValuationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.inspectionDetail,
      page: () => const InspectionDetailView(),
      binding: InspectionValuationBinding(),
      transition: Transition.rightToLeft,
    ),
    // ── Search ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

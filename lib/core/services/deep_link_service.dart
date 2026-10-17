import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../design_system/molecules/custom_snackbar.dart';
import '../extensions/context_extensions.dart';
import '../services/logger_service.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_keys.dart';
import '../../routes/app_routes.dart';
import '../../features/approved_vehicles/data/repositories/approved_vehicle_repository_impl.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/subscription/models/user_subscription.dart';
import '../../features/subscription/services/subscription_guard_service.dart';

/// DeepLinkService handles inbound universal links and App Links.
///
/// URL format:
///   https://www.vahaanbazar.com/vehicle/{sb_vehicle_id}?ref={user_id}
///   https://www.vahaanbazar.com/approved-vehicle/{approved_vehicle_id}?ref=...
///   https://www.vahaanbazar.com/auction/{auction_id}?ref=...
///   https://www.vahaanbazar.com/auction-vehicle/{vehicle_id}?ref=...
///   https://www.vahaanbazar.com/referral?ref={user_id}
/// (the old https://vahaanbazar.in links keep working)
///
/// The service:
///   1. On cold start: reads the initial link (if any) and stores
///      referral_code + content info in local storage for OTP verify.
///   2. On warm resume: navigates immediately to the vehicle detail.
///
/// Register in AppBinding / AppLifecycle and call initialize() once.
class DeepLinkService extends GetxService {
  static DeepLinkService get to => Get.find();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  // Keys used to persist the pending deep-link across sessions
  static const _kPendingRef = 'pending_referral_code';
  static const _kPendingContentType = 'pending_content_type';
  static const _kPendingContentId = 'pending_content_id';

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool _coldStartHandled = false;

  // ── Public API ─────────────────────────────────────────────────

  /// Call once after the app has finished bootstrapping.
  Future<void> initialize() async {
    // 1. Handle cold-start link (app was opened via link while not running)
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        LoggerService.to.info('[DeepLink] Cold-start URI: $initial');
        _coldStartHandled = true;
        _handleUri(initial, isColdStart: true);
      }
    } catch (e) {
      LoggerService.to.error('[DeepLink] getInitialLink error: $e');
    }

    // 2. Listen for warm-start links (app already running)
    _sub = _appLinks.uriLinkStream.listen((uri) {
      // Skip the warm-start event that fires simultaneously with cold-start
      if (_coldStartHandled) {
        _coldStartHandled = false;
        LoggerService.to.info(
          '[DeepLink] Skipping duplicate warm-start after cold-start',
        );
        return;
      }
      LoggerService.to.info('[DeepLink] Warm-start URI: $uri');
      _handleUri(uri, isColdStart: false);
    }, onError: (e) => LoggerService.to.error('[DeepLink] stream error: $e'));
  }

  /// Returns a pending referral code saved during cold start (used in
  /// OTP verify so it can be sent to the backend).
  String? consumePendingReferralCode() {
    final code = LocalStorageService.to.read<String>(_kPendingRef);
    if (code != null && code.isNotEmpty) {
      LocalStorageService.to.remove(_kPendingRef);
      LocalStorageService.to.remove(_kPendingContentType);
      LocalStorageService.to.remove(_kPendingContentId);
    }
    return code;
  }

  /// Reads the pending referral code without clearing it (used to prefill
  /// the referral input on the verify-OTP screen).
  String? peekPendingReferralCode() =>
      LocalStorageService.to.read<String>(_kPendingRef);

  /// Clears only the stored referral code once it has been used.
  void clearPendingReferralCode() =>
      LocalStorageService.to.remove(_kPendingRef);

  String? consumePendingContentType() =>
      LocalStorageService.to.read<String>(_kPendingContentType);

  String? consumePendingContentId() =>
      LocalStorageService.to.read<String>(_kPendingContentId);

  // ── URI parsing & routing ──────────────────────────────────────

  /// path prefix -> content_type understood by POST /api/v2/auth/verify-otp
  static const _pathTypes = <String, String>{
    'vehicle': 'buy_vehicle',
    'v': 'buy_vehicle',
    'approved-vehicle': 'approved_vehicle',
    'auction': 'live_auction',
    'auction-vehicle': 'auction_vehicle',
  };

  void _handleUri(Uri uri, {required bool isColdStart}) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final ref = uri.queryParameters['ref']; // referral code

    LoggerService.to.info(
      '[DeepLink] path=${uri.path} ref=$ref coldStart=$isColdStart',
    );
    if (segments.isEmpty) return;

    final head = segments.first;
    if (head == 'referral') {
      _persistPending(ref: ref, contentType: 'referral_dashboard');
      return;
    }

    final contentType = _pathTypes[head];
    final contentId = segments.length > 1 ? segments[1].trim() : '';
    if (contentType == null || contentId.isEmpty) return;

    // Always persist referral code + content (needed if the user must sign up
    // or log in before the screen can open).
    _persistPending(ref: ref, contentType: contentType, contentId: contentId);

    // Warm start: open immediately. Cold start: resumePendingNavigation()
    // runs once home is loaded (and the user is logged in).
    if (!isColdStart) _openContent(contentType, contentId);
  }

  void _persistPending({String? ref, String? contentType, String? contentId}) {
    if (ref != null && ref.isNotEmpty) {
      LocalStorageService.to.write(_kPendingRef, ref);
      // If the login screen is already open, fill its referral field now.
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().prefillReferralFromDeepLink();
      }
    }
    if (contentType != null) {
      LocalStorageService.to.write(_kPendingContentType, contentType);
    }
    if (contentId != null) {
      LocalStorageService.to.write(_kPendingContentId, contentId);
    }
  }

  Future<void> _openContent(String contentType, String contentId) async {
    switch (contentType) {
      case 'buy_vehicle':
      case 'vehicle': // stored by older builds
        _navigateToVehicle(contentId);
        break;
      case 'approved_vehicle':
        await _navigateToApprovedVehicle(contentId);
        break;
      case 'live_auction':
      case 'upcoming_auction':
      case 'closed_auction':
      case 'auction_vehicle':
        await _navigateToAuctionModule();
        break;
    }
  }

  void _navigateToVehicle(String vehicleId) {
    // Navigate to buy vehicle detail screen
    // The buy vehicle detail screen reads vehicle id from Get.arguments
    Get.toNamed(
      AppRoutes.buyVehicleDetail,
      arguments: {'sb_vehicle_id': vehicleId, 'from_deep_link': true},
    );
  }

  /// Loads the shared approved vehicle by id and opens its detail screen.
  Future<void> _navigateToApprovedVehicle(String approvedVehicleId) async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) return; // pending is kept for login
    try {
      final listing = await ApprovedVehicleRepositoryImpl()
          .getListingByVehicleId(
            userId: userId,
            approvedVehicleId: approvedVehicleId,
          );
      if (listing == null) {
        CustomSnackbar.show(
          message: 'This vehicle is no longer available',
          type: SnackbarType.info,
        );
        Get.toNamed(AppRoutes.approvedVehicleBuySell);
        return;
      }
      Get.toNamed(AppRoutes.approvedVehicleDetail, arguments: {'listing': listing});
    } catch (e) {
      LoggerService.to.error('[DeepLink] approved vehicle open failed: $e');
      CustomSnackbar.show(
        message: 'Could not open the shared vehicle',
        type: SnackbarType.error,
      );
    }
  }

  /// Auction links follow the same rule as every auction entry (SUBT001):
  /// subscribed -> auction module, otherwise -> choose a plan.
  Future<void> _navigateToAuctionModule() async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) return; // pending is kept for login
    final guard = SubscriptionGuardService.to;
    await guard.ensureLoaded(forceRefresh: false);
    if (guard.hasActiveSubscription(SubscriptionTypeCode.auction)) {
      Get.toNamed(AppRoutes.auctionType);
    } else {
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auction,
          'title': appL10n.coreChooseSubscriptionPlan,
          'subtitle': appL10n.coreChooseSubscriptionPlanAuctionSubtitle,
        },
      );
    }
  }

  /// Call from HomeController / MainShellController after login to
  /// handle any cold-start deep links that couldn't navigate immediately.
  void resumePendingNavigation() {
    final contentType = LocalStorageService.to.read<String>(
      _kPendingContentType,
    );
    final contentId = LocalStorageService.to.read<String>(_kPendingContentId);
    if (contentType == null ||
        contentType == 'referral_dashboard' ||
        contentType == 'referral' ||
        contentId == null ||
        contentId.isEmpty) {
      return;
    }
    LocalStorageService.to.remove(_kPendingContentType);
    LocalStorageService.to.remove(_kPendingContentId);
    // Delay slightly to ensure the widget tree is fully built
    Future.delayed(const Duration(milliseconds: 300), () {
      _openContent(contentType, contentId);
    });
  }
}

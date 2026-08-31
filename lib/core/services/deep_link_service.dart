import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../services/logger_service.dart';
import '../storage/local_storage_service.dart';
import '../../routes/app_routes.dart';

/// DeepLinkService handles inbound universal links and App Links.
///
/// URL format:
///   https://vahaanbazar.in/vehicle/{sb_vehicle_id}?ref={user_id}
///   https://vahaanbazar.in/referral?ref={user_id}
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

  String? consumePendingContentType() =>
      LocalStorageService.to.read<String>(_kPendingContentType);

  String? consumePendingContentId() =>
      LocalStorageService.to.read<String>(_kPendingContentId);

  // ── URI parsing & routing ──────────────────────────────────────

  void _handleUri(Uri uri, {required bool isColdStart}) {
    final path = uri.path; // e.g. /vehicle/BSVEH000000001
    final ref = uri.queryParameters['ref']; // referral code

    LoggerService.to.info(
      '[DeepLink] path=$path ref=$ref coldStart=$isColdStart',
    );

    if (path.startsWith('/vehicle/') || path.startsWith('/v/')) {
      final vehicleId = path
          .replaceFirst('/vehicle/', '')
          .replaceFirst('/v/', '')
          .trim();
      if (vehicleId.isEmpty) return;

      // Always persist referral code + content
      _persistPending(ref: ref, contentType: 'vehicle', contentId: vehicleId);

      if (!isColdStart) {
        // Warm start — navigate immediately
        _navigateToVehicle(vehicleId);
      }
      // Cold start — navigation will happen once home/auth is loaded
      // and the controller calls resumeNavigation()
    } else if (path.startsWith('/referral')) {
      _persistPending(ref: ref, contentType: 'referral', contentId: null);
    }
  }

  void _persistPending({String? ref, String? contentType, String? contentId}) {
    if (ref != null && ref.isNotEmpty) {
      LocalStorageService.to.write(_kPendingRef, ref);
    }
    if (contentType != null) {
      LocalStorageService.to.write(_kPendingContentType, contentType);
    }
    if (contentId != null) {
      LocalStorageService.to.write(_kPendingContentId, contentId);
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

  /// Call from HomeController / MainShellController after login to
  /// handle any cold-start deep links that couldn't navigate immediately.
  void resumePendingNavigation() {
    final contentType = LocalStorageService.to.read<String>(
      _kPendingContentType,
    );
    final contentId = LocalStorageService.to.read<String>(_kPendingContentId);

    if (contentType == 'vehicle' && contentId != null && contentId.isNotEmpty) {
      LocalStorageService.to.remove(_kPendingContentType);
      LocalStorageService.to.remove(_kPendingContentId);
      // Delay slightly to ensure the widget tree is fully built
      Future.delayed(const Duration(milliseconds: 300), () {
        _navigateToVehicle(contentId);
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../routes/app_routes.dart';
import '../main_shell/controllers/main_shell_controller.dart';
import 'tour_overlay.dart';

/// Keys on the real widgets the first-run Home tour highlights.
/// Home and the shell exist once, so global keys are safe here; other
/// screens use [TourScope]/[TourAnchor] instead.
class HomeTourKeys {
  HomeTourKeys._();
  static final search = GlobalKey(debugLabel: 'tour_search');
  static final notifications = GlobalKey(debugLabel: 'tour_notifications');
  static final liveAuctions = GlobalKey(debugLabel: 'tour_live_auctions');
  static final services = GlobalKey(debugLabel: 'tour_services');
  static final bottomNav = GlobalKey(debugLabel: 'tour_bottom_nav');
}

/// First-run guided tour of the Home screen and the bottom tabs.
/// Shown once per install; replayable from Profile → App tour.
class HomeTour {
  HomeTour._();

  static bool _running = false;

  static bool get hasSeen =>
      LocalStorageService.to.getBool(StorageKeys.hasSeenHomeTour);

  /// Called by Home once its dashboard has rendered.
  static void maybeStart(BuildContext context) {
    if (_running || hasSeen) return;
    _running = true;
    // Let the dashboard settle (images, layout) before measuring targets.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!context.mounted || !_homeInFront(context)) {
        _running = false;
        return;
      }
      _show(context);
    });
  }

  /// Replay from Profile: forget every screen's tour, switch to Home, run it.
  static void replay() {
    if (_running) return;
    resetAllTours();
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().onTabTapped(BottomNavTab.home.index);
    }
    _running = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      final ctx = HomeTourKeys.search.currentContext;
      if (ctx == null || !ctx.mounted) {
        _running = false;
        return;
      }
      _show(ctx);
    });
  }

  /// Clears the Home flag and every per-screen tour flag, so each screen's
  /// tour shows again on its next visit.
  static void resetAllTours() {
    final storage = LocalStorageService.to;
    storage.remove(StorageKeys.hasSeenHomeTour);
    for (final id in StorageKeys.screenTourIds) {
      storage.remove(StorageKeys.screenTourSeen(id));
    }
  }

  static bool _homeInFront(BuildContext context) {
    if (Get.currentRoute != AppRoutes.home) return false;
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    if (Get.isRegistered<MainShellController>() &&
        Get.find<MainShellController>().currentIndex.value !=
            BottomNavTab.home.index) {
      return false;
    }
    return true;
  }

  static Future<void> _show(BuildContext context) async {
    final l10n = context.l10n;
    final steps = <TourStep>[
      TourStep.forContext(
        () => HomeTourKeys.search.currentContext,
        title: l10n.tourSearchTitle,
        body: l10n.tourSearchBody,
      ),
      TourStep.forContext(
        () => HomeTourKeys.liveAuctions.currentContext,
        title: l10n.tourAuctionsTitle,
        body: l10n.tourAuctionsBody,
        padding: 0, // full-width carousel: keep the cut-out on screen
      ),
      TourStep.forContext(
        () => HomeTourKeys.services.currentContext,
        title: l10n.tourServicesTitle,
        body: l10n.tourServicesBody,
      ),
      TourStep.forContext(
        () => HomeTourKeys.notifications.currentContext,
        title: l10n.tourNotificationsTitle,
        body: l10n.tourNotificationsBody,
        padding: 6,
        circle: true,
      ),
      _navTab(
        BottomNavTab.subscriptions,
        l10n.tourSubscriptionsTitle,
        l10n.tourSubscriptionsBody,
      ),
      _navTab(
        BottomNavTab.categories,
        l10n.tourCategoriesTitle,
        l10n.tourCategoriesBody,
      ),
      _navTab(
        BottomNavTab.rewards,
        l10n.tourRewardsTitle,
        l10n.tourRewardsBody,
      ),
      _navTab(
        BottomNavTab.settings,
        l10n.tourProfileTitle,
        l10n.tourProfileBody,
      ),
    ];

    try {
      await showTourOverlay(context, steps);
    } finally {
      // Finished, skipped or backed out: either way, don't show it again.
      LocalStorageService.to.setBool(StorageKeys.hasSeenHomeTour, true);
      _running = false;
    }
  }

  /// A circle on one bottom-bar tab. Same slot maths as AppBottomNavBar:
  /// 16 px side padding, 5 equal slots, icons centred in the 64 px bar
  /// under a 2 px wave allowance.
  static TourStep _navTab(BottomNavTab tab, String title, String body) {
    return TourStep(
      title: title,
      body: body,
      circle: true,
      resolve: () {
        final bar = TourStep.rectOf(HomeTourKeys.bottomNav.currentContext);
        if (bar == null) return null;
        const sidePad = 16.0;
        final slotW = (bar.width - sidePad * 2) / BottomNavTab.values.length;
        final cx = bar.left + sidePad + slotW * (tab.index + 0.5);
        final cy = bar.top + 2 + 32;
        return Rect.fromCircle(center: Offset(cx, cy), radius: 28);
      },
    );
  }
}

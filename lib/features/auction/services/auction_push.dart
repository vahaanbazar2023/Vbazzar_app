import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../controllers/watchlist_controller.dart';

/// Auction pushes from the backend (`data.action`):
/// - `auto_bid_placed` / `auto_bid_stopped` — auto-bid placed a bid for the user, or stopped
/// - `outbid` — someone (often another user's auto-bid) outbid the user
class AuctionPush {
  AuctionPush._();

  static const autoBidPlaced = 'auto_bid_placed';
  static const autoBidStopped = 'auto_bid_stopped';
  static const outbid = 'outbid';

  static String _action(Map<String, dynamic> data) =>
      data['action']?.toString() ?? '';

  static bool isAuctionUpdate(Map<String, dynamic> data) =>
      const {autoBidPlaced, autoBidStopped, outbid}.contains(_action(data));

  /// Screen to open when the user taps the push, or null for pushes this handler doesn't own.
  static String? routeFor(Map<String, dynamic> data) {
    switch (_action(data)) {
      case autoBidPlaced:
      case autoBidStopped:
        return AppRoutes.myWatchlist;
      case outbid:
        return AppRoutes.myBids;
      default:
        return null;
    }
  }

  /// A push arrived while the app is open: refresh whichever auction screens are showing bids.
  static void onReceived(Map<String, dynamic> data) {
    if (!isAuctionUpdate(data)) return;
    try {
      WatchlistController.refreshIfOpen();
      if (Get.isRegistered<VehicleListingController>()) {
        Get.find<VehicleListingController>().silentRefresh();
      }
    } catch (e) {
      debugPrint('⚠️ [AuctionPush.onReceived] $e');
    }
  }

  /// The user tapped an auction push. Returns true if it was handled (navigated).
  /// On a cold start the navigator isn't ready yet; the app then just opens normally.
  static bool onOpened(Map<String, dynamic> data) {
    final route = routeFor(data);
    if (route == null || Get.key.currentState == null) return false;
    onReceived(data);
    if (Get.currentRoute == route) return true;
    Get.toNamed(route);
    return true;
  }
}

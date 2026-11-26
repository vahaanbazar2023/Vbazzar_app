import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../approved_vehicles/services/approved_access_gate.dart';

/// Opens a link from a Vaani reply inside the app.
///
/// Vaani is the website's assistant, so its links are website paths
/// (`/app/buy-sell`, `/app/auctions/vehicle/AV123`, ...), sometimes as full
/// vahaanbazar URLs. Every `/app/...` path is mapped to the matching app
/// screen, with the same rules the app uses elsewhere:
///  * auctions need the auction plan, otherwise the plan screen opens;
///  * a vehicle id opens that vehicle (approved vehicles are loaded first);
///  * screens that need a category to be picked open their module home.
///
/// Website-only pages (policies, blog, about, careers, ...) open in an in-app
/// browser tab; phone, mail, WhatsApp and store links go to their own apps.
class VaaniLinkRouter {
  VaaniLinkRouter._();

  static const _websiteHosts = {
    'vahaanbazar.com',
    'www.vahaanbazar.com',
    'vahaanbazar.in',
    'www.vahaanbazar.in',
  };

  /// Exact `/app/...` paths → app routes that open without arguments.
  static const Map<String, String> _screens = {
    '/app': AppRoutes.search,
    '/app/search': AppRoutes.search,
    // Auctions: the user's own lists.
    '/app/auctions/my-bids': AppRoutes.myBids,
    '/app/auctions/my-wins': AppRoutes.myWins,
    '/app/auctions/wishlist': AppRoutes.myWishlist,
    '/app/auctions/gate-passes': AppRoutes.myGatePasses,
    // Buy & sell. Selling needs a category, which is picked on the home.
    '/app/buy-sell': AppRoutes.buySellHome,
    '/app/buy-sell/listings': AppRoutes.buySellHome,
    '/app/buy-sell/subscribed': AppRoutes.buySellHome,
    '/app/buy-sell/my-vehicles': AppRoutes.buySellHome,
    '/app/buy-sell/wishlist': AppRoutes.buySellHome,
    '/app/buy-sell/sell': AppRoutes.buySellHome,
    // Approved vehicles (bookings, inspections and selling live on its home).
    '/app/approved': AppRoutes.approvedVehicleBuySell,
    '/app/approved/category': AppRoutes.approvedVehicleCategory,
    '/app/approved/listings': AppRoutes.approvedVehicleCategory,
    '/app/approved/bookings': AppRoutes.approvedVehicleBuySell,
    '/app/approved/inspections': AppRoutes.approvedVehicleBuySell,
    '/app/approved/sell': AppRoutes.approvedVehicleBuySell,
    // Inspection & valuation.
    '/app/inspection': AppRoutes.inspectionHome,
    '/app/inspection/new': AppRoutes.inspectionHome,
    '/app/inspection/mine': AppRoutes.inspectionHome,
    '/app/inspection/agent': AppRoutes.inspectionHome,
    // Insurance & finance.
    '/app/insurance-finance': AppRoutes.insuranceFinance,
    '/app/insurance-finance/apply': AppRoutes.insuranceFinance,
    '/app/insurance-finance/quotes': AppRoutes.insuranceFinance,
    // Spares & FMS.
    '/app/spares': AppRoutes.spareFms,
    '/app/spares/shops': AppRoutes.spareFms,
    '/app/spares/orders': AppRoutes.spareOrders,
    // Service support.
    '/app/services': AppRoutes.serviceSupport,
    // Plans.
    '/app/subscription': AppRoutes.subscription,
    '/app/subscription/confirm': AppRoutes.subscription,
    '/app/subscription/mine': AppRoutes.mySubscriptions,
    // Wallet & rewards.
    '/app/wallet': AppRoutes.walletDashboard,
    '/app/rewards': AppRoutes.walletDashboard,
    '/app/wallet/cash-out': AppRoutes.cashOut,
    '/app/wallet/refund': AppRoutes.initiateRefund,
    // Account.
    '/app/profile': AppRoutes.profile,
    '/app/settings': AppRoutes.profile,
    '/app/notifications': AppRoutes.notifications,
    '/app/partner': AppRoutes.partnerWithUs,
    '/app/vendor': AppRoutes.partnerWithUs,
  };

  /// Path prefixes (`prefix/<anything>`) → app routes, for detail pages the
  /// app can't open by id; the user lands on the list instead.
  static const Map<String, String> _sections = {
    '/app/auctions/my-bids/': AppRoutes.myBids,
    '/app/auctions/my-wins/': AppRoutes.myWins,
    '/app/inspection/': AppRoutes.inspectionHome,
    '/app/insurance-finance/quotes/': AppRoutes.insuranceFinance,
    '/app/spares/orders/': AppRoutes.spareOrders,
    '/app/spares/': AppRoutes.spareFms,
    '/app/services/': AppRoutes.serviceSupport,
    '/app/vendor/': AppRoutes.partnerWithUs,
  };

  static Future<void> open(String href) async {
    final link = href.trim();
    if (link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // Our own website, as a relative path or a full URL → try an app screen.
    if (_isOwnSite(uri)) {
      final path = _normalise(uri.path);
      if (await _openInApp(path)) return;
      // A website-only page: show it without leaving the app.
      await _openWeb(_absolute(uri));
      return;
    }

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      // Play/App Store, WhatsApp, social: their own apps handle these best.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    // tel:, mailto:, upi:, ...
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  static bool _isOwnSite(Uri uri) {
    if (!uri.hasScheme) return uri.path.startsWith('/');
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    final chatHost = Uri.tryParse(ApiConstants.chatBaseUrl)?.host;
    return _websiteHosts.contains(uri.host) || uri.host == chatHost;
  }

  static String _normalise(String path) {
    final p = path.replaceAll(RegExp(r'/+$'), '');
    return p.isEmpty ? '/' : p;
  }

  static Uri _absolute(Uri uri) => uri.hasScheme
      ? uri
      : Uri.parse('${ApiConstants.chatBaseUrl}${uri.toString()}');

  /// Returns true when [path] was handled inside the app.
  static Future<bool> _openInApp(String path) async {
    // Signing in: the app user is already signed in (Vaani is only reachable
    // from inside the app), so there is nothing to open.
    if (path == '/login' || path == '/signup' || path == '/register') {
      return true;
    }
    if (!path.startsWith('/app')) return false;

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    // Vehicles by id.
    if (segments.length == 4 && segments[2] == 'vehicle') {
      final id = Uri.decodeComponent(segments[3]);
      switch (segments[1]) {
        case 'buy-sell':
          return _openContent('buy_vehicle', id);
        case 'approved':
          return _openContent('approved_vehicle', id);
        case 'auctions':
          return _openContent('auction_vehicle', id);
      }
    }

    // Anything else under auctions browses the auction module: plan check.
    if (path == '/app/auctions' ||
        path == '/app/auctions/category' ||
        path == '/app/auctions/list' ||
        path == '/app/auctions/vehicles') {
      return _openContent('live_auction', '');
    }

    final screen = _screens[path];
    if (screen == AppRoutes.approvedVehicleCategory) {
      await openApprovedVehicles(screen!); // Gold plan only
      return true;
    }
    if (screen != null) {
      Get.toNamed(screen);
      return true;
    }
    for (final entry in _sections.entries) {
      if (path.startsWith(entry.key)) {
        Get.toNamed(entry.value);
        return true;
      }
    }
    // Some other app page (payment result, partner tools, ...): app home.
    Get.until((route) => route.isFirst);
    return true;
  }

  static Future<bool> _openContent(String type, String id) async {
    if (!Get.isRegistered<DeepLinkService>()) return false;
    final userId = await SecureStorageService.instance.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) {
      Get.toNamed(AppRoutes.login);
      return true;
    }
    await DeepLinkService.to.openContent(type, id);
    return true;
  }

  static Future<void> _openWeb(Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return;
    } catch (_) {}
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

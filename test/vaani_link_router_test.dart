import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/features/chatbot/services/vaani_link_router.dart';
import 'package:vahaan_mobile_2_0/routes/app_routes.dart';

/// Vaani links to website paths; each must land on the app screen, not a browser.
void main() {
  Future<String> openFrom(WidgetTester tester, String href) async {
    final routes = <String>{
      AppRoutes.search,
      AppRoutes.myBids,
      AppRoutes.myWins,
      AppRoutes.buySellHome,
      AppRoutes.approvedVehicleBuySell,
      AppRoutes.approvedVehicleCategory,
      AppRoutes.inspectionHome,
      AppRoutes.insuranceFinance,
      AppRoutes.spareFms,
      AppRoutes.spareOrders,
      AppRoutes.serviceSupport,
      AppRoutes.subscription,
      AppRoutes.mySubscriptions,
      AppRoutes.walletDashboard,
      AppRoutes.cashOut,
      AppRoutes.initiateRefund,
      AppRoutes.profile,
      AppRoutes.notifications,
      AppRoutes.partnerWithUs,
    };
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(name: '/home', page: () => const Text('home')),
          for (final r in routes) GetPage(name: r, page: () => Text(r)),
        ],
      ),
    );
    await VaaniLinkRouter.open(href);
    await tester.pumpAndSettle();
    final route = Get.currentRoute;
    Get.reset();
    return route;
  }

  const cases = {
    '/app/buy-sell': AppRoutes.buySellHome,
    '/app/buy-sell/sell': AppRoutes.buySellHome,
    '/app/approved': AppRoutes.approvedVehicleBuySell,
    '/app/approved/listings': AppRoutes.approvedVehicleCategory,
    '/app/inspection/new': AppRoutes.inspectionHome,
    '/app/inspection/INS123': AppRoutes.inspectionHome,
    '/app/insurance-finance/quotes/Q1': AppRoutes.insuranceFinance,
    '/app/spares/SP1': AppRoutes.spareFms,
    '/app/spares/orders/O1': AppRoutes.spareOrders,
    '/app/services': AppRoutes.serviceSupport,
    '/app/subscription': AppRoutes.subscription,
    '/app/subscription/mine': AppRoutes.mySubscriptions,
    '/app/rewards': AppRoutes.walletDashboard,
    '/app/wallet/cash-out': AppRoutes.cashOut,
    '/app/wallet/refund': AppRoutes.initiateRefund,
    '/app/auctions/my-bids': AppRoutes.myBids,
    '/app/auctions/my-wins/W1': AppRoutes.myWins,
    '/app/profile': AppRoutes.profile,
    '/app/notifications/': AppRoutes.notifications,
    '/app/partner?x=1': AppRoutes.partnerWithUs,
    'https://www.vahaanbazar.com/app/spares': AppRoutes.spareFms,
    'https://vahaanbazar.in/app/buy-sell': AppRoutes.buySellHome,
    '/app/payment/result': '/home',
    '/login': '/home',
  };

  for (final c in cases.entries) {
    testWidgets('${c.key} → ${c.value}', (tester) async {
      expect(await openFrom(tester, c.key), c.value);
    });
  }
}

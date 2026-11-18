import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/auction/controllers/watchlist_controller.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/auction_pagination.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/vehicle_listing.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/auto_bid_service.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_listing_service.dart';
import 'package:vahaan_mobile_2_0/features/auction/views/my_wishlist_view.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';

VehicleListing _v({bool auto = false, int count = 2}) =>
    VehicleListing.fromJson({
      'id': 1,
      'vehicle_id': 'VEH1',
      'auction_id': 'AUC1',
      'make': 'Tata',
      'model': 'Signa',
      'registration_no': 'MH01AB1234',
      'your_bid': 100000,
      'current_highest_bid': 110000,
      'minimum_next_bid': 115000,
      'bid_increment_amount': 5000,
      'user_vehicle_bid_count': count,
      'max_user_vehicles_bid_limit': 10,
      'available_balance': 500000,
      'is_watchlisted': true,
      'is_auto_bid_enabled': auto,
      'auction_end_date': '', // no running timer in tests
    });

class _FakeListing extends VehicleListingService {
  _FakeListing(this.items);
  List<VehicleListing> items;
  int calls = 0;
  @override
  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  fetchWatchlistedVehicles({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    calls++;
    return (vehicles: items, pagination: AuctionPagination.empty());
  }
}

class _FakeAutoBid extends AutoBidService {
  _FakeAutoBid() : super(network: null);
  final calls = <bool>[];
  AutoBidException? fail;
  @override
  Future<AutoBidState> setAutoBid({
    required String userId,
    required String vehicleId,
    required bool enabled,
  }) async {
    calls.add(enabled);
    if (fail != null) throw fail!;
    return AutoBidState(
      vehicleId: vehicleId,
      isEnabled: enabled,
      bidsPlaced: enabled ? 1 : 0,
      yourBid: enabled ? 115000 : 100000,
      bidCount: enabled ? 3 : 2,
      currentHighestBid: enabled ? 115000 : 110000,
      isHighestBidder: enabled,
      remainingBidLimit: 385000,
    );
  }
}

Future<(WatchlistController, _FakeListing, _FakeAutoBid)> _pump(
  WidgetTester tester, {
  List<VehicleListing>? items,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(375, 812) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Get.reset();
  Get.put(MainShellController()); // AppLayout's bottom nav
  final listing = _FakeListing(items ?? [_v()]);
  final auto = _FakeAutoBid();
  final c = Get.put(
    WatchlistController(
      listingService: listing,
      autoBidService: auto,
      userId: () async => 'VB1',
    ),
  );
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MyWatchlistView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (c, listing, auto);
}

void main() {
  tearDown(Get.reset);

  testWidgets('lists watchlisted vehicles with an auto-bid switch', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('My Watchlist'), findsOneWidget);
    expect(find.text('Tata Signa'), findsOneWidget);
    expect(find.text('Auto-bid'), findsOneWidget);
    expect(
      find.text(
        'When someone outbids you, we place your next bid automatically.',
      ),
      findsOneWidget,
    );
    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.value, isFalse);
  });

  testWidgets(
    'switching on asks first, then calls the API and shows the new state',
    (tester) async {
      final (c, listing, auto) = await _pump(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Switch on auto-bid?'), findsOneWidget);
      expect(find.textContaining('+ ₹5,000'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(auto.calls, isEmpty); // cancelled: nothing sent

      listing.items = [
        _v(auto: true, count: 3),
      ]; // what the server lists after the immediate auto-bid
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch on'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(auto.calls, [true]);
      expect(listing.calls, 2); // auto-bid placed a bid → list refreshed
      expect(c.vehicles.single.isAutoBidEnabled, isTrue);
      expect(c.vehicles.single.userVehicleBidCount, 3);
      expect(find.text('On · bid 3 of 10'), findsOneWidget);
    },
  );

  testWidgets('switching off needs no confirmation', (tester) async {
    final (c, _, auto) = await _pump(tester, items: [_v(auto: true)]);
    expect(find.text('On · bid 2 of 10'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(auto.calls, [false]);
    expect(c.vehicles.single.isAutoBidEnabled, isFalse);
  });

  testWidgets('a refused switch-on rolls the switch back', (tester) async {
    final (c, _, auto) = await _pump(tester);
    auto.fail = const AutoBidException(
      'MAX_BID_LIMIT_REACHED',
      'You have used all 10 bids on this vehicle.',
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch on'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(c.vehicles.single.isAutoBidEnabled, isFalse);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('empty watchlist explains how to add vehicles', (tester) async {
    await _pump(tester, items: const []);
    expect(find.textContaining('Tap the eye icon'), findsOneWidget);
  });

  testWidgets('fits in every app language without overflow', (tester) async {
    for (final lang in ['en', 'hi', 'te', 'kn', 'ml', 'ta']) {
      await _pump(tester, locale: Locale(lang), items: [_v(auto: true)]);
      expect(tester.takeException(), isNull, reason: lang);
    }
  });
}

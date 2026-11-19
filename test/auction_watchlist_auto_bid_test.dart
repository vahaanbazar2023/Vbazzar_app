import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/services/notification_service.dart';
import 'package:vahaan_mobile_2_0/features/auction/controllers/watchlist_controller.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/vehicle_listing.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/auction_push.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/auto_bid_service.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_listing_service.dart';
import 'package:vahaan_mobile_2_0/routes/app_routes.dart';

Map<String, dynamic> _vehicle([Map<String, dynamic> extra = const {}]) => {
  'id': 7,
  'vehicle_id': 'VEH1',
  'auction_id': 'AUC1',
  'make': 'Tata',
  'model': 'Signa',
  'your_bid': 1000,
  'current_highest_bid': 1200,
  'user_vehicle_bid_count': 2,
  'max_user_vehicles_bid_limit': 10,
  'bank_name': 'HDFC',
  'is_wishlisted': true,
  ...extra,
};

void main() {
  group('VehicleListing watchlist / auto-bid flags', () {
    test('parsed from is_watchlisted / is_auto_bid_enabled', () {
      final v = VehicleListing.fromJson(
        _vehicle({'is_watchlisted': true, 'is_auto_bid_enabled': true}),
      );
      expect(v.isWatchlisted, isTrue);
      expect(v.isAutoBidEnabled, isTrue);
    });

    test('older responses without the flags default to off', () {
      final v = VehicleListing.fromJson(_vehicle());
      expect(v.isWatchlisted, isFalse);
      expect(v.isAutoBidEnabled, isFalse);
    });

    test('auto-bid limit is parsed and can be cleared with copyWith', () {
      final v = VehicleListing.fromJson(
        _vehicle({
          'is_auto_bid_enabled': true,
          'auto_bid_max_amount': 250000.0,
        }),
      );
      expect(v.autoBidMaxAmount, 250000);
      expect(
        v.copyWith(isWishlisted: false).autoBidMaxAmount,
        250000,
      ); // kept when not passed
      expect(
        v.copyWith(autoBidMaxAmount: null).autoBidMaxAmount,
        isNull,
      ); // cleared
      expect(VehicleListing.fromJson(_vehicle()).autoBidMaxAmount, isNull);
    });

    test(
      'limit bounds: next bid when losing, a step above own bid when on top',
      () {
        final losing = VehicleListing.fromJson(
          _vehicle({'minimum_next_bid': 1300, 'bid_increment_amount': 100}),
        );
        expect(losing.minimumAutoBidLimit, 1300);
        final onTop = VehicleListing.fromJson(
          _vehicle({
            'your_bid': 1200,
            'current_highest_bid': 1200,
            'bid_increment_amount': 100,
          }),
        );
        expect(onTop.minimumAutoBidLimit, 1300);
        expect(
          VehicleListing.fromJson(
            _vehicle({'available_balance': 5000}),
          ).buyingLimitForVehicle,
          6000,
        );
      },
    );

    test('copyWith changes only what it is given', () {
      final v = VehicleListing.fromJson(_vehicle({'is_watchlisted': true}));
      final c = v.copyWith(
        isAutoBidEnabled: true,
        yourBid: 1300,
        userVehicleBidCount: 3,
      );
      expect(c.isAutoBidEnabled, isTrue);
      expect(c.yourBid, 1300);
      expect(c.userVehicleBidCount, 3);
      expect(c.isWatchlisted, isTrue);
      expect(c.isWishlisted, isTrue);
      expect(c.bankName, 'HDFC');
      expect(c.currentHighestBid, 1200);
      expect(c.vehicleId, 'VEH1');
      expect(c.id, 7);
    });
  });

  group('watchlist listing request', () {
    test('watchlisted_only is sent only for the watchlist', () {
      final normal = VehicleListingService.buildRequestBody(
        userId: 'U',
        auctionType: 'live_auctions',
        vehicleType: '4w',
      );
      expect(normal.containsKey('watchlisted_only'), isFalse);

      final watch = VehicleListingService.buildRequestBody(
        userId: 'U',
        auctionType: '',
        vehicleType: '',
        watchlistedOnly: true,
      );
      expect(watch['watchlisted_only'], isTrue);
      expect(watch['wishlisted_only'], isFalse);
      expect(watch['vehicle_type'], '');
    });
  });

  group('AutoBidService responses', () {
    test('success body → data', () {
      final data = AutoBidService.dataOf({
        'status': 'success',
        'data': {
          'vehicle_id': 'VEH1',
          'is_watchlisted': true,
          'is_auto_bid_enabled': false,
        },
      });
      final r = WatchlistToggleResult.fromJson(data);
      expect(r.isWatchlisted, isTrue);
      expect(r.isAutoBidEnabled, isFalse);
    });

    test('error body → AutoBidException with the server code', () {
      expect(
        () => AutoBidService.dataOf({
          'status': 'error',
          'message': 'No bid limit',
          'error': {
            'code': 'NO_ACTIVE_SUBSCRIPTION',
            'message': 'No bid limit available.',
          },
        }),
        throwsA(
          isA<AutoBidException>()
              .having((e) => e.code, 'code', 'NO_ACTIVE_SUBSCRIPTION')
              .having((e) => e.message, 'message', 'No bid limit available.')
              .having((e) => e.needsBidLimit, 'needsBidLimit', isTrue),
        ),
      );
    });

    test('limit errors send the user to buy a plan; others do not', () {
      expect(
        const AutoBidException('BID_EXCEEDS_LIMIT', '').needsBidLimit,
        isTrue,
      );
      expect(
        const AutoBidException('MAX_BID_LIMIT_REACHED', '').needsBidLimit,
        isFalse,
      );
      expect(
        const AutoBidException('AUCTION_ENDED', '').needsBidLimit,
        isFalse,
      );
    });

    test('a body without data is an error, not a crash', () {
      expect(
        () => AutoBidService.dataOf({'status': 'success'}),
        throwsA(isA<AutoBidException>()),
      );
    });

    test('auto-bid state parses the toggle response (floats included)', () {
      final s = AutoBidState.fromJson({
        'vehicle_id': 'VEH1',
        'is_auto_bid_enabled': true,
        'auto_bid_stop_reason': null,
        'auto_bids_placed': 1,
        'your_bid': 1300.0,
        'user_vehicle_bid_count': 3,
        'max_user_vehicles_bid_limit': 10,
        'current_highest_bid': 1300.0,
        'is_highest_bidder': true,
        'remaining_bid_limit': 48700.0,
      });
      expect(s.isEnabled, isTrue);
      expect(s.bidsPlaced, 1);
      expect(s.yourBid, 1300);
      expect(s.bidCount, 3);
      expect(s.isHighestBidder, isTrue);
      expect(s.remainingBidLimit, 48700);
      expect(s.stopReason, isNull);
    });

    test('stopped state keeps the reason', () {
      final s = AutoBidState.fromJson({
        'vehicle_id': 'VEH1',
        'is_auto_bid_enabled': false,
        'auto_bid_stop_reason': 'insufficient_limit',
      });
      expect(s.isEnabled, isFalse);
      expect(s.stopReason, 'insufficient_limit');
      expect(s.maxBids, 10);
    });
  });

  group('auction pushes', () {
    test('auto-bid pushes open the watchlist, outbid opens my bids', () {
      expect(
        AuctionPush.routeFor({'action': 'auto_bid_placed'}),
        AppRoutes.myWatchlist,
      );
      expect(
        AuctionPush.routeFor({'action': 'auto_bid_stopped'}),
        AppRoutes.myWatchlist,
      );
      expect(AuctionPush.routeFor({'action': 'outbid'}), AppRoutes.myBids);
    });

    test('other pushes are left alone', () {
      expect(AuctionPush.routeFor({'action': 'bid_success'}), isNull);
      expect(AuctionPush.routeFor({}), isNull);
      expect(
        AuctionPush.isAuctionUpdate({'action': 'winning_letter'}),
        isFalse,
      );
      expect(
        AuctionPush.isAuctionUpdate({'action': 'auto_bid_placed'}),
        isTrue,
      );
    });

    test('local-notification payload round-trips as JSON', () {
      expect(
        NotificationService.decodePayload(
          '{"action":"auto_bid_placed","vehicle_id":"VEH1"}',
        ),
        {'action': 'auto_bid_placed', 'vehicle_id': 'VEH1'},
      );
      expect(
        NotificationService.decodePayload('{action: outbid}'),
        isNull,
      ); // old toString() format
      expect(NotificationService.decodePayload(null), isNull);
    });

    test('amounts are formatted with thousands separators', () {
      expect(WatchlistController.formatAmount(1300), '1,300');
      expect(WatchlistController.formatAmount(100), '100');
      expect(WatchlistController.formatAmount(1234567), '1,234,567');
    });
  });
}

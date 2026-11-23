import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/auction_listing.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_listing_service.dart';

/// A home `live_auctions` item as the backend sends it.
Map<String, dynamic> _card({Map<String, dynamic>? redirect, String start = '2026-01-01T10:00:00+00:00'}) => {
  'id': 7,
  'auction_id': 'AUC123',
  'auction_title': 'HDFC CV Auction',
  'start_at': start,
  'end_at': '2099-01-01T10:00:00+00:00',
  'status': 'active',
  'vehicle_type': 'CV',
  'vehicle_count': 12,
  'dashboard_image_url': 'https://img/x.png',
  if (redirect != null) 'redirect': redirect,
};

void main() {
  test('banner opens that auction\'s vehicle list (redirect from backend)', () {
    final auction = AuctionListing.fromJson(_card(redirect: {
      'screen': 'auction_vehicle_listing',
      'params': {'auction_id': 'AUC123', 'auction_type': 'live_auctions', 'vehicle_type': 'cv'},
      'auction_title': 'HDFC CV Auction',
      'bid_increment_amount': 2000,
    }));

    expect(auction.vehicleListArguments(), {
      'auctionId': 'AUC123',
      'auctionType': 'live_auctions',
      'initialTab': 0,
      'vehicleType': 'cv',
      'auctionTitle': 'HDFC CV Auction',
      'bidIncrementAmount': 2000,
    });
  });

  test('without the redirect block it still opens that auction (older backend)', () {
    final args = AuctionListing.fromJson(_card()).vehicleListArguments();
    expect(args['auctionId'], 'AUC123');
    expect(args['vehicleType'], 'cv');
    expect(args['auctionType'], 'live_auctions');
    expect(args.containsKey('bidIncrementAmount'), isFalse);
  });

  test('an auction that has not started opens on the Upcoming tab', () {
    final args = AuctionListing.fromJson(_card(start: '2099-01-01T09:00:00+00:00')).vehicleListArguments();
    expect(args['auctionType'], 'upcoming_auctions');
    expect(args['initialTab'], 2);
  });

  test('auction_id is sent only when one auction is asked for', () {
    final one = VehicleListingService.buildRequestBody(
      userId: 'VB1', auctionType: 'live_auctions', vehicleType: 'cv', auctionId: 'AUC123');
    expect(one['auction_id'], 'AUC123');

    final all = VehicleListingService.buildRequestBody(
      userId: 'VB1', auctionType: 'live_auctions', vehicleType: 'cv');
    expect(all.containsKey('auction_id'), isFalse);
  });
}

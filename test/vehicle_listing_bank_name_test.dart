import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/vehicle_listing.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_listing_service.dart';

Map<String, dynamic> _json({Object? bank = _absent}) => {
  'id': 1,
  'vehicle_id': 'VEH1',
  'auction_id': 'AUC1',
  'make': 'Tata',
  'model': 'Signa',
  if (bank != _absent) 'bank_name': bank,
};

const Object _absent = Object();

void main() {
  _contractTests();
  test('bank_name from /vehicle-listings-pagination is parsed', () {
    expect(VehicleListing.fromJson(_json(bank: 'HDFC Bank')).bankName, 'HDFC Bank');
  });

  test('the server sends NIL when there is no bank, and it is kept as received', () {
    expect(VehicleListing.fromJson(_json(bank: 'NIL')).bankName, 'NIL');
  });

  test('older responses without bank_name still parse', () {
    expect(VehicleListing.fromJson(_json()).bankName, '');
    expect(VehicleListing.fromJson(_json(bank: null)).bankName, '');
  });
}

// ── request / response as documented for /vehicle-listings-pagination ────────────────────────
void _contractTests() {
  group('vehicle-listings-pagination contract', () {
    test('request body is exactly the documented one', () {
      expect(
        VehicleListingService.buildRequestBody(
          userId: 'VB0000001',
          auctionType: 'live_auctions',
          vehicleType: '4w',
          category: 'bank',
        ),
        {
          'user_id': 'VB0000001',
          'auction_type': 'live_auctions',
          'vehicle_type': '4w',
          'category': 'bank',
          'region_id': '',
          'state_id': '',
          'bank_name': '',
          'wishlisted_only': false,
          'page': 1,
          'limit': 20,
        },
      );
    });

    test('bank filter is trimmed and never null; wishlist flag is passed', () {
      final b = VehicleListingService.buildRequestBody(
        userId: 'U',
        auctionType: 'live_auctions',
        vehicleType: '4w',
        bankName: '  HDFC Bank ',
        wishlistedOnly: true,
      );
      expect(b['bank_name'], 'HDFC Bank');
      expect(b['wishlisted_only'], isTrue);
    });

    final response = {
      'vehicle_type': '4w',
      'vehicles': [
        {
          'id': 1423,
          'vehicle_id': 'VEH000001423',
          'auction_id': 'AUC000000035',
          'make': 'Honda',
          'model': 'HONDA CITY 1.5 V MT PETROL',
          'bank_name': 'NIL',
          'owner': 'Vahaan Bazar',
          'images': ['https://d292d9iyz44uws.cloudfront.net/VEH000001423_1.jpg'],
        },
        {
          'id': 1424,
          'vehicle_id': 'VEH000001424',
          'auction_id': 'AUC000000035',
          'make': 'TATA',
          'model': 'TATA TIGOR',
          'bank_name': 'HDFC Bank',
        },
      ],
      'pagination': {
        'current_page': 1,
        'total_pages': 2,
        'total_count': 33,
        'limit': 20,
        'has_next': true,
        'has_previous': false,
      },
    };

    test('response parses with and without the top-level data wrapper', () {
      for (final body in [response, {'status': 'success', 'data': response}]) {
        final r = VehicleListingService.parseResponse(body);
        expect(r.vehicles.map((v) => v.bankName), ['NIL', 'HDFC Bank']);
        expect(r.pagination.hasNext, isTrue);
        expect(r.pagination.totalCount, 33);
      }
    });

    test('NIL is hidden in the UI, a real bank is shown', () {
      final r = VehicleListingService.parseResponse(response);
      expect(r.vehicles[0].displayBankName, '');
      expect(r.vehicles[1].displayBankName, 'HDFC Bank');
      expect(VehicleListing.fromJson(_json(bank: ' nil ')).displayBankName, '');
    });

    test('an empty page parses', () {
      final r = VehicleListingService.parseResponse(<String, dynamic>{
        'vehicles': <dynamic>[],
        'pagination': <String, dynamic>{},
      });
      expect(r.vehicles, isEmpty);
    });
  });
}

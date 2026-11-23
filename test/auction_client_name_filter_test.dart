import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auction/controllers/vehicle_listing_controller.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/vehicle_listing_service.dart';

void main() {
  test('Client Name dropdown lists the banks from /auctions/auction-banks', () {
    final names = VehicleListingController.parseBankNames({
      'status': 'success',
      'data': {
        'banks': [
          {'id': 1, 'bank_name': 'AU Small Finance Bank', 'display_order': 0},
          {'id': 2, 'bank_name': 'HDFC Bank', 'display_order': 0},
          {'id': 3, 'bank_name': ' NIL ', 'display_order': 0},
          {'id': 4, 'bank_name': '', 'display_order': 0},
          {'id': 5, 'bank_name': 'HDFC Bank', 'display_order': 0},
        ],
      },
    });
    expect(names, ['AU Small Finance Bank', 'HDFC Bank']);
  });

  test('an unexpected response gives an empty list, not a crash', () {
    expect(VehicleListingController.parseBankNames(null), isEmpty);
    expect(VehicleListingController.parseBankNames({'data': {}}), isEmpty);
  });

  test('the chosen client is sent as bank_name', () {
    final body = VehicleListingService.buildRequestBody(
      userId: 'VB1', auctionType: 'live_auctions', vehicleType: 'cv', bankName: 'HDFC Bank');
    expect(body['bank_name'], 'HDFC Bank');
  });
}

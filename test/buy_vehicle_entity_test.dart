import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/buy_and_sell/domain/entities/buy_vehicle_entity.dart';

BuyVehicleEntity _v({double? price, String? access, bool interested = false}) =>
    BuyVehicleEntity(
      id: 'V1',
      categoryCode: 'C1',
      categoryName: 'Cat',
      price: price,
      vehicleDetailsAccess: access,
      isInterested: interested,
    );

void main() {
  group('BuyVehicleEntity.displayPrice', () {
    test('shows full price when vehicle_details_access is yes', () {
      expect(_v(price: 2500000, access: 'yes').displayPrice, '₹25,00,000');
    });

    test('masks everything but the first digit when access is not yes', () {
      expect(_v(price: 2500000, access: 'no').displayPrice, '₹2x,xx,xxx');
      expect(_v(price: 2500000).displayPrice, '₹2x,xx,xxx');
    });

    test('masks short prices', () {
      expect(_v(price: 750).displayPrice, '₹7xx');
    });

    test('does not mask the price-on-request text', () {
      final v = _v(price: null, access: 'no');
      expect(v.displayPrice, v.formattedPrice);
      expect(v.displayPrice.contains('x'), isFalse);
    });

    test('access check is case-insensitive', () {
      expect(_v(price: 100000, access: 'YES').displayPrice, '₹1,00,000');
    });
  });

  group('BuyVehicleEntity.parseFlag', () {
    test('parses bools, yes/true/1 strings', () {
      expect(BuyVehicleEntity.parseFlag(true), true);
      expect(BuyVehicleEntity.parseFlag(false), false);
      expect(BuyVehicleEntity.parseFlag('yes'), true);
      expect(BuyVehicleEntity.parseFlag('TRUE'), true);
      expect(BuyVehicleEntity.parseFlag('1'), true);
      expect(BuyVehicleEntity.parseFlag('no'), false);
      expect(BuyVehicleEntity.parseFlag('false'), false);
    });

    test('returns null when absent or empty', () {
      expect(BuyVehicleEntity.parseFlag(null), isNull);
      expect(BuyVehicleEntity.parseFlag(''), isNull);
    });
  });

  group('BuyVehicleEntity.fromSingleVehicleJson', () {
    test('reads odometer, document flags and is_interested', () {
      final e = BuyVehicleEntity.fromSingleVehicleJson({
        'sb_vehicle_id': 'BSVEH1',
        'category_code': 'C1',
        'category_name': 'Cat',
        'odometer': 60000,
        'fitness': true,
        'insurance': 'yes',
        'original_invoice': false,
        'gst_applicability': 'true',
        'is_interested': 'yes',
      });
      expect(e.odometer, '60000');
      expect(e.fitness, true);
      expect(e.insurance, true);
      expect(e.originalInvoice, false);
      expect(e.gstApplicability, true);
      expect(e.isInterested, true);
    });

    test('flags stay null (rows hidden) when the API omits them', () {
      final e = BuyVehicleEntity.fromSingleVehicleJson({
        'sb_vehicle_id': 'BSVEH1',
        'category_code': 'C1',
        'category_name': 'Cat',
      });
      expect(e.fitness, isNull);
      expect(e.odometer, isNull);
      expect(e.isInterested, false);
    });
  });
}

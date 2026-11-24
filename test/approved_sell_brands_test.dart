import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/controllers/approved_vehicle_controller.dart';

typedef C = ApprovedVehicleController;

void main() {
  test('each Approved category reads its matching Buy & Sell brand lists', () {
    expect(C.brandSourcesFor('4W'), ['CARS']);
    expect(C.brandSourcesFor('cv'), ['TRUC', 'LCVH', 'ICVH', 'TIPR', 'TRLR', 'BUSS']);
    expect(C.brandSourcesFor('CE'), contains('EXCV'));
    expect(C.brandSourcesFor('FE'), ['FARM']);
  });

  test('2W and 3W read their own brand-only categories (2W / 3W)', () {
    expect(C.brandSourcesFor('2W'), ['2W']);
    expect(C.brandSourcesFor('3w'), ['3W']);
    expect(C.brandSourcesFor(''), isEmpty);
  });

  test('a code that is already a Buy & Sell category is used as is', () {
    expect(C.brandSourcesFor('TRUC'), ['TRUC']);
  });

  test('brand responses in every known shape are read', () {
    final row = {'brand_code': 'TATA', 'brand_name': 'Tata'};
    expect(C.parseBrandRows({'brands': [row]}), [row]);
    expect(C.parseBrandRows({'data': {'brands': [row]}}), [row]);
    expect(C.parseBrandRows({'data': [row]}), [row]);
    expect(C.parseBrandRows(null), isEmpty);
  });

  test('merged brands: one per name (any case), A to Z', () {
    final merged = C.mergeBrands([
      [{'brand_code': 'T1', 'brand_name': 'Tata'}, {'brand_code': 'A1', 'brand_name': 'Ashok Leyland'}],
      [{'brand_code': 'T2', 'brand_name': 'TATA'}, {'brand_code': 'E1', 'brand_name': 'Eicher'}],
    ]);
    expect(merged.map((b) => b['brand_name']), ['Ashok Leyland', 'Eicher', 'Tata']);
  });
}

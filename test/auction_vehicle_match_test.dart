import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/controllers/approved_vehicle_controller.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/domain/entities/auction_vehicle_match.dart';

void main() {
  final brands = [
    {'brand_code': 'TATA', 'brand_name': 'Tata'},
    {'brand_code': 'ASHO', 'brand_name': 'Ashok Leyland'},
    {'brand_code': 'MAHI', 'brand_name': 'Mahindra'},
    {'brand_code': 'MAHD', 'brand_name': 'Mahindra & Mahindra'},
  ];
  AuctionVehicleMatch make(String? m) =>
      AuctionVehicleMatch(vehicleId: 'V', make: m);
  AuctionVehicleMatch make_(String m) => make(m);

  test('the make finds its brand, ignoring case, spaces and suffixes', () {
    expect(make('TATA').matchBrand(brands)?['brand_code'], 'TATA');
    expect(make('Tata Motors').matchBrand(brands)?['brand_code'], 'TATA');
    expect(make('ashok-leyland').matchBrand(brands)?['brand_code'], 'ASHO');
    // the longest matching brand name wins
    expect(
      make('Mahindra & Mahindra Ltd').matchBrand(brands)?['brand_code'],
      'MAHD',
    );
  });

  test('short auction makes find our full brand names', () {
    final ours = [
      {'brand_code': 'TW_HERO', 'brand_name': 'Hero MotoCorp'},
      {'brand_code': 'MARU', 'brand_name': 'Maruti Suzuki'},
      {'brand_code': 'HYUN', 'brand_name': 'Hyundai'},
      {'brand_code': 'MAHI', 'brand_name': 'Mahindra'},
      {'brand_code': 'MAHD', 'brand_name': 'Mahindra & Mahindra'},
    ];
    String? code(String make) => make_(make).matchBrand(ours)?['brand_code'];
    expect(code('HERO'), 'TW_HERO'); // brand starts with the make
    expect(code('MARUTI'), 'MARU');
    expect(code('Maruti Suzuki India Ltd'), 'MARU'); // make starts with brand
    expect(code('HYUNDAI MOTOR INDIA'), 'HYUN');
    expect(code('MAHINDRA'), 'MAHI'); // exact beats longer names
    expect(code('Mahindra and Mahindra'), 'MAHI'); // same first word
  });

  test('no brand for an unknown or missing make', () {
    expect(make('Volvo').matchBrand(brands), isNull);
    expect(make(null).matchBrand(brands), isNull);
    expect(make('Tata').matchBrand(const []), isNull);
  });

  test('reads the lookup response, skipping blanks', () {
    final m = AuctionVehicleMatch.fromJson({
      'vehicle_id': 'VEH1',
      'vehicle': {
        'make': ' Tata ',
        'year_of_manufacturing': '2019',
        'chassis_number': '',
        'images': ['https://x/a.jpg', ' ', null],
      },
    });
    expect(m.vehicleId, 'VEH1');
    expect(m.make, 'Tata');
    expect(m.year, 2019);
    expect(m.chassisNumber, isNull);
    expect(m.images, ['https://x/a.jpg']);
  });

  test(
    'only real JPG/PNG/GIF photos are kept (the server checks the bytes)',
    () {
      String? ext(List<int> b) => ApprovedVehicleController.photoExtension(b);
      expect(ext([0xFF, 0xD8, 0xFF, 0xE0, 1]), 'jpg');
      expect(ext([0x89, 0x50, 0x4E, 0x47, 0x0D]), 'png');
      expect(ext([0x47, 0x49, 0x46, 0x38, 0x39]), 'gif');
      expect(ext('RIFF....WEBP'.codeUnits), isNull); // WEBP named .jpg
      expect(ext('<?xml AccessDenied'.codeUnits), isNull); // an S3 error page
      expect(ext(const []), isNull);
    },
  );
}

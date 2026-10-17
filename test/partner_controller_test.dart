import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/services/gps_location_service.dart';
import 'package:vahaan_mobile_2_0/features/partner/controllers/partner_controller.dart';
import 'package:vahaan_mobile_2_0/features/partner/data/partner_data_source.dart';
import 'package:vahaan_mobile_2_0/features/partner/models/partner_models.dart';
import 'package:vahaan_mobile_2_0/features/profile/models/profile_models.dart';

ProfileData _profile({String userType = 'CUSTOMER'}) => ProfileData(
  userId: 'VB0000013',
  username: 'ravi',
  firstName: 'Ravi',
  lastName: 'Kumar',
  email: 'ravi@x.com',
  phoneNumber: '9876543210',
  userType: userType,
  state: 'Telangana',
  city: 'Hyderabad',
  registrationStatus: 'completed',
  createdAt: '',
);

PartnerRequest _request(String status, {String? reason}) => PartnerRequest(
  requestId: 'PREQ0000001',
  role: 'MECHANIC',
  name: 'Ravi Kumar',
  mobileNumber: '9876543210',
  businessName: 'Ravi Garage',
  status: status,
  rejectionReason: reason,
);

class _FakeDataSource extends PartnerDataSource {
  PartnerRequest? existing;
  PartnerApiResult<PartnerRequest>? nextResult;
  PartnerRequestPayload? lastPayload;
  int submitCalls = 0;

  @override
  Future<PartnerRequest?> fetchMyRequest() async => existing;

  @override
  Future<PartnerApiResult<PartnerRequest>> submit(
    PartnerRequestPayload payload,
  ) async {
    submitCalls++;
    lastPayload = payload;
    return nextResult ??
        PartnerApiResult(
          success: true,
          code: 200,
          message: 'ok',
          data: _request('pending'),
        );
  }
}

class _FakeGps extends GpsLocationService {
  bool available = true;
  @override
  Future<bool> getCurrentLocation() async {
    if (!available) return false;
    latitude.value = 17.385044;
    longitude.value = 78.486671;
    hasLocation.value = true;
    return true;
  }
}

Future<PartnerController> _make(
  WidgetTester tester,
  _FakeDataSource ds, {
  ProfileData? profile,
}) async {
  // A GetMaterialApp gives the snackbars (used on error paths) an overlay.
  await tester.pumpWidget(
    const GetMaterialApp(home: Scaffold(body: SizedBox())),
  );
  final c = PartnerController(
    dataSource: ds,
    profileLoader: () async => profile ?? _profile(),
  );
  Get.put(c);
  await tester.pump();
  await tester.pump();
  return c;
}

/// Submits and lets the result snackbar finish (its timer would otherwise
/// still be pending when the test ends).
Future<void> _submit(WidgetTester tester, PartnerController c) async {
  await c.submit();
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  late _FakeGps gps;

  setUp(() {
    Get.reset();
    gps = _FakeGps();
    Get.put<GpsLocationService>(gps);
  });

  tearDown(Get.reset);

  testWidgets('name, mobile and user id come from the profile', (tester) async {
    final c = await _make(tester, _FakeDataSource());
    expect(c.isLoading.value, isFalse);
    expect(c.nameCtrl.text, 'Ravi Kumar');
    expect(c.mobileCtrl.text, '9876543210');
    expect(c.isCustomer, isTrue);
    expect(c.showStatus, isFalse);
  });

  testWidgets('empty form is rejected locally and never hits the API', (
    tester,
  ) async {
    final ds = _FakeDataSource();
    final c = await _make(tester, ds);
    await _submit(tester, c);
    expect(c.roleError.value, isNotNull);
    expect(c.businessNameError.value, isNotNull);
    expect(ds.submitCalls, 0);
  });

  testWidgets('aadhaar is optional but must be valid when given', (
    tester,
  ) async {
    final ds = _FakeDataSource();
    final c = await _make(tester, ds);
    c.selectRole(PartnerRole.mechanic);
    c.businessNameCtrl.text = 'Ravi Garage';

    c.aadhaarCtrl.text = '123';
    await _submit(tester, c);
    expect(c.aadhaarError.value, isNotNull);
    expect(ds.submitCalls, 0);

    c.aadhaarCtrl.text = '1234 5678 9012'; // cannot start with 0 or 1
    await _submit(tester, c);
    expect(c.aadhaarError.value, isNotNull);

    c.aadhaarCtrl.text = '2345 6789 0123';
    await _submit(tester, c);
    expect(c.aadhaarError.value, isNull);
    expect(ds.submitCalls, 1);
    expect(ds.lastPayload!.toJson()['aadhaar_number'], '234567890123');
  });

  testWidgets('payload carries profile identity and GPS, not city/state', (
    tester,
  ) async {
    final ds = _FakeDataSource();
    final c = await _make(tester, ds);
    c.selectRole(PartnerRole.sparePartShop);
    c.businessNameCtrl.text = '  Sri Balaji Auto Spares ';
    await c.captureLocation();
    expect(c.hasLocation, isTrue);

    await _submit(tester, c);
    final j = ds.lastPayload!.toJson();
    expect(j['user_id'], 'VB0000013');
    expect(j['role'], 'SPARE_PART_SHOP');
    expect(j['name'], 'Ravi Kumar');
    expect(j['mobile_number'], '9876543210');
    expect(j['business_name'], 'Sri Balaji Auto Spares');
    expect(j['latitude'], 17.385044);
    expect(j['longitude'], 78.486671);
    // Left for the server to reverse-geocode.
    expect(j.containsKey('city'), isFalse);
    expect(j.containsKey('state'), isFalse);
    expect(j.containsKey('aadhaar_number'), isFalse);
    expect(j.containsKey('location'), isFalse);
  });

  testWidgets('without GPS the profile city/state are sent instead', (
    tester,
  ) async {
    final ds = _FakeDataSource();
    final c = await _make(tester, ds);
    c.selectRole(PartnerRole.vendor);
    c.businessNameCtrl.text = 'Ravi Traders';
    c.addressCtrl.text = 'Auto Nagar';
    await _submit(tester, c);
    final j = ds.lastPayload!.toJson();
    expect(j.containsKey('latitude'), isFalse);
    expect(j['city'], 'Hyderabad');
    expect(j['state'], 'Telangana');
    expect(j['location'], 'Auto Nagar');
  });

  testWidgets('failed GPS leaves location unset', (tester) async {
    gps.available = false;
    final c = await _make(tester, _FakeDataSource());
    await c.captureLocation();
    await tester.pump(const Duration(seconds: 4));
    expect(c.hasLocation, isFalse);
  });

  testWidgets('successful submit switches to the status view', (tester) async {
    final ds = _FakeDataSource();
    final c = await _make(tester, ds);
    c.selectRole(PartnerRole.mechanic);
    c.businessNameCtrl.text = 'Ravi Garage';
    await _submit(tester, c);
    expect(c.myRequest.value?.isPending, isTrue);
    expect(c.showStatus, isTrue);
    expect(c.isSubmitting.value, isFalse);
  });

  testWidgets('server error keeps the form and shows no status', (
    tester,
  ) async {
    final ds = _FakeDataSource()
      ..nextResult = const PartnerApiResult(
        success: false,
        code: 400,
        message: 'Only customer accounts can apply',
        errorCode: 'NOT_A_CUSTOMER',
      );
    final c = await _make(tester, ds);
    c.selectRole(PartnerRole.mechanic);
    c.businessNameCtrl.text = 'Ravi Garage';
    await _submit(tester, c);
    expect(c.myRequest.value, isNull);
    expect(c.showStatus, isFalse);
  });

  testWidgets('existing pending request is shown instead of the form', (
    tester,
  ) async {
    final c = await _make(
      tester,
      _FakeDataSource()..existing = _request('pending'),
    );
    expect(c.showStatus, isTrue);
  });

  testWidgets('duplicate on submit falls back to the existing request', (
    tester,
  ) async {
    final ds = _FakeDataSource()
      ..nextResult = const PartnerApiResult(
        success: false,
        code: 409,
        message: 'already pending',
        errorCode: 'PARTNER_REQUEST_EXISTS',
      );
    final c = await _make(tester, ds);
    ds.existing = _request('pending'); // created elsewhere in the meantime
    c.selectRole(PartnerRole.mechanic);
    c.businessNameCtrl.text = 'Ravi Garage';
    await _submit(tester, c);
    expect(c.showStatus, isTrue);
  });

  testWidgets('rejected request shows status until the user applies again', (
    tester,
  ) async {
    final c = await _make(
      tester,
      _FakeDataSource()
        ..existing = _request('rejected', reason: 'Docs unclear'),
    );
    expect(c.myRequest.value!.rejectionReason, 'Docs unclear');
    expect(c.showStatus, isTrue);
    c.applyAgain();
    expect(c.showStatus, isFalse);
  });

  testWidgets('incomplete registration is an expected state, not an error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: SizedBox())),
    );
    final c = PartnerController(
      dataSource: _FakeDataSource(),
      profileLoader: () async => throw Exception('Registration is incomplete'),
    );
    Get.put(c);
    await tester.pump();
    await tester.pump();
    expect(c.registrationIncomplete.value, isTrue);
    expect(c.loadError.value, isNull);
    expect(c.isLoading.value, isFalse);
  });

  testWidgets('other load failures are still shown as errors', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: SizedBox())),
    );
    final c = PartnerController(
      dataSource: _FakeDataSource(),
      profileLoader: () async => throw Exception('Network down'),
    );
    Get.put(c);
    await tester.pump();
    await tester.pump();
    expect(c.registrationIncomplete.value, isFalse);
    expect(c.loadError.value, 'Network down');
  });

  testWidgets('a user who is already a partner is not a customer', (
    tester,
  ) async {
    final c = await _make(
      tester,
      _FakeDataSource(),
      profile: _profile(userType: 'VENDOR'),
    );
    expect(c.isCustomer, isFalse);
  });

  test('request model parses the backend envelope data', () {
    final r = PartnerRequest.fromJson({
      'request_id': 'PREQ0000009',
      'role': 'SPARE_PART_SHOP',
      'status': 'approved',
      'name': 'A',
      'mobile_number': '9',
      'business_name': 'B',
    });
    expect(r.isApproved, isTrue);
    expect(PartnerRole.fromApi(r.role), PartnerRole.sparePartShop);
    expect(PartnerRole.fromApi('nope'), isNull);
  });
}

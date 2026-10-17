import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/core/services/gps_location_service.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';
import 'package:vahaan_mobile_2_0/features/partner/controllers/partner_controller.dart';
import 'package:vahaan_mobile_2_0/features/partner/data/partner_data_source.dart';
import 'package:vahaan_mobile_2_0/features/partner/models/partner_models.dart';
import 'package:vahaan_mobile_2_0/features/partner/views/partner_with_us_view.dart';
import 'package:vahaan_mobile_2_0/features/profile/models/profile_models.dart';

ProfileData _profile(String type) => ProfileData(
  userId: 'VB0000013',
  username: 'ravi',
  firstName: 'Ravi',
  lastName: 'Kumar',
  email: 'ravi@x.com',
  phoneNumber: '9876543210',
  userType: type,
  state: 'Telangana',
  city: 'Hyderabad',
  registrationStatus: 'completed',
  createdAt: '',
);

class _Ds extends PartnerDataSource {
  PartnerRequest? existing;
  @override
  Future<PartnerRequest?> fetchMyRequest() async => existing;
}

PartnerRequest _req(
  String status, {
  String? reason,
  String role = 'MECHANIC',
}) => PartnerRequest(
  requestId: 'PREQ0000001',
  role: role,
  name: 'Ravi Kumar',
  mobileNumber: '9876543210',
  businessName: 'Ravi Garage',
  status: status,
  rejectionReason: reason,
);

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  bool incompleteRegistration = false,
  String userType = 'CUSTOMER',
  PartnerRequest? existing,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Get.reset();
  Get.put(MainShellController());
  Get.put<GpsLocationService>(GpsLocationService());
  Get.put(
    PartnerController(
      dataSource: _Ds()..existing = existing,
      profileLoader: () async => incompleteRegistration
          ? throw Exception('Registration is incomplete')
          : _profile(userType),
    ),
  );
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PartnerWithUsView(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  tearDown(Get.reset);

  const phones = {
    'small 320x568': Size(320, 568),
    'normal 375x812': Size(375, 812),
  };

  for (final e in phones.entries) {
    testWidgets('form renders without overflow (${e.key})', (tester) async {
      await _pump(tester, size: e.value);
      expect(find.text('Partner with us'), findsWidgets);
      expect(find.text('Ravi Kumar'), findsOneWidget); // from profile
      expect(find.text('9876543210'), findsOneWidget); // from profile
      expect(find.text('Submit request'), findsOneWidget);
      expect(find.text('Use my current location'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('role dropdown lists the three roles', (tester) async {
    await _pump(tester, size: const Size(375, 812));
    await tester.tap(find.text('Select role'));
    await tester.pumpAndSettle();
    expect(find.text('Vendor'), findsOneWidget);
    expect(find.text('Mechanic'), findsOneWidget);
    expect(find.text('Spare Part Shop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('submitting an empty form shows inline errors', (tester) async {
    await _pump(tester, size: const Size(375, 812));
    await tester.ensureVisible(find.text('Submit request'));
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(find.text('Please select a role'), findsOneWidget);
    expect(find.text('Enter your business name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending request shows the status card, not the form', (
    tester,
  ) async {
    await _pump(tester, size: const Size(375, 812), existing: _req('pending'));
    expect(find.text('Request under review'), findsOneWidget);
    expect(find.textContaining('9876543210'), findsWidgets);
    expect(find.text('PREQ0000001'), findsOneWidget);
    expect(find.text('Submit request'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('approved request', (tester) async {
    await _pump(
      tester,
      size: const Size(320, 568),
      existing: _req('approved', role: 'SPARE_PART_SHOP'),
    );
    expect(find.text("You're a partner!"), findsOneWidget);
    expect(find.text('Spare Part Shop'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejected request shows the reason and re-apply', (tester) async {
    await _pump(
      tester,
      size: const Size(375, 812),
      existing: _req('rejected', reason: 'Docs unclear'),
    );
    expect(find.text('Request not approved'), findsOneWidget);
    expect(find.text('Reason: Docs unclear'), findsOneWidget);
    await tester.tap(find.text('Apply again'));
    await tester.pumpAndSettle();
    expect(find.text('Submit request'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incomplete registration shows a Complete profile prompt', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(375, 812),
      incompleteRegistration: true,
    );
    expect(find.text('Complete your profile first'), findsOneWidget);
    expect(find.text('Complete profile'), findsOneWidget);
    expect(find.text('Submit request'), findsNothing);
    expect(
      find.text('Retry'),
      findsNothing,
    ); // not a failure the user can retry
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing partners see an info card', (tester) async {
    await _pump(tester, size: const Size(375, 812), userType: 'VENDOR');
    expect(find.text("You're already a partner"), findsOneWidget);
    expect(find.text('Submit request'), findsNothing);
  });

  for (final lang in ['hi', 'kn', 'ml', 'ta', 'te']) {
    testWidgets('renders in $lang without overflow', (tester) async {
      await _pump(tester, size: const Size(320, 568), locale: Locale(lang));
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Submit request'), findsNothing); // translated
      expect(tester.takeException(), isNull);
    });
  }
}

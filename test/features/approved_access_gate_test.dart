import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/services/approved_access_gate.dart';
import 'package:vahaan_mobile_2_0/features/subscription/models/user_subscription.dart';

void main() {
  group('my-subscriptions has_approved_vehicle_access', () {
    MySubscriptionsData parse(Map<String, dynamic> extra) =>
        MySubscriptionsData.fromJson({
          'data': {
            'subscriptions': [],
            'total_count': 0,
            'additional_details': {'auction_bid_limit_overall': 0, ...extra},
          },
        });

    test('Gold user', () {
      expect(
        parse({'has_approved_vehicle_access': true}).hasApprovedVehicleAccess,
        isTrue,
      );
    });
    test('Silver / Bronze / deposit user', () {
      expect(
        parse({'has_approved_vehicle_access': false}).hasApprovedVehicleAccess,
        isFalse,
      );
    });
    test('older server without the flag', () {
      expect(parse({}).hasApprovedVehicleAccess, isNull);
    });
  });

  testWidgets('locked dialog shows the message and the upgrade button', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ApprovedLockedDialog()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(approvedLockedMessage), findsOneWidget);
    expect(find.text('Upgrade to Gold'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });
}

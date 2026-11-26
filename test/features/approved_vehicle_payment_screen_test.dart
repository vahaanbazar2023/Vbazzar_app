import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/data/models/approved_vehicle_listing_model.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/views/approved_vehicle_payment_screen.dart';

void main() {
  test('amounts use Indian grouping, paise only when present', () {
    expect(formatRupees(200000), '₹2,00,000');
    expect(formatRupees(4720), '₹4,720');
    expect(formatRupees(1810.5), '₹1,810.50');
    expect(formatRupees(999), '₹999');
  });

  final listing = ApprovedVehicleListingModel.fromJson({
    'id': 1,
    'approved_vehicle_id': 'AVEH000000201',
    'registration_number': 'AP07TN3548',
    'brand': 'Ashok Leyland',
    'asset_description': 'Dost RLS BS IV',
    'year_of_manufacturing': 2018,
    'price': 200000,
    'city_name': 'Guntur',
    'state_name': 'Andhra Pradesh',
  });

  /// A phone screen of `width` x `height` logical pixels (3x density).
  void phone(WidgetTester tester, double width, double height) {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = Size(width * 3, height * 3);
    addTearDown(tester.view.reset);
  }

  Widget host(ApprovedVehiclePaymentPurpose purpose, double amount) =>
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ApprovedVehiclePaymentView(
              listing: listing,
              purpose: purpose,
              amount: amount,
              busy: false,
              onPay: () {},
            ),
          ),
        ),
      );

  testWidgets('booking: one-time amount, commission note, no validity', (
    tester,
  ) async {
    phone(tester, 393, 852); // iPhone 16 Pro
    await tester.pumpWidget(host(ApprovedVehiclePaymentPurpose.booking, 5000));
    await tester.pump();
    expect(find.text('Reserve this vehicle'), findsOneWidget);
    expect(find.text('₹5,000'), findsNWidgets(2)); // ticket + pay bar
    expect(find.text('One-time payment'), findsNothing);
    expect(find.text('2% commission + GST'), findsOneWidget);
    expect(find.textContaining('Days'), findsNothing);
    expect(
      find.textContaining('₹2,00,000', findRichText: true),
      findsOneWidget,
    ); // vehicle price
    expect(find.text('AP07TN3548'), findsOneWidget);
  });

  testWidgets('inspection: no commission note, no validity', (tester) async {
    phone(tester, 393, 852);
    await tester.pumpWidget(
      host(ApprovedVehiclePaymentPurpose.inspection, 1810.5),
    );
    await tester.pump();
    expect(find.text('Get it checked by an expert'), findsOneWidget);
    expect(find.text('₹1,810.50'), findsNWidgets(2));
    expect(find.text('2% commission + GST'), findsNothing);
    expect(find.textContaining('Days'), findsNothing);
  });

  testWidgets('fits a small phone with a large amount and long names', (
    tester,
  ) async {
    phone(tester, 320, 640);
    await tester.pumpWidget(
      host(ApprovedVehiclePaymentPurpose.booking, 12345678.5),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('\u20B91,23,45,678.50'), findsNWidgets(2));
  });
}

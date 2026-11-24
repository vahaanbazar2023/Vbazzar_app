import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/core/utils/amount_in_words.dart';
import 'package:vahaan_mobile_2_0/features/auction/domain/repositories/auction_repository.dart';
import 'package:vahaan_mobile_2_0/features/auction/models/vehicle_listing.dart';
import 'package:vahaan_mobile_2_0/features/auction/services/bid_flow.dart';
import 'package:vahaan_mobile_2_0/features/auction/widgets/bid_confirm_dialog.dart';

/// Fails the test if the bid reaches the server.
class _NoCallRepo extends Fake implements AuctionRepository {}

VehicleListing _vehicle() => VehicleListing.fromJson({
  'id': 1,
  'vehicle_id': 'VEH1',
  'auction_id': 'AUC1',
  'minimum_price': 100000,
  'your_bid': 0,
  'current_highest_bid': 110000,
  'available_balance': 500000,
});

Future<void> _pumpHost(
  WidgetTester tester,
  void Function(bool) onResult,
  int amount,
) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (_) => TextButton(
              onPressed: () async =>
                  onResult(await showBidConfirmDialog(amount)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  group('AmountInWords', () {
    test('uses the Indian system', () {
      expect(AmountInWords.number(0), 'Zero');
      expect(AmountInWords.number(7), 'Seven');
      expect(AmountInWords.number(15), 'Fifteen');
      expect(AmountInWords.number(40), 'Forty');
      expect(AmountInWords.number(105), 'One Hundred Five');
      expect(AmountInWords.number(1000), 'One Thousand');
      expect(AmountInWords.number(115000), 'One Lakh Fifteen Thousand');
      expect(AmountInWords.number(250000), 'Two Lakh Fifty Thousand');
      expect(
        AmountInWords.number(9999999),
        'Ninety Nine Lakh Ninety Nine Thousand Nine Hundred Ninety Nine',
      );
      expect(AmountInWords.number(10000000), 'One Crore');
      expect(
        AmountInWords.number(123456789),
        'Twelve Crore Thirty Four Lakh Fifty Six Thousand Seven Hundred Eighty Nine',
      );
      expect(AmountInWords.number(1500000000), 'One Hundred Fifty Crore');
    });

    test('rupees suffix', () {
      expect(AmountInWords.rupees(1), 'One Rupee Only');
      expect(
        AmountInWords.rupees(250000),
        'Two Lakh Fifty Thousand Rupees Only',
      );
    });
  });

  test('formatIndian groups by lakh and crore', () {
    expect(BidConfirmDialog.formatIndian(500), '500');
    expect(BidConfirmDialog.formatIndian(1000), '1,000');
    expect(BidConfirmDialog.formatIndian(250000), '2,50,000');
    expect(BidConfirmDialog.formatIndian(123456789), '12,34,56,789');
  });

  testWidgets('shows the amount in figures and words; CONFIRM returns true', (
    tester,
  ) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r, 250000);

    expect(find.text('Confirm your bid'), findsOneWidget);
    expect(find.text('₹ 2,50,000'), findsOneWidget);
    expect(find.text('Two Lakh Fifty Thousand Rupees Only'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bidConfirmOk')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.byType(BidConfirmDialog), findsNothing);
  });

  testWidgets('CANCEL returns false', (tester) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r, 120000);
    await tester.tap(find.byKey(const Key('bidConfirmCancel')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('tapping outside returns false', (tester) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r, 120000);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  group('BidFlow', () {
    test('asks to confirm the bid amount and stops when cancelled', () async {
      int? asked;
      final out = await BidFlow.placeBid(
        vehicle: _vehicle(),
        bidAmount: 120000,
        repository: _NoCallRepo(),
        confirm: (a) async {
          asked = a;
          return false;
        },
      );
      expect(asked, 120000);
      expect(out, BidFlow.cancelled);
    });

    test('does not ask when the amount is already invalid', () async {
      var asked = false;
      final out = await BidFlow.placeBid(
        vehicle: _vehicle(),
        bidAmount: 105000, // below current highest 1,10,000
        repository: _NoCallRepo(),
        confirm: (_) async => asked = true,
      );
      expect(asked, isFalse);
      expect(out, isNot(BidFlow.cancelled));
      expect(out, isNotNull);
    });
  });
}

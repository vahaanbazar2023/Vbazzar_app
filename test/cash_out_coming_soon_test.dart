import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/profile/views/cash_out_coming_soon.dart';
import 'package:vahaan_mobile_2_0/features/profile/views/cash_out_screen.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(375, 812),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Get.reset();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CashOutScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  test('withdrawals are switched off until the feature is live', () {
    expect(CashOutScreen.enabled, isFalse);
  });

  testWidgets(
    'withdraw opens the coming-soon view, without the wallet controller',
    (tester) async {
      // No ProfileController is registered: the placeholder must not need it.
      await _pump(tester);
      expect(find.byType(CashOutComingSoonView), findsOneWidget);
      expect(find.text('Withdraw to Bank'), findsOneWidget);
      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.text('Withdrawals are coming soon'), findsOneWidget);
      expect(find.text('Back to Rewards'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final code in ['hi', 'te', 'kn', 'ml', 'ta']) {
    testWidgets('coming-soon view fits a small phone in $code', (tester) async {
      await _pump(tester, size: const Size(320, 568), locale: Locale(code));
      expect(find.byType(CashOutComingSoonView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/subscription/controllers/subscription_controller.dart';
import 'package:vahaan_mobile_2_0/features/subscription/models/subscription_plan.dart';
import 'package:vahaan_mobile_2_0/features/subscription/views/subscription_screen.dart';

SubscriptionPlan _plan(String type, String code, String name, double price, String metric, String value) => SubscriptionPlan(
      typeCode: type, planCode: code, name: name, price: price, displayOrder: 0, status: 'active',
      featDescription: '', planMetric: metric, planMetricValue: value);

/// Auction Zone entry: two options when deposit plans exist, the access plans straight away when they don't.
Future<void> _pump(WidgetTester tester, {required List<SubscriptionPlan> deposits, Locale locale = const Locale('en'), bool depositList = false}) async {
  tester.view.physicalSize = const Size(375, 812) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Get.reset();
  final access = SubscriptionController(
      subscriptionSource: 'SUBT001', prebuiltPlan: _plan('SUBT001', 'PLAN01', 'Gold', 999, 'days', '30'));
  // The choice step looks up the deposit controller by tag; a pre-built one skips the network.
  final dep = Get.put(
      SubscriptionController(
          subscriptionSource: 'SUBT008', prebuiltPlan: _plan('SUBT008', 'DEP0', 'x', 1, 'amount', '1')),
      tag: 'SUBT008');
  if (deposits.isEmpty) {
    dep.isLoading.value = false;
    dep.plans.clear();
  } else {
    dep.plans.assignAll(deposits);
  }
  access.onInit();
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => GetMaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: depositList
            ? SubscriptionPlanBody(controller: dep, subscriptionSource: 'SUBT008')
            : AuctionEntryBody(accessController: access),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('shows the access pass and the refundable deposit as two options', (tester) async {
    await _pump(tester, deposits: [
      _plan('SUBT008', 'DEP1', 'Starter deposit', 10000, 'amount', '500000'),
      _plan('SUBT008', 'DEP2', 'Pro deposit', 25000, 'amount', '1500000'),
    ]);
    expect(find.text('How do you want to bid?'), findsOneWidget);
    expect(find.text('Access pass'), findsOneWidget);
    expect(find.text('Refundable deposit'), findsOneWidget);
    expect(find.text('From ₹999'), findsOneWidget);
    expect(find.text('From ₹10,000'), findsOneWidget);
    expect(find.text('₹15,00,000'), findsOneWidget);
    expect(find.textContaining('100%'), findsNothing);
  });

  testWidgets('without deposit plans it goes straight to the access plans', (tester) async {
    await _pump(tester, deposits: const []);
    expect(find.text('How do you want to bid?'), findsNothing);
    expect(find.text('Gold'), findsOneWidget);
  });

  testWidgets('fits in every app language without overflow', (tester) async {
    for (final lang in ['hi', 'te', 'kn', 'ml', 'ta']) {
      await _pump(tester, locale: Locale(lang), deposits: [
        _plan('SUBT008', 'DEP1', 'Starter deposit', 10000, 'amount', '500000'),
      ]);
      expect(tester.takeException(), isNull, reason: 'choice step, $lang');
    }
  });

  testWidgets('deposit plan cards show amount, bid limit and money back', (tester) async {
    await _pump(tester, depositList: true, deposits: [
      _plan('SUBT008', 'DEP1', 'Starter deposit', 10000, 'amount', '500000'),
      _plan('SUBT008', 'DEP2', 'Pro deposit', 25000, 'amount', '1500000'),
    ]);
    expect(find.text('₹10,000'), findsOneWidget);
    expect(find.text('₹5,00,000'), findsOneWidget);
    expect(find.text('Pay deposit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a card opens its plans in place, with a Pay bar for the picked plan', (tester) async {
    await _pump(tester, deposits: [
      _plan('SUBT008', 'DEP1', 'Starter deposit', 10000, 'amount', '500000'),
    ]);
    expect(find.text('Starter deposit'), findsNothing);
    await tester.tap(find.text('Refundable deposit'));
    await tester.pumpAndSettle();
    expect(find.text('Starter deposit'), findsOneWidget);
    expect(find.text('Pay deposit · ₹10,000'), findsOneWidget);
    // switching cards closes the other one
    await tester.tap(find.text('Access pass'));
    await tester.pumpAndSettle();
    expect(find.text('Starter deposit'), findsNothing);
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Pay Now · ₹999'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

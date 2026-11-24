import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/subscription/models/user_subscription.dart';
import 'package:vahaan_mobile_2_0/features/subscription/views/my_plans_tab.dart';
import 'package:vahaan_mobile_2_0/theme/theme_config.dart';

/// My Plans used to crash ("RenderBox was not laid out") as soon as a card
/// showed Renew: the app theme gives buttons an infinite minimum width, and the
/// Renew button sits in a Row.
void main() {
  UserSubscription sub({bool renew = false, int? days}) => UserSubscription(
    typeCode: 'SUBT001',
    subscriptionType: 'Auction Access',
    planName: 'Auction Access – 30 Days',
    endDate: '08 Nov 2026, 06:11PM',
    userSubCode: 'US1',
    status: 'active',
    planCode: 'P1',
    canRenew: renew,
    daysLeft: days,
  );

  testWidgets('cards with and without Renew lay out under the app theme', (tester) async {
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        theme: ThemeConfig.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(children: [
            MyPlanCard(sub: sub()),
            MyPlanCard(sub: sub(renew: true, days: 12)),
          ]),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(RenewPlanButton), findsOneWidget);
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/subscription/controllers/subscription_confirm_controller.dart';
import 'package:vahaan_mobile_2_0/features/subscription/models/subscription_plan.dart';
import 'package:vahaan_mobile_2_0/features/subscription/views/subscription_confirm_screen.dart';
import 'package:vahaan_mobile_2_0/core/design_system/organisms/app_bottom_nav_bar.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';
import 'package:vahaan_mobile_2_0/features/payment/controllers/payment_controller.dart';
import 'package:vahaan_mobile_2_0/theme/theme_config.dart';

Future<void> _loadFonts() async {
  for (final fam in ['Montserrat', 'PlusJakartaSans']) {
    final dir = fam == 'Montserrat'
        ? 'assets/fonts/Montserrat/static'
        : 'assets/fonts/Plus_Jakarta_Sans/static';
    final loader = FontLoader(fam);
    for (final f in Directory(dir).listSync().whereType<File>()) {
      if (f.path.endsWith('.ttf') && !f.path.contains('Italic')) {
        loader.addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer)));
      }
    }
    await loader.load();
  }
  final roboto = FontLoader('Roboto');
  final mi = FontLoader('MaterialIcons');
  final sdk = Platform.environment['FLUTTER_ROOT'];
  if (sdk != null) {
    final icons = File('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      mi.addFont(Future.value(ByteData.view(icons.readAsBytesSync().buffer)));
      await mi.load();
    }
  }
  roboto.addFont(Future.value(ByteData.view(
      File('assets/fonts/Montserrat/static/Montserrat-Regular.ttf').readAsBytesSync().buffer)));
  await roboto.load();
}

/// The Renew / Confirm Subscription screen: the app header and bottom nav
/// (AppLayout), a renewal note with the dates, no plan code on renewal.
///
/// Set PREVIEW=1 to also write PNGs of each case to build/previews/.
void main() {
  const plan = SubscriptionPlan(
    typeCode: 'SUBT001',
    planCode: 'PLAN007',
    name: 'Gold',
    price: 999,
    displayOrder: 1,
    status: 'active',
    featDescription:
        'Unlimited access to every live bank auction for the whole period.',
    planMetric: 'days',
    planMetricValue: '30',
  );
  const renewArgs = <String, dynamic>{
    'renewal': true,
    'days_left': 12,
    'current_end_date': '05 Dec 2026, 06:11PM',
  };

  Future<void> show(
    WidgetTester tester, {
    required Map<String, dynamic> extra,
    String lang = 'en',
    double scale = 1.0,
  }) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Get.testMode = true;
    Get.put(MainShellController()).changePage(BottomNavTab.subscriptions.index);
    Get.put(PaymentController());
    Get.put(SubscriptionConfirmController(
      planArg: plan,
      sourceArg: 'SUBT001',
      extraArgs: extra,
    ));
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        theme: ThemeConfig.lightTheme,
        locale: Locale(lang),
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SizedBox(),
        getPages: [
          GetPage(name: '/c', page: () => const SubscriptionConfirmScreen()),
        ],
      ),
    ));
    Get.toNamed('/c', arguments: {'plan': plan, 'source': 'SUBT001', ...extra});
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  }

  Future<void> preview(WidgetTester tester, String name) async {
    if (Platform.environment['PREVIEW'] != '1') return;
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../build/previews/$name.png'),
    );
  }

  tearDown(Get.reset);

  testWidgets('renewal: app header, bottom nav, dates, no plan code',
      (tester) async {
    await show(tester, extra: renewArgs);
    expect(find.text('Renew Plan'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.textContaining('05 Dec 2026'), findsOneWidget);
    expect(find.text('Plan Code'), findsNothing);
    expect(find.text('PLAN007'), findsNothing);
    expect(find.text('Pay ₹999'), findsOneWidget);
    await preview(tester, 'renew_en');
  });

  testWidgets('new purchase: confirm title, plan code shown', (tester) async {
    await show(tester, extra: const {});
    expect(find.text('Confirm Subscription'), findsOneWidget);
    expect(find.text('PLAN007'), findsOneWidget);
    expect(find.textContaining('05 Dec 2026'), findsNothing);
  });

  testWidgets('renewal lays out in Hindi at 1.5x font', (tester) async {
    await show(tester, extra: renewArgs, lang: 'hi', scale: 1.5);
    await preview(tester, 'renew_hi');
  });
}

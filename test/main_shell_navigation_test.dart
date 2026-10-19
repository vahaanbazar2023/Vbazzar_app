import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';
import 'package:vahaan_mobile_2_0/routes/app_routes.dart';

Widget _app(String initial) => GetMaterialApp(
  initialRoute: initial,
  getPages: [
    GetPage(
      name: AppRoutes.home,
      page: () => const Scaffold(body: Text('shell')),
    ),
    GetPage(
      name: '/sub1',
      page: () => const Scaffold(body: Text('sub1')),
    ),
    GetPage(
      name: '/sub2',
      page: () => const Scaffold(body: Text('sub2')),
    ),
  ],
);

void main() {
  late MainShellController shell;

  setUp(() {
    Get.reset();
    shell = Get.put(MainShellController());
  });

  testWidgets(
    'tapping any tab from a pushed screen returns to the shell on that tab',
    (tester) async {
      await tester.pumpWidget(_app(AppRoutes.home));
      Get.toNamed('/sub1');
      await tester.pumpAndSettle();
      Get.toNamed('/sub2');
      await tester.pumpAndSettle();
      expect(find.text('sub2'), findsOneWidget);

      shell.onTabTapped(2);
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.home);
      expect(find.text('shell'), findsOneWidget);
      expect(shell.currentIndex.value, 2);
    },
  );

  testWidgets(
    'tapping the already-selected tab also goes back to its root and signals a reselect',
    (tester) async {
      await tester.pumpWidget(_app(AppRoutes.home));
      shell.changePage(3);
      Get.toNamed('/sub1');
      await tester.pumpAndSettle();

      final before = shell.reselectTick.value;
      shell.onTabTapped(3);
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.home);
      expect(shell.currentIndex.value, 3);
      expect(shell.reselectTick.value, before + 1);
      expect(shell.reselectedIndex.value, 3);
    },
  );

  testWidgets('a normal tab switch on the shell does not signal a reselect', (
    tester,
  ) async {
    await tester.pumpWidget(_app(AppRoutes.home));
    final before = shell.reselectTick.value;
    shell.onTabTapped(1);
    await tester.pumpAndSettle();
    expect(shell.currentIndex.value, 1);
    expect(shell.reselectTick.value, before);
  });

  testWidgets(
    'without the shell in the stack (deep link) it opens the shell instead of closing the app',
    (tester) async {
      await tester.pumpWidget(_app('/sub1'));
      await tester.pumpAndSettle();
      expect(find.text('sub1'), findsOneWidget);

      shell.onTabTapped(1);
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.home);
      expect(find.text('shell'), findsOneWidget);
      expect(shell.currentIndex.value, 1);
    },
  );
}

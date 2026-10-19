import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  /// Bumped every time the already-selected tab is tapped again, together with
  /// [reselectedIndex]. A tab screen can `ever()` on this to scroll to top /
  /// refresh itself.
  final reselectTick = 0.obs;
  final reselectedIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    update(); // refresh GetBuilder-based bottom bars on pushed screens
  }

  /// Bottom-bar tap (shell and pushed screens use this).
  ///
  /// Selects the tab and unwinds every screen pushed on top of the shell, so
  /// tapping a tab — including the one that is already selected — always lands
  /// on that tab's original (root) screen instead of staying on a sub-screen.
  void onTabTapped(int index) {
    final isReselect = index == currentIndex.value;
    changePage(index);
    if (Get.currentRoute != AppRoutes.home) _unwindToShell();
    if (isReselect) {
      reselectedIndex.value = index;
      reselectTick.value++;
    }
  }

  /// Pops every screen above the shell. Never empties the navigator: if the
  /// shell isn't in the stack at all (e.g. the app was opened straight onto a
  /// deep-linked screen) it is opened instead.
  void _unwindToShell() {
    var found = false;
    Get.key.currentState?.popUntil((route) {
      if (route.settings.name == AppRoutes.home) {
        found = true;
        return true;
      }
      return route.isFirst; // stop at the bottom instead of closing the app
    });
    if (!found) Get.offAllNamed(AppRoutes.home);
  }
}

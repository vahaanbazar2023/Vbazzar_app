import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/design_system/organisms/app_bottom_nav_bar.dart';
import 'package:vahaan_mobile_2_0/features/main_shell/controllers/main_shell_controller.dart';

void main() {
  tearDown(Get.reset);

  test('the Profile tab is the fifth tab, which the Home avatar now opens', () {
    // Home's avatar calls onTabTapped(BottomNavTab.settings.index): that tab
    // must be the Profile screen's slot (index 4) in MainShellScreen._tabs.
    expect(BottomNavTab.settings.index, 4);
  });

  test(
    'a new login starts on Home even if the last session ended on Profile',
    () {
      // Registered permanently in AppBinding, so it outlives logout.
      final shell = Get.put(MainShellController(), permanent: true);
      shell.changePage(BottomNavTab.settings.index);
      shell.reselectedIndex.value = BottomNavTab.settings.index;
      expect(shell.currentIndex.value, 4);

      shell.resetToHome();

      expect(shell.currentIndex.value, BottomNavTab.home.index);
      expect(shell.reselectedIndex.value, BottomNavTab.home.index);
    },
  );
}

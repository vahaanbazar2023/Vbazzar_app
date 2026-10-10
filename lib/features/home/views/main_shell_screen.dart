import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../categories/categories_binding.dart';
import '../../categories/views/categories_screen.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_screen.dart';
import 'home_content.dart';
import '../../../core/extensions/context_extensions.dart';

/// Main shell controller for bottom nav management
class MainShellController extends GetxController {
  final currentTab = BottomNavTab.home.obs;

  void switchTab(BottomNavTab tab) {
    currentTab.value = tab;
  }
}

/// Main shell screen with bottom navigation
/// Contains: Home, Subscriptions, Categories, Settings
class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildBody(context, controller.currentTab.value)),
      extendBody: true,
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentTab: controller.currentTab.value,
          onTabSelected: controller.switchTab,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.home:
        return const HomeContent();
      case BottomNavTab.subscriptions:
        return _PlaceholderScreen(title: context.l10n.coreSubscriptions);
      case BottomNavTab.categories:
        CategoriesBinding().dependencies();
        return const CategoriesScreen();
      case BottomNavTab.rewards:
        return _PlaceholderScreen(title: context.l10n.coreRewards);
      case BottomNavTab.settings:
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
        return const ProfileScreen();
    }
  }
}

/// Placeholder screen for tabs not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              context.l10n.coreTitleComingSoon(title),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

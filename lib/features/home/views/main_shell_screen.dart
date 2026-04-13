import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../categories/categories_binding.dart';
import '../../categories/views/categories_screen.dart';
import '../../profile/views/profile_screen.dart';
import 'home_content.dart';

/// Main shell controller for bottom nav management
class MainShellController extends GetxController {
  final currentTab = BottomNavTab.home.obs;

  void switchTab(BottomNavTab tab) {
    currentTab.value = tab;
  }
}

/// Main shell screen with bottom navigation
/// Contains: Home, Subscriptions, Categories, Rewards, Settings
class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildBody(controller.currentTab.value)),
      extendBody: true,
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentTab: controller.currentTab.value,
          onTabSelected: controller.switchTab,
        ),
      ),
    );
  }

  Widget _buildBody(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.home:
        return const HomeContent();
      case BottomNavTab.subscriptions:
        return const _PlaceholderScreen(title: 'Subscriptions');
      case BottomNavTab.categories:
        CategoriesBinding().dependencies();
        return const CategoriesScreen();
      case BottomNavTab.rewards:
        return const _PlaceholderScreen(title: 'Rewards');
      case BottomNavTab.settings:
        return const ProfileScreen(); // Settings uses profile for now
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
              '$title Coming Soon',
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

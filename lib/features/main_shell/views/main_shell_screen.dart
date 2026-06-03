import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../controllers/main_shell_controller.dart';
import '../../home/views/home_screen.dart';
import '../../subscription/views/my_subscription_screen.dart';
import '../../categories/views/categories_screen.dart';
import '../../wishlist/views/wishlist_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeScreen(),
            MySubscriptionScreen(), // Subscriptions tab
            CategoriesScreen(),
            WishlistScreen(), // Rewards placeholder
            ProfileScreen(), // Settings placeholder
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentTab: BottomNavTab.values[controller.currentIndex.value],
          onTabSelected: (tab) => controller.changePage(tab.index),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../controllers/main_shell_controller.dart';
import '../../home/views/home_screen.dart';
import '../../subscription/views/my_subscription_screen.dart';
import '../../categories/views/categories_screen.dart';
import '../../rewards/views/rewards_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  static const _tabs = [
    HomeScreen(),
    MySubscriptionScreen(),
    CategoriesScreen(),
    RewardsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => _LazyIndexedStack(
          index: controller.currentIndex.value,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Obx(
        () => MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: AppBottomNavBar(
            currentTab: BottomNavTab.values[controller.currentIndex.value],
            onTabSelected: (tab) => controller.changePage(tab.index),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lazy IndexedStack — only builds a tab the first time it's visited,
// then keeps it alive (like IndexedStack but without up-front cost).
// ─────────────────────────────────────────────────────────────────────────────

class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _LazyIndexedStack({required this.index, required this.children});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  // Track which tabs have been visited and should be kept alive
  late final List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.filled(widget.children.length, false);
    _activated[widget.index] = true; // activate the initial tab
  }

  @override
  void didUpdateWidget(_LazyIndexedStack old) {
    super.didUpdateWidget(old);
    if (widget.index != old.index) {
      _activated[widget.index] = true; // activate on first visit
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (i) {
        return Offstage(
          offstage: i != widget.index,
          child: _activated[i]
              ? TickerMode(
                  enabled: i == widget.index,
                  child: widget.children[i],
                )
              : const SizedBox.shrink(), // not yet visited — zero cost
        );
      }),
    );
  }
}

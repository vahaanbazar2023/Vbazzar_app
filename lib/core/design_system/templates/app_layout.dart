import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../molecules/collapsible_section.dart';
import '../organisms/app_bottom_nav_bar.dart';
import '../organisms/app_header.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';
import '../../../routes/app_routes.dart';

/// Main app layout: white body with [AppHeader] at the top.
class AppLayout extends StatelessWidget {
  final String title;
  final String? subtitle; // kept for API compat, not rendered
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Color? bodyColor;
  final Widget? headerExtra;
  final Widget? floatingActionButton;

  /// When true the bottom nav slides away (e.g. while a list is scrolling).
  final RxBool? hideBottomNav;

  const AppLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.headerExtra,
    this.bodyColor,
    this.floatingActionButton,
    this.hideBottomNav,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bodyColor ?? Colors.white,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: _bottomNav(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPad),
            AppHeader(
              title: title,
              showBack: showBack,
              onBack: onBack,
              actions: actions,
            ),
            if (headerExtra != null) headerExtra!,
            Expanded(
              child: Container(color: bodyColor ?? Colors.white, child: body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    final nav = GetBuilder<MainShellController>(
      builder: (ctrl) => AppBottomNavBar(
        currentTab: BottomNavTab.values[ctrl.currentIndex.value],
        onTabSelected: (tab) {
          ctrl.changePage(tab.index);
          Get.until((route) => route.settings.name == AppRoutes.home);
        },
      ),
    );
    final hide = hideBottomNav;
    if (hide == null) return nav;
    return Obx(
      () => CollapsibleSection(
        hidden: hide.value,
        overflowTop: true,
        child: nav,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/shell_layout.dart';
import '../controllers/subscription_controller.dart';
import 'my_plans_tab.dart';
import 'explore_plans_tab.dart';
import 'combo_plans_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MySubscriptionScreen — uses ShellLayout (no extra bottom nav)
// ─────────────────────────────────────────────────────────────────────────────

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MySubscriptionController _myCtrl;
  late final SubscriptionController _exploreCtrl;

  static const _subtitles = ['My Plans', 'Explore Plans', 'Combo Plans'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _myCtrl = Get.isRegistered<MySubscriptionController>()
        ? Get.find<MySubscriptionController>()
        : Get.put(MySubscriptionController());
    _exploreCtrl =
        Get.isRegistered<SubscriptionController>(tag: 'MY_SUB_EXPLORE')
        ? Get.find<SubscriptionController>(tag: 'MY_SUB_EXPLORE')
        : Get.put(
            SubscriptionController(subscriptionSource: 'SUBT001'),
            tag: 'MY_SUB_EXPLORE',
          );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // true when pushed as a named route; false when embedded as a shell tab
    final isPushed = ModalRoute.of(context)?.settings.name != null;
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, __) {
        return ShellLayout(
          title: 'Subscription',
          subtitle: _subtitles[_tabController.index],
          showBack: false,
          // Tab bar pinned inside the white body via headerExtra
          headerExtra: _SubTabBar(controller: _tabController),
          body: TabBarView(
            controller: _tabController,
            children: [
              MyPlansTab(
                ctrl: _myCtrl,
                onGoExplore: () => _tabController.animateTo(1),
              ),
              ExplorePlansTab(ctrl: _exploreCtrl),
              const ComboPlansTab(),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar
// ─────────────────────────────────────────────────────────────────────────────

class _SubTabBar extends StatelessWidget {
  final TabController controller;
  const _SubTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.grey500,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: AppColors.grey200,
      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      labelStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(text: 'My Plans'),
        Tab(text: 'Explore Plans'),
        Tab(text: 'Combo Plans'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/shell_layout.dart';
import '../../../core/extensions/context_extensions.dart';
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

  List<String> _subtitles(BuildContext context) => [
    context.l10n.profSubMyPlans,
    context.l10n.profSubExplorePlans,
    context.l10n.profSubComboPlans,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _myCtrl = Get.isRegistered<MySubscriptionController>()
        ? Get.find<MySubscriptionController>()
        : Get.put(MySubscriptionController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, __) {
        return ShellLayout(
          title: context.l10n.profSubSubscription,
          subtitle: _subtitles(context)[_tabController.index],
          showBack: false,
          headerExtra: _SubTabBar(controller: _tabController),
          body: TabBarView(
            controller: _tabController,
            children: [
              MyPlansTab(
                ctrl: _myCtrl,
                onGoExplore: () => _tabController.animateTo(1),
              ),
              const ExplorePlansTab(),
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
      tabs: [
        Tab(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(context.l10n.profSubMyPlans, maxLines: 1),
          ),
        ),
        Tab(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(context.l10n.profSubExplorePlans, maxLines: 1),
          ),
        ),
        Tab(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(context.l10n.profSubComboPlans, maxLines: 1),
          ),
        ),
      ],
    );
  }
}

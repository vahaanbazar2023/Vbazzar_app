import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../core/design_system/templates/shell_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../main_shell/controllers/main_shell_controller.dart';
import '../controllers/subscription_controller.dart';
import 'my_plans_tab.dart';
import 'explore_plans_tab.dart';
import 'combo_plans_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MySubscriptionScreen — uses ShellLayout (no extra bottom nav)
// ─────────────────────────────────────────────────────────────────────────────

class MySubscriptionScreen extends StatefulWidget {
  /// True for the bottom bar's Subscription tab: it opens on Explore Plans, and
  /// goes back there on every tap of that tab. The "My Subscriptions" route
  /// (Profile, after buying a plan) leaves it false and opens on My Plans.
  final bool inShell;

  const MySubscriptionScreen({super.key, this.inShell = false});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen>
    with SingleTickerProviderStateMixin {
  static const _exploreTab = 1;

  late final TabController _tabController;
  late final MySubscriptionController _myCtrl;
  final _shellWorkers = <Worker>[];

  List<String> _subtitles(BuildContext context) => [
    context.l10n.profSubMyPlans,
    context.l10n.profSubExplorePlans,
    context.l10n.profSubComboPlans,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.inShell ? _exploreTab : 0,
    );
    _myCtrl = Get.isRegistered<MySubscriptionController>()
        ? Get.find<MySubscriptionController>()
        : Get.put(MySubscriptionController());

    // The shell keeps this tab alive, so a later tap would otherwise reopen
    // whichever plan tab was left open. Both a switch to this tab and a tap on
    // it while already selected count.
    if (widget.inShell && Get.isRegistered<MainShellController>()) {
      final shell = Get.find<MainShellController>();
      final subscriptions = BottomNavTab.subscriptions.index;
      _shellWorkers
        ..add(ever<int>(shell.currentIndex, (i) {
          if (i == subscriptions) _showExplore();
        }))
        ..add(ever<int>(shell.reselectTick, (_) {
          if (shell.reselectedIndex.value == subscriptions) _showExplore();
        }));
    }
  }

  void _showExplore() {
    if (mounted && _tabController.index != _exploreTab) {
      _tabController.index = _exploreTab;
    }
  }

  @override
  void dispose() {
    for (final w in _shellWorkers) {
      w.dispose();
    }
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

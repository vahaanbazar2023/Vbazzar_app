import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';
import 'fms_tab.dart';
import 'spare_support_tab.dart';

/// Main Spare & FMS screen with 2 tabs in the body:
/// Tab 0: FMS — Spare parts listing in 2-column grid
/// Tab 1: Spare Support — Shop listing by category (CE/CV)
class SpareFmsHomeView extends GetView<SpareAndFmsController> {
  const SpareFmsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Spares',
      subtitle: 'Find spare parts and nearby shops',
      showBack: true,
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: const [
                FmsTab(),
                SpareSupportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppFonts.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
        unselectedLabelStyle: AppFonts.labelMedium.copyWith(
          fontSize: 13.sp,
        ),
        dividerColor: Colors.transparent,
        indicatorPadding: EdgeInsets.all(3.r),
        tabs: SpareAndFmsController.tabs
            .map((t) => Tab(text: t))
            .toList(),
      ),
    );
  }
}
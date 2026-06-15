import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/insurance_finance_controller.dart';
import 'finance_form_view.dart';
import 'insurance_form_view.dart';

/// Main Insurance & Finance screen with 2 tabs:
/// Tab 0: Insurance — Vehicle insurance request form
/// Tab 1: Finance — Vehicle finance request form
class InsuranceFinanceView extends GetView<InsuranceFinanceController> {
  const InsuranceFinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.insuranceFinance,
      subtitle: context.l10n.insuranceFinanceSubtitle,
      showBack: true,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [InsuranceFormView(), FinanceFormView()],
                ),
              ),
            ],
          ),

          // ── Backdrop Loading Overlay ──────────────────────────
          Obx(
            () => controller.isSubmitting.value
                ? CustomLoader.backdrop()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
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
        dividerColor: Colors.transparent,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppFonts.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        unselectedLabelStyle: AppFonts.labelLarge.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.all(4.r),
        tabs: [
          Tab(text: context.l10n.insurance),
          Tab(text: context.l10n.finance),
        ],
      ),
    );
  }
}

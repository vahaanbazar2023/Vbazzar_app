import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/inspection_valuation_controller.dart';
import '../widgets/inspection_card.dart';

/// Paginated list of the user's inspection submissions with pull-to-refresh.
class MyInspectionsView extends GetView<InspectionValuationController> {
  const MyInspectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger fetch on first build if inspections haven't been loaded yet
    if (!controller.hasAttemptedLoad.value &&
        !controller.isInspectionsLoading.value &&
        controller.inspections.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchMyInspections(refresh: true);
        controller.setupInspectionsScrollListener();
      });
    }

    return AppLayout(
      title: context.l10n.myInspections,
      subtitle: context.l10n.trackInspectionRequests,
      showBack: true,
      body: Obx(() {
        // Initial loading
        if (controller.isInspectionsLoading.value &&
            controller.inspections.isEmpty) {
          return _buildShimmerList();
        }

        // Error state (only after attempted load)
        if (controller.hasAttemptedLoad.value &&
            controller.hasError.value &&
            controller.inspections.isEmpty) {
          return _buildErrorState(context);
        }

        // Empty state
        if (controller.hasAttemptedLoad.value &&
            !controller.isInspectionsLoading.value &&
            controller.inspections.isEmpty) {
          return _buildEmptyState(context);
        }

        // Data state
        return _buildDataList(context);
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              context.l10n.somethingWentWrong,
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : context.l10n.unableToLoadInspections,
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            GradientButton.filled(
              text: context.l10n.retry,
              onPressed: () => controller.fetchMyInspections(refresh: true),
              width: 140.w,
              height: 42.h,
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 56.r,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              context.l10n.noInspectionsFound,
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.inspectionRequestsAppearHere,
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            GradientButton.filled(
              text: context.l10n.requestInspection,
              onPressed: () => _navigateToInspectionForm(),
              width: 180.w,
              height: 42.h,
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToInspectionForm() async {
    final storage = SecureStorageService.to;
    final userType = await storage.read(StorageKeys.userType);
    if (userType == 'AGENT') {
      Get.toNamed(AppRoutes.agentValuationForm);
    } else {
      Get.toNamed(AppRoutes.customerValuationForm);
    }
  }

  Widget _buildDataList(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => controller.fetchMyInspections(refresh: true),
      child: ListView.builder(
        controller: controller.inspectionsScrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount:
            controller.inspections.length +
            (controller.isLoadMoreLoading.value ? 1 : 0) +
            (!controller.inspectionsHasMore.value &&
                    controller.inspections.isNotEmpty
                ? 1
                : 0),
        itemBuilder: (context, index) {
          // Load-more indicator at bottom
          if (index == controller.inspections.length &&
              controller.isLoadMoreLoading.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: SizedBox(
                  width: 28.r,
                  height: 28.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          // "No more" text at bottom
          if (index == controller.inspections.length &&
              !controller.inspectionsHasMore.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  context.l10n.noMoreInspections,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final vehicle = controller.inspections[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: InspectionCard(
              inspection: vehicle,
              onTap: () =>
                  Get.toNamed(AppRoutes.inspectionDetail, arguments: vehicle),
            ),
          );
        },
      ),
    );
  }
}

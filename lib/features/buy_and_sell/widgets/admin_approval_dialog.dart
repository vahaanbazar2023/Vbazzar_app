import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/extensions/context_extensions.dart';

/// Shown after a vehicle is submitted or edited: the listing needs admin
/// approval and the team will reach out shortly.
class AdminApprovalDialog extends StatelessWidget {
  const AdminApprovalDialog({super.key});

  static Future<void> show() {
    return Get.dialog(const AdminApprovalDialog(), barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132.w,
              height: 132.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              padding: EdgeInsets.all(14.r),
              child: Image.asset(AppAssets.contactUs, fit: BoxFit.contain),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    size: 13.r,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    l10n.pendingStatus,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.spareAdminApprovalRequired,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.spareTeamWillReachYouShortly,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            GradientButton.filled(
              text: l10n.insOkay,
              width: 140.w,
              height: 36.h,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

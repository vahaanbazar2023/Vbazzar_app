import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../subscription/models/user_subscription.dart';
import '../../subscription/services/subscription_guard_service.dart';

/// Approved vehicles open only for an active Gold plan (SUBT001 / PLAN001).
/// Silver, Bronze, the auction deposit (SUBT008) and no plan see them locked.
///
/// Every way into approved vehicles (auction type card, vendor Buy, search,
/// shared links, Vaani) goes through [ensureApprovedVehicleAccess].

const approvedLockedMessage =
    "You don't have a valid plan to see the approved vehicles.";

/// The server's error code when a non-Gold user calls the approved APIs.
const approvedPlanRequiredCode = 'APPROVED_VEHICLE_PLAN_REQUIRED';

/// Whether the user may open approved vehicles (loads the plans if needed).
Future<bool> hasApprovedVehicleAccess() async {
  final guard = SubscriptionGuardService.to;
  await guard.ensureLoaded();
  return guard.hasApprovedVehicleAccess;
}

/// True when the user may open approved vehicles; otherwise shows the locked
/// message and returns false.
Future<bool> ensureApprovedVehicleAccess() async {
  if (await hasApprovedVehicleAccess()) return true;
  await showApprovedLockedDialog();
  return false;
}

/// Opens [route] when the user has a Gold plan, else shows the locked message.
Future<void> openApprovedVehicles(String route, {dynamic arguments}) async {
  if (await ensureApprovedVehicleAccess()) {
    Get.toNamed(route, arguments: arguments);
  }
}

Future<void> showApprovedLockedDialog() async {
  await Get.dialog<void>(
    const ApprovedLockedDialog(),
    barrierDismissible: true,
    barrierColor: Colors.black54,
  );
}

class ApprovedLockedDialog extends StatelessWidget {
  const ApprovedLockedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: AppColors.lightOrangeBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 28.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              approvedLockedMessage,
              key: const Key('approvedLockedMessage'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Approved vehicles are available with the Gold plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 18.h),
            GradientButton.filled(
              text: 'Upgrade to Gold',
              height: 44.h,
              onPressed: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.subscription,
                  arguments: {
                    'subscription_source': SubscriptionTypeCode.auction,
                    'title': appL10n.coreChooseSubscriptionPlan,
                    'subtitle':
                        'Pick the Gold plan to unlock approved vehicles',
                  },
                );
              },
            ),
            SizedBox(height: 6.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

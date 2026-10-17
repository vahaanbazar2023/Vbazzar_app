import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../models/partner_models.dart';

/// Compact "Partner with us" entry shown inside Spare & FMS and Service Support.
/// Opens the same form, optionally with the role pre-selected.
class PartnerCtaBanner extends StatelessWidget {
  final PartnerRole? presetRole;
  final EdgeInsetsGeometry? margin;

  const PartnerCtaBanner({super.key, this.presetRole, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => Get.toNamed(
            AppRoutes.partnerWithUs,
            arguments: presetRole == null
                ? null
                : {'role': presetRole!.apiValue},
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: Colors.white,
                    size: 19.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.partnerWithUsTitle,
                        style: AppFonts.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        context.l10n.partnerCtaSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 22.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

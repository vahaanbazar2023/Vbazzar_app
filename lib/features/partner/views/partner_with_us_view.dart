import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/partner_controller.dart';
import '../models/partner_models.dart';

/// "Partner with us" — one form for Vendor, Mechanic and Spare Part Shop.
/// Name, mobile number and user id come from the profile; the user only adds
/// role, business name, optional Aadhaar and location.
class PartnerWithUsView extends GetView<PartnerController> {
  const PartnerWithUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.partnerWithUsTitle,
      subtitle: context.l10n.partnerWithUsSubtitle,
      showBack: true,
      bodyColor: AppColors.grey100,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoader());
        }
        if (controller.registrationIncomplete.value) {
          return _InfoCard(
            icon: Icons.person_add_alt_1_rounded,
            color: const Color(0xFFF59E0B),
            title: context.l10n.partnerCompleteProfileTitle,
            body: context.l10n.partnerCompleteProfileBody,
            action: GradientButton.filled(
              text: context.l10n.partnerCompleteProfileButton,
              onPressed: () => Get.toNamed(AppRoutes.completeProfile),
              width: double.infinity,
              height: 46.h,
            ),
          );
        }
        if (controller.loadError.value != null) {
          return _ErrorState(
            message: controller.loadError.value!,
            onRetry: controller.load,
          );
        }
        if (!controller.isCustomer && controller.myRequest.value == null) {
          return _InfoCard(
            icon: Icons.verified_rounded,
            color: AppColors.success,
            title: context.l10n.partnerAlreadyPartnerTitle,
            body: context.l10n.partnerAlreadyPartnerBody(
              controller.profile.value?.userType ?? '',
            ),
          );
        }
        if (controller.showStatus) {
          return _StatusView(controller: controller);
        }
        return _FormView(controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form
// ─────────────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final PartnerController controller;
  const _FormView({required this.controller});

  String _roleLabel(BuildContext context, PartnerRole r) {
    switch (r) {
      case PartnerRole.vendor:
        return context.l10n.partnerRoleVendor;
      case PartnerRole.mechanic:
        return context.l10n.partnerRoleMechanic;
      case PartnerRole.sparePartShop:
        return context.l10n.partnerRoleSpareShop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(
            title: context.l10n.partnerHeroTitle,
            body: context.l10n.partnerHeroBody,
          ),
          SizedBox(height: 14.h),
          _Card(
            children: [
              _SectionTitle(context.l10n.partnerRoleLabel),
              Obx(
                () => CustomDropdownField<PartnerRole>(
                  value: controller.selectedRole.value,
                  items: PartnerRole.values,
                  placeholder: context.l10n.partnerRoleHint,
                  prefixIcon: Icons.storefront_rounded,
                  searchable: false,
                  errorText: controller.roleError.value,
                  itemLabel: (r) => _roleLabel(context, r),
                  onChanged: controller.selectRole,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _Card(
            children: [
              _SectionTitle(context.l10n.partnerYourDetails),
              _Label(context.l10n.partnerName),
              CustomInputField(
                controller: controller.nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                suffixIcon: Icons.lock_outline_rounded,
                readOnly: true,
              ),
              SizedBox(height: 10.h),
              _Label(context.l10n.partnerMobile),
              CustomInputField(
                controller: controller.mobileCtrl,
                prefixIcon: Icons.phone_outlined,
                suffixIcon: Icons.lock_outline_rounded,
                readOnly: true,
              ),
              SizedBox(height: 6.h),
              Text(
                context.l10n.partnerFromProfileNote,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              _Label(context.l10n.partnerBusinessName),
              Obx(
                () => CustomInputField(
                  controller: controller.businessNameCtrl,
                  placeholder: context.l10n.partnerBusinessNameHint,
                  prefixIcon: Icons.business_center_outlined,
                  errorText: controller.businessNameError.value,
                  textInputAction: TextInputAction.next,
                  maxLength: 300,
                  onChanged: (_) => controller.businessNameError.value = null,
                ),
              ),
              SizedBox(height: 10.h),
              _Label(context.l10n.partnerAadhaar),
              Obx(
                () => CustomInputField(
                  controller: controller.aadhaarCtrl,
                  placeholder: context.l10n.partnerAadhaarHint,
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  errorText: controller.aadhaarError.value,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  onChanged: (_) => controller.aadhaarError.value = null,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _Card(
            children: [
              _SectionTitle(context.l10n.partnerLocationSection),
              _LocationPicker(controller: controller),
              SizedBox(height: 12.h),
              _Label(context.l10n.partnerAddressLabel),
              CustomInputField(
                controller: controller.addressCtrl,
                placeholder: context.l10n.partnerAddressHint,
                prefixIcon: Icons.place_outlined,
                maxLines: 2,
                height: 70.h,
                maxLength: 500,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(
            () => GradientButton.filled(
              text: context.l10n.partnerSubmit,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submit,
              width: double.infinity,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  final PartnerController controller;
  const _LocationPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final captured = controller.hasLocation;
      final locating = controller.isLocating.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: locating ? null : controller.captureLocation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: captured
                    ? AppColors.successBackground
                    : AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: captured
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  locating
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          captured
                              ? Icons.check_circle_rounded
                              : Icons.my_location_rounded,
                          color: captured
                              ? AppColors.success
                              : AppColors.primary,
                          size: 22.r,
                        ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      captured
                          ? context.l10n.partnerLocationCaptured
                          : context.l10n.partnerUseCurrentLocation,
                      style: AppFonts.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: captured ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                  if (captured)
                    GestureDetector(
                      onTap: controller.clearLocation,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.r,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.l10n.partnerLocationAutoNote,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status (pending / approved / rejected)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusView extends StatelessWidget {
  final PartnerController controller;
  const _StatusView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = controller.myRequest.value!;
    final roleLabel = _roleText(context, r.role);

    late final IconData icon;
    late final Color color;
    late final String title;
    late final String body;
    if (r.isApproved) {
      icon = Icons.verified_rounded;
      color = AppColors.success;
      title = context.l10n.partnerStatusApprovedTitle;
      body = context.l10n.partnerStatusApprovedBody(roleLabel);
    } else if (r.isRejected) {
      icon = Icons.cancel_rounded;
      color = AppColors.error;
      title = context.l10n.partnerStatusRejectedTitle;
      body = (r.rejectionReason ?? '').isNotEmpty
          ? context.l10n.partnerStatusRejectedReason(r.rejectionReason!)
          : '';
    } else {
      icon = Icons.hourglass_top_rounded;
      color = const Color(0xFFF59E0B);
      title = context.l10n.partnerStatusPendingTitle;
      body = context.l10n.partnerStatusPendingBody(r.mobileNumber);
    }

    return _InfoCard(
      icon: icon,
      color: color,
      title: title,
      body: body,
      footer: [
        _KeyValue(context.l10n.partnerRole, roleLabel),
        _KeyValue(context.l10n.partnerBusinessName, r.businessName),
        _KeyValue(context.l10n.partnerRequestIdLabel, r.requestId),
      ],
      action: r.isRejected
          ? GradientButton.filled(
              text: context.l10n.partnerApplyAgain,
              onPressed: controller.applyAgain,
              width: double.infinity,
              height: 46.h,
            )
          : null,
    );
  }

  String _roleText(BuildContext context, String api) {
    switch (PartnerRole.fromApi(api)) {
      case PartnerRole.vendor:
        return context.l10n.partnerRoleVendor;
      case PartnerRole.mechanic:
        return context.l10n.partnerRoleMechanic;
      case PartnerRole.sparePartShop:
        return context.l10n.partnerRoleSpareShop;
      case null:
        return api;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final String title;
  final String body;
  const _Hero({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.handshake_rounded,
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: AppFonts.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppFonts.titleSmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: AppFonts.labelMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValue(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final List<Widget> footer;
  final Widget? action;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.footer = const [],
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
      child: _Card(
        children: [
          Center(
            child: Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 38.r),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (body.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Center(
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (footer.isNotEmpty) ...[
            SizedBox(height: 16.h),
            const Divider(height: 1),
            SizedBox(height: 8.h),
            ...footer,
          ],
          if (action != null) ...[SizedBox(height: 16.h), action!],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44.r,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            GradientButton.filled(
              text: context.l10n.retry,
              onPressed: onRetry,
              width: 140.w,
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}

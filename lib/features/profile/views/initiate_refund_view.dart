import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/initiate_refund_controller.dart';

class InitiateRefundView extends GetView<InitiateRefundController> {
  const InitiateRefundView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFFDF0F0),
            body: Column(
              children: [
                _Header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User ID (read-only, auto-filled)
                        _FieldLabel(context.l10n.userId),
                        SizedBox(height: AppSpacing.sm),
                        Obx(() {
                          return CustomInputField(
                            controller: TextEditingController(
                              text: controller.userId.value,
                            ),
                            placeholder: context.l10n.userId,
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            onChanged: (_) {},
                          );
                        }),
                        SizedBox(height: AppSpacing.md),

                        // Account Holder Name
                        _FieldLabel(context.l10n.accountHolderName),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.accHolderNameController,
                          placeholder: context.l10n.enterAccountHolderName,
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Account Number
                        _FieldLabel(context.l10n.accountNumber),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.accountNumberController,
                          placeholder: context.l10n.enterAccountNumber,
                          prefixIcon: Icons.account_balance_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Bank Name
                        _FieldLabel(context.l10n.bankName),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.bankNameController,
                          placeholder: context.l10n.enterBankName,
                          prefixIcon: Icons.account_balance_outlined,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Branch Name
                        _FieldLabel(context.l10n.branchName),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.branchNameController,
                          placeholder: context.l10n.enterBranchName,
                          prefixIcon: Icons.location_on_outlined,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.md),

                        // IFSC Code
                        _FieldLabel(context.l10n.ifscCode),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.ifscCodeController,
                          placeholder: context.l10n.enterIfscCode,
                          prefixIcon: Icons.code_outlined,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.md),

                        // Refund Type
                        _FieldLabel(context.l10n.refundType),
                        SizedBox(height: AppSpacing.sm),
                        CustomInputField(
                          controller: controller.refundTypeController,
                          placeholder: context.l10n.enterRefundType,
                          prefixIcon: Icons.category_outlined,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: AppSpacing.xxl),

                        // Submit button
                        Obx(() {
                          final isValid = controller.isFormValid;
                          return isValid
                              ? GradientButton.filled(
                                  text: context.l10n.initiateRefundTitle,
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : () => controller.submitRefund(),
                                  isLoading: controller.isSubmitting.value,
                                  width: double.infinity,
                                )
                              : GradientButton.outlined(
                                  text: context.l10n.initiateRefundTitle,
                                  onPressed: null,
                                  width: double.infinity,
                                );
                        }),
                        SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Full-screen loading overlay
          Obx(() {
            return controller.isSubmitting.value
                ? CustomLoader.backdrop()
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + 12.h,
        bottom: 20.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authHeaderGradientStart,
            AppColors.authHeaderGradientEnd,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back, color: AppColors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Text(
            context.l10n.initiateRefundTitle,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.headingMedium.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

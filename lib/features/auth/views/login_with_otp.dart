import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/input_formatters.dart';
import '../controllers/auth_controller.dart';

class LoginWithOtp extends GetView<AuthController> {
  const LoginWithOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: context.l10n.logInWithOtp,
      subtitle: '',
      subtitleUnderlinedText: '',
      onSubtitleUnderlinedTap: () {},
      showBackButton: true,
      onBackPressed: () => Get.back(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Center(
            child: Text(
              context.l10n.enterYourMobileNumber,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          Center(
            child: Text(
              context.l10n.weWillSendYouOtp,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                color: AppColors.grey650,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.enterMobileNumber,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Phone number input
          Obx(
            () => CustomInputField(
              controller: controller.phoneController,
              placeholder: context.l10n.phoneNumberPlaceholder,
              prefixIcon: Icons.phone_outlined,
              errorText: controller.errorText.value,
              validator: (value) =>
                  controller.validatePhoneNumber(context, value),
              showSuccessState: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onChanged: controller.onPhoneChanged,
              onSubmitted: (_) => controller.sendOtp(context),
              inputFormatters: [InputFormatters.phoneNumber],
            ),
          ),

          SizedBox(height: AppSpacing.xxl),

          // Send OTP button
          Obx(() {
            final isValid = controller.isPhoneValid;
            return isValid
                ? GradientButton.filled(
                    text: context.l10n.sendOtp,
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.sendOtp(context),
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  )
                : GradientButton.outlined(
                    text: context.l10n.sendOtp,
                    onPressed: null,
                    width: double.infinity,
                  );
          }),
        ],
      ),
      bottomWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.haveTroubleLoggingIn,
            style: AppTextStyles.getMontserratStyle(
              14.sp,
              FontWeight.w400,
              AppColors.black,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${context.l10n.contact} ",
                style: AppTextStyles.getMontserratStyle(
                  12.sp,
                  FontWeight.w500,
                  AppColors.black,
                ),
              ),
              SizedBox(width: 4.w),
              GradientText(
                AppStrings.phoneNumber,
                style: AppTextStyles.getMontserratStyle(
                  14.sp,
                  FontWeight.w500,
                  AppColors.grey650,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

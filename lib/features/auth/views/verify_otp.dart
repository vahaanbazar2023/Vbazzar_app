import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auth_controller.dart';

/// Bridges Pinput's SmsRetriever interface with SmartAuth's User Consent API.
/// When SMS arrives, Android shows a one-tap system dialog.
/// On approval, Pinput auto-fills the code and fires onCompleted.
class _SmsRetrieverImpl implements SmsRetriever {
  const _SmsRetrieverImpl();

  @override
  Future<String?> getSmsCode() async {
    final res = await SmartAuth.instance.getSmsWithUserConsentApi();
    return res.data?.code;
  }

  @override
  Future<void> dispose() {
    return SmartAuth.instance.removeUserConsentApiListener();
  }

  @override
  bool get listenForMultipleSms => false;
}

class VerifyOTP extends GetView<AuthController> {
  const VerifyOTP({super.key});

  @override
  Widget build(BuildContext context) {
    // Focus node for OTP input
    final focusNode = FocusNode();

    // Gradient border decoration
    final gradientBorderDecoration = BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment(0.0, -0.8),
        end: Alignment(0.0, 1.0),
        colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        stops: [0.0899, 0.7771],
      ),
      borderRadius: BorderRadius.circular(12.r),
    );

    // Default Pinput theme (unfilled/inactive boxes with gradient border simulation)
    final defaultPinTheme = PinTheme(
      width: 47.w, // Increased to accommodate gradient container
      height: 47.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.2, -1.0),
          end: Alignment(0.2, 1.0),
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          stops: [0.0899, 0.7771],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(1.0.w), // This creates the border effect
      margin: EdgeInsets.zero,
    );

    // Focused Pinput theme (active box)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    // Submitted Pinput theme (filled boxes with gradient)
    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
    );

    // Error Pinput theme
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error, width: 2.w),
      ),
    );

    return AuthLayout(
      title: context.l10n.enterOtp,
      subtitle: context.l10n.loggingInViaOtp,
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
              context.l10n.enterSixDigitOtpSentTo,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          // Subtitle with phone number
          Center(
            child: Obx(() {
              final phoneNumber = controller.phoneText.value;
              return RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.grey650,
                  ),
                  children: [
                    TextSpan(
                      text: phoneNumber.isNotEmpty
                          ? '+91 $phoneNumber'
                          : context.l10n.phoneNumberPlaceholder,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: AppSpacing.xxl),

          // OTP Input with Pinput
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Pinput(
                controller: controller.otpController,
                focusNode: focusNode,
                length: 6,
                smsRetriever: const _SmsRetrieverImpl(),
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                errorPinTheme: errorPinTheme,
                pinAnimationType: PinAnimationType.scale,
                animationDuration: const Duration(milliseconds: 200),
                preFilledWidget: Container(
                  padding: EdgeInsets.all(0.5.w),
                  decoration: gradientBorderDecoration,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11.0.r),
                    ),
                  ),
                ),
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
                onCompleted: (pin) {
                  // Call verify OTP API
                  debugPrint('OTP Completed: $pin');
                  controller.verifyOtp(context, pin);
                },
                onChanged: (value) {
                  // Clear error when user types (otpText is auto-synced via listener)
                  if (controller.errorText.value != null) {
                    controller.errorText.value = null;
                  }
                },
              ),
            ),
          ),

          SizedBox(height: AppSpacing.md),
          // Timer or Resend OTP button
          Obx(() {
            if (controller.canResendOtp.value) {
              // Show resend button when timer expires
              return Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.resendOtp,
                  child: GradientText(
                    context.l10n.resendOtp,
                    style: AppTextStyles.getMontserratStyle(
                      16.sp,
                      FontWeight.w600,
                      AppColors.textHelper,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              );
            } else {
              // Show timer
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      context.l10n.didNotReceiveOtp,
                      style: AppTextStyles.getMontserratStyle(
                        10.sp,
                        FontWeight.w600,
                        AppColors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppAssets.clock,
                        width: 14.w,
                        height: 14.h,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${context.l10n.resendOtp} in ${controller.formattedTimer}',
                        style: AppTextStyles.getMontserratStyle(
                          12.sp,
                          FontWeight.w600,
                          AppColors.textHelper,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }),

          SizedBox(height: AppSpacing.xxl),
          // Verify button
          Obx(() {
            final isOtpComplete = controller.otpText.value.length == 6;
            return isOtpComplete
                ? GradientButton.filled(
                    text: context.l10n.verify,
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            // Implement verify OTP
                            final otp = controller.otpText.value;
                            debugPrint('Verifying OTP: $otp');
                            controller.verifyOtp(context, otp);
                          },
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  )
                : GradientButton.outlined(
                    text: context.l10n.verify,
                    onPressed: null,
                    width: double.infinity,
                  );
          }),

          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

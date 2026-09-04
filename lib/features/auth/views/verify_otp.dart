import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auth_controller.dart';

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
    final focusNode = FocusNode();

    // ── Pin themes ────────────────────────────────────────────────
    final defaultPinTheme = PinTheme(
      width: 47.w,
      height: 47.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Plus Jakarta Sans',
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
      padding: EdgeInsets.all(1.0.w),
      margin: EdgeInsets.zero,
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Plus Jakarta Sans',
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error, width: 2.w),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── AppHeader ─────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: context.l10n.enterOtp,
              showBack: true,
              onBack: () => Get.back(),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),

                    // ── OTP white card ──────────────────────────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Lock icon
                          Container(
                            width: 56.r,
                            height: 56.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 26.r,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 14.h),

                          Text(
                            context.l10n.enterSixDigitOtpSentTo,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),

                          Obx(() {
                            final phone = controller.phoneText.value;
                            return RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13.sp,
                                  color: AppColors.grey600,
                                ),
                                children: [
                                  const TextSpan(text: 'Sent to '),
                                  TextSpan(
                                    text: phone.isNotEmpty
                                        ? '+91 $phone'
                                        : context.l10n.phoneNumberPlaceholder,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 28.h),

                          // Pinput
                          Pinput(
                            controller: controller.otpController,
                            focusNode: focusNode,
                            length: 6,
                            smsRetriever: const _SmsRetrieverImpl(),
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: submittedPinTheme,
                            errorPinTheme: errorPinTheme,
                            pinAnimationType: PinAnimationType.scale,
                            animationDuration: const Duration(
                              milliseconds: 200,
                            ),
                            preFilledWidget: Container(
                              padding: EdgeInsets.all(0.5.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment(0.0, -0.8),
                                  end: Alignment(0.0, 1.0),
                                  colors: [
                                    AppColors.ctaGradientStart,
                                    AppColors.ctaGradientEnd,
                                  ],
                                  stops: [0.0899, 0.7771],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
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
                            onCompleted: (pin) =>
                                controller.verifyOtp(context, pin),
                            onChanged: (value) {
                              if (controller.errorText.value != null) {
                                controller.errorText.value = null;
                              }
                            },
                          ),

                          SizedBox(height: 16.h),

                          // Timer / Resend
                          Obx(() {
                            if (controller.canResendOtp.value) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: controller.resendOtp,
                                  child: GradientText(
                                    context.l10n.resendOtp,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    context.l10n.didNotReceiveOtp,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
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
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),

                          SizedBox(height: 24.h),

                          // Verify button
                          Obx(() {
                            final isComplete =
                                controller.otpText.value.length == 6;
                            return isComplete
                                ? GradientButton.filled(
                                    text: context.l10n.verify,
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () => controller.verifyOtp(
                                            context,
                                            controller.otpText.value,
                                          ),
                                    isLoading: controller.isLoading.value,
                                    width: double.infinity,
                                  )
                                : GradientButton.outlined(
                                    text: context.l10n.verify,
                                    onPressed: null,
                                    width: double.infinity,
                                  );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.grey300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'Need help?',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12.sp,
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.grey300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Support card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.headset_mic_outlined,
                              size: 20.r,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.haveTroubleLoggingIn,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Text(
                                      '${context.l10n.contact}: ',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12.sp,
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                    GradientText(
                                      AppStrings.phoneNumber,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20.r,
                            color: AppColors.grey400,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

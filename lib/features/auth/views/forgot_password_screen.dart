import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auth_controller.dart';
import 'login_widgets.dart';

const _font = 'Plus Jakarta Sans';

/// Set or reset a password in two steps: text a code to the account's mobile
/// number, then choose a new password. An account created by OTP has no
/// password until the user comes through here once.
///
/// Laid out like the login screen: the app header, then one white card holding
/// a short hero, a two-step progress bar and the form panel.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController controller = Get.find<AuthController>();
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    // Always start at the first step.
    controller.resetTransactionId.value = null;
    // Save the user retyping the number they already entered on the OTP tab.
    final phone = controller.phoneController.text.trim();
    if (controller.usernameController.text.trim().isEmpty &&
        phone.length == 10) {
      controller.usernameController.text = phone;
    }
  }

  Future<void> _changePassword() async {
    final changed = await controller.resetPassword();
    // Not Get.back(): the success snackbar is showing at this point, and
    // Get.back() would close the snackbar and leave this screen open.
    if (changed && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: context.l10n.authSetNewPassword),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 24.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
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
                    child: Obx(() {
                      final codeSent =
                          controller.resetTransactionId.value != null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _hero(context, codeSent),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: _StepBar(step: codeSent ? 2 : 1),
                          ),
                          SizedBox(height: 14.h),
                          Container(
                            margin: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: codeSent
                                  ? _resetStep(context)
                                  : _sendStep(context),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  const LoginHelpSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// What this step asks for, beside the lock artwork used on the login screen.
  Widget _hero(BuildContext context, bool codeSent) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 14.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  codeSent
                      ? context.l10n.newPassword
                      : context.l10n.forgotPassword,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  codeSent
                      ? context.l10n.authPasswordMinLength
                      : context.l10n.authResetCodeHint,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 12.sp,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Image.asset(
            'assets/images/png/login_shield.png',
            width: 56.w,
            height: 62.h,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String text,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: enabled
          ? GradientButton.filled(
              text: text,
              onPressed: controller.isLoading.value ? null : onPressed,
              isLoading: controller.isLoading.value,
              width: 200.w,
              height: 44.h,
            )
          : GradientButton.outlined(
              text: text,
              onPressed: null,
              width: 200.w,
              height: 44.h,
            ),
    );
  }

  List<Widget> _sendStep(BuildContext context) {
    return [
      CustomInputField(
        controller: controller.usernameController,
        placeholder: context.l10n.authUsernameOrMobile,
        prefixIcon: Icons.person_outline_rounded,
        textInputAction: TextInputAction.done,
        maxLength: 20,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]')),
        ],
        onSubmitted: (_) => controller.sendPasswordResetCode(),
      ),
      SizedBox(height: 14.h),
      _button(
        text: context.l10n.authSendCode,
        enabled: controller.usernameText.value.trim().length >= 6,
        onPressed: controller.sendPasswordResetCode,
      ),
    ];
  }

  List<Widget> _resetStep(BuildContext context) {
    return [
      CustomInputField(
        controller: controller.resetCodeController,
        placeholder: context.l10n.enterOtp,
        prefixIcon: Icons.sms_outlined,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: 8,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      SizedBox(height: 10.h),
      CustomInputField(
        controller: controller.newPasswordController,
        placeholder: context.l10n.newPassword,
        prefixIcon: Icons.lock_outline_rounded,
        obscureText: _hidePassword,
        suffixIcon: _hidePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () => setState(() => _hidePassword = !_hidePassword),
        textInputAction: TextInputAction.done,
      ),
      SizedBox(height: 14.h),
      _button(
        text: context.l10n.changePassword,
        enabled: controller.isResetFormValid,
        onPressed: _changePassword,
      ),
      SizedBox(height: 2.h),
      // Own Obx: the countdown repaints this line only, not the whole form.
      Obx(() {
        final style = TextStyle(
          fontFamily: _font,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        );
        if (!controller.canResendOtp.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Text(
              '${context.l10n.resendOtp} in ${controller.formattedTimer}',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return Center(
          child: TextButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.sendPasswordResetCode,
            child: Text(context.l10n.resendOtp, style: style),
          ),
        );
      }),
    ];
  }
}

/// Two segments: the first is always filled, the second once the code is sent.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$step / 2',
      child: Row(
        children: [
          for (var i = 1; i <= 2; i++) ...[
            if (i > 1) SizedBox(width: 6.w),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4.h,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.primary : AppColors.grey200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

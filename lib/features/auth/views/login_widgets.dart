import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';

const _font = 'Plus Jakarta Sans';
const _termsUrl = 'https://www.vahaanbazar.com/terms-and-conditions';
const _privacyUrl = 'https://www.vahaanbazar.com/privacy-policy';

/// Username / password may only contain what the backend accepts for a login id.
final _loginIdFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-Z0-9_.]'),
);

/// "OTP | Password" switch at the top of the login card.
class LoginModeToggle extends StatelessWidget {
  const LoginModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Obx(() {
      final passwordMode = controller.isPasswordMode.value;
      return Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            _tab(context.l10n.otp, !passwordMode, () {
              controller.isPasswordMode.value = false;
            }),
            _tab(context.l10n.password, passwordMode, () {
              controller.isPasswordMode.value = true;
            }),
          ],
        ),
      );
    });
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 34.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: _font,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }
}

/// The two tick-boxes on the OTP form: agreement to the Terms & Privacy Policy
/// (required to continue) and offers / auction alerts (optional).
class LoginConsentBoxes extends StatefulWidget {
  const LoginConsentBoxes({super.key});

  @override
  State<LoginConsentBoxes> createState() => _LoginConsentBoxesState();
}

class _LoginConsentBoxesState extends State<LoginConsentBoxes> {
  final AuthController controller = Get.find<AuthController>();
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _open(_termsUrl);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _open(_privacyUrl);

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: _font,
      fontSize: 11.5.sp,
      color: AppColors.grey600,
      height: 1.4,
    );
    final link = base.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          Obx(
            () => _row(
              value: controller.agreedToTerms.value,
              onChanged: (v) => controller.agreedToTerms.value = v,
              child: Text.rich(
                TextSpan(
                  style: base,
                  children: [
                    TextSpan(text: context.l10n.authIAgreeToThe),
                    TextSpan(
                      text: context.l10n.termsAndConditions,
                      style: link,
                      recognizer: _termsTap,
                    ),
                    TextSpan(text: context.l10n.and),
                    TextSpan(
                      text: context.l10n.privacyPolicy,
                      style: link,
                      recognizer: _privacyTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Obx(
            () => _row(
              value: controller.marketingOptIn.value,
              onChanged: (v) => controller.marketingOptIn.value = v,
              child: Text(context.l10n.authOffersOptIn, style: base),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22.r,
          height: 22.r,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Username (or mobile number) + password form shown in password mode.
class PasswordLoginPanel extends StatefulWidget {
  const PasswordLoginPanel({super.key});

  @override
  State<PasswordLoginPanel> createState() => _PasswordLoginPanelState();
}

class _PasswordLoginPanelState extends State<PasswordLoginPanel> {
  final AuthController controller = Get.find<AuthController>();
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 6.h),
        CustomInputField(
          controller: controller.usernameController,
          placeholder: context.l10n.authUsernameOrMobile,
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          maxLength: 20,
          inputFormatters: [_loginIdFormatter],
        ),
        SizedBox(height: 10.h),
        CustomInputField(
          controller: controller.passwordController,
          placeholder: context.l10n.enterPassword,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _hidePassword,
          suffixIcon: _hidePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixTap: () => setState(() => _hidePassword = !_hidePassword),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.loginWithPassword(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.to(() => const ForgotPasswordScreen()),
            child: Text(
              context.l10n.forgotPassword,
              style: TextStyle(
                fontFamily: _font,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Obx(() {
          final ready = controller.isPasswordFormValid;
          return Center(
            child: ready
                ? GradientButton.filled(
                    text: context.l10n.inspLogIn,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.loginWithPassword,
                    isLoading: controller.isLoading.value,
                    width: 200.w,
                    height: 44.h,
                  )
                : GradientButton.outlined(
                    text: context.l10n.inspLogIn,
                    onPressed: null,
                    width: 200.w,
                    height: 44.h,
                  ),
          );
        }),
        SizedBox(height: 10.h),
        Text(
          context.l10n.authNoPasswordHint,
          style: TextStyle(
            fontFamily: _font,
            fontSize: 11.sp,
            color: AppColors.grey600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

/// "Need help?" divider and the support card with the helpline number.
/// Shown under the login card and under the set-password card; tapping the
/// card calls the helpline.
class LoginHelpSection extends StatelessWidget {
  const LoginHelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                context.l10n.inspNeedHelp,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 12.sp,
                  color: AppColors.grey500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
          ],
        ),
        SizedBox(height: 14.h),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => launchUrl(Uri.parse('tel:+91${AppStrings.phoneNumber}')),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                          fontFamily: _font,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${context.l10n.contact}: ',
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: 12.sp,
                              color: AppColors.grey600,
                            ),
                          ),
                          GradientText(
                            AppStrings.phoneNumber,
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }
}

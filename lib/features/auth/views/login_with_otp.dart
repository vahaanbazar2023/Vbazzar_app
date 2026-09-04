import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/input_formatters.dart';
import '../controllers/auth_controller.dart';

class LoginWithOtp extends StatefulWidget {
  const LoginWithOtp({super.key});

  @override
  State<LoginWithOtp> createState() => _LoginWithOtpState();
}

class _LoginWithOtpState extends State<LoginWithOtp> {
  final AuthController controller = Get.find<AuthController>();

  Country _selectedCountry = countries.firstWhere(
    (c) => c.code == 'IN',
    orElse: () => countries.first,
  );

  void _openCountryPicker() {
    final searchCtrl = TextEditingController();
    List<Country> filtered = List.from(countries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                    child: Text(
                      'Select Country',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.grey300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.grey300),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      onChanged: (q) {
                        setModalState(() {
                          filtered = countries
                              .where(
                                (c) =>
                                    c.name.toLowerCase().contains(
                                      q.toLowerCase(),
                                    ) ||
                                    c.dialCode.contains(q),
                              )
                              .toList();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final isSelected = c.code == _selectedCountry.code;
                        return ListTile(
                          leading: Text(
                            c.flag ?? '',
                            style: TextStyle(fontSize: 22.sp),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          trailing: Text(
                            '+${c.dialCode}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.sp,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey500,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                          onTap: () {
                            setState(() => _selectedCountry = c);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── App Header ────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: AppHeader(title: 'Log In', showBack: false),
          ),

          // ── Scrollable body ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),

                    // ── White card ──────────────────────────────
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
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome row
                          Padding(
                           padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back! 👋',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 13.sp,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Log In',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.black,
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        'with OTP',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                          height: 1.1,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          Container(
                                            width: 28.r,
                                            height: 28.r,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.shield_outlined,
                                              size: 14.r,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Secure and quick access\nto your account',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 11.sp,
                                              color: AppColors.grey600,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Shield image
                                Image.asset(
                                  'assets/images/png/login_shield.png',
                                  width: 100.w,
                                  height: 110.h,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                      
                        
                      
                          // Input card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.grey200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Phone icon
                                Container(
                                  width: 48.r,
                                  height: 48.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.phone_android_rounded,
                                    size: 22.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  context.l10n.enterYourMobileNumber,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  context.l10n.weWillSendYouOtp,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12.sp,
                                    color: AppColors.grey600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.h),
                      
                                // Country picker + phone input
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Country picker
                                    GestureDetector(
                                      onTap: _openCountryPicker,
                                      child: Container(
                                        height: 50.h,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.grey300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 32.r,
                                              height: 32.r,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.grey200,
                                                  width: 1,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                _selectedCountry.flag ?? '🏳',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              '+${_selectedCountry.dialCode}',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Plus Jakarta Sans',
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Icon(
                                              Icons
                                                  .keyboard_arrow_down_rounded,
                                              size: 16.r,
                                              color: AppColors.grey500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Phone number input
                                    Expanded(
                                      child: Obx(
                                        () => CustomInputField(
                                          controller:
                                              controller.phoneController,
                                          placeholder: context
                                              .l10n
                                              .phoneNumberPlaceholder,
                                          prefixIcon: Icons.phone_outlined,
                                          errorText:
                                              controller.errorText.value,
                                          validator: (value) =>
                                              controller.validatePhoneNumber(
                                                context,
                                                value,
                                              ),
                                          showSuccessState: true,
                                          keyboardType: TextInputType.phone,
                                          textInputAction:
                                              TextInputAction.done,
                                          onChanged:
                                              controller.onPhoneChanged,
                                          onSubmitted: (_) =>
                                              controller.sendOtp(context),
                                          inputFormatters: [
                                            InputFormatters.phoneNumber,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                      
                                // Send OTP button
                                Obx(() {
                                  final isValid = controller.isPhoneValid;
                                  return SizedBox(
                                    width: double.infinity,
                                    child: isValid
                                        ? GradientButton.filled(
                                        
                                            text: context.l10n.sendOtp,
                                            onPressed:
                                                controller.isLoading.value
                                                ? null
                                                : () => controller.sendOtp(
                                                    context,
                                                  ),
                                            isLoading:
                                                controller.isLoading.value,
                                            width: 100.w,
                                          )
                                        : GradientButton.outlined(
                                            text: context.l10n.sendOtp,
                                            onPressed: null,
                                             width: 100.w,
                                          ),
                                  );
                                }),
                              ],
                            ),
                          ),
                      
                          SizedBox(height: 16.h),
                      
                          // Privacy note
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 18.r,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'Your number is safe with us.\nWe never share it with anyone.',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.sp,
                                      color: AppColors.grey600,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

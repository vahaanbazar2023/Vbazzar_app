import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/models/location_models.dart';
import '../controllers/profile_controller.dart';

class ManageProfileView extends GetView<ProfileController> {
  const ManageProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize form with existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initManageProfileForm();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                    // First Name
                    _FieldLabel('First Name *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomInputField(
                        controller: controller.firstNameController,
                        placeholder: 'Enter first name',
                        prefixIcon: Icons.person_outline,
                        errorText: controller.firstNameErrorText.value,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {},
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Last Name
                    _FieldLabel('Last Name'),
                    SizedBox(height: AppSpacing.sm),
                    CustomInputField(
                      controller: controller.lastNameController,
                      placeholder: 'Enter last name (optional)',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Email
                    _FieldLabel('Email *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomInputField(
                        controller: controller.emailController,
                        placeholder: 'Enter email address',
                        prefixIcon: Icons.email_outlined,
                        errorText: controller.emailErrorText.value,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {},
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Address
                    _FieldLabel('Address'),
                    SizedBox(height: AppSpacing.sm),
                    CustomInputField(
                      controller: controller.addressController,
                      placeholder: 'Enter address',
                      prefixIcon: Icons.home_outlined,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Pincode
                    _FieldLabel('Pincode'),
                    SizedBox(height: AppSpacing.sm),
                    CustomInputField(
                      controller: controller.pincodeController,
                      placeholder: 'Enter pincode',
                      prefixIcon: Icons.location_on_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: AppSpacing.md),

                    // State dropdown
                    _FieldLabel('State *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(() {
                      if (controller.isLoadingStates.value) {
                        return SizedBox(
                          height: 48.h,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _StateDropdown(controller: controller);
                    }),
                    SizedBox(height: AppSpacing.md),

                    // City dropdown
                    _FieldLabel('City *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(() {
                      if (controller.isLoadingCities.value) {
                        return SizedBox(
                          height: 48.h,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _CityDropdown(controller: controller);
                    }),
                    SizedBox(height: AppSpacing.xxl),

                    // Save button
                    Obx(() {
                      final isValid =
                          controller.isManageProfileFormValid;
                      return isValid
                          ? GradientButton.filled(
                              text: 'Save Changes',
                              onPressed: controller.isUpdatingProfile.value
                                  ? null
                                  : () => controller.updateProfile(),
                              isLoading: controller.isUpdatingProfile.value,
                              width: double.infinity,
                            )
                          : GradientButton.outlined(
                              text: 'Save Changes',
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
            'Manage Profile',
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

// ── State Dropdown ────────────────────────────────────────────────────────────

class _StateDropdown extends StatelessWidget {
  const _StateDropdown({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: controller.stateErrorText.value != null
                ? AppColors.error
                : AppColors.grey300,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<StateModel>(
            value: controller.selectedState.value,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'Select state',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey650,
                  fontSize: 14.sp,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            borderRadius: BorderRadius.circular(12.r),
            items: controller.availableStates
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.stateName),
                  ),
                )
                .toList(),
            onChanged: (state) => controller.onStateSelected(state),
          ),
        ),
      ),
    );
  }
}

// ── City Dropdown ─────────────────────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: controller.cityErrorText.value != null
                ? AppColors.error
                : AppColors.grey300,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<CityModel>(
            value: controller.selectedCity.value,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                controller.selectedState.value == null
                    ? 'Select state first'
                    : 'Select city',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey650,
                  fontSize: 14.sp,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            borderRadius: BorderRadius.circular(12.r),
            items: controller.availableCities
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.cityName),
                  ),
                )
                .toList(),
            onChanged: controller.selectedState.value == null
                ? null
                : (city) => controller.onCitySelected(city),
          ),
        ),
      ),
    );
  }
}
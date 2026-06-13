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

                    // Mobile Number (read-only)
                    _FieldLabel('Mobile Number'),
                    SizedBox(height: AppSpacing.sm),
                    CustomInputField(
                      controller: controller.phoneNumberController,
                      placeholder: 'Mobile number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: AppSpacing.md),

                    // State (autocomplete)
                    _FieldLabel('State *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomAutocompleteField<StateModel>(
                        controller: controller.stateTextController,
                        placeholder: 'Select State',
                        prefixIcon: Icons.location_on_outlined,
                        errorText: controller.stateErrorText.value,
                        isLoading: controller.isLoadingStates.value,
                        options: controller.availableStates,
                        displayStringForOption: (s) => s.stateName,
                        onSelected: (state) =>
                            controller.onStateSelected(state),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // City (autocomplete)
                    _FieldLabel('City *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomAutocompleteField<CityModel>(
                        controller: controller.cityTextController,
                        placeholder: controller.selectedState.value == null
                            ? 'Select state first'
                            : 'Select City',
                        prefixIcon: Icons.location_city_outlined,
                        errorText: controller.cityErrorText.value,
                        isLoading: controller.isLoadingCities.value,
                        options: controller.availableCities,
                        enabled: controller.selectedState.value != null,
                        displayStringForOption: (c) => c.cityName,
                        onSelected: (city) =>
                            controller.onCitySelected(city),
                      ),
                    ),
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


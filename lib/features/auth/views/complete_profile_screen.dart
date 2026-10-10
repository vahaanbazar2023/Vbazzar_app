import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/input_formatters.dart';
import '../controllers/auth_controller.dart';

class CompleteProfileScreen extends GetView<AuthController> {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch states when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.availableStates.isEmpty) controller.fetchStates();
    });

    return AuthLayout(
      title: context.l10n.inspCompleteProfile,
      subtitle: '',
      subtitleUnderlinedText: '',
      onSubtitleUnderlinedTap: () {},
      showBackButton: false,
      onBackPressed: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              context.l10n.inspTellUsAboutYourself,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              context.l10n.inspCompleteProfileSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                color: AppColors.grey650,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // First Name (required)
          Text(
            '${context.l10n.firstName} *',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Obx(
            () => CustomInputField(
              controller: controller.firstNameController,
              placeholder: context.l10n.inspEnterFirstName,
              prefixIcon: Icons.person_outline,
              errorText: controller.firstNameErrorText.value,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onChanged: (_) {},
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Last Name (optional)
          Text(
            context.l10n.lastName,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          CustomInputField(
            controller: controller.lastNameController,
            placeholder: context.l10n.enterLastNameOptional,
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onChanged: (_) {},
          ),
          SizedBox(height: AppSpacing.md),

          // Email (required)
          Text(
            '${context.l10n.email} *',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Obx(
            () => CustomInputField(
              controller: controller.emailController,
              placeholder: context.l10n.inspEnterEmailAddress,
              prefixIcon: Icons.email_outlined,
              errorText: controller.emailErrorText.value,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) {},
              inputFormatters: [InputFormatters.email],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // State dropdown
          Text(
            '${context.l10n.state} *',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Obx(() {
            if (controller.isLoadingStates.value) {
              return SizedBox(
                height: 48.h,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _StateDropdown(controller: controller);
          }),
          SizedBox(height: AppSpacing.md),

          // City dropdown
          Text(
            '${context.l10n.city} *',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Obx(() {
            if (controller.isLoadingCities.value) {
              return SizedBox(
                height: 48.h,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _CityDropdown(controller: controller);
          }),
          SizedBox(height: AppSpacing.xxl),

          // Submit button
          Obx(() {
            final isValid = controller.isCompleteProfileFormValid;
            return isValid
                ? GradientButton.filled(
                    text: context.l10n.inspSaveAndContinue,
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.completeProfile(context),
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  )
                : GradientButton.outlined(
                    text: context.l10n.inspSaveAndContinue,
                    onPressed: null,
                    width: double.infinity,
                  );
          }),
          SizedBox(height: AppSpacing.md),
        ],
      ),
      bottomWidget: const SizedBox.shrink(),
    );
  }
}

// ── State dropdown ──────────────────────────────────────────────

class _StateDropdown extends StatelessWidget {
  const _StateDropdown({required this.controller});

  final AuthController controller;

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
          child: DropdownButton<String>(
            value: controller.selectedState.value?.stateId,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                context.l10n.selectState,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    value: s.stateId,
                    child: Text(
                      s.stateName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (stateId) {
              final state = controller.availableStates.firstWhereOrNull(
                (s) => s.stateId == stateId,
              );
              controller.onStateSelected(state);
            },
          ),
        ),
      ),
    );
  }
}

// ── City dropdown ───────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.controller});

  final AuthController controller;

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
          child: DropdownButton<String>(
            value: controller.selectedCity.value?.cityId,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                controller.selectedState.value == null
                    ? context.l10n.inspSelectStateFirst
                    : context.l10n.selectCity,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    value: c.cityId,
                    child: Text(
                      c.cityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: controller.selectedState.value == null
                ? null
                : (cityId) {
                    final city = controller.availableCities.firstWhereOrNull(
                      (c) => c.cityId == cityId,
                    );
                    controller.onCitySelected(city);
                  },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
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

    // A required step after sign-up: the app's standard white header, no back button.
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              AppHeader(
                title: context.l10n.inspCompleteProfile,
                showBack: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.inspTellUsAboutYourself,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.inspCompleteProfileSubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12.5.sp,
                          color: AppColors.grey650,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Each field shows its name once: as the floating label on the border (with * when required).
                      Obx(
                        () => CustomInputField(
                          controller: controller.firstNameController,
                          label: '${context.l10n.firstName} *',
                          placeholder: context.l10n.inspEnterFirstName,
                          prefixIcon: Icons.person_outline,
                          errorText: controller.firstNameErrorText.value,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [InputFormatters.alphabeticOnly],
                          onChanged: (_) {},
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      CustomInputField(
                        controller: controller.lastNameController,
                        label: context.l10n.lastName,
                        placeholder: context.l10n.enterLastNameOptional,
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [InputFormatters.alphabeticOnly],
                        onChanged: (_) {},
                      ),
                      SizedBox(height: AppSpacing.md),
                      Obx(
                        () => CustomInputField(
                          controller: controller.emailController,
                          label: '${context.l10n.email} *',
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
                      SizedBox(height: AppSpacing.xl),

                      // Submit button — centred and the same size as the other sign-in buttons
                      Center(
                        child: Obx(() {
                          final isValid = controller.isCompleteProfileFormValid;
                          return isValid
                              ? GradientButton.filled(
                                  text: context.l10n.inspSaveAndContinue,
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () =>
                                            controller.completeProfile(context),
                                  isLoading: controller.isLoading.value,
                                  width: 200.w,
                                  height: 44.h,
                                )
                              : GradientButton.outlined(
                                  text: context.l10n.inspSaveAndContinue,
                                  onPressed: null,
                                  width: 200.w,
                                  height: 44.h,
                                );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dropdown drawn like [CustomInputField]: same border, icon and text, and its name as the floating label — inside the
/// box while nothing is picked, on the border once something is.
class _LabelledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool hasError;

  const _LabelledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(7.5.r),
      borderSide: BorderSide(color: c, width: 1.w),
    );
    final text = AppTextStyles.bodyMedium.copyWith(
      fontSize: 14.sp,
      color: AppColors.grey850,
      fontWeight: FontWeight.w400,
      fontFamily: 'Montserrat',
    );
    return InputDecorator(
      isEmpty: value == null,
      decoration: InputDecoration(
        labelText: label,
        enabled: enabled,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: text.copyWith(color: AppColors.grey550),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          color: hasError ? AppColors.error : AppColors.grey650,
        ),
        prefixIcon: Icon(icon, size: 20.sp, color: AppColors.grey650),
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
        border: border(AppColors.blackTransparent),
        enabledBorder: border(
          hasError ? AppColors.error : AppColors.blackTransparent,
        ),
        disabledBorder: border(AppColors.blackTransparent),
        focusedBorder: border(AppColors.ctaGradientStart),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          style: text,
          // The label sits inside the empty box, so no extra hint text.
          hint: const SizedBox.shrink(),
          disabledHint: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(12.r),
          items: items,
          onChanged: onChanged,
        ),
      ),
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
      () => _LabelledDropdown<String>(
        label: '${context.l10n.state} *',
        icon: Icons.map_outlined,
        hasError: controller.stateErrorText.value != null,
        value: controller.selectedState.value?.stateId,
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
      () => _LabelledDropdown<String>(
        // Until a state is picked the box is greyed out and says so.
        label: controller.selectedState.value == null
            ? '${context.l10n.city} * · ${context.l10n.inspSelectStateFirst}'
            : '${context.l10n.city} *',
        icon: Icons.location_city_outlined,
        hasError: controller.cityErrorText.value != null,
        value: controller.selectedCity.value?.cityId,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/location_models.dart';
import '../controllers/profile_controller.dart';

class ManageProfileView extends StatefulWidget {
  const ManageProfileView({super.key});

  @override
  State<ManageProfileView> createState() => _ManageProfileViewState();
}

class _ManageProfileViewState extends State<ManageProfileView> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    // Recreate text controllers synchronously before the widget tree builds —
    // this ensures CustomAutocompleteField never receives a disposed controller.
    controller.recreateFormControllers();
    // Fetch states + prefill form data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initManageProfileForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            AppHeader(title: context.l10n.edit_profile_term),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name
                    _FieldLabel('${context.l10n.firstName} *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomInputField(
                        controller: controller.firstNameController,
                        placeholder: context.l10n.enterFirstName,
                        prefixIcon: Icons.person_outline,
                        errorText: controller.firstNameErrorText.value,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {},
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Last Name
                    _FieldLabel(context.l10n.lastName),
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

                    // Email
                    _FieldLabel('${context.l10n.email} *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomInputField(
                        controller: controller.emailController,
                        placeholder: context.l10n.enterEmail,
                        prefixIcon: Icons.email_outlined,
                        errorText: controller.emailErrorText.value,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {},
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Mobile Number (read-only)
                    _FieldLabel(context.l10n.mobileNumber),
                    SizedBox(height: AppSpacing.sm),
                    CustomInputField(
                      controller: controller.phoneNumberController,
                      placeholder: context.l10n.mobileNumber,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: AppSpacing.md),

                    // State (autocomplete)
                    _FieldLabel('${context.l10n.state} *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomAutocompleteField<StateModel>(
                        controller: controller.stateTextController,
                        placeholder: context.l10n.selectState,
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
                    _FieldLabel('${context.l10n.city} *'),
                    SizedBox(height: AppSpacing.sm),
                    Obx(
                      () => CustomAutocompleteField<CityModel>(
                        controller: controller.cityTextController,
                        placeholder: controller.selectedState.value == null
                            ? context.l10n.selectStateFirst
                            : context.l10n.selectCity,
                        prefixIcon: Icons.location_city_outlined,
                        errorText: controller.cityErrorText.value,
                        isLoading: controller.isLoadingCities.value,
                        options: controller.availableCities,
                        enabled: controller.selectedState.value != null,
                        displayStringForOption: (c) => c.cityName,
                        onSelected: (city) => controller.onCitySelected(city),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Save button
                    Obx(() {
                      final isValid = controller.isManageProfileFormValid;
                      return isValid
                          ? GradientButton.filled(
                              text: context.l10n.saveChanges,
                              onPressed: controller.isUpdatingProfile.value
                                  ? null
                                  : () => controller.updateProfile(),
                              isLoading: controller.isUpdatingProfile.value,
                              width: double.infinity,
                            )
                          : GradientButton.outlined(
                              text: context.l10n.saveChanges,
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

// ── Header replaced by AppHeader ─────────────────────────────────────────────

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

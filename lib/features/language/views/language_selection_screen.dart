import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/language_controller.dart';
import '../models/language_model.dart';

class LanguageSelectionScreen extends GetView<LanguageController> {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          /// RED HEADER
          Container(
            width: double.infinity,
            height: 240.h,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.lg,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6B1111), Color(0xFF4A0B0B)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  context.l10n.languagePreference,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.weWillUseThisAcrossTheApp,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          /// WHITE SECTION WITH OVERLAP
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -AppRadius.xxl),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xxl),
                    topRight: Radius.circular(AppRadius.xxl),
                    bottomLeft: Radius.circular(AppRadius.xl),
                    bottomRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xxl),

                    /// TITLE
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        context.l10n.chooseYourPreferredLanguage,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    /// LANGUAGE LIST
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: controller.languages.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSpacing.lg),
                        itemBuilder: (context, index) {
                          final language = controller.languages[index];

                          return Obx(() {
                            final isSelected =
                                controller.selectedLanguage.value == language;

                            return _LanguageCard(
                              language: language,
                              isSelected: isSelected,
                              onTap: () => controller.selectLanguage(language),
                            );
                          });
                        },
                      ),
                    ),

                    /// CONTINUE BUTTON
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        top: AppSpacing.lg,
                        bottom:
                            MediaQuery.of(context).padding.bottom +
                            AppSpacing.xl,
                      ),
                      child: Obx(() {
                        final isLanguageSelected =
                            controller.selectedLanguage.value != null;

                        return isLanguageSelected
                            ? GradientButton.filled(
                                text: context.l10n.continueButton,
                                onPressed: controller.continueToHome,
                              )
                            : GradientButton.outlined(
                                text: context.l10n.continueButton,
                                onPressed: controller.continueToHome,
                              );
                      }),
                    ),
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

class _LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6A0706)
                : AppColors.black.withOpacity(0.12),
            width: 1.w,
          ),
          borderRadius: AppRadius.borderRadiusSm,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA50300).withOpacity(0.5),
                    offset: Offset(0, 4.h),
                    blurRadius: 12.r,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    offset: Offset(0, 2.h),
                    blurRadius: 4.r,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  language.name,
                  style: AppTextStyles.headingXSmall.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  language.localName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

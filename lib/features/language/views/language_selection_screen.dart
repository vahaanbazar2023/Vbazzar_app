import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/language_controller.dart';
import '../models/language_model.dart';

class LanguageSelectionScreen extends GetView<LanguageController> {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fromProfile = Get.arguments?['fromProfile'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── AppHeader ──────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: context.l10n.languagePreference,
              showBack: fromProfile,
              onBack: fromProfile ? () => Get.back() : null,
            ),
          ),

          // ── Content ───────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              itemCount: controller.languages.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? AppSpacing.lg : AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _HeroBanner(
                    title: context.l10n.chooseYourPreferredLanguage,
                  );
                }
                final language = controller.languages[index - 1];
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

          // ── Pinned Continue / Save button ─────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.06),
                  offset: Offset(0, -2.h),
                  blurRadius: 8.r,
                ),
              ],
            ),
            child: Obx(() {
              final isLanguageSelected =
                  controller.selectedLanguage.value != null;
              final buttonAction = fromProfile
                  ? controller.switchLanguageAndGoBack
                  : controller.continueToHome;
              final text = fromProfile
                  ? context.l10n.save
                  : context.l10n.continueButton;

              return Center(
                child: isLanguageSelected
                    ? GradientButton.filled(
                        text: text,
                        onPressed: buttonAction,
                        width: 140.w,
                        height: 36.h,
                      )
                    : GradientButton.outlined(
                        text: text,
                        onPressed: buttonAction,
                        width: 140.w,
                        height: 36.h,
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero banner: gradient surface with globe motif + title
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String title;

  const _HeroBanner({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            offset: Offset(0, 8.h),
            blurRadius: 20.r,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative translucent globe + rings
          Positioned(
            right: -28.r,
            bottom: -34.r,
            child: Icon(
              Icons.public_rounded,
              size: 140.r,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Positioned(
            right: 60.w,
            top: -24.r,
            child: Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language card: script glyph badge + names + animated check
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  static const _accent = Color(0xFF6A0706);

  static const _glyphs = {
    'en': 'A',
    'hi': 'अ',
    'te': 'అ',
    'kn': 'ಅ',
    'ml': 'അ',
    'ta': 'அ',
  };

  @override
  Widget build(BuildContext context) {
    final glyph = _glyphs[language.code] ?? language.name[0];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF6F5) : Colors.white,
          border: Border.all(
            color: isSelected ? _accent : AppColors.black.withOpacity(0.08),
            width: isSelected ? 1.5.w : 1.w,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.25)
                  : AppColors.black.withOpacity(0.06),
              offset: Offset(0, isSelected ? 6.h : 3.h),
              blurRadius: isSelected ? 16.r : 8.r,
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Glyph badge ───────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          AppColors.ctaGradientStart,
                          AppColors.ctaGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Text(
                glyph,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.black,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // ── Names ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.localName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingXSmall.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    language.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),

            // ── Check indicator ───────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _accent : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? _accent
                      : AppColors.black.withOpacity(0.2),
                  width: 1.5.w,
                ),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check_rounded,
                  size: 15.r,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

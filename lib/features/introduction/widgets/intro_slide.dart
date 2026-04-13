import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/utils/custom_text_styles.dart';
import '../models/intro_model.dart';
import '../controllers/intro_controller.dart';

/// A single intro slide matching the Figma layout exactly
class IntroSlide extends StatelessWidget {
  final IntroModel slide;
  final int currentPage;
  final int totalPages;
  final bool isActive;
  final VoidCallback onNext;

  const IntroSlide({
    super.key,
    required this.slide,
    required this.currentPage,
    required this.totalPages,
    required this.isActive,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.xxxl),

        // ── Text content (Figma specs) - MOVED TO TOP ──────
        // Title: Plus Jakarta Sans Bold, 28pt, white, line-height 139%
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            slide.title,
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.white,
              height: 1.39,
            ),
          ),
        ),

        SizedBox(height: AppSpacing.sm),

        // Description: Plus Jakarta Sans Regular, 18pt, 88% opacity, line-height 132%
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            slide.description,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 18.sp,
              color: AppColors.white.withOpacity(0.88),
              height: 1.32,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // ── Navigation indicators + forward button ──────────
        SizedBox(
          height: AppSizes.buttonLg,
          child: Stack(
            children: [
              // Centered dot indicators
              Center(
                child: Obx(() {
                  final controller = IntroController.to;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (i) {
                      final isIndicatorActive =
                          controller.currentPage.value == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(
                          right: i < totalPages - 1 ? AppSpacing.sm : 0,
                        ),
                        width: isIndicatorActive ? 46.2.w : 9.73.w,
                        height: 9.73.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFill,
                          borderRadius: AppRadius.borderRadiusXxl,
                          border: isIndicatorActive
                              ? Border.all(
                                  color: const Color(
                                    0xFFD41F1F,
                                  ).withOpacity(0.3),
                                  width: 1.w,
                                )
                              : null,
                          boxShadow: isIndicatorActive
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD41F1F,
                                    ).withOpacity(0.3),
                                    offset: Offset(0, 2.43.h),
                                    blurRadius: 9.73.r,
                                    spreadRadius: 3.25.r,
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD41F1F,
                                    ).withOpacity(0.28),
                                    offset: Offset(2.43.w, 0),
                                    blurRadius: 9.73.r,
                                    spreadRadius: 3.25.r,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  );
                }),
              ),

              // Forward button (right-aligned)
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onNext,
                    child: Container(
                      width: AppSizes.buttonMd,
                      height: AppSizes.buttonMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: AppSizes.borderWidthThin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.22),
                            blurRadius: 8,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.white,
                        size: AppSizes.iconSm,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),

        // ── Vehicle image area with background text - MOVED TO BOTTOM ────
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Large faded background text (Figma: Moul, 137.57pt, opacity 0.25)
              // Slide 1: "BUY", Slide 2: "SELL", Slide 3: "BID"
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    currentPage == 0
                        ? 'BUY'
                        : currentPage == 1
                        ? 'SELL'
                        : 'BID',
                    style: MoulTextStyle.style(
                      fontSize: 120.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.25),
                      letterSpacing: 2.75,
                      height: 1.0,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 7.64
                        ..color = AppColors.white.withOpacity(0.25),
                    ),
                  ),
                ),
              ),

              // Vehicle image with rounded bottom corners (Figma: 30px radius)
              Positioned.fill(
                top: 80.h,
                child: ClipRRect(
                  borderRadius: AppRadius.bottomOnly(AppRadius.xl),
                  child: Image.asset(
                    slide.imagePath,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.directions_car_rounded,
                      size: AppSizes.imageLg,
                      color: AppColors.white.withOpacity(0.25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

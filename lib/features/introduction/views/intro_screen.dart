import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/intro_controller.dart';
import '../widgets/intro_slide.dart';

class IntroScreen extends GetView<IntroController> {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pageCtrl = PageController();

    // Set page controller in the controller for auto-play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPageController(pageCtrl);
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // ── Decorative blurred red ellipses ─────────────────
          Positioned(
            top: -size.height * 0.08,
            left: -size.width * 0.3,
            child: _BlurredEllipse(
              width: size.width * 1,
              height: size.width * 1.3,
              opacity: 0.19,
            ),
          ),
          Positioned(
            top: -size.height * 0.14,
            left: -size.width * 0.05,
            child: _BlurredEllipse(
              width: size.width * 0.7,
              height: size.width * 0.7,
              opacity: 0.17,
            ),
          ),

          // ── Main content ────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Skip button ───────────────────────────────
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Padding(
                //     padding: EdgeInsets.only(
                //       right: AppSpacing.md,
                //       top: AppSpacing.sm,
                //     ),
                //     child: TextButton(
                //       onPressed: controller.finishIntro,
                //       child: Text(
                //         'Skip',
                //         style: AppTextStyles.labelMedium.copyWith(
                //           color: AppColors.white.withOpacity(0.6),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                // ── Slide area ────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: pageCtrl,
                    itemCount: controller.slides.length,
                    onPageChanged: controller.onPageChanged,
                    itemBuilder: (_, index) => IntroSlide(
                      slide: controller.slides[index],
                      currentPage: index,
                      totalPages: controller.slides.length,
                      isActive: index == controller.currentPage.value,
                      onNext: () {
                        if (!controller.isLastPage) {
                          pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        controller.nextPage();
                      },
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

// ─── Decorative blurred ellipse ────────────────────────────────
class _BlurredEllipse extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _BlurredEllipse({
    required this.width,
    required this.height,
    this.opacity = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80.w, sigmaY: 80.w),
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight.withOpacity(opacity),
        ),
      ),
    );
  }
}

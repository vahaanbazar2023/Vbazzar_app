import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          controller.ellipseController,
          controller.phase1Controller,
          controller.phase2Controller,
          controller.phase3Controller,
          controller.phase4Controller,
        ]),
        builder: (context, _) {
          final textR = controller.textRect(size.width, size.height);
          final logoR = controller.logoRect(size.width, size.height);
          final vehiclesR = controller.vehiclesRect(size.width, size.height);
          final taglineR = controller.taglineRect(size.width, size.height);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Blurred red ellipse background ─────────────────
              Positioned(
                left: -218.0 * (size.width / 412),
                top: -116.1 * (size.height / 917),
                child: Opacity(
                  opacity: controller.ellipseOpacity.value,
                  child: _BlurredEllipse(width: 691.w, height: 509.w),
                ),
              ),

              // ── VAHAAN BAZAR text ──────────────────────────────
              Positioned(
                left: textR.left,
                top: textR.top,
                width: textR.width,
                height: textR.height,
                child: Image.asset(
                  'assets/images/png/vahaan_bazar_text.png',
                  fit: BoxFit.contain,
                ),
              ),

              // ── VB Logo ────────────────────────────────────────
              Positioned(
                left: logoR.left,
                top: logoR.top,
                width: logoR.width,
                height: logoR.height,
                child: Image.asset(
                  'assets/images/png/vb_logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              // ── Vehicle illustrations ──────────────────────────
              Positioned(
                left: vehiclesR.left,
                top: vehiclesR.top,
                width: vehiclesR.width,
                height: vehiclesR.height,
                child: Image.asset(
                  'assets/images/png/vehicle_illustrations.png',
                  fit: BoxFit.contain,
                ),
              ),

              // ── Tagline ────────────────────────────────────────
              Positioned(
                left: taglineR.left,
                top: taglineR.top,
                width: taglineR.width,
                height: taglineR.height,
                child: Image.asset(
                  'assets/images/png/tagline_text.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Blurred red ellipse (Figma: opacity ~0.05, blur radius 107)
class _BlurredEllipse extends StatelessWidget {
  final double width;
  final double height;

  const _BlurredEllipse({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 107.w, sigmaY: 107.w),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

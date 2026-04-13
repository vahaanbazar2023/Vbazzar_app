import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';

// ── Figma SMART_ANIMATE position data ────────────────────────────
// Each element's (left, top, width, height) at each of the 5 keyframes
// Source canvas: 412 × 917

class ElementRect {
  final double left, top, width, height;
  const ElementRect(this.left, this.top, this.width, this.height);

  ElementRect lerpTo(ElementRect other, double t) {
    return ElementRect(
      lerpDouble(left, other.left, t)!,
      lerpDouble(top, other.top, t)!,
      lerpDouble(width, other.width, t)!,
      lerpDouble(height, other.height, t)!,
    );
  }

  /// Scale from Figma 412×917 canvas to actual screen size
  ElementRect toScreen(double sx, double sy) {
    return ElementRect(left * sx, top * sy, width * sx, height * sy);
  }
}

class SplashController extends GetxController with GetTickerProviderStateMixin {
  static SplashController get to => Get.find();
  final _logger = LoggerService.instance;

  bool _isDisposed = false;

  // Figma canvas reference size
  static const double _canvasW = 412.0;
  static const double _canvasH = 917.0;

  // Figma cubic bezier: (0.5, 0, 0.09, 1.02)
  static final Curve _figmaCurve = Cubic(0.5, 0.0, 0.09, 1.02);

  // ── Keyframe data per element (5 frames) ───────────────────────
  // "VAHAAN BAZAR" text (Frame 1261155708)
  static const _textFrames = [
    ElementRect(-233, 385.3, 877, 97.4), // F1: huge, centered
    ElementRect(36, 440, 340, 37.8), // F2: fits in frame
    ElementRect(117.5, 444, 267, 29.7), // F3: moved right, smaller
    ElementRect(117.5, 444, 267, 29.7), // F4: same as F3
    ElementRect(149, 419.7, 231.6, 25.7), // F5: final
  ];

  // VB Logo (vb-logo 2)
  static const _logoFrames = [
    ElementRect(-254, 400, 134.3, 118), // F1: off-screen left
    ElementRect(-254, 400, 134.3, 118), // F2: still off-screen
    ElementRect(21, 421, 87, 76.5), // F3: visible, left side
    ElementRect(22.5, 422.3, 84, 73.8), // F4: slightly smaller
    ElementRect(18, 368, 127.1, 111.7), // F5: larger, moved up
  ];

  // Vehicle illustrations (Frame 1261155707)
  static const _vehiclesFrames = [
    ElementRect(-171, -233, 753, 143), // F1: off-screen top
    ElementRect(-171, -233, 753, 143), // F2: still off-screen
    ElementRect(-171, -233, 753, 143), // F3: still off-screen
    ElementRect(117.5, 384, 265, 50.3), // F4: visible above text
    ElementRect(150, 368, 229.9, 43.7), // F5: final
  ];

  // Tagline (Frame 1261155709)
  static const _taglineFrames = [
    ElementRect(-171, 950, 753, 55), // F1: off-screen bottom
    ElementRect(-171, 950, 753, 55), // F2: still off-screen
    ElementRect(-171, 950, 753, 55), // F3: still off-screen
    ElementRect(-171, 499, 753, 55), // F4: visible, still wide
    ElementRect(150, 453.4, 249, 18.2), // F5: final
  ];

  // ── Animation controllers (one per transition) ────────────────
  late AnimationController phase1Controller; // F1→F2: 1.0s
  late AnimationController phase2Controller; // F2→F3: 0.6s
  late AnimationController phase3Controller; // F3→F4: 1.0s
  late AnimationController phase4Controller; // F4→F5: 1.0s

  // Curved progress for each phase
  late Animation<double> phase1Progress;
  late Animation<double> phase2Progress;
  late Animation<double> phase3Progress;
  late Animation<double> phase4Progress;

  // Background ellipse
  late AnimationController ellipseController;
  late Animation<double> ellipseOpacity;

  @override
  void onInit() {
    super.onInit();
    _logger.info('SplashController: onInit called');
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Background ellipse
    ellipseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    ellipseOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: ellipseController, curve: Curves.easeIn));

    // Phase 1: Frame 1 → 2 (1.0s)
    phase1Controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    phase1Progress = CurvedAnimation(
      parent: phase1Controller,
      curve: _figmaCurve,
    );

    // Phase 2: Frame 2 → 3 (0.6s)
    phase2Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    phase2Progress = CurvedAnimation(
      parent: phase2Controller,
      curve: _figmaCurve,
    );

    // Phase 3: Frame 3 → 4 (1.0s)
    phase3Controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    phase3Progress = CurvedAnimation(
      parent: phase3Controller,
      curve: _figmaCurve,
    );

    // Phase 4: Frame 4 → 5 (1.0s)
    phase4Controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    phase4Progress = CurvedAnimation(
      parent: phase4Controller,
      curve: _figmaCurve,
    );

    _startAnimationSequence();
  }

  // ── Compute current rect for any element ──────────────────────
  ElementRect _currentRect(
    List<ElementRect> frames,
    double screenW,
    double screenH,
  ) {
    final sx = screenW / _canvasW;
    final sy = screenH / _canvasH;

    // Determine which keyframe pair we're interpolating
    ElementRect rect;
    if (phase4Controller.value > 0) {
      rect = frames[3].lerpTo(frames[4], phase4Progress.value);
    } else if (phase3Controller.value > 0) {
      rect = frames[2].lerpTo(frames[3], phase3Progress.value);
    } else if (phase2Controller.value > 0) {
      rect = frames[1].lerpTo(frames[2], phase2Progress.value);
    } else {
      rect = frames[0].lerpTo(frames[1], phase1Progress.value);
    }

    return rect.toScreen(sx, sy);
  }

  ElementRect textRect(double w, double h) => _currentRect(_textFrames, w, h);
  ElementRect logoRect(double w, double h) => _currentRect(_logoFrames, w, h);
  ElementRect vehiclesRect(double w, double h) =>
      _currentRect(_vehiclesFrames, w, h);
  ElementRect taglineRect(double w, double h) =>
      _currentRect(_taglineFrames, w, h);

  void _startAnimationSequence() async {
    ellipseController.forward();

    // Phase 1: after 10ms timeout (Figma: 0.01s)
    await Future.delayed(const Duration(milliseconds: 10));
    if (_isDisposed) return;
    await phase1Controller.forward().orCancel.catchError((_) {});

    // Phase 2: after 20ms timeout (Figma: 0.02s)
    await Future.delayed(const Duration(milliseconds: 20));
    if (_isDisposed) return;
    await phase2Controller.forward().orCancel.catchError((_) {});

    // Phase 3: after 50ms timeout (Figma: 0.05s)
    await Future.delayed(const Duration(milliseconds: 50));
    if (_isDisposed) return;
    await phase3Controller.forward().orCancel.catchError((_) {});

    // Phase 4: after 80ms timeout (Figma: 0.08s)
    await Future.delayed(const Duration(milliseconds: 80));
    if (_isDisposed) return;
    await phase4Controller.forward().orCancel.catchError((_) {});

    // Hold then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_isDisposed) _navigate();
  }

  @override
  void onReady() {
    super.onReady();
    _logger.info('SplashController: onReady called');
  }

  Future<void> _navigate() async {
    _logger.info('Starting navigation');

    final hasSeenIntro = LocalStorageService.to.getBool(
      StorageKeys.hasSeenIntro,
    );
    final token = await SecureStorageService.to.read(StorageKeys.authToken);
    final profileCompleted = await SecureStorageService.to.read(
      StorageKeys.profileCompleted,
    );

    if (token != null && token.isNotEmpty) {
      if (profileCompleted == 'true') {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.completeProfile);
      }
    } else if (hasSeenIntro) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.introduction);
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    ellipseController.dispose();
    phase1Controller.dispose();
    phase2Controller.dispose();
    phase3Controller.dispose();
    phase4Controller.dispose();
    super.onClose();
  }
}

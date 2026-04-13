import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../models/intro_model.dart';

class IntroController extends GetxController {
  static IntroController get to => Get.find();

  final currentPage = 0.obs;
  Timer? _autoPlayTimer;
  PageController? pageController;

  final List<IntroModel> slides = const [
    IntroModel(
      title: 'Welcome to\nVAHAAN BAZAR',
      description:
          'Buy and sell vehicles in one place Across trucks, equipment, and more',
      imagePath: AppAssets.introSlide1,
    ),
    IntroModel(
      title: 'Welcome to\nVAHAAN BAZAR',
      description:
          'Create listings in minutes and connect with thousands of buyers instantly.',
      imagePath: AppAssets.introSlide2,
    ),
    IntroModel(
      title: 'Welcome to\nVAHAAN BAZAR',
      description:
          'Join live auctions and secure vehicles at competitive prices.',
      imagePath: AppAssets.introSlide3,
    ),
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  @override
  void onClose() {
    _autoPlayTimer?.cancel();
    super.onClose();
  }

  void setPageController(PageController controller) {
    pageController = controller;
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isLastPage) {
        timer.cancel();
        finishIntro();
      } else {
        pageController?.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    _startAutoPlay(); // Restart timer on manual page change
  }

  void nextPage() {
    if (isLastPage) {
      finishIntro();
      return;
    }
    currentPage.value++;
  }

  void finishIntro() {
    LocalStorageService.to.setBool(StorageKeys.hasSeenIntro, true);
    Get.offAllNamed(AppRoutes.languageSelection);
  }
}

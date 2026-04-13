import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../models/language_model.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final selectedLanguage = Rxn<LanguageModel>();

  final List<LanguageModel> languages = const [
    LanguageModel(
      code: 'en',
      name: 'English',
      localName: 'English',
      flagAsset: 'assets/flags/en.png',
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      localName: 'हिन्दी',
      flagAsset: 'assets/flags/hi.png',
    ),
    LanguageModel(
      code: 'te',
      name: 'Telugu',
      localName: 'తెలుగు',
      flagAsset: 'assets/flags/te.png',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final savedCode = LocalStorageService.to.getString(
      StorageKeys.languageCode,
    );
    if (savedCode.isNotEmpty) {
      selectedLanguage.value = languages.firstWhereOrNull(
        (lang) => lang.code == savedCode,
      );
      if (selectedLanguage.value != null) {
        // Defer locale update until after build phase completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.updateLocale(Locale(savedCode));
        });
      }
    }
  }

  void selectLanguage(LanguageModel language) {
    selectedLanguage.value = language;
    // Update app locale - defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(language.code));
    });
  }

  void continueToHome() {
    if (selectedLanguage.value == null) {
      Get.snackbar(
        'Language Required',
        'Please select a language to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save language preference
    LocalStorageService.to.setString(
      StorageKeys.languageCode,
      selectedLanguage.value!.code,
    );

    // Navigate to login with OTP (keep navigation stack for back button)
    Get.toNamed(AppRoutes.loginWithOtp);
  }

  /// Get localizations from context
  dynamic getLocalizations(BuildContext context) {
    return context.l10n;
  }
}

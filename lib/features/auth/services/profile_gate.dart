import 'dart:async';

import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';

/// New users can browse and pay first; after their first successful payment
/// they must complete their profile. Users whose profile is already complete
/// are never interrupted.
class ProfileGate {
  ProfileGate._();

  static Future<bool> _profileCompleted() async =>
      await SecureStorageService.to.read(StorageKeys.profileCompleted) ==
      'true';

  /// True when a payment was made but the profile is still incomplete.
  static Future<bool> mustCompleteProfile() async {
    if (await _profileCompleted()) return false;
    return await SecureStorageService.to.read(
          StorageKeys.profileRequiredAfterPayment,
        ) ==
        'true';
  }

  /// Call after any successful payment. Persists the requirement (so it
  /// survives an app restart) and, after the module's own success handling
  /// has had time to finish, sends the user to Complete Profile.
  static Future<void> onPaymentSuccess() async {
    if (await _profileCompleted()) return;
    await SecureStorageService.to.write(
      StorageKeys.profileRequiredAfterPayment,
      'true',
    );
    Timer(const Duration(seconds: 2), () async {
      if (await mustCompleteProfile() &&
          Get.currentRoute != AppRoutes.completeProfile) {
        Get.offAllNamed(AppRoutes.completeProfile);
      }
    });
  }
}

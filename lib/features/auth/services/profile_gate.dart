import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../profile/data/profile_data_source.dart';

/// New users can browse and pay first; after their first successful payment
/// they must complete their profile. Users whose profile is already complete
/// are never interrupted.
///
/// "Complete" is decided by the server's data, not only by the flag on this
/// phone: the flag is set by OTP sign-in and by Complete Profile, but not by
/// password sign-in, and an existing customer may sign in on a new phone. So
/// before sending anyone to Complete Profile we look at their profile; when it
/// already has a name and a real email we remember that and let them through.
class ProfileGate {
  ProfileGate._();

  static const _placeholderEmailDomain = '@placeholder.vahaan.local';

  /// Asks the server whether this user's profile is complete. Replaced in tests.
  @visibleForTesting
  static Future<bool> Function() serverCheck = _profileCompleteOnServer;

  static Future<bool> _profileCompletedLocally() async =>
      await SecureStorageService.to.read(StorageKeys.profileCompleted) ==
      'true';

  /// The same rule as the server's sign-in (a first name and a real email).
  /// Any failure (offline, slow, signed out) counts as "don't know" → false.
  static Future<bool> _profileCompleteOnServer() async {
    try {
      final userId = await SecureStorageService.to.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) return false;
      final res = await ProfileDataSource()
          .fetchProfile(userId)
          .timeout(const Duration(seconds: 5));
      final p = res.data;
      if (p == null) return false;
      final email = p.email.trim().toLowerCase();
      return p.firstName.trim().isNotEmpty &&
          email.isNotEmpty &&
          !email.endsWith(_placeholderEmailDomain);
    } catch (e) {
      debugPrint('ProfileGate: could not check the profile on the server: $e');
      return false;
    }
  }

  /// True when the profile is complete here or on the server. A server "yes"
  /// is saved on this phone and clears any pending requirement.
  static Future<bool> _profileCompleted() async {
    if (await _profileCompletedLocally()) return true;
    if (!await serverCheck()) return false;
    await SecureStorageService.to.write(StorageKeys.profileCompleted, 'true');
    await SecureStorageService.to.delete(
      StorageKeys.profileRequiredAfterPayment,
    );
    return true;
  }

  /// After a sign-in that doesn't report the flag: ask the server once and save the answer.
  static Future<void> rememberServerStatus() async {
    if (await serverCheck()) {
      await SecureStorageService.to.write(StorageKeys.profileCompleted, 'true');
    }
  }

  /// True when a payment was made but the profile is still incomplete.
  static Future<bool> mustCompleteProfile() async {
    if (await _profileCompletedLocally()) return false;
    final required =
        await SecureStorageService.to.read(
          StorageKeys.profileRequiredAfterPayment,
        ) ==
        'true';
    if (!required) return false;
    return !await _profileCompleted();
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

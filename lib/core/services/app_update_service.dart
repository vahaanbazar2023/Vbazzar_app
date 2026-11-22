import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

import 'logger_service.dart';

/// Forced update through Google Play In-App Updates (Android only).
///
/// On launch, asks Play whether a newer version of this app is live. If so, it
/// shows Play's full-screen "Update" flow; if the user declines, the app closes,
/// so every user ends up on the latest Play release (the 1.x app worked the same way).
///
/// Only works for installs that came from the Play Store. Sideloaded/adb or debug
/// installs get no update info, and the check is skipped. Play can take a few hours
/// after a release goes live before devices see it.
class AppUpdateService {
  AppUpdateService._();

  static final _logger = LoggerService.instance;

  /// Never let a slow or missing Play Store hold up the splash screen.
  static const _checkTimeout = Duration(seconds: 8);

  static Future<void> enforceLatestVersion() async {
    if (!Platform.isAndroid) return;

    final AppUpdateInfo info;
    try {
      info = await InAppUpdate.checkForUpdate().timeout(_checkTimeout);
    } catch (e) {
      // Not installed from Play, no Play Store, offline, or timed out: carry on.
      _logger.warning('AppUpdateService: update check skipped: $e');
      return;
    }

    _logger.info(
      'AppUpdateService: availability=${info.updateAvailability} '
      'availableVersionCode=${info.availableVersionCode} '
      'immediateAllowed=${info.immediateUpdateAllowed}',
    );

    final mustUpdate =
        info.updateAvailability == UpdateAvailability.updateAvailable ||
        // An update the user already started and left: resume it.
        info.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress;
    if (!mustUpdate || !info.immediateUpdateAllowed) return;

    try {
      final result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.userDeniedUpdate) {
        _logger.info('AppUpdateService: update declined, closing app');
        await SystemNavigator.pop();
      }
    } catch (e) {
      // Play failed to run the update flow; don't lock the user out.
      _logger.error('AppUpdateService: immediate update failed', e);
    }
  }
}

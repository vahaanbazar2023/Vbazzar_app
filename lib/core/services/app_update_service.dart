import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/context_extensions.dart';
import 'logger_service.dart';

/// Forced update through Google Play (Android only). Every user must be on the
/// latest Play release to use the app.
///
/// Checked on launch (splash) and whenever the app comes back to the foreground
/// (at most every [_resumeInterval]). When Play reports a newer version:
///  1. Play's full-screen immediate update is shown;
///  2. if the user backs out of it, the app closes;
///  3. if Play can't run that flow, a non-dismissible "Update required" dialog
///     sends the user to the Play Store listing.
///
/// The 1.x app only did step 1, on launch, and let the user carry on after
/// backing out.
///
/// Only Play Store installs get update info: sideloaded/adb/debug installs, no
/// Play Store, offline or a slow reply ([_checkTimeout]) all skip the check, so
/// startup is never blocked by Play itself. Play can take a few hours after a
/// release goes live before devices see it.
class AppUpdateService {
  AppUpdateService._();

  static final _logger = LoggerService.instance;

  static const _packageName = 'com.vahaanbazar.app';
  static const _checkTimeout = Duration(seconds: 8);
  static const _resumeInterval = Duration(minutes: 30);

  static bool _running = false;
  static bool _blockingDialogShown = false;
  static DateTime? _lastCheck;

  /// Call on launch, before navigating anywhere.
  static Future<void> enforceLatestVersion() => _check();

  /// Call when the app returns to the foreground.
  static Future<void> recheckOnResume() async {
    final last = _lastCheck;
    if (last != null && DateTime.now().difference(last) < _resumeInterval) {
      return;
    }
    await _check();
  }

  static Future<void> _check() async {
    if (!Platform.isAndroid || _running || _blockingDialogShown) return;
    _running = true;
    _lastCheck = DateTime.now();
    try {
      final AppUpdateInfo info;
      try {
        info = await InAppUpdate.checkForUpdate().timeout(_checkTimeout);
      } catch (e) {
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
      if (!mustUpdate) return;

      if (!info.immediateUpdateAllowed) {
        await _showBlockingUpdateDialog();
        return;
      }

      final AppUpdateResult result;
      try {
        result = await InAppUpdate.performImmediateUpdate();
      } catch (e) {
        _logger.error('AppUpdateService: immediate update failed', e);
        await _showBlockingUpdateDialog();
        return;
      }

      switch (result) {
        case AppUpdateResult.success:
          // Play installs and restarts the app itself.
          break;
        case AppUpdateResult.userDeniedUpdate:
          _logger.info('AppUpdateService: update declined, closing app');
          await SystemNavigator.pop();
        case AppUpdateResult.inAppUpdateFailed:
          await _showBlockingUpdateDialog();
      }
    } finally {
      _running = false;
    }
  }

  /// A dialog the user can't close; its button opens the Play Store listing.
  static Future<void> _showBlockingUpdateDialog() async {
    if (_blockingDialogShown) return;
    _blockingDialogShown = true;
    final l10n = appL10n;
    // Not awaited: the dialog stays up for good, and the splash/resume caller
    // must not wait on it.
    unawaited(
      Get.dialog<void>(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.coreForceUpdateTitle),
            content: Text(l10n.coreForceUpdateMessage),
            actions: [
              FilledButton(
                onPressed: _openPlayStore,
                child: Text(l10n.coreForceUpdateButton),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      ),
    );
  }

  static Future<void> _openPlayStore() async {
    final market = Uri.parse('market://details?id=$_packageName');
    final web = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_packageName',
    );
    try {
      if (await launchUrl(market, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {}
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}

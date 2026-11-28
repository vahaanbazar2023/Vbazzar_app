import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/context_extensions.dart';
import 'logger_service.dart';

/// Forced update: every user must be on the latest store release to use the app.
///
/// **iOS** (App Store): the installed version is compared with the version live
/// on the App Store (Apple's public lookup for our bundle id). When the store
/// has a newer one, the non-dismissible "Update required" dialog sends the user
/// to the App Store. A failed / slow lookup skips the check, and a build newer
/// than the store (TestFlight, App Review) is never blocked. Apple's lookup can
/// lag a release by a few hours.
///
/// **Android** (Google Play):
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
  static const _appStoreId = '6753955870';
  static const _checkTimeout = Duration(seconds: 8);
  static const _resumeInterval = Duration(minutes: 30);

  static bool _running = false;
  static bool _blockingDialogShown = false;
  static DateTime? _lastCheck;

  /// True once the "Update required" dialog is up: nothing may navigate away
  /// from it (the splash checks this before opening Home).
  static bool get blocked => _blockingDialogShown;

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
    if (_running || _blockingDialogShown) return;
    if (Platform.isIOS) return _checkIos();
    if (!Platform.isAndroid) return;
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

  /// iOS: block when the App Store has a newer version than the one installed.
  static Future<void> _checkIos() async {
    _running = true;
    _lastCheck = DateTime.now();
    try {
      final installed = (await PackageInfo.fromPlatform()).version;
      final String? store;
      try {
        store = await _appStoreVersion().timeout(_checkTimeout);
      } catch (e) {
        _logger.warning('AppUpdateService: App Store check skipped: $e');
        return;
      }
      _logger.info(
        'AppUpdateService: iOS installed=$installed appStore=$store',
      );
      if (store != null && isOlder(installed, store)) {
        await _showBlockingUpdateDialog();
      }
    } finally {
      _running = false;
    }
  }

  /// The version live on the App Store (India storefront), or null if Apple
  /// doesn't list the app. A plain Dio, so no API headers go to Apple.
  static Future<String?> _appStoreVersion() async {
    final res = await Dio().get<dynamic>(
      'https://itunes.apple.com/lookup',
      queryParameters: {
        'bundleId': _packageName,
        'country': 'in',
        't': DateTime.now().millisecondsSinceEpoch, // skip stale caches
      },
      options: Options(responseType: ResponseType.plain),
    );
    final body = jsonDecode(res.data.toString()) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? const [];
    if (results.isEmpty) return null;
    return (results.first as Map<String, dynamic>)['version']?.toString();
  }

  /// `a` is an older version than `b` ("2.0.8" < "2.0.10" < "2.1"). Anything
  /// that isn't a plain dotted number compares as 0.
  static bool isOlder(String a, String b) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((x) => int.tryParse(x.trim()) ?? 0)
        .toList();
    final x = parts(a), y = parts(b);
    for (var i = 0; i < (x.length > y.length ? x.length : y.length); i++) {
      final p = i < x.length ? x[i] : 0, q = i < y.length ? y[i] : 0;
      if (p != q) return p < q;
    }
    return false;
  }

  /// A dialog the user can't close; its button opens the store listing.
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
    if (Platform.isIOS) {
      final app = Uri.parse('itms-apps://apps.apple.com/app/id$_appStoreId');
      try {
        if (await launchUrl(app, mode: LaunchMode.externalApplication)) return;
      } catch (_) {}
      await launchUrl(
        Uri.parse('https://apps.apple.com/app/id$_appStoreId'),
        mode: LaunchMode.externalApplication,
      );
      return;
    }
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

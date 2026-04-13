import 'package:flutter/widgets.dart';
import '../localisation/app_localizations.dart';

/// Extension on BuildContext to simplify access to localized strings.
///
/// This extension provides easy access to the app's localization system
/// through a convenient getter method.
///
/// Usage:
/// ```dart
/// Text(context.l10n.login)
/// Text(context.l10n.continueButton)
/// ```
///
/// This works with multiple languages (English, Hindi, Telugu) using ARB files.
extension LocalizationExt on BuildContext {
  /// Returns the AppLocalizations instance for the current context.
  ///
  /// This allows you to access all localized strings defined in the ARB files.
  ///
  /// Example:
  /// ```dart
  /// final localizations = context.l10n;
  /// print(localizations.appName);
  /// print(localizations.welcome);
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

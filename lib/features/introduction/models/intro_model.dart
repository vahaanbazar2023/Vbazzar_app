import 'package:flutter/widgets.dart';
import '../../../core/extensions/context_extensions.dart';

class IntroModel {
  final String title;
  final String description;
  final String imagePath;

  /// Slide position (0-based); used to resolve the localized copy.
  final int index;

  const IntroModel({
    required this.title,
    required this.description,
    required this.imagePath,
    this.index = 0,
  });

  /// Localized slide title (falls back to [title]).
  String localizedTitle(BuildContext context) =>
      context.l10n.coreIntroWelcomeTitle;

  /// Localized slide description (falls back to [description]).
  String localizedDescription(BuildContext context) {
    final l10n = context.l10n;
    switch (index) {
      case 0:
        return l10n.coreIntroSlide1Desc;
      case 1:
        return l10n.coreIntroSlide2Desc;
      case 2:
        return l10n.coreIntroSlide3Desc;
      default:
        return description;
    }
  }
}

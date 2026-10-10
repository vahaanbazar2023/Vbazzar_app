import 'package:flutter/widgets.dart';
import '../../../core/extensions/context_extensions.dart';

class CategoryItem {
  final String id;
  final String title;

  /// Optional shorter label used where space is limited (e.g. home 3-col grid).
  /// Falls back to [title] when null.
  final String? shortTitle;

  final String assetPath;

  const CategoryItem({
    required this.id,
    required this.title,
    this.shortTitle,
    required this.assetPath,
  });

  /// Localized display title for this category (falls back to [title]).
  String localizedTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (id) {
      case 'auction':
        return l10n.auctionZone;
      case 'buy_sell':
        return l10n.coreBuyAndSell;
      case 'fms':
        return l10n.coreFms;
      case 'insurance':
        return l10n.insuranceFinance;
      case 'inspection':
        return l10n.coreInspection;
      case 'service_support':
        return l10n.coreServiceSupport;
      default:
        return title;
    }
  }

  /// Localized short title, falling back to [localizedTitle].
  String localizedShortTitle(BuildContext context) {
    if (id == 'insurance') return context.l10n.insurance;
    return shortTitle ?? localizedTitle(context);
  }
}

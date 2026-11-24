import 'package:flutter/widgets.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/user_subscription.dart';

/// The icon shown for a subscription type (SUBT001…SUBT006) on My Plans and
/// on the confirm / renew screen.
String subscriptionIconAsset(String typeCode) {
  switch (typeCode) {
    case 'SUBT001':
    case 'SUBT002':
      return AppAssets.subIconKing2;
    case 'SUBT003':
      return AppAssets.subIconStep1;
    case 'SUBT004':
      return AppAssets.subIconShield2;
    case 'SUBT005':
      return AppAssets.subIconInspection;
    case 'SUBT006':
      return AppAssets.subIconMechanic;
    default:
      return AppAssets.subIconAuction;
  }
}

/// An API date ("08 Nov 2026, 06:11PM" or ISO) as "08 Nov 2026" in the app
/// language; '—' when missing, the raw text when it can't be read.
String formatPlanDate(BuildContext context, String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final dt = UserSubscription.parseApiDate(raw);
  if (dt == null) return raw;
  final l = context.l10n;
  final m = [
    l.profSubMonthJan,
    l.profSubMonthFeb,
    l.profSubMonthMar,
    l.profSubMonthApr,
    l.profSubMonthMay,
    l.profSubMonthJun,
    l.profSubMonthJul,
    l.profSubMonthAug,
    l.profSubMonthSep,
    l.profSubMonthOct,
    l.profSubMonthNov,
    l.profSubMonthDec,
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month - 1]} ${dt.year}';
}

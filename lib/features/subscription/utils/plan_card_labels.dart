import '../../../core/localisation/app_localizations.dart';
import '../models/subscription_plan.dart';

/// Text shown on a subscription plan card, worked out from the plan name.
///
/// Gold / Elite, Silver / Premium and Bronze / Basic keep their translated
/// tier wording. Any other name (e.g. "Pro") is used as is — "Pro Plan",
/// "Pro Benefits", "Pro Support" — instead of falling back to "Basic".
/// Labels sent by the server (support_label, benefit_label) always win.
class PlanCardLabels {
  PlanCardLabels._();

  static String _key(SubscriptionPlan p) => p.name.trim().toLowerCase();

  static bool _isElite(String k) => k == 'gold' || k == 'elite';
  static bool _isPremium(String k) => k == 'silver' || k == 'premium';
  static bool _isBasic(String k) => k == 'bronze' || k == 'basic' || k.isEmpty;

  /// The value in the third chip, e.g. "Elite Plan" / "Pro Plan".
  static String badge(AppLocalizations l, SubscriptionPlan p) {
    final k = _key(p);
    if (_isElite(k)) return l.profSubElitePlan;
    if (_isPremium(k)) return l.profSubPremiumPlan;
    if (_isBasic(k)) return l.profSubBasicPlan;
    return l.profSubPlanName(p.name.trim());
  }

  /// The small caption above [badge]; only the most popular card shows one.
  static String benefit(
    AppLocalizations l,
    SubscriptionPlan p, {
    required bool mostPopular,
  }) {
    if (!mostPopular) return '';
    final fromServer = p.benefitLabel?.trim();
    if (fromServer != null && fromServer.isNotEmpty) return fromServer;
    if (_isElite(_key(p))) return l.profSubEliteBenefits;
    return l.profSubNamedBenefits(p.name.trim());
  }

  /// The line next to the headset icon.
  static String support(AppLocalizations l, SubscriptionPlan p) {
    final fromServer = p.supportLabel?.trim();
    if (fromServer != null && fromServer.isNotEmpty) return fromServer;
    final k = _key(p);
    if (_isElite(k)) return l.profSubEliteSupport;
    if (_isPremium(k)) return l.profSubPremiumSupport;
    if (_isBasic(k)) return l.profSubBasicSupport;
    return l.profSubNamedSupport(p.name.trim());
  }
}

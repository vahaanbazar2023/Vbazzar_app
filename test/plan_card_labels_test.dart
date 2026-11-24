import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/subscription/models/subscription_plan.dart';
import 'package:vahaan_mobile_2_0/features/subscription/utils/plan_card_labels.dart';

SubscriptionPlan _plan(String name, {String? support, String? benefit}) =>
    SubscriptionPlan.fromJson({
      'name': name,
      'price': 1999,
      'support_label': support,
      'benefit_label': benefit,
    });

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final hi = lookupAppLocalizations(const Locale('hi'));

  group('Pro plan (Vehicle Details Access / Auction Access)', () {
    final pro = _plan('Pro');
    test('is not labelled Basic or Elite', () {
      expect(PlanCardLabels.badge(en, pro), 'Pro Plan');
      expect(
        PlanCardLabels.benefit(en, pro, mostPopular: true),
        'Pro Benefits',
      );
      expect(PlanCardLabels.support(en, pro), 'Pro Support');
    });
    test('translated template', () {
      expect(PlanCardLabels.badge(hi, pro), 'Pro प्लान');
    });
  });

  test('known tiers keep their wording', () {
    expect(PlanCardLabels.badge(en, _plan('Elite')), 'Elite Plan');
    expect(PlanCardLabels.badge(en, _plan('gold')), 'Elite Plan');
    expect(PlanCardLabels.badge(en, _plan('Premium')), 'Premium Plan');
    expect(PlanCardLabels.badge(en, _plan('Basic')), 'Basic Plan');
    expect(PlanCardLabels.badge(en, _plan(' basic ')), 'Basic Plan');
    expect(PlanCardLabels.support(en, _plan('Elite')), 'Elite Support');
    expect(PlanCardLabels.support(en, _plan('Basic')), 'Basic Support');
    expect(
      PlanCardLabels.benefit(en, _plan('Elite'), mostPopular: true),
      'Elite Benefits',
    );
  });

  test('only the most popular card has a benefits caption', () {
    expect(PlanCardLabels.benefit(en, _plan('Pro'), mostPopular: false), '');
    expect(PlanCardLabels.benefit(en, _plan('Elite'), mostPopular: false), '');
  });

  test('server labels win; blank server labels fall back', () {
    final p = _plan(
      'Pro',
      support: 'Priority Support',
      benefit: 'Top Benefits',
    );
    expect(PlanCardLabels.support(en, p), 'Priority Support');
    expect(PlanCardLabels.benefit(en, p, mostPopular: true), 'Top Benefits');
    final blank = _plan('Pro', support: ' ', benefit: '');
    expect(PlanCardLabels.support(en, blank), 'Pro Support');
    expect(
      PlanCardLabels.benefit(en, blank, mostPopular: true),
      'Pro Benefits',
    );
  });
}

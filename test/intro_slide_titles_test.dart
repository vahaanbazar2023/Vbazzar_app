import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/introduction/models/intro_model.dart';

/// Each intro slide shows its own heading (it used to show "Welcome to VAHAAN BAZAR"
/// on every slide), in every app language.
void main() {
  const slides = [
    IntroModel(title: 'a', description: 'a', imagePath: '', index: 0),
    IntroModel(title: 'b', description: 'b', imagePath: '', index: 1),
    IntroModel(title: 'c', description: 'c', imagePath: '', index: 2),
  ];

  Future<List<String>> titlesFor(WidgetTester tester, Locale locale) async {
    late List<String> titles;
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        titles = [for (final s in slides) s.localizedTitle(context)];
        return const SizedBox();
      }),
    ));
    return titles;
  }

  testWidgets('English slides show their own titles', (tester) async {
    expect(await titlesFor(tester, const Locale('en')), [
      'Your Vehicle Marketplace',
      'List. Connect. Sell.',
      'Bid Smart. Buy Better.',
    ]);
  });

  testWidgets('every language has three different, translated slide titles', (tester) async {
    final english = await titlesFor(tester, const Locale('en'));
    for (final locale in AppLocalizations.supportedLocales) {
      final titles = await titlesFor(tester, locale);
      expect(titles.toSet().length, 3, reason: '$locale');
      expect(titles.every((t) => t.trim().isNotEmpty), isTrue, reason: '$locale');
      if (locale.languageCode != 'en') {
        expect(titles, isNot(english), reason: '$locale should be translated');
      }
    }
  });
}

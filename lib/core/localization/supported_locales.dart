import 'package:flutter/material.dart';

class SupportedLocales {
  SupportedLocales._();

  static const Locale english = Locale('en', 'US');
  static const Locale hindi = Locale('hi', 'IN');

  static const List<Locale> all = [english, hindi];

  static String nameOf(Locale locale) => switch (locale.languageCode) {
    'en' => 'English',
    'hi' => 'हिंदी',
    _ => locale.languageCode,
  };
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../routes/app_pages.dart';
import '../core/extensions/context_extensions.dart';

class AppRouter {
  AppRouter._();

  static String get initialRoute => AppRoutes.splash;

  static List<GetPage> get pages => AppPages.pages;

  static GetPage get unknownRoute => GetPage(
    name: '/not-found',
    page: () => Scaffold(body: Center(child: Text(appL10n.corePageNotFound))),
  );
}

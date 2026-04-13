import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/localisation/app_localizations.dart';
import '../theme/theme_config.dart';
import 'app_binding.dart';
import 'app_router.dart';

class VahaanApp extends StatelessWidget {
  const VahaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // White icons on Android
            statusBarBrightness: Brightness.dark, // White icons on iOS
          ),
          child: GetMaterialApp(
            title: 'Vahaan Bazar',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,

            // Flutter Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
              Locale('te'), // Telugu
            ],
            locale: const Locale('en'),
            fallbackLocale: const Locale('en'),

            // Routing
            initialRoute: AppRouter.initialRoute,
            getPages: AppRouter.pages,
            unknownRoute: AppRouter.unknownRoute,

            // Global Bindings
            initialBinding: AppBinding(),

            // Builder — dismiss keyboard on tap outside
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: child ?? const SizedBox(),
              );
            },
          ),
        );
      },
    );
  }
}

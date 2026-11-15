import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/localisation/app_localizations.dart';
import 'package:vahaan_mobile_2_0/features/auth/controllers/auth_controller.dart';
import 'package:vahaan_mobile_2_0/features/auth/data/auth_data_source.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/forgot_password_models.dart';
import 'package:vahaan_mobile_2_0/features/auth/repositories/auth_repository.dart';
import 'package:vahaan_mobile_2_0/features/auth/views/forgot_password_screen.dart';
import 'package:vahaan_mobile_2_0/features/auth/views/login_with_otp.dart';

Future<AuthController> _pump(
  WidgetTester tester, {
  Size size = const Size(375, 812),
  Locale locale = const Locale('en'),
  Widget home = const LoginWithOtp(),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  Get.reset();
  final controller = Get.put(AuthController());
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return controller;
}

class _ResetOk extends AuthDataSource {
  int resets = 0;
  @override
  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
  ) async {
    resets++;
    return ResetPasswordResponse(status: 'success', code: 200, message: 'ok');
  }
}

void main() {
  tearDown(Get.reset);

  const phones = {
    'small 320x568': Size(320, 568),
    'normal 375x812': Size(375, 812),
  };

  for (final e in phones.entries) {
    testWidgets('OTP mode is log in or sign up, with consent (${e.key})', (
      tester,
    ) async {
      await _pump(tester, size: e.value);
      expect(find.text('Log In / Sign Up'), findsOneWidget);
      expect(find.text('with OTP'), findsOneWidget);
      expect(
        find.text('New here? Your account is created automatically.'),
        findsOneWidget,
      );
      // The card says one thing once: no greeting, no repeated OTP explanation.
      expect(find.textContaining('Welcome'), findsNothing);
      expect(find.textContaining('We will send you'), findsNothing);
      expect(find.byType(Checkbox), findsNWidgets(2));
      expect(find.byIcon(Icons.headset_mic_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password mode shows the password form (${e.key})', (
      tester,
    ) async {
      final controller = await _pump(tester, size: e.value);
      controller.isPasswordMode.value = true;
      await tester.pump();
      expect(find.text('Log In'), findsWidgets);
      expect(find.text('with Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Send OTP needs a valid number and the agreement', (
    tester,
  ) async {
    final controller = await _pump(tester);
    controller.phoneController.text = '9876543210';
    await tester.pump();
    expect(controller.isPhoneValid, isTrue);
    expect(controller.agreedToTerms.value, isFalse);

    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(controller.agreedToTerms.value, isTrue);
    expect(controller.marketingOptIn.value, isFalse);
  });

  for (final code in ['hi', 'te', 'kn', 'ml', 'ta']) {
    testWidgets('both modes render on a small phone in $code', (tester) async {
      final controller = await _pump(
        tester,
        size: const Size(320, 568),
        locale: Locale(code),
      );
      expect(tester.takeException(), isNull);
      controller.isPasswordMode.value = true;
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('set-password screen starts by asking for the account', (
    tester,
  ) async {
    final controller = await _pump(tester, home: const ForgotPasswordScreen());
    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Send Code'), findsOneWidget);

    controller.resetTransactionId.value = 'tx';
    await tester.pump();
    expect(find.text('Change Password'), findsOneWidget);
    // Resend is locked behind the 120 second countdown, then becomes a button.
    expect(find.text('Resend OTP in 02:00'), findsOneWidget);
    expect(find.text('Resend OTP'), findsNothing);
    controller.canResendOtp.value = true;
    await tester.pump();
    expect(find.text('Resend OTP'), findsOneWidget);
    // The helpline block is on this screen too.
    expect(find.byIcon(Icons.headset_mic_outlined), findsOneWidget);
    expect(controller.isResetFormValid, isFalse);
    controller.resetCodeController.text = '123456';
    controller.newPasswordController.text = 'secret123';
    await tester.pump();
    expect(controller.isResetFormValid, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final code in ['en', 'hi', 'te', 'kn', 'ml', 'ta']) {
    testWidgets('set-password steps render on a small phone in $code', (
      tester,
    ) async {
      final controller = await _pump(
        tester,
        size: const Size(320, 568),
        locale: Locale(code),
        home: const ForgotPasswordScreen(),
      );
      expect(tester.takeException(), isNull);
      controller.resetTransactionId.value = 'tx';
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('set-password prefills the number typed on the OTP tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Get.reset();
    final controller = Get.put(AuthController());
    controller.phoneController.text = '9876543210';
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => GetMaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(controller.usernameController.text, '9876543210');
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing the password closes the set-password screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Get.reset();
    final ds = _ResetOk();
    final controller = Get.put(
      AuthController()..authRepository = AuthRepository(dataSource: ds),
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => GetMaterialApp(
          locale: const Locale('en'), // earlier tests leave another locale set
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('login page')),
        ),
      ),
    );
    Get.to(() => const ForgotPasswordScreen());
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    controller.usernameController.text = '9876543210';
    controller.resetTransactionId.value = 'tx';
    controller.resetCodeController.text = '123456';
    controller.newPasswordController.text = 'secret123';
    await tester.pump();
    await tester.tap(find.text('Change Password'));
    await tester.pump(); // request completes, success snackbar opens
    await tester.pump(const Duration(milliseconds: 600)); // route pops
    await tester.pumpAndSettle(const Duration(seconds: 4)); // snackbar closes

    expect(ds.resets, 1);
    // Back on the login page, not stuck on step 1 of this screen again.
    expect(find.byType(ForgotPasswordScreen), findsNothing);
    expect(find.text('login page'), findsOneWidget);
  });
}

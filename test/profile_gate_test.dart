import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/storage/storage_keys.dart';
import 'package:vahaan_mobile_2_0/features/auth/services/profile_gate.dart';
import 'package:vahaan_mobile_2_0/routes/app_routes.dart';

/// In-memory stand-in for the flutter_secure_storage platform channel.
final _store = <String, String>{};

void _mockSecureStorage() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      final args = (call.arguments as Map?) ?? {};
      final key = args['key'] as String?;
      switch (call.method) {
        case 'write':
          _store[key!] = args['value'] as String;
          return null;
        case 'read':
          return _store[key];
        case 'delete':
          _store.remove(key);
          return null;
        case 'containsKey':
          return _store.containsKey(key);
        case 'readAll':
          return Map<String, String>.from(_store);
        case 'deleteAll':
          _store.clear();
          return null;
      }
      return null;
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _store.clear();
    _mockSecureStorage();
  });

  group('ProfileGate', () {
    test('no requirement before any payment', () async {
      expect(await ProfileGate.mustCompleteProfile(), isFalse);
    });

    test('payment with incomplete profile persists the requirement', () async {
      await ProfileGate.onPaymentSuccess();
      expect(_store[StorageKeys.profileRequiredAfterPayment], 'true');
      expect(await ProfileGate.mustCompleteProfile(), isTrue);
    });

    test('payment with completed profile never interrupts the user', () async {
      _store[StorageKeys.profileCompleted] = 'true';
      await ProfileGate.onPaymentSuccess();
      expect(_store.containsKey(StorageKeys.profileRequiredAfterPayment),
          isFalse);
      expect(await ProfileGate.mustCompleteProfile(), isFalse);
    });

    test('requirement is lifted once the profile is completed', () async {
      await ProfileGate.onPaymentSuccess();
      _store[StorageKeys.profileCompleted] = 'true';
      expect(await ProfileGate.mustCompleteProfile(), isFalse);
    });

    testWidgets('after payment the user is sent to Complete Profile',
        (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/start',
          getPages: [
            GetPage(
              name: '/start',
              page: () => const Scaffold(body: Text('start')),
            ),
            GetPage(
              name: AppRoutes.completeProfile,
              page: () => const Scaffold(body: Text('complete-profile')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      unawaited(ProfileGate.onPaymentSuccess());
      await tester.pump();
      await tester.pump();
      // Gate waits ~2s for the module's own success handling, then re-checks.
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('complete-profile'), findsOneWidget);
    });

    testWidgets('completed profile stays on the current screen',
        (tester) async {
      _store[StorageKeys.profileCompleted] = 'true';
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/start',
          getPages: [
            GetPage(
              name: '/start',
              page: () => const Scaffold(body: Text('start')),
            ),
            GetPage(
              name: AppRoutes.completeProfile,
              page: () => const Scaffold(body: Text('complete-profile')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      unawaited(ProfileGate.onPaymentSuccess());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('start'), findsOneWidget);
      expect(find.text('complete-profile'), findsNothing);
    });
  });
}

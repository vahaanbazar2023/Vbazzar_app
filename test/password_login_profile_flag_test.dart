import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/storage/storage_keys.dart';
import 'package:vahaan_mobile_2_0/features/auth/data/auth_data_source.dart';
import 'package:vahaan_mobile_2_0/features/auth/repositories/auth_repository.dart';
import 'package:vahaan_mobile_2_0/features/auth/services/profile_gate.dart';

/// Password sign-in keeps the same "profile completed" flag as OTP sign-in.
final _store = <String, String>{};

class _FakeSource extends AuthDataSource {
  _FakeSource(this.body);
  final Map<String, dynamic> body;
  @override
  Future<Map<String, dynamic>> loginWithPassword({required String usernamePhone, required String password, String? fcmToken}) async => body;
}

Map<String, dynamic> _ok(Map<String, dynamic> extra) =>
    {'status': 'success', 'data': {'token': 't', 'user_id': 'VB1', 'user_type': 'BUYER', ...extra}};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    _store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        final a = (call.arguments as Map?) ?? {};
        final k = a['key'] as String?;
        switch (call.method) {
          case 'write':
            _store[k!] = a['value'] as String;
            return null;
          case 'read':
            return _store[k];
          case 'delete':
            _store.remove(k);
            return null;
        }
        return null;
      },
    );
  });

  test('saves profile_completed=true from the server', () async {
    await AuthRepository(dataSource: _FakeSource(_ok({'profile_completed': true}))).loginWithPassword(usernamePhone: 'x', password: 'y');
    expect(_store[StorageKeys.profileCompleted], 'true');
  });

  test('saves profile_completed=false from the server', () async {
    await AuthRepository(dataSource: _FakeSource(_ok({'profile_completed': false}))).loginWithPassword(usernamePhone: 'x', password: 'y');
    expect(_store[StorageKeys.profileCompleted], 'false');
  });

  test('an older server without the flag: the profile is looked up and remembered', () async {
    ProfileGate.serverCheck = () async => true;
    await AuthRepository(dataSource: _FakeSource(_ok({}))).loginWithPassword(usernamePhone: 'x', password: 'y');
    await Future<void>.delayed(Duration.zero);
    expect(_store[StorageKeys.profileCompleted], 'true');
  });
}

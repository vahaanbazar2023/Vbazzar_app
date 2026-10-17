import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/auth/controllers/auth_controller.dart';
import 'package:vahaan_mobile_2_0/features/auth/data/auth_data_source.dart';
import 'package:vahaan_mobile_2_0/features/auth/models/referral_validation.dart';
import 'package:vahaan_mobile_2_0/features/auth/repositories/auth_repository.dart';

class _FakeDataSource extends AuthDataSource {
  final calls = <String>[];
  Future<ReferralValidation> Function(String code)? handler;

  @override
  Future<ReferralValidation> validateReferralCode(String code) {
    calls.add(code);
    return handler!(code);
  }
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 600));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeDataSource ds;
  late AuthController c;

  setUp(() {
    ds = _FakeDataSource();
    c = AuthController()..authRepository = AuthRepository(dataSource: ds);
    c.onInit();
  });

  tearDown(() => c.referralController.removeListener(() {}));

  test('response parsing', () {
    final ok = ReferralValidation.fromJson({
      'status': 'success',
      'data': {'valid': true, 'referrer_first_name': 'Ravi'},
    });
    expect(ok.valid, isTrue);
    expect(ok.referrerFirstName, 'Ravi');
    final off = ReferralValidation.fromJson({
      'data': {'valid': false, 'reason': 'REFER_EARN_DISABLED'},
    });
    expect(off.valid, isFalse);
    expect(off.isDisabled, isTrue);
  });

  test('a full-length valid code shows who invited the user', () async {
    ds.handler = (_) async =>
        const ReferralValidation(valid: true, referrerFirstName: 'Ravi');
    c.referralController.text = 'VB0000013';
    expect(c.referralStatus.value, ReferralStatus.checking);
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.valid);
    expect(c.referrerName.value, 'Ravi');
    expect(ds.calls, ['VB0000013']);
  });

  test('an invalid code is flagged', () async {
    ds.handler = (_) async =>
        const ReferralValidation(valid: false, reason: 'INVALID_CODE');
    c.referralController.text = 'VB9999999';
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.invalid);
    expect(c.referrerName.value, isNull);
  });

  test('refer & earn switched off is not an error the user caused', () async {
    ds.handler = (_) async =>
        const ReferralValidation(valid: false, reason: 'REFER_EARN_DISABLED');
    c.referralController.text = 'VB0000013';
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.disabled);
  });

  test('a network failure never blocks: status unavailable', () async {
    ds.handler = (_) async => throw Exception('offline');
    c.referralController.text = 'VB0000013';
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.unavailable);
  });

  test('short or cleared codes are not sent to the server', () async {
    ds.handler = (_) async => const ReferralValidation(valid: true);
    c.referralController.text = 'VB0000';
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.idle);
    expect(ds.calls, isEmpty);
    c.referralController.text = 'VB0000013';
    c.referralController.clear();
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.idle);
    expect(ds.calls, isEmpty);
  });

  test('a late answer for an old code is ignored', () async {
    ds.handler = (code) async {
      if (code == 'VB0000001') {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return const ReferralValidation(valid: true, referrerFirstName: 'Old');
      }
      return const ReferralValidation(valid: false, reason: 'INVALID_CODE');
    };
    c.referralController.text = 'VB0000001';
    await Future<void>.delayed(const Duration(milliseconds: 450)); // request in flight
    c.referralController.text = 'VB0000002';
    await _settle();
    await _settle();
    expect(c.referralStatus.value, ReferralStatus.invalid);
    expect(c.referrerName.value, isNull);
  });

  test('tapping Send OTP before the debounce still checks the code', () async {
    ds.handler = (_) async =>
        const ReferralValidation(valid: false, reason: 'INVALID_CODE');
    c.referralController.text = 'VB9999999';
    await c.ensureReferralChecked(); // what sendOtp runs first
    expect(c.referralStatus.value, ReferralStatus.invalid);
    // empty code: nothing to check, login is never blocked
    c.referralController.clear();
    ds.calls.clear();
    await c.ensureReferralChecked();
    expect(ds.calls, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/services/app_update_service.dart';

void main() {
  test('older-version comparison used by the iOS forced update', () {
    expect(AppUpdateService.isOlder('1.0.34', '2.0.8'), isTrue);
    expect(AppUpdateService.isOlder('2.0.8', '2.0.10'), isTrue); // numeric, not text order
    expect(AppUpdateService.isOlder('2.0.10', '2.0.8'), isFalse);
    expect(AppUpdateService.isOlder('2.0.8', '2.0.8'), isFalse);
    expect(AppUpdateService.isOlder('2.0', '2.0.1'), isTrue);
    expect(AppUpdateService.isOlder('2.0.9', '2.0.8'), isFalse); // TestFlight / review build ahead of the store
    expect(AppUpdateService.isOlder('2.0.8+108', '2.0.8'), isFalse);
  });
}

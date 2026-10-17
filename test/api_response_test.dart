import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/utils/api_response.dart';

void main() {
  test('the refund endpoint response (status=success, code=201) is a success', () {
    expect(
      isApiSuccess({
        'status': 'success',
        'code': 201,
        'message': 'Auction refund request initiated successfully',
        'data': {},
      }),
      true,
    );
  });

  test('older {success: true} responses still count', () {
    expect(isApiSuccess({'success': true, 'message': 'ok'}), true);
  });

  test('errors and empty bodies are failures', () {
    expect(isApiSuccess({'status': 'error', 'code': 400, 'message': 'x'}), false);
    expect(isApiSuccess({'status': 'error', 'code': 200}), false);
    expect(isApiSuccess({'success': false}), false);
    expect(isApiSuccess({}), false);
    expect(isApiSuccess(null), false);
  });
}

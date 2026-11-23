import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/data/repositories/approved_vehicle_repository_impl.dart';

/// appr-veh-submit refusals are shown to the seller word for word.
void main() {
  String? msg(Map? body) =>
      ApprovedVehicleRepositoryImpl.submitErrorMessage(body);

  test('a 400 business error: its message', () {
    expect(
      msg({
        'status': 'error',
        'code': 400,
        'message':
            "images: 'a.heic' is not allowed. Accepted: .jpg, .jpeg, .png, .gif.",
        'detail': {'code': 'INVALID_FIELD_VALUE', 'message': 'x'},
      }),
      "images: 'a.heic' is not allowed. Accepted: .jpg, .jpeg, .png, .gif.",
    );
  });

  test('a 422: each field and its problem', () {
    expect(
      msg({
        'detail': [
          {
            'loc': ['body', 'price'],
            'msg': 'Input should be greater than 0',
          },
          {
            'loc': ['body', 'brand'],
            'msg': 'Field required',
          },
        ],
      }),
      'price: Input should be greater than 0\nbrand: Field required',
    );
  });

  test('403 and odd shapes', () {
    expect(
      msg({
        'message':
            'Access denied. Only VENDOR users can submit approved vehicles.',
      }),
      'Access denied. Only VENDOR users can submit approved vehicles.',
    );
    expect(msg({'detail': 'Not authenticated'}), 'Not authenticated');
    expect(msg({}), isNull);
    expect(msg(null), isNull);
  });
}

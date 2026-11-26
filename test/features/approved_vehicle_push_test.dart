import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/services/deep_link_service.dart';
import 'package:vahaan_mobile_2_0/features/approved_vehicles/services/approved_vehicle_push.dart';

void main() {
  test('only the approved-vehicle push is recognised', () {
    expect(
      ApprovedVehiclePush.isApprovedVehiclePush({'action': 'approved_vehicle_new'}),
      isTrue,
    );
    expect(ApprovedVehiclePush.isApprovedVehiclePush({'action': 'outbid'}), isFalse);
    expect(ApprovedVehiclePush.isApprovedVehiclePush({}), isFalse);
  });

  test('one vehicle opens that vehicle; a batch opens the section', () {
    final one = ApprovedVehiclePush.contentFor({
      'action': 'approved_vehicle_new',
      'approved_vehicle_id': ' AVEH000000001 ',
    });
    expect(one.type, 'approved_vehicle');
    expect(one.id, 'AVEH000000001');

    final many = ApprovedVehiclePush.contentFor({
      'action': 'approved_vehicle_new',
      'approved_vehicle_id': '',
    });
    expect(many.type, DeepLinkService.approvedVehiclesSection);
    expect(many.id, isNotEmpty); // pending content needs an id to be resumed
  });
}

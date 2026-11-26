import 'package:get/get.dart';

import '../../../core/services/deep_link_service.dart';

/// "New approved vehicle" push from the backend (`data.action` =
/// `approved_vehicle_new`), sent to all users when an admin approves one.
///
/// Tapping it opens that vehicle the same way a shared link does: users with
/// the Approved Vehicles plan go straight to its details, everyone else sees
/// the usual locked message. A push for several vehicles (`approved_vehicle_id`
/// empty) opens the Approved Vehicles section behind the same check.
class ApprovedVehiclePush {
  ApprovedVehiclePush._();

  static const action = 'approved_vehicle_new';

  static bool isApprovedVehiclePush(Map<String, dynamic> data) =>
      data['action']?.toString() == action;

  /// The `DeepLinkService` content to open for this push.
  static ({String type, String id}) contentFor(Map<String, dynamic> data) {
    final id = data['approved_vehicle_id']?.toString().trim() ?? '';
    return id.isEmpty
        ? (type: DeepLinkService.approvedVehiclesSection, id: 'all')
        : (type: 'approved_vehicle', id: id);
  }

  /// The user tapped a push. Returns true if it was this kind (handled).
  /// On a cold start, or when logged out, it opens once home has loaded.
  static bool onOpened(Map<String, dynamic> data) {
    if (!isApprovedVehiclePush(data)) return false;
    if (!Get.isRegistered<DeepLinkService>()) return true;
    final content = contentFor(data);
    DeepLinkService.to.openFromPush(content.type, content.id);
    return true;
  }
}

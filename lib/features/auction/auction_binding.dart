import 'package:get/get.dart';
import 'controllers/auction_controller.dart';
import 'controllers/auction_list_controller.dart';
import 'services/auction_service.dart';
import 'utils/auction_utils.dart';
import '../approved_vehicles/domain/entities/approved_vehicle_category_entity.dart';

class AuctionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionService>(() => AuctionService());
    Get.lazyPut<AuctionController>(() {
      final args = Get.arguments as Map<String, dynamic>? ?? {};

      // Resolve vehicle_type from the category argument
      final categoryArg = args['category'];
      String categoryName = '';
      if (categoryArg is ApprovedVehicleCategoryEntity) {
        categoryName = categoryArg.categoryName;
      } else if (categoryArg is String) {
        categoryName = categoryArg;
      }
      // Resolve vehicle_type directly from categoryCode if available,
      // otherwise fall back to name-based mapping.
      String vehicleType = '';
      if (categoryArg is ApprovedVehicleCategoryEntity) {
        vehicleType = categoryArg.categoryCode; // 2W, 3W, 4W, CV, CE, FE
        // ignore: avoid_print
        print(
          '🏷️ [AuctionBinding] code="${categoryArg.categoryCode}" name="${categoryArg.categoryName}" → vehicle_type="$vehicleType"',
        );
      } else {
        vehicleType = AuctionUtils.vehicleTypeForCategory(categoryName);
        // ignore: avoid_print
        print(
          '🏷️ [AuctionBinding] category="$categoryName" → vehicle_type="$vehicleType"',
        );
      }

      return AuctionController(
        initialTabIndex: args['tabIndex'] as int? ?? 0,
        selectedVehicleType: vehicleType,
        service: Get.find<AuctionService>(),
      );
    });
    // AuctionListController provides filter state used by the filter sheet
    Get.lazyPut<AuctionListController>(
      () => AuctionListController(service: Get.find<AuctionService>()),
    );
  }
}

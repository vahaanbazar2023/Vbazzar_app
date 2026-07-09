import 'package:get/get.dart';
import 'controllers/auction_controller.dart';
import 'controllers/auction_list_controller.dart';
import 'services/auction_service.dart';

class AuctionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionService>(() => AuctionService());
    Get.lazyPut<AuctionController>(() {
      final args = Get.arguments as Map<String, dynamic>? ?? {};

      // category is now always a String category code (2W, 3W, 4W, CV, CE, FE)
      // passed from AuctionCategoryController.onCategoryTapped
      final vehicleType =
          (args['category'] as String?)?.toUpperCase().trim() ?? '';

      // ignore: avoid_print
      print('🏷️ [AuctionBinding] vehicle_type="$vehicleType"');

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

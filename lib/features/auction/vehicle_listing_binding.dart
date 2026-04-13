import 'package:get/get.dart';
import 'controllers/vehicle_listing_controller.dart';
import 'models/auction_listing.dart';
import 'services/vehicle_listing_service.dart';

class VehicleListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleListingService>(() => VehicleListingService());
    Get.lazyPut<VehicleListingController>(
      () => VehicleListingController(
        auction: Get.arguments['auction'] as AuctionListing,
        service: Get.find<VehicleListingService>(),
      ),
    );
  }
}

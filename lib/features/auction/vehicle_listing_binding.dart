import 'package:get/get.dart';
import 'controllers/vehicle_listing_controller.dart';
import 'services/vehicle_listing_service.dart';

class VehicleListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleListingService>(() => VehicleListingService());
    Get.lazyPut<VehicleListingController>(() {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      return VehicleListingController(
        auctionType: args['auctionType'] as String? ?? 'live_auctions',
        vehicleType: args['vehicleType'] as String? ?? '',
        auctionTitle: args['auctionTitle'] as String? ?? '',
        bidIncrementAmount:
            (args['bidIncrementAmount'] as num?)?.toInt() ?? 5000,
        service: Get.find<VehicleListingService>(),
      );
    });
  }
}

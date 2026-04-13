import 'package:get/get.dart';
import 'controllers/auction_controller.dart';
import 'services/auction_service.dart';

class AuctionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionService>(() => AuctionService());
    Get.lazyPut<AuctionController>(
      () => AuctionController(
        initialTabIndex: Get.arguments?['tabIndex'] as int? ?? 0,
        service: Get.find<AuctionService>(),
      ),
    );
  }
}

import 'package:get/get.dart';
import 'controllers/buy_sell_home_controller.dart';

class BuySellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuySellHomeController>(() => BuySellHomeController());
  }
}
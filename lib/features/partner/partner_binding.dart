import 'package:get/get.dart';
import 'controllers/partner_controller.dart';

class PartnerBinding extends Bindings {
  @override
  void dependencies() {
    // Fresh state every time the screen opens (role preset, status, form).
    Get.lazyPut<PartnerController>(() => PartnerController(), fenix: false);
  }
}

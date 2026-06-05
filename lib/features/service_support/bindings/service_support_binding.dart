import 'package:get/get.dart';
import '../controllers/service_support_controller.dart';

class ServiceSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServiceSupportController());
  }
}
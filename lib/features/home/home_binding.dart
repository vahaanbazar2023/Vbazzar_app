import 'package:get/get.dart';
import 'controllers/home_controller.dart';
import '../notifications/controllers/notification_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // NotificationController lives with the shell so the badge is always live
    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(),
        permanent: true,
      );
    }
  }
}

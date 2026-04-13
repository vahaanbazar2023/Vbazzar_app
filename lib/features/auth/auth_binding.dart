import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import '../language/controllers/language_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use permanent: true to prevent disposal during route transitions
    // This prevents "TextEditingController was used after being disposed" errors
    // that occur when animation widgets try to access controllers during navigation
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<LanguageController>()) {
      Get.lazyPut<LanguageController>(() => LanguageController());
    }
  }
}

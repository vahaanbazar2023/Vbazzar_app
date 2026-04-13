import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    // MainShellController is permanent (registered in AppBinding) — skip if exists
    if (!Get.isRegistered<MainShellController>()) {
      Get.lazyPut<MainShellController>(() => MainShellController());
    }
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

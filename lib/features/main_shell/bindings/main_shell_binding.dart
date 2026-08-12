import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../categories/controllers/categories_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../subscription/controllers/combo_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainShellController>()) {
      Get.lazyPut<MainShellController>(() => MainShellController());
    }
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MySubscriptionController>(() => MySubscriptionController());
    Get.lazyPut<ComboController>(() => ComboController());
  }
}

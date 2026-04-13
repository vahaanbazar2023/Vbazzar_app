import 'package:get/get.dart';
import 'controllers/home_controller.dart';
import 'views/main_shell_screen.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

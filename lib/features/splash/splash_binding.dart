import 'package:get/get.dart';
import '../../core/services/logger_service.dart';
import 'controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  final _logger = LoggerService.instance;

  @override
  void dependencies() {
    _logger.info('SplashBinding: Initializing SplashController');
    // Use Get.put instead of Get.lazyPut to instantiate immediately
    Get.put<SplashController>(SplashController());
    _logger.info('SplashBinding: SplashController initialized');
  }
}

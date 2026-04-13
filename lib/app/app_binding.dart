import 'package:get/get.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/location_service.dart';
import '../core/network/network_service.dart';
import '../features/main_shell/controllers/main_shell_controller.dart';
import 'app_lifecycle.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('═══════════════════════════════════════════════════════');
    print('🔧 AppBinding.dependencies() called');
    print('═══════════════════════════════════════════════════════');

    // Register NetworkService (must be done after GetMaterialApp is created)
    if (!Get.isRegistered<NetworkService>()) {
      print('📦 Registering NetworkService...');
      Get.put<NetworkService>(NetworkService(), permanent: true);
      print('✅ NetworkService registered successfully');
    } else {
      print('ℹ️  NetworkService already registered');
    }

    // Register ConnectivityService if not already registered from Bootstrap
    if (!Get.isRegistered<ConnectivityService>()) {
      print('📦 Registering ConnectivityService...');
      Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
      print('✅ ConnectivityService registered successfully');
    } else {
      print('ℹ️  ConnectivityService already registered');
    }

    // Register LocationService
    if (!Get.isRegistered<LocationService>()) {
      print('📦 Registering LocationService...');
      Get.put<LocationService>(LocationService(), permanent: true);
      print('✅ LocationService registered successfully');
    } else {
      print('ℹ️  LocationService already registered');
    }

    // Register MainShellController permanently so it survives route changes
    if (!Get.isRegistered<MainShellController>()) {
      Get.put<MainShellController>(MainShellController(), permanent: true);
    }

    // Register AppLifecycle
    if (!Get.isRegistered<AppLifecycle>()) {
      print('📦 Registering AppLifecycle...');
      Get.put(AppLifecycle(), permanent: true);
      print('✅ AppLifecycle registered successfully');
    } else {
      print('ℹ️  AppLifecycle already registered');
    }

    // Verify all critical services are available
    try {
      Get.find<ConnectivityService>();
      Get.find<NetworkService>();
      print('═══════════════════════════════════════════════════════');
      print('✅ AppBinding: All critical services verified');
      print('═══════════════════════════════════════════════════════');
    } catch (e) {
      print('═══════════════════════════════════════════════════════');
      print('❌ AppBinding: Missing critical services - $e');
      print('═══════════════════════════════════════════════════════');
      rethrow;
    }
  }
}

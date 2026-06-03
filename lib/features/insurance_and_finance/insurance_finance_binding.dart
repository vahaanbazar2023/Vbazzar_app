import 'package:get/get.dart';

import '../../core/network/network_service.dart';
import '../../core/services/location_service.dart';
import 'controllers/insurance_finance_controller.dart';
import 'data/repositories/insurance_finance_repository_impl.dart';
import 'domain/repositories/insurance_finance_repository.dart';

class InsuranceFinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure LocationService is available
    if (!Get.isRegistered<LocationService>()) {
      Get.put<LocationService>(LocationService(), permanent: true);
    }

    // Register repository
    Get.lazyPut<InsuranceFinanceRepository>(
      () => InsuranceFinanceRepositoryImpl(NetworkService.to),
    );

    // Register controller
    Get.lazyPut<InsuranceFinanceController>(
      () => InsuranceFinanceController(
        repository: Get.find<InsuranceFinanceRepository>(),
        locationService: Get.find<LocationService>(),
      ),
    );
  }
}
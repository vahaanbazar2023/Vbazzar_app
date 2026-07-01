import 'package:get/get.dart';
import 'controllers/approved_vehicle_controller.dart';
import 'data/repositories/approved_vehicle_repository_impl.dart';

class ApprovedVehicleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApprovedVehicleController(
          repository: ApprovedVehicleRepositoryImpl(),
        ));
  }
}



import 'package:get/get.dart';

import 'controllers/spare_and_fms_controller.dart';
import 'data/repositories/spare_fms_repository_impl.dart';
import 'domain/repositories/spare_fms_repository.dart';

class SpareFmsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpareFmsRepository>(
      () => SpareFmsRepositoryImpl(),
      fenix: true,
    );
    Get.lazyPut<SpareAndFmsController>(
      () => SpareAndFmsController(repository: Get.find<SpareFmsRepository>()),
      fenix: true,
    );
  }
}
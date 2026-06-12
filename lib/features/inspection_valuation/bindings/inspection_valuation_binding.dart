import 'package:get/get.dart';
import '../controllers/inspection_valuation_controller.dart';
import '../controllers/agent_inspection_controller.dart';

class InspectionValuationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InspectionValuationController>(
      () => InspectionValuationController(),
    );
    Get.lazyPut<AgentInspectionController>(
      () => AgentInspectionController(),
    );
  }
}
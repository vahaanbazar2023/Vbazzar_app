import 'package:get/get.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

class HomeController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rxn<DashboardData>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final data = await _repository.getDashboardHome();
      if (data != null) {
        dashboardData.value = data;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load dashboard.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

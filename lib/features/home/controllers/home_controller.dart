import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/profile/repositories/profile_repository.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

class HomeController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rxn<DashboardData>();
  final userName = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _loadUserName();
    fetchDashboard();
  }

  Future<void> _loadUserName() async {
    try {
      final response = await _profileRepository.fetchProfile();
      if (response.isSuccess && response.data != null) {
        final p = response.data!;
        final fullName = '${p.firstName} ${p.lastName}'.trim();
        userName.value = fullName.isNotEmpty ? fullName : p.username;
      }
    } catch (_) {
      // Silently fall back to stored name if available
      final stored =
          await SecureStorageService.to.read(StorageKeys.userName) ?? '';
      userName.value = stored.trim();
    }
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    dashboardData.value = null; // clear stale data so shimmer shows
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

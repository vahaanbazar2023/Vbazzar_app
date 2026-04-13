import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../models/profile_models.dart';
import '../repositories/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileRepository? _repo;
  ProfileRepository get _repository => _repo ??= ProfileRepository();

  // ── Reactive state ────────────────────────────────────────────
  final isLoading = false.obs;
  final isLoggingOut = false.obs;
  final profile = Rxn<ProfileData>();
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _repository.fetchProfile();
      if (response.isSuccess) {
        profile.value = response.data;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load profile';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      await _repository.logout();
    } catch (_) {
      // Session clear still happens inside repository; proceed to nav
    } finally {
      isLoggingOut.value = false;
      Get.offAllNamed(AppRoutes.loginWithOtp);
    }
  }
}

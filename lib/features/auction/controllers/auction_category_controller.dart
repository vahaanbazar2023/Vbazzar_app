import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../approved_vehicles/data/repositories/approved_vehicle_repository_impl.dart';
import '../../approved_vehicles/domain/entities/approved_vehicle_category_entity.dart';

class AuctionCategoryController extends GetxController {
  final ApprovedVehicleRepositoryImpl _repository;

  AuctionCategoryController({ApprovedVehicleRepositoryImpl? repository})
      : _repository = repository ?? ApprovedVehicleRepositoryImpl();

  // Categories fetched from the same API as approved vehicles
  final categories = <ApprovedVehicleCategoryEntity>[].obs;
  final isLoadingCategories = false.obs;
  final categoriesError = ''.obs;
  final categoriesTotalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({bool isRefresh = false}) async {
    if (isLoadingCategories.value) return;
    isLoadingCategories.value = true;
    categoriesError.value = '';

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getCategories(userId: userId);
      categories.assignAll(result.categories);
      categoriesTotalCount.value = result.totalCount;
    } catch (e) {
      categoriesError.value = 'Failed to load categories. Pull to refresh.';
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Called when a category is tapped — navigates to auction listings
  /// passing the selected category.
  void onCategoryTapped(ApprovedVehicleCategoryEntity category) {
    Get.toNamed(
      AppRoutes.auctionListings,
      arguments: {'category': category},
    );
  }
}
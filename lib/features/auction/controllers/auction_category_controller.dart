import 'package:get/get.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../core/extensions/context_extensions.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class AuctionLiveCategory {
  final String categoryCode;
  final int count;
  final String? iconUrl;
  final int? bidIncrementAmount;

  const AuctionLiveCategory({
    required this.categoryCode,
    required this.count,
    this.iconUrl,
    this.bidIncrementAmount,
  });

  factory AuctionLiveCategory.fromJson(Map<String, dynamic> json) {
    return AuctionLiveCategory(
      categoryCode: (json['category'] as String? ?? '').toUpperCase(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      iconUrl: json['icon_url'] as String?,
      bidIncrementAmount: (json['bid_increment_amount'] as num?)?.toInt(),
    );
  }

  bool get isLive => count > 0;

  /// Human-readable display name for the category code.
  String get displayName {
    switch (categoryCode.toUpperCase()) {
      case '2W':
        return appL10n.aucTwoWheeler;
      case '3W':
        return appL10n.aucThreeWheeler;
      case '4W':
        return appL10n.aucFourWheeler;
      case 'CV':
        return appL10n.aucCommercialVehicle;
      case 'CE':
        return appL10n.aucConstructionEquipment;
      case 'FE':
        return appL10n.aucFarmEquipment;
      default:
        return categoryCode;
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────

class AuctionCategoryController extends GetxController {
  final NetworkService _network;

  AuctionCategoryController({NetworkService? network})
    : _network = network ?? NetworkService.to;

  final categories = <AuctionLiveCategory>[].obs;
  final isLoadingCategories = false.obs;
  final categoriesError = ''.obs;

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
      final response = await _network.post(
        ApiEndpoints.liveAuctionCategoryCounts,
        data: {'user_id': userId},
      );

      final data = response.data as Map<String, dynamic>?;
      final raw =
          ((data?['data'] as Map<String, dynamic>?)?['categories']
              as List<dynamic>?) ??
          [];

      categories.assignAll(
        raw
            .map((e) => AuctionLiveCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      categoriesError.value = appL10n.aucFailedLoadCategories;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Navigate directly to vehicle listings for the selected category.
  void onCategoryTapped(AuctionLiveCategory category) {
    Get.toNamed(
      AppRoutes.vehicleListings,
      arguments: {
        'auctionType': 'live_auctions',
        'vehicleType': category.categoryCode.toLowerCase(),
        'auctionTitle': category.displayName,
        'bidIncrementAmount': category.bidIncrementAmount ?? 5000,
      },
    );
  }
}

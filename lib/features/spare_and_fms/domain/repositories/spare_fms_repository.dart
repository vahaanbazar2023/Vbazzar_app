import '../../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../entities/shop_entity.dart';
import '../entities/spare_order_entity.dart';
import '../entities/spare_part_entity.dart';

/// Pagination metadata for list responses.
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Abstract repository interface for Spare & FMS data operations.
///
/// Implemented by [SpareFmsRepositoryImpl] in the data layer.
abstract class SpareFmsRepository {
  /// Fetch paginated spare parts list.
  Future<({List<SparePartEntity> spares, PaginationMeta pagination})>
  getSparesList({required int page, required int limit, String? userId});

  /// Record user interest in a spare part.
  /// Returns the created spare order ID on success.
  Future<String> recordSpareInterest({
    required String spareId,
    required String userId,
  });

  /// Fetch shops list (basic, no location filter).
  Future<({List<ShopEntity> shops, PaginationMeta pagination})> getShopsList({
    required int page,
    required int limit,
    String? userId,
  });

  /// Fetch shops list filtered by location and category (CE/CV).
  Future<
    ({
      List<ShopEntity> shops,
      PaginationMeta pagination,
      List<ListingAd> ads,
      UserLocationEntity? userLocation,
    })
  >
  getShopsListByCategory({
    required double latitude,
    required double longitude,
    required String shopCategoryType,
    required String userId,
    required int page,
    required int limit,
  });

  /// Record shop subscription (basic).
  Future<bool> recordShopSubscription({
    required String shopId,
    required String userId,
  });

  /// Create shop subscription with number access.
  Future<bool> createShopSubscription({
    required String shopId,
    required String userId,
  });

  /// Fetch user's spare orders (My Bookings).
  Future<({List<SpareOrderEntity> orders, PaginationMeta pagination})>
  getUserSparesOrders({
    required String userId,
    required int page,
    required int limit,
  });
}

import 'buy_vehicle_entity.dart';

/// Paginated response for buy vehicle listing.
class PaginatedBuyVehiclesResponse {
  final List<BuyVehicleEntity> vehicles;
  final int totalPages;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const PaginatedBuyVehiclesResponse({
    required this.vehicles,
    required this.totalPages,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
  });
}
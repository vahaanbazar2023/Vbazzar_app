import 'sell_vehicle_entity.dart';

/// Paginated response for sell vehicle listing.
class PaginatedSellVehiclesResponse {
  final List<SellVehicleEntity> vehicles;
  final int totalPages;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const PaginatedSellVehiclesResponse({
    required this.vehicles,
    required this.totalPages,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
  });
}
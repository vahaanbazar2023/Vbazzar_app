import 'subscribed_vehicle_entity.dart';

/// Paginated response for subscribed vehicle listing.
class PaginatedSubscribedVehiclesResponse {
  final List<SubscribedVehicleEntity> vehicles;
  final int totalPages;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const PaginatedSubscribedVehiclesResponse({
    required this.vehicles,
    required this.totalPages,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
  });
}
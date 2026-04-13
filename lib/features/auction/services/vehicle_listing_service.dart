import '../../../core/network/network_service.dart';
import '../models/auction_pagination.dart';
import '../models/vehicle_listing.dart';

class VehicleListingService {
  static const String _path = '/api/v1/auctions/vehicle-listings-pagination';

  final NetworkService _network;

  VehicleListingService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  fetchVehicles({
    required String userId,
    required String auctionId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _path,
      data: {
        'user_id': userId,
        'auction_id': auctionId,
        'page': page,
        'limit': limit,
      },
    );

    final body = response.data ?? {};
    final rawVehicles = body['vehicles'] as List<dynamic>? ?? [];
    final rawPagination = body['pagination'] as Map<String, dynamic>? ?? {};

    return (
      vehicles: rawVehicles
          .map((e) => VehicleListing.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: AuctionPagination.fromJson(rawPagination),
    );
  }
}

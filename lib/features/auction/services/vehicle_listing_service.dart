import 'package:flutter/foundation.dart';
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

    final responseBody = response.data ?? {};
    print(responseBody);

    // API wraps payload under a top-level "data" key:
    // { status, code, message, data: { vehicles: [...], pagination: {...} } }
    // Fall back to the root body so the service works if the API ever changes.
    final body = (responseBody['data'] is Map<String, dynamic>
        ? responseBody['data'] as Map<String, dynamic>
        : responseBody);

    debugPrint('📦 [VehicleListingService] keys: ${body.keys.toList()}');
    debugPrint(
      '📦 [VehicleListingService] vehicle count: '
      '${(body['vehicles'] as List<dynamic>? ?? []).length}',
    );

    final rawVehicles = body['vehicles'] as List<dynamic>? ?? [];
    final rawPagination = body['pagination'] as Map<String, dynamic>? ?? {};

    final vehicles = <VehicleListing>[];
    for (int i = 0; i < rawVehicles.length; i++) {
      try {
        vehicles.add(
          VehicleListing.fromJson(rawVehicles[i] as Map<String, dynamic>),
        );
      } catch (e, st) {
        debugPrint(
          '❌ [VehicleListingService] failed to parse vehicle[$i]: $e\n$st',
        );
        debugPrint('   Raw: ${rawVehicles[i]}');
      }
    }

    return (
      vehicles: vehicles,
      pagination: AuctionPagination.fromJson(rawPagination),
    );
  }
}

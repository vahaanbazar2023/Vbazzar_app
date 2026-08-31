import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../models/auction_pagination.dart';
import '../models/vehicle_listing.dart';

class VehicleListingService {
  final NetworkService _network;

  VehicleListingService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  fetchVehicles({
    required String userId,
    required String auctionType,
    required String vehicleType,
    String category = '',
    String regionId = '',
    String stateId = '',
    int page = 1,
    int limit = 20,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'auction_type': auctionType,
      'vehicle_type': vehicleType,
      'category': category,
      'region_id': regionId,
      'state_id': stateId,
      'page': page,
      'limit': limit,
    };

    debugPrint(
      '📤 [VehicleListingService] REQUEST → ${ApiEndpoints.auctionVehicleListings}\n$body',
    );

    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.auctionVehicleListings,
      data: body,
    );

    final responseBody = response.data ?? {};

    // API wraps payload under a top-level "data" key.
    final bodyData = (responseBody['data'] is Map<String, dynamic>
        ? responseBody['data'] as Map<String, dynamic>
        : responseBody);

    debugPrint(
      '📦 [VehicleListingService] vehicle count: '
      '${(bodyData['vehicles'] as List<dynamic>? ?? []).length}',
    );

    final rawVehicles = bodyData['vehicles'] as List<dynamic>? ?? [];
    final rawPagination = bodyData['pagination'] as Map<String, dynamic>? ?? {};

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
      }
    }

    return (
      vehicles: vehicles,
      pagination: AuctionPagination.fromJson(rawPagination),
    );
  }
}

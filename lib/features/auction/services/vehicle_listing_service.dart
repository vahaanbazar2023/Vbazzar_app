import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../models/auction_pagination.dart';
import '../models/vehicle_listing.dart';

class VehicleListingService {
  final NetworkService _network;

  VehicleListingService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  /// POST /api/v1/auctions/vehicle-listings-pagination
  ///
  /// Every field the API documents is always sent: `bank_name` ('' = no filter, never null) and
  /// `wishlisted_only` (false by default).
  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  fetchVehicles({
    required String userId,
    required String auctionType,
    required String vehicleType,
    String category = '',
    String regionId = '',
    String stateId = '',
    String bankName = '',
    int page = 1,
    int limit = 20,
  }) {
    return _fetch(
      label: 'REQUEST',
      body: buildRequestBody(
        userId: userId,
        auctionType: auctionType,
        vehicleType: vehicleType,
        category: category,
        regionId: regionId,
        stateId: stateId,
        bankName: bankName,
        page: page,
        limit: limit,
      ),
    );
  }

  /// Fetch only wishlisted vehicles for the user
  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  fetchWishlistedVehicles({
    required String userId,
    String vehicleType = '2w', // Default to 2W, can be changed
    int page = 1,
    int limit = 20,
  }) {
    return _fetch(
      label: 'WISHLIST REQUEST',
      body: buildRequestBody(
        userId: userId,
        auctionType: 'live_auctions', // Default to live auctions
        vehicleType: vehicleType,
        page: page,
        limit: limit,
        wishlistedOnly: true, // Key filter for wishlist
      ),
    );
  }

  /// The JSON body the API expects (see the request example in the API docs).
  @visibleForTesting
  static Map<String, dynamic> buildRequestBody({
    required String userId,
    required String auctionType,
    required String vehicleType,
    String category = '',
    String regionId = '',
    String stateId = '',
    String bankName = '',
    int page = 1,
    int limit = 20,
    bool wishlistedOnly = false,
  }) => <String, dynamic>{
    'user_id': userId,
    'auction_type': auctionType,
    'vehicle_type': vehicleType,
    'category': category,
    'region_id': regionId,
    'state_id': stateId,
    'bank_name': bankName.trim(), // '' = no filter; the API rejects null
    'wishlisted_only': wishlistedOnly,
    'page': page,
    'limit': limit,
  };

  /// Parse `{vehicles, pagination}`, whether or not the API wraps it under a top-level `data` key.
  /// One malformed vehicle is skipped instead of failing the whole page.
  @visibleForTesting
  static ({List<VehicleListing> vehicles, AuctionPagination pagination})
  parseResponse(Map<String, dynamic> responseBody) {
    final bodyData = responseBody['data'] is Map<String, dynamic>
        ? responseBody['data'] as Map<String, dynamic>
        : responseBody;
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

  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  _fetch({required String label, required Map<String, dynamic> body}) async {
    debugPrint(
      '📤 [VehicleListingService] $label → ${ApiEndpoints.auctionVehicleListings}\n$body',
    );
    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.auctionVehicleListings,
      data: body,
    );
    final result = parseResponse(response.data ?? {});
    debugPrint(
      '📦 [VehicleListingService] vehicle count: ${result.vehicles.length}',
    );
    return result;
  }

  /// Search vehicles across all active auctions by query
  Future<({List<VehicleListing> vehicles, AuctionPagination pagination})>
  searchVehicles({
    required String userId,
    required String searchQuery,
    String vehicleType = '', // Empty means search all categories
    int page = 1,
    int limit = 20,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'search_query': searchQuery.trim(),
      'vehicle_type': vehicleType,
      'page': page,
      'limit': limit,
    };

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 SEARCH REQUEST');
    debugPrint('URL: ${ApiEndpoints.vehicleSearch}');
    debugPrint('BODY: $body');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.vehicleSearch,
      data: body,
    );

    final responseBody = response.data ?? {};

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📥 SEARCH RESPONSE');
    debugPrint('Status: ${response.statusCode}');
    debugPrint(
      'Vehicle Count: ${(responseBody['vehicles'] as List<dynamic>? ?? []).length}',
    );
    debugPrint('Pagination: ${responseBody['pagination']}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final rawVehicles = responseBody['vehicles'] as List<dynamic>? ?? [];
    final rawPagination =
        responseBody['pagination'] as Map<String, dynamic>? ?? {};

    final vehicles = <VehicleListing>[];
    for (int i = 0; i < rawVehicles.length; i++) {
      try {
        vehicles.add(
          VehicleListing.fromJson(rawVehicles[i] as Map<String, dynamic>),
        );
      } catch (e, st) {
        debugPrint(
          '❌ [VehicleListingService] failed to parse search vehicle[$i]: $e\n$st',
        );
      }
    }

    return (
      vehicles: vehicles,
      pagination: AuctionPagination.fromJson(rawPagination),
    );
  }
}

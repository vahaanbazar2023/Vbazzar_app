import 'package:dio/dio.dart' as dio;
import '../../../../core/network/network_service.dart';
import '../../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../../domain/entities/approved_vehicle_listing_entity.dart';
import '../../domain/entities/auction_vehicle_match.dart';
import '../../domain/repositories/approved_vehicle_repository.dart';
import '../models/approved_vehicle_category_model.dart';
import '../models/approved_vehicle_listing_model.dart';

/// Concrete implementation of [ApprovedVehicleRepository].
///
/// Talks to the remote API via [NetworkService] and maps
/// raw JSON responses into domain entities via DTOs.
class ApprovedVehicleRepositoryImpl implements ApprovedVehicleRepository {
  static const String _categoriesPath =
      '/api/v1/approved-veh/appr-veh-categories';
  static const String _listingsPath = '/api/v1/approved-veh/appr-veh-listings';
  static const String _submitPath = '/api/v1/approved-veh/appr-veh-submit';
  static const String _userInterestPath =
      '/api/v1/approved-veh/appr-veh-user-interest';
  static const String _userBookedPath =
      '/api/v1/approved-veh/appr-veh-user-booked';
  static const String _auctionLookupPath =
      '/api/v1/approved-veh/appr-veh-auction-lookup';

  final NetworkService _network;

  ApprovedVehicleRepositoryImpl({NetworkService? network})
    : _network = network ?? NetworkService.to;

  // ── Categories ──────────────────────────────────────────────

  @override
  Future<PaginatedCategoriesResult> getCategories({
    required String userId,
    String status = 'Active',
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _categoriesPath,
      data: {'user_id': userId, 'status': status, 'page': page, 'limit': limit},
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const PaginatedCategoriesResult(categories: [], totalCount: 0);
    }

    final rawCategories = data['categories'] as List<dynamic>? ?? [];
    final totalCount = _parseInt(data['total_count']);

    return PaginatedCategoriesResult(
      categories: rawCategories
          .map(
            (e) => ApprovedVehicleCategoryModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      totalCount: totalCount,
    );
  }

  // ── Listings ────────────────────────────────────────────────

  @override
  Future<PaginatedListingsResult> getListings({
    required String userId,
    String status = 'approved',
    String categoryType = '',
    String stateCode = '',
    String cityCode = '',
    double? minPrice,
    double? maxPrice,
    int? yearFrom,
    int? yearTo,
    String searchRegistration = '',
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'status': status,
      'page': page,
      'limit': limit,
    };

    if (categoryType.isNotEmpty) body['category_type'] = categoryType;
    if (stateCode.isNotEmpty) body['state_code'] = stateCode;
    if (cityCode.isNotEmpty) body['city_code'] = cityCode;
    if (minPrice != null) body['min_price'] = minPrice;
    if (maxPrice != null) body['max_price'] = maxPrice;
    if (yearFrom != null) body['year_from'] = yearFrom;
    if (yearTo != null) body['year_to'] = yearTo;
    if (searchRegistration.isNotEmpty) {
      body['search_registration'] = searchRegistration;
    }

    final response = await _network.post<Map<String, dynamic>>(
      _listingsPath,
      data: body,
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const PaginatedListingsResult(listings: [], totalCount: 0);
    }

    final rawListings = data['listings'] as List<dynamic>? ?? [];
    final totalCount = _parseInt(data['total_count']);

    final vehicleListings = <ApprovedVehicleListingEntity>[];
    final adsList = <ListingAd>[];

    for (final item in rawListings) {
      final map = item as Map<String, dynamic>;
      if (map['is_advertisement'] == true) {
        adsList.add(ListingAd.fromJson(map));
      } else {
        final listing = ApprovedVehicleListingModel.fromJson(map);
        if (listing.isBooked.toLowerCase() != 'yes') {
          vehicleListings.add(listing);
        }
      }
    }

    return PaginatedListingsResult(
      listings: vehicleListings,
      ads: adsList,
      totalCount: totalCount,
    );
  }

  @override
  Future<ApprovedVehicleListingEntity?> getListingByVehicleId({
    required String userId,
    required String approvedVehicleId,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _listingsPath,
      data: {
        'user_id': userId,
        'approved_vehicle_id': approvedVehicleId,
        'page': 1,
        'limit': 1,
      },
    );
    final raw =
        (response.data?['data'] as Map<String, dynamic>?)?['listings']
            as List<dynamic>? ??
        const [];
    for (final item in raw) {
      final map = item as Map<String, dynamic>;
      if (map['is_advertisement'] == true) continue;
      return ApprovedVehicleListingModel.fromJson(map);
    }
    return null;
  }

  // ── User Interest (Book / Inspection) ───────────────────────

  @override
  Future<UserInterestResult> updateUserInterest({
    required String userId,
    required String approvedVehicleId,
    required String isInterested,
    required String isBooked,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _userInterestPath,
      data: {
        'user_id': userId,
        'approved_vehicle_id': approvedVehicleId,
        'is_interested': isInterested,
        'is_booked': isBooked,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? {};

    return UserInterestResult(
      subscriptionId: _parseInt(data['subscription_id']),
      approvedVehicleId: data['approved_vehicle_id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      inspectionRequested: data['inspection_requested']?.toString() ?? '',
      isBooked: data['is_booked']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
    );
  }

  // ── User Booked / Inspected Vehicles ────────────────────────

  @override
  Future<PaginatedListingsResult> getUserBookedVehicles({
    required String userId,
    String? bookedVehicles,
    String? inspectionRequested,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'page': page,
      'limit': limit,
    };

    if (bookedVehicles != null) body['booked_vehicles'] = bookedVehicles;
    if (inspectionRequested != null) {
      body['inspection_requested'] = inspectionRequested;
    }

    final response = await _network.post<Map<String, dynamic>>(
      _userBookedPath,
      data: body,
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const PaginatedListingsResult(listings: [], totalCount: 0);
    }

    final rawVehicles = data['vehicles'] as List<dynamic>? ?? [];
    final totalCount = _parseInt(data['total_count']);

    return PaginatedListingsResult(
      listings: rawVehicles
          .map(
            (e) =>
                ApprovedVehicleListingModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      totalCount: totalCount,
    );
  }

  // ── Submit Vehicle (Sell Form) ──────────────────────────────

  @override
  Future<AuctionVehicleMatch?> findAuctionVehicle({
    required String userId,
    required String registrationNumber,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _auctionLookupPath,
      data: {'user_id': userId, 'registration_number': registrationNumber},
    );
    final body = response.data;
    // Not found comes back as HTTP 200 with status "error" and code 404.
    if (body == null || body['status'] != 'success') return null;
    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;
    return AuctionVehicleMatch.fromJson(data);
  }

  @override
  Future<void> submitVehicle(dio.FormData formData) async {
    Map<String, dynamic>? body;
    try {
      final response = await _network.upload<Map<String, dynamic>>(
        _submitPath,
        formData,
      );
      body = response.data;
    } on dio.DioException catch (e) {
      // 403 / 422 / 503 come back as HTTP errors with a JSON body.
      final data = e.response?.data;
      final message = submitErrorMessage(data is Map ? data : null);
      if (message != null) throw SubmitVehicleRejected(message);
      rethrow;
    }
    // Success is `status: "success"`; refusals are HTTP 200 with
    // `status: "error"` and the reason in `message`.
    if (body?['status'] == 'success') return;
    throw SubmitVehicleRejected(
      submitErrorMessage(body) ?? 'Failed to submit the vehicle.',
    );
  }

  /// The exact reason in an appr-veh-submit error body: its `message`, or for
  /// a 422 the `detail` list joined ("price: Input should be greater than 0").
  static String? submitErrorMessage(Map? body) {
    if (body == null) return null;
    final detail = body['detail'];
    if (detail is List && detail.isNotEmpty) {
      final lines = [
        for (final d in detail)
          if (d is Map)
            [
              if (d['loc'] is List && (d['loc'] as List).isNotEmpty)
                '${(d['loc'] as List).last}',
              '${d['msg'] ?? ''}',
            ].where((x) => x.isNotEmpty).join(': '),
      ].where((x) => x.isNotEmpty).toList();
      if (lines.isNotEmpty) return lines.join('\n');
    }
    final message = body['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) return message;
    if (detail is Map && '${detail['message'] ?? ''}'.trim().isNotEmpty) {
      return '${detail['message']}'.trim();
    }
    if (detail is String && detail.trim().isNotEmpty) return detail.trim();
    return null;
  }

  // ── Helpers ─────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

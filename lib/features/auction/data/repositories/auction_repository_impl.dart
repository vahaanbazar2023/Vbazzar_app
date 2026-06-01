import 'package:get/get.dart' hide Response;
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/entities/bid_entity.dart';
import '../../domain/entities/vehicle_listing_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';
import '../models/vehicle_listing_model.dart';

/// Concrete implementation of [AuctionRepository].
///
/// Uses [NetworkService] for HTTP communication and maps API
/// responses to domain entities.
class AuctionRepositoryImpl implements AuctionRepository {
  final NetworkService _network = Get.find<NetworkService>();

  // ─── Debug Logger ────────────────────────────────────────────
  void _logRequest(String endpoint, Map<String, dynamic> body) {
    // ignore: avoid_print
    print('🔵 [AUCTION API REQUEST] $endpoint');
    // ignore: avoid_print
    print('   Body: $body');
  }

  void _logResponse(String endpoint, dynamic data) {
    // ignore: avoid_print
    print('🟢 [AUCTION API RESPONSE] $endpoint');
    // ignore: avoid_print
    print('   Data: $data');
  }

  void _logError(String endpoint, Object error) {
    // ignore: avoid_print
    print('🔴 [AUCTION API ERROR] $endpoint');
    // ignore: avoid_print
    print('   Error: $error');
  }

  // ─── Auction Listings ────────────────────────────────────────

  @override
  Future<({List<AuctionEntity> auctions, PaginationEntity pagination})>
      fetchAuctionListings({
    required String userId,
    required String auctionType,
    String categoryType = '',
    String vehicleType = '',
    String regionId = '',
    String stateId = '',
    int page = 1,
    int limit = 10,
  }) async {
    final body = <String, dynamic>{
      'page': page,
      'limit': limit,
      'auction_type': auctionType,
    };
    if (userId.isNotEmpty) body['user_id'] = userId;
    if (categoryType.isNotEmpty) body['category_type'] = categoryType;
    if (vehicleType.isNotEmpty) body['vehicle_type'] = vehicleType;
    if (stateId.isNotEmpty) body['state_id'] = stateId;
    if (regionId.isNotEmpty) body['region_id'] = regionId;

    _logRequest(ApiEndpoints.auctionListings, body);
    try {
      final response = await _network.post(
        ApiEndpoints.auctionListings,
        data: body,
      );

      final data = response.data['data'] ?? {};
      _logResponse(ApiEndpoints.auctionListings, response.data);
      final auctionsList = (data['auctions'] as List<dynamic>? ?? [])
          .map((e) => AuctionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return (
        auctions: auctionsList,
        pagination: PaginationEntity(
          totalCount: _parseInt(data['total_count']),
          page: _parseInt(data['page']),
          limit: _parseInt(data['limit']),
          hasNext: false,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.auctionListings, e);
      rethrow;
    }
  }

  // ─── Vehicle Listings ────────────────────────────────────────

  @override
  Future<({List<VehicleListingEntity> vehicles, PaginationEntity pagination})>
      fetchVehicleListings({
    required String userId,
    required String auctionId,
    int page = 1,
    int limit = 10,
    String searchValue = '',
    String categoryType = '',
    String stateCode = '',
    String cityCode = '',
    int? minPrice,
    int? maxPrice,
    int? yearFrom,
    int? yearTo,
  }) async {
    final body = <String, dynamic>{
      'auction_id': auctionId,
      'page': page,
      'limit': limit,
    };
    if (userId.isNotEmpty) body['user_id'] = userId;
    if (searchValue.isNotEmpty) body['search_value'] = searchValue;
    if (categoryType.isNotEmpty) body['category_type'] = categoryType;
    if (stateCode.isNotEmpty) body['state_code'] = stateCode;
    if (cityCode.isNotEmpty) body['city_code'] = cityCode;
    if (minPrice != null) body['min_price'] = minPrice;
    if (maxPrice != null) body['max_price'] = maxPrice;
    if (yearFrom != null) body['year_from'] = yearFrom;
    if (yearTo != null) body['year_to'] = yearTo;

    _logRequest(ApiEndpoints.auctionVehicleListings, body);
    try {
      final response = await _network.post(
        ApiEndpoints.auctionVehicleListings,
        data: body,
      );

      _logResponse(ApiEndpoints.auctionVehicleListings, response.data);

      // Handle both wrapped (response.data['data']) and unwrapped (response.data) structures
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData.containsKey('data') &&
              responseData['data'] != null
          ? responseData['data'] as Map<String, dynamic>
          : responseData;

      final vehiclesList = (data['vehicles'] as List<dynamic>? ?? [])
          .map((e) => VehicleListingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return (
        vehicles: vehiclesList,
        pagination: PaginationEntity(
          totalCount: _parseInt(data['total_count']),
          page: _parseInt(data['page']),
          limit: _parseInt(data['limit']),
          hasNext: data['has_next'] == true,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.auctionVehicleListings, e);
      rethrow;
    }
  }

  // ─── Bid Operations ──────────────────────────────────────────

  @override
  Future<BidEntity> placeBid({
    required String userId,
    required String vehicleId,
    required String auctionId,
    required int bidAmount,
  }) async {
    final bidBody = {
      'vehicle_id': vehicleId,
      'auction_id': auctionId,
      'bid_amount': bidAmount,
      'user_id': userId,
    };
    _logRequest(ApiEndpoints.placeBid, bidBody);
    try {
      final response = await _network.post(
        ApiEndpoints.placeBid,
        data: bidBody,
      );

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.placeBid, responseData);

      // Check if the API returned an error status
      final status = responseData['status'] as String? ?? '';
      if (status == 'error') {
        final errorMsg =
            responseData['message'] as String? ?? 'Failed to place bid';
        final errorData =
            responseData['error'] as Map<String, dynamic>?;
        final errorCode = errorData?['code'] as String? ?? '';
        final errorDetails = errorData?['message'] as String? ?? errorMsg;
        _logError(ApiEndpoints.placeBid, '[$errorCode] $errorDetails');
        throw BidException(errorDetails, errorCode);
      }

      final data = responseData['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return BidEntity(
          bidId: '',
          vehicleId: '',
          auctionId: '',
          bidAmount: 0,
          bidStatus: 'unknown',
        );
      }

      return BidModel.fromJson(data);
    } catch (e) {
      _logError(ApiEndpoints.placeBid, e);
      rethrow;
    }
  }

  // ─── My Bids ─────────────────────────────────────────────────

  @override
  Future<({List<MyBidEntity> bids, PaginationEntity pagination})> fetchMyBids({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final myBidsBody = {
      'user_id': userId,
      'page': page,
      'limit': limit,
    };
    _logRequest(ApiEndpoints.myBids, myBidsBody);
    try {
      final response = await _network.post(
        ApiEndpoints.myBids,
        data: myBidsBody,
      );

      final data = response.data['data'] ?? {};
      _logResponse(ApiEndpoints.myBids, response.data);
      final bidsList = (data['bids'] as List<dynamic>? ?? [])
          .map((e) => MyBidModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return (
        bids: bidsList,
        pagination: PaginationEntity(
          totalCount: _parseInt(data['total_count']),
          page: _parseInt(data['page']),
          limit: _parseInt(data['limit']),
          hasNext: false,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.myBids, e);
      rethrow;
    }
  }

  // ─── My Wins ─────────────────────────────────────────────────

  @override
  Future<({List<MyWinEntity> wins, PaginationEntity pagination})> fetchMyWins({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final myWinsBody = {
      'user_id': userId,
      'page': page,
      'limit': limit,
    };
    _logRequest(ApiEndpoints.myWins, myWinsBody);
    try {
      final response = await _network.post(
        ApiEndpoints.myWins,
        data: myWinsBody,
      );

      final data = response.data['data'] ?? {};
      _logResponse(ApiEndpoints.myWins, response.data);
      final winsList = (data['wins'] as List<dynamic>? ?? [])
          .map((e) => MyWinModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return (
        wins: winsList,
        pagination: PaginationEntity(
          totalCount: _parseInt(data['total_count']),
          page: _parseInt(data['page']),
          limit: _parseInt(data['limit']),
          hasNext: false,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.myWins, e);
      rethrow;
    }
  }

  // ─── Winning Letter ──────────────────────────────────────────

  @override
  Future<List<int>> downloadWinningLetter({
    required String winId,
    required String vehicleId,
    required String auctionId,
  }) async {
    final letterBody = {
      'win_id': winId,
      'vehicle_id': vehicleId,
      'auction_id': auctionId,
    };
    _logRequest(ApiEndpoints.winningLetter, letterBody);
    try {
      final response = await _network.post(
        ApiEndpoints.winningLetter,
        data: letterBody,
      );

      _logResponse(ApiEndpoints.winningLetter,
          'PDF response received (${response.data?.runtimeType})');

      // If response is raw bytes
      if (response.data is List) {
        return (response.data as List).cast<int>();
      }
      // If response contains a URL or message
      return [];
    } catch (e) {
      _logError(ApiEndpoints.winningLetter, e);
      rethrow;
    }
  }

  // ─── Insurance Interest ──────────────────────────────────────

  @override
  Future<bool> updateInsuranceInterest({
    required String vehicleId,
    required String auctionId,
    required bool insuranceInterest,
  }) async {
    final insuranceBody = {
      'vehicle_id': vehicleId,
      'auction_id': auctionId,
      'insurance_interest': insuranceInterest,
    };
    _logRequest(ApiEndpoints.updateInsuranceInterest, insuranceBody);
    try {
      final response = await _network.post(
        ApiEndpoints.updateInsuranceInterest,
        data: insuranceBody,
      );
      _logResponse(ApiEndpoints.updateInsuranceInterest, response.data);
      return response.data['status'] == 'success';
    } catch (e) {
      _logError(ApiEndpoints.updateInsuranceInterest, e);
      return false;
    }
  }

  // ─── Regions & States ────────────────────────────────────────

  @override
  Future<List<RegionEntity>> fetchRegions() async {
    _logRequest(ApiEndpoints.regions, {});
    try {
      final response = await _network.get(ApiEndpoints.regions);
      final data = response.data['data'];
      _logResponse(ApiEndpoints.regions, response.data);

      List<dynamic> regionsList = [];
      if (data is Map<String, dynamic>) {
        regionsList = data['regions'] as List<dynamic>? ?? [];
      } else if (data is List) {
        regionsList = data;
      }

      return regionsList
          .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logError(ApiEndpoints.regions, e);
      rethrow;
    }
  }

  @override
  Future<List<StateByRegionEntity>> fetchStatesByRegion({
    required String regionId,
  }) async {
    final endpoint = ApiEndpoints.statesByRegion(regionId);
    _logRequest(endpoint, {'region_id': regionId});
    try {
      final response = await _network.get(endpoint);
      final data = response.data['data'];
      _logResponse(endpoint, response.data);

      List<dynamic> statesList = [];
      if (data is Map<String, dynamic>) {
        statesList = data['states'] as List<dynamic>? ?? [];
      } else if (data is List) {
        statesList = data;
      }

      return statesList
          .map(
              (e) => StateByRegionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  // ─── Vehicle Search ──────────────────────────────────────────

  @override
  Future<List<VehicleListingEntity>> searchVehicles({
    required String searchValue,
    required String auctionId,
  }) async {
    final searchBody = {
      'search_value': searchValue,
      'auction_id': auctionId,
    };
    _logRequest(ApiEndpoints.vehicleSearch, searchBody);
    try {
      final response = await _network.post(
        ApiEndpoints.vehicleSearch,
        data: searchBody,
      );

      final data = response.data['data'];
      _logResponse(ApiEndpoints.vehicleSearch, response.data);
      if (data is List) {
        return data
            .map((e) =>
                VehicleListingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final vehicles = data['vehicles'];
        if (vehicles is List) {
          return vehicles
              .map((e) => VehicleListingModel.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      _logError(ApiEndpoints.vehicleSearch, e);
      rethrow;
    }
  }

  // ─── Refund ──────────────────────────────────────────────────

  @override
  Future<bool> initiateRefund({
    required String userId,
    required String accHolderName,
    required String accountNumber,
    required String bankName,
    required String branchName,
    required String ifscCode,
  }) async {
    final refundBody = {
      'user_id': userId,
      'acc_holder_name': accHolderName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'branch_name': branchName,
      'ifsc_code': ifscCode,
      'refund_type': 'Auction Deposit Refund',
    };
    _logRequest(ApiEndpoints.auctionRefundInitiate, refundBody);
    try {
      final response = await _network.post(
        ApiEndpoints.auctionRefundInitiate,
        data: refundBody,
      );
      _logResponse(ApiEndpoints.auctionRefundInitiate, response.data);
      return response.data['status'] == 'success';
    } catch (e) {
      _logError(ApiEndpoints.auctionRefundInitiate, e);
      return false;
    }
  }

  // ─── Excel Download ──────────────────────────────────────────

  @override
  Future<List<int>> downloadVehicleExcel({
    required String auctionId,
    String categoryType = '',
    String stateCode = '',
  }) async {
    final excelBody = <String, dynamic>{'auction_id': auctionId};
    if (categoryType.isNotEmpty) excelBody['category_type'] = categoryType;
    if (stateCode.isNotEmpty) excelBody['state_code'] = stateCode;

    _logRequest(ApiEndpoints.vehicleExcelDownload, excelBody);
    try {
      final response = await _network.post(
        ApiEndpoints.vehicleExcelDownload,
        data: excelBody,
      );

      _logResponse(ApiEndpoints.vehicleExcelDownload,
          'Excel response received (${response.data?.runtimeType})');

      if (response.data is List) {
        return (response.data as List).cast<int>();
      }
      return [];
    } catch (e) {
      _logError(ApiEndpoints.vehicleExcelDownload, e);
      return [];
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
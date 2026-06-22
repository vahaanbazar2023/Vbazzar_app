import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/network_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../domain/entities/shop_entity.dart';
import '../../domain/entities/spare_order_entity.dart';
import '../../domain/entities/spare_part_entity.dart';
import '../../domain/repositories/spare_fms_repository.dart';
import '../models/shop_model.dart';
import '../models/spare_order_model.dart';
import '../models/spare_part_model.dart';

/// Concrete implementation of [SpareFmsRepository].
///
/// Uses [NetworkService] for HTTP communication and maps API
/// responses to domain entities.
class SpareFmsRepositoryImpl implements SpareFmsRepository {
  final NetworkService _network = Get.find<NetworkService>();

  // ─── Debug Logger ────────────────────────────────────────────
  void _logRequest(String endpoint, Map<String, dynamic> body) {
    // ignore: avoid_print
    print('🔵 [SPARE-FMS API REQUEST] $endpoint');
    // ignore: avoid_print
    print('   Body: $body');
  }

  void _logResponse(String endpoint, dynamic data) {
    // ignore: avoid_print
    print('🟢 [SPARE-FMS API RESPONSE] $endpoint');
    // ignore: avoid_print
    print('   Data: $data');
  }

  void _logError(String endpoint, Object error) {
    // ignore: avoid_print
    print('🔴 [SPARE-FMS API ERROR] $endpoint');
    // ignore: avoid_print
    print('   Error: $error');
  }

  // ─── List Spares ────────────────────────────────────────────

  @override
  Future<({List<SparePartEntity> spares, PaginationMeta pagination})>
  getSparesList({required int page, required int limit, String? userId}) async {
    final body = <String, dynamic>{'page': page, 'limit': limit};
    if (userId != null && userId.isNotEmpty) body['user_id'] = userId;

    _logRequest(ApiEndpoints.listSpares, body);
    try {
      final response = await _network.post(ApiEndpoints.listSpares, data: body);

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.listSpares, responseData);

      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final sparesList = (data['spares'] as List<dynamic>? ?? [])
          .map((e) => SparePartModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};

      return (
        spares: sparesList.cast<SparePartEntity>(),
        pagination: PaginationMeta(
          currentPage: _parseInt(paginationData['current_page']),
          totalPages: _parseInt(paginationData['total_pages']),
          totalCount: _parseInt(paginationData['total_count']),
          limit: _parseInt(paginationData['limit']),
          hasNext: paginationData['has_next'] == true,
          hasPrevious: paginationData['has_previous'] == true,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.listSpares, e);
      rethrow;
    }
  }

  // ─── Record Spare Interest ──────────────────────────────────

  @override
  Future<String> recordSpareInterest({
    required String spareId,
    required String userId,
  }) async {
    final body = {'spare_id': spareId, 'user_id': userId};

    _logRequest(ApiEndpoints.userSpareInterest, body);
    try {
      final response = await _network.post(
        ApiEndpoints.userSpareInterest,
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.userSpareInterest, responseData);

      if (responseData['status'] == 'error') {
        throw Exception(
          responseData['message'] as String? ?? 'Failed to record interest',
        );
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      return data?['spare_order_id'] as String? ?? '';
    } catch (e) {
      _logError(ApiEndpoints.userSpareInterest, e);
      rethrow;
    }
  }

  // ─── List Shops (Basic) ─────────────────────────────────────

  @override
  Future<({List<ShopEntity> shops, PaginationMeta pagination})> getShopsList({
    required int page,
    required int limit,
    String? userId,
  }) async {
    final body = <String, dynamic>{'page': page, 'limit': limit};
    if (userId != null && userId.isNotEmpty) body['user_id'] = userId;

    _logRequest(ApiEndpoints.listShops, body);
    try {
      final response = await _network.post(ApiEndpoints.listShops, data: body);

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.listShops, responseData);

      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final shopsList = (data['shops'] as List<dynamic>? ?? [])
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};

      return (
        shops: shopsList.cast<ShopEntity>(),
        pagination: PaginationMeta(
          currentPage: _parseInt(paginationData['current_page']),
          totalPages: _parseInt(paginationData['total_pages']),
          totalCount: _parseInt(paginationData['total_count']),
          limit: _parseInt(paginationData['limit']),
          hasNext: paginationData['has_next'] == true,
          hasPrevious: paginationData['has_previous'] == true,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.listShops, e);
      rethrow;
    }
  }

  // ─── List Shops by Category ─────────────────────────────────

  @override
  Future<
    ({
      List<ShopEntity> shops,
      PaginationMeta pagination,
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
  }) async {
    final body = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'shop_category_type': shopCategoryType,
      'page': page,
      'limit': limit,
    };
    if (userId.isNotEmpty) body['user_id'] = userId;

    _logRequest(ApiEndpoints.listShops, body);
    debugPrint(
      '📤 [list-shops] FULL REQUEST:\n'
      '  URL     : ${ApiEndpoints.listShops}\n'
      '  lat     : $latitude\n'
      '  lng     : $longitude\n'
      '  category: $shopCategoryType\n'
      '  page    : $page  limit: $limit\n'
      '  userId  : $userId',
    );
    try {
      final response = await _network.post(ApiEndpoints.listShops, data: body);

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.listShops, responseData);
      // ── Extra debug: print first shop's mobile_number field ──
      final shops = (responseData['data'] as Map<String, dynamic>?)?['shops'];
      if (shops is List && shops.isNotEmpty) {
        final first = shops.first as Map<String, dynamic>?;
        debugPrint(
          '📥 [list-shops] first shop'
          ' mobile_number="${first?['mobile_number']}"'
          ' | number_access_subscription="${first?['number_access_subscription']}"'
          ' | subscription_plan_code="${first?['subscription_plan_code']}"'
          ' | subscription_amount="${first?['subscription_amount']}"',
        );
      }

      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final shopsList = (data['shops'] as List<dynamic>? ?? [])
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};

      final userLocationData = data['user_location'] as Map<String, dynamic>?;

      return (
        shops: shopsList.cast<ShopEntity>(),
        pagination: PaginationMeta(
          currentPage: _parseInt(paginationData['current_page']),
          totalPages: _parseInt(paginationData['total_pages']),
          totalCount: _parseInt(paginationData['total_count']),
          limit: _parseInt(paginationData['limit']),
          hasNext: paginationData['has_next'] == true,
          hasPrevious: paginationData['has_previous'] == true,
        ),
        userLocation: userLocationData != null
            ? UserLocationModel.fromJson(userLocationData)
            : null,
      );
    } catch (e) {
      _logError(ApiEndpoints.listShops, e);
      // Print the raw error response body so we can see what field the server rejects
      if (e is DioException && e.response != null) {
        debugPrint('🔴 [list-shops] ERROR RESPONSE BODY: ${e.response?.data}');
        debugPrint('🔴 [list-shops] STATUS: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // ─── Record Shop Subscription ───────────────────────────────

  @override
  Future<bool> recordShopSubscription({
    required String shopId,
    required String userId,
  }) async {
    final body = {'shop_id': shopId, 'user_id': userId};

    _logRequest(ApiEndpoints.userShopSubscription, body);
    try {
      final response = await _network.post(
        ApiEndpoints.userShopSubscription,
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.userShopSubscription, responseData);
      return responseData['status'] == 'success';
    } catch (e) {
      _logError(ApiEndpoints.userShopSubscription, e);
      return false;
    }
  }

  // ─── Create Shop Subscription (with Number Access) ──────────

  @override
  Future<bool> createShopSubscription({
    required String shopId,
    required String userId,
  }) async {
    final body = {
      'shop_id': shopId,
      'user_id': userId,
      'number_access_subscription': 'yes',
    };

    _logRequest(ApiEndpoints.userShopSubscription, body);
    try {
      final response = await _network.post(
        ApiEndpoints.userShopSubscription,
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.userShopSubscription, responseData);
      return responseData['status'] == 'success';
    } catch (e) {
      _logError(ApiEndpoints.userShopSubscription, e);
      return false;
    }
  }

  // ─── User Spares Orders Listing ─────────────────────────────

  @override
  Future<({List<SpareOrderEntity> orders, PaginationMeta pagination})>
  getUserSparesOrders({
    required String userId,
    required int page,
    required int limit,
  }) async {
    final body = {'user_id': userId, 'page': page, 'limit': limit};

    _logRequest(ApiEndpoints.userSparesOrdersListing, body);
    try {
      final response = await _network.post(
        ApiEndpoints.userSparesOrdersListing,
        data: body,
      );

      final responseData = response.data as Map<String, dynamic>;
      _logResponse(ApiEndpoints.userSparesOrdersListing, responseData);

      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final ordersList = (data['orders'] as List<dynamic>? ?? [])
          .map((e) => SpareOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};

      return (
        orders: ordersList.cast<SpareOrderEntity>(),
        pagination: PaginationMeta(
          currentPage: _parseInt(paginationData['current_page']),
          totalPages: _parseInt(paginationData['total_pages']),
          totalCount: _parseInt(paginationData['total_items']),
          limit: _parseInt(paginationData['limit']),
          hasNext: paginationData['has_next'] == true,
          hasPrevious: paginationData['has_previous'] == true,
        ),
      );
    } catch (e) {
      _logError(ApiEndpoints.userSparesOrdersListing, e);
      rethrow;
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

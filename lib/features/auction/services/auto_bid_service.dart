import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

/// Error from the watchlist / auto-bid APIs. [code] is the server's error code
/// (e.g. `NO_ACTIVE_SUBSCRIPTION`, `BID_EXCEEDS_LIMIT`, `MAX_BID_LIMIT_REACHED`, `AUCTION_ENDED`).
class AutoBidException implements Exception {
  final String code;
  final String message;
  const AutoBidException(this.code, this.message);

  /// The user needs (more) bid limit — the app should offer the SUBT002 plan.
  bool get needsBidLimit =>
      code == 'NO_ACTIVE_SUBSCRIPTION' || code == 'BID_EXCEEDS_LIMIT';

  @override
  String toString() => 'AutoBidException[$code]: $message';
}

/// `data` of POST /auctions/watchlist/toggle.
class WatchlistToggleResult {
  final String vehicleId;
  final bool isWatchlisted;
  final bool isAutoBidEnabled;
  const WatchlistToggleResult({
    required this.vehicleId,
    required this.isWatchlisted,
    required this.isAutoBidEnabled,
  });

  factory WatchlistToggleResult.fromJson(Map<String, dynamic> j) =>
      WatchlistToggleResult(
        vehicleId: j['vehicle_id']?.toString() ?? '',
        isWatchlisted: j['is_watchlisted'] == true,
        isAutoBidEnabled: j['is_auto_bid_enabled'] == true,
      );
}

/// `data` of POST /auctions/auto-bid/toggle: auto-bid state and where the user stands on the vehicle.
class AutoBidState {
  final String vehicleId;
  final bool isEnabled;

  /// Why auto-bid last stopped when it is off: `user_disabled`, `watchlist_removed`, `max_bids`, `insufficient_limit`.
  final String? stopReason;

  /// Per-vehicle auto-bid limit; null = up to the whole buying limit.
  final int? maxAmount;

  /// Bids auto-bid placed during this call (switching on while losing bids at once).
  final int bidsPlaced;
  final int? yourBid;
  final int bidCount;
  final int maxBids;
  final int? currentHighestBid;
  final bool isHighestBidder;
  final int remainingBidLimit;

  const AutoBidState({
    required this.vehicleId,
    required this.isEnabled,
    this.stopReason,
    this.maxAmount,
    this.bidsPlaced = 0,
    this.yourBid,
    this.bidCount = 0,
    this.maxBids = 10,
    this.currentHighestBid,
    this.isHighestBidder = false,
    this.remainingBidLimit = 0,
  });

  static int? _int(dynamic v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}');

  factory AutoBidState.fromJson(Map<String, dynamic> j) => AutoBidState(
    vehicleId: j['vehicle_id']?.toString() ?? '',
    isEnabled: j['is_auto_bid_enabled'] == true,
    stopReason: j['auto_bid_stop_reason']?.toString(),
    maxAmount: _int(j['auto_bid_max_amount']),
    bidsPlaced: _int(j['auto_bids_placed']) ?? 0,
    yourBid: _int(j['your_bid']),
    bidCount: _int(j['user_vehicle_bid_count']) ?? 0,
    maxBids: _int(j['max_user_vehicles_bid_limit']) ?? 10,
    currentHighestBid: _int(j['current_highest_bid']),
    isHighestBidder: j['is_highest_bidder'] == true,
    remainingBidLimit: _int(j['remaining_bid_limit']) ?? 0,
  );
}

class AutoBidService {
  final NetworkService _network;
  AutoBidService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  /// Add the vehicle to the auction watchlist, or remove it (which also switches its auto-bid off).
  Future<WatchlistToggleResult> toggleWatchlist({
    required String userId,
    required String vehicleId,
  }) async {
    final body = await _post(ApiEndpoints.watchlistToggle, {
      'user_id': userId,
      'vehicle_id': vehicleId,
    });
    return WatchlistToggleResult.fromJson(dataOf(body));
  }

  /// Switch auto-bid on or off. Switching on also watchlists the vehicle and, if the user is losing,
  /// bids for them straight away. [maxAmount] caps what auto-bid may bid on this vehicle (null = whole
  /// buying limit); calling again with enabled=true while on just changes it.
  Future<AutoBidState> setAutoBid({
    required String userId,
    required String vehicleId,
    required bool enabled,
    int? maxAmount,
  }) async {
    final body = await _post(ApiEndpoints.autoBidToggle, {
      'user_id': userId,
      'vehicle_id': vehicleId,
      'enabled': enabled,
      if (enabled) 'max_amount': maxAmount,
    });
    return AutoBidState.fromJson(dataOf(body));
  }

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> data,
  ) async {
    debugPrint('📤 [AutoBidService] $url $data');
    try {
      final response = await _network.post<Map<String, dynamic>>(
        url,
        data: data,
      );
      final body = response.data ?? const <String, dynamic>{};
      debugPrint('📥 [AutoBidService] $url $body');
      return body;
    } on DioException catch (e) {
      // Some business errors (e.g. NO_ACTIVE_SUBSCRIPTION) come back as HTTP 403 with the
      // usual error body — surface them as AutoBidException, not a generic failure.
      final body = e.response?.data;
      debugPrint('❌ [AutoBidService] $url ${e.response?.statusCode} $body');
      if (body is Map<String, dynamic> && body['status'] == 'error')
        return body;
      if (body is Map<String, dynamic> && body['detail'] != null) {
        throw AutoBidException(
          'HTTP_${e.response?.statusCode}',
          body['detail'].toString(),
        );
      }
      rethrow;
    }
  }

  /// `data` of a success body; throws [AutoBidException] for an error body. Business errors arrive
  /// with HTTP 200 and `status: "error"` (same as the bid API).
  @visibleForTesting
  static Map<String, dynamic> dataOf(Map<String, dynamic> body) {
    if (body['status'] == 'error') {
      final err = body['error'] is Map<String, dynamic>
          ? body['error'] as Map<String, dynamic>
          : const <String, dynamic>{};
      throw AutoBidException(
        err['code']?.toString() ?? '',
        err['message']?.toString() ?? body['message']?.toString() ?? '',
      );
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    throw const AutoBidException('', 'Unexpected response');
  }
}

import '../../../core/network/network_service.dart';
import '../models/auction_listing.dart';
import '../models/auction_pagination.dart';

class AuctionService {
  static const String _listingsPath =
      '/api/v1/auctions/auction-listings-pagination';

  final NetworkService _network;

  AuctionService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  Future<({List<AuctionListing> auctions, AuctionPagination pagination})>
  fetchListings({
    required String userId,
    required String auctionType,
    String category = '',
    String vehicleType = '',
    String regionId = '',
    String stateId = '',
    int page = 1,
    int limit = 20,
  }) async {
    final body = {
      'user_id': userId,
      'auction_type': auctionType,
      'category': category,
      'vehicle_type': vehicleType,
      'region_id': regionId,
      'state_id': stateId,
      'page': page,
      'limit': limit,
    };

    // ignore: avoid_print
    print('📤 [auction-listings] REQUEST → $_listingsPath\n$body');

    final response = await _network.post<Map<String, dynamic>>(
      _listingsPath,
      data: body,
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return (
        auctions: <AuctionListing>[],
        pagination: AuctionPagination.empty(),
      );
    }

    final rawAuctions = data['auctions'] as List<dynamic>? ?? [];
    final rawPagination = data['pagination'] as Map<String, dynamic>? ?? {};

    return (
      auctions: rawAuctions
          .map((e) => AuctionListing.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: AuctionPagination.fromJson(rawPagination),
    );
  }
}

import 'buy_vehicle_entity.dart';

class ListingAd {
  final int id;
  final String title;
  final String bannerImageUrl;
  final String surface;
  final int insertEveryN; // insert ad after every N vehicles
  final String redirectType; // "internal_screen" | "external_url"
  final String redirectValue;

  const ListingAd({
    required this.id,
    required this.title,
    required this.bannerImageUrl,
    required this.surface,
    required this.insertEveryN,
    required this.redirectType,
    required this.redirectValue,
  });

  bool get isInternal => redirectType == 'internal_screen';

  factory ListingAd.fromJson(Map<String, dynamic> j) => ListingAd(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: j['title'] as String? ?? '',
    bannerImageUrl: j['banner_image_url'] as String? ?? '',
    surface: j['surface'] as String? ?? '',
    insertEveryN: (j['insert_every_n'] as num?)?.toInt() ?? 5,
    redirectType: j['redirect_type'] as String? ?? '',
    redirectValue: j['redirect_value'] as String? ?? '',
  );
}

/// Paginated response for buy vehicle listing.
class PaginatedBuyVehiclesResponse {
  final List<BuyVehicleEntity> vehicles;
  final List<ListingAd> ads;
  final int totalPages;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const PaginatedBuyVehiclesResponse({
    required this.vehicles,
    this.ads = const [],
    required this.totalPages,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
  });
}

import 'buy_vehicle_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Polymorphic feed item — either a vehicle listing or an advertisement.
// Used in the buy-vehicle listings to interleave ads dynamically.
// ─────────────────────────────────────────────────────────────────────────────

sealed class FeedItem {}

/// A normal vehicle listing item.
class VehicleFeedItem extends FeedItem {
  final BuyVehicleEntity vehicle;
  VehicleFeedItem(this.vehicle);
}

/// An advertisement item injected by the API into the feed.
class AdFeedItem extends FeedItem {
  final int id;
  final String title;
  final String bannerImageUrl;
  final String surface;
  final int insertEveryN;
  final String redirectType;   // "internal_screen" | "external_url"
  final String redirectValue;  // route name or URL

  AdFeedItem({
    required this.id,
    required this.title,
    required this.bannerImageUrl,
    required this.surface,
    required this.insertEveryN,
    required this.redirectType,
    required this.redirectValue,
  });

  bool get isInternal => redirectType == 'internal_screen';

  factory AdFeedItem.fromJson(Map<String, dynamic> json) => AdFeedItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        bannerImageUrl: json['banner_image_url'] as String? ?? '',
        surface: json['surface'] as String? ?? '',
        insertEveryN: (json['insert_every_n'] as num?)?.toInt() ?? 5,
        redirectType: json['redirect_type'] as String? ?? '',
        redirectValue: json['redirect_value'] as String? ?? '',
      );
}

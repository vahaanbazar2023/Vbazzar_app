import '../../../auction/models/auction_listing.dart';

// ─── Dashboard Category (most_bought_categories) ─────────────────────────────

class DashboardCategory {
  final int id;
  final String categoryCode;
  final String categoryName;
  final String categoryPlan;
  final double subscriptionAmount;
  final int sortingOrder;
  final String iconName;
  final String iconUrl;
  final String appDashImageUrl;
  final String status;
  final int vehicleCount;

  const DashboardCategory({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    this.categoryPlan = '',
    this.subscriptionAmount = 0,
    this.sortingOrder = 0,
    this.iconName = '',
    this.iconUrl = '',
    required this.appDashImageUrl,
    this.status = 'active',
    required this.vehicleCount,
  });

  factory DashboardCategory.fromJson(Map<String, dynamic> json) {
    return DashboardCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryCode: json['category_code'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      categoryPlan: json['category_plan'] as String? ?? '',
      subscriptionAmount:
          (json['subscription_amount'] as num?)?.toDouble() ?? 0,
      sortingOrder: (json['sorting_order'] as num?)?.toInt() ?? 0,
      iconName: json['icon_name'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      appDashImageUrl: json['app_dash_image_url'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      vehicleCount: (json['vehicle_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}

// ─── Dashboard Advertisement ──────────────────────────────────────────────────

class DashboardAdvertisement {
  final int id;
  final String title;
  final String bannerImageUrl;
  final String surface;
  final String redirectType; // 'internal_screen' | 'external_url'
  final String redirectValue; // route name or URL
  final String homeAfterSection; // which section this ad follows

  const DashboardAdvertisement({
    required this.id,
    required this.title,
    required this.bannerImageUrl,
    this.surface = 'home',
    required this.redirectType,
    required this.redirectValue,
    required this.homeAfterSection,
  });

  factory DashboardAdvertisement.fromJson(Map<String, dynamic> json) {
    return DashboardAdvertisement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      bannerImageUrl: json['banner_image_url'] as String? ?? '',
      surface: json['surface'] as String? ?? 'home',
      redirectType: json['redirect_type'] as String? ?? '',
      redirectValue: json['redirect_value'] as String? ?? '',
      homeAfterSection: json['home_after_section'] as String? ?? '',
    );
  }

  bool get isInternal => redirectType == 'internal_screen';
}

// ─── SparePartDashboard (simplified model for dashboard feed) ─────────────────

class SparePartDashboard {
  final int id;
  final String sparePartId;
  final String spareName;
  final String spareDescription;
  final String price;
  final List<String> photos;
  final String status;
  final int displayOrder;

  const SparePartDashboard({
    required this.id,
    required this.sparePartId,
    required this.spareName,
    required this.spareDescription,
    required this.price,
    required this.photos,
    required this.status,
    required this.displayOrder,
  });

  factory SparePartDashboard.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    List<String> photos = [];
    if (rawPhotos is String) {
      photos = rawPhotos
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawPhotos is List) {
      photos = List<String>.from(rawPhotos.map((e) => e.toString()));
    }
    return SparePartDashboard(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sparePartId: json['spare_part_id'] as String? ?? '',
      spareName: json['spare_name'] as String? ?? '',
      spareDescription: json['spare_description'] as String? ?? '',
      price: json['price']?.toString() ?? '0',
      photos: photos,
      status: json['status'] as String? ?? '',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }

  String get firstPhoto => photos.isNotEmpty ? photos.first : '';
}

// ─── Dashboard Response ───────────────────────────────────────────────────────

class DashboardData {
  final List<AuctionListing> liveAuctions;
  final List<DashboardCategory> mostBoughtCategories;
  final List<SparePartDashboard> sparesFms;
  final List<DashboardAdvertisement> advertisements;

  // Convenience: get ad for a specific section
  DashboardAdvertisement? adAfter(String section) {
    try {
      return advertisements.firstWhere((a) => a.homeAfterSection == section);
    } catch (_) {
      return null;
    }
  }

  const DashboardData({
    required this.liveAuctions,
    required this.mostBoughtCategories,
    required this.sparesFms,
    required this.advertisements,
  });

  /// Parses the new feed-based API response:
  /// data.feed → array of { item_type: "section" | "advertisement", ... }
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final feed = json['feed'] as List<dynamic>? ?? [];

    final auctions = <AuctionListing>[];
    final categories = <DashboardCategory>[];
    final spares = <SparePartDashboard>[];
    final ads = <DashboardAdvertisement>[];

    for (final item in feed) {
      final map = item as Map<String, dynamic>;
      final itemType = map['item_type'] as String? ?? '';

      if (itemType == 'section') {
        final section = map['section'] as String? ?? '';
        final items = map['items'] as List<dynamic>? ?? [];

        switch (section) {
          case 'live_auctions':
            auctions.addAll(
              items
                  .map(
                    (e) => AuctionListing.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            );
            break;
          case 'most_bought_categories':
            categories.addAll(
              items
                  .map(
                    (e) =>
                        DashboardCategory.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            );
            break;
          case 'spares_fms':
            spares.addAll(
              items
                  .map(
                    (e) =>
                        SparePartDashboard.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            );
            break;
        }
      } else if (itemType == 'advertisement' ||
          map['is_advertisement'] == true) {
        ads.add(DashboardAdvertisement.fromJson(map));
      }
    }

    return DashboardData(
      liveAuctions: auctions,
      mostBoughtCategories: categories,
      sparesFms: spares,
      advertisements: ads,
    );
  }
}

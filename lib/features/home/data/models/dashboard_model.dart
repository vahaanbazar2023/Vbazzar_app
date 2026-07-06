import '../../../auction/models/auction_listing.dart';
import '../../../spare_and_fms/data/models/spare_part_model.dart';

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
    required this.categoryPlan,
    required this.subscriptionAmount,
    required this.sortingOrder,
    required this.iconName,
    required this.iconUrl,
    required this.appDashImageUrl,
    required this.status,
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
      status: json['status'] as String? ?? '',
      vehicleCount: (json['vehicle_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}

// ─── Dashboard Response ───────────────────────────────────────────────────────

class DashboardData {
  final List<AuctionListing> liveAuctions;
  final List<DashboardCategory> mostBoughtCategories;
  final List<SparePartModel> sparesFms;

  const DashboardData({
    required this.liveAuctions,
    required this.mostBoughtCategories,
    required this.sparesFms,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final auctionsRaw = json['live_auctions'] as List<dynamic>? ?? [];
    final categoriesRaw =
        json['most_bought_categories'] as List<dynamic>? ?? [];
    final sparesRaw = json['spares_fms'] as List<dynamic>? ?? [];

    return DashboardData(
      liveAuctions: auctionsRaw
          .map((e) => AuctionListing.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostBoughtCategories: categoriesRaw
          .map((e) => DashboardCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      sparesFms: sparesRaw
          .map((e) => SparePartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

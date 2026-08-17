class AuctionListing {
  final int id;
  final String auctionId;
  final String auctionTitle;
  final String startAt;
  final String endAt;
  final String status;
  final String vehicleType;
  final int vehicleCount;
  final String dashboardImageUrl;
  final int displayOrder;

  // Legacy fields kept for backward-compat with auction screens
  final String insertedAt;
  final String updatedAt;
  final String category;
  final String regionId;
  final String stateId;

  const AuctionListing({
    this.id = 0,
    required this.auctionId,
    required this.auctionTitle,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.vehicleType = '',
    this.vehicleCount = 0,
    this.dashboardImageUrl = '',
    this.displayOrder = 0,
    this.insertedAt = '',
    this.updatedAt = '',
    this.category = '',
    this.regionId = '',
    this.stateId = '',
  });

  factory AuctionListing.fromJson(Map<String, dynamic> json) {
    return AuctionListing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      auctionId: json['auction_id'] as String? ?? '',
      auctionTitle: json['auction_title'] as String? ?? '',
      startAt: json['start_at'] as String? ?? '',
      endAt: json['end_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehicleCount: (json['vehicle_count'] as num?)?.toInt() ?? 0,
      dashboardImageUrl: json['dashboard_image_url'] as String? ?? '',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      insertedAt: json['inserted_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      category: json['category'] as String? ?? '',
      regionId: json['region_id'] as String? ?? '',
      stateId: json['state_id'] as String? ?? '',
    );
  }
}

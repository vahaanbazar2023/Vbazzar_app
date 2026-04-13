class AuctionListing {
  final String auctionId;
  final String startAt;
  final String endAt;
  final String status;
  final String insertedAt;
  final String updatedAt;
  final String category;
  final String vehicleType;
  final String regionId;
  final String stateId;
  final String auctionTitle;
  final int vehicleCount;

  const AuctionListing({
    required this.auctionId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.insertedAt,
    required this.updatedAt,
    required this.category,
    required this.vehicleType,
    required this.regionId,
    required this.stateId,
    required this.auctionTitle,
    required this.vehicleCount,
  });

  factory AuctionListing.fromJson(Map<String, dynamic> json) {
    return AuctionListing(
      auctionId: json['auction_id'] as String? ?? '',
      startAt: json['start_at'] as String? ?? '',
      endAt: json['end_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      insertedAt: json['inserted_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      category: json['category'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      regionId: json['region_id'] as String? ?? '',
      stateId: json['state_id'] as String? ?? '',
      auctionTitle: json['auction_title'] as String? ?? '',
      vehicleCount: (json['vehicle_count'] as num?)?.toInt() ?? 0,
    );
  }
}

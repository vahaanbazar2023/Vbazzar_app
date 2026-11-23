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

  /// Home banner tap target, from the backend's `redirect.params`
  /// (empty when the backend does not send it yet).
  final String redirectAuctionType;
  final String redirectVehicleType;
  final int? bidIncrementAmount;

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
    this.redirectAuctionType = '',
    this.redirectVehicleType = '',
    this.bidIncrementAmount,
    this.insertedAt = '',
    this.updatedAt = '',
    this.category = '',
    this.regionId = '',
    this.stateId = '',
  });

  factory AuctionListing.fromJson(Map<String, dynamic> json) {
    final redirect = json['redirect'] is Map ? json['redirect'] as Map : const {};
    final params = redirect['params'] is Map ? redirect['params'] as Map : const {};
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
      redirectAuctionType: params['auction_type']?.toString() ?? '',
      redirectVehicleType: params['vehicle_type']?.toString() ?? '',
      bidIncrementAmount: (redirect['bid_increment_amount'] as num?)?.toInt(),
      insertedAt: json['inserted_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      category: json['category'] as String? ?? '',
      regionId: json['region_id'] as String? ?? '',
      stateId: json['state_id'] as String? ?? '',
    );
  }

  /// `auction_type` for the vehicle list. The backend says whether the
  /// auction has started; without that, a start time in the future means
  /// upcoming.
  String get listAuctionType {
    if (redirectAuctionType.isNotEmpty) return redirectAuctionType;
    final start = DateTime.tryParse(startAt);
    if (start != null && start.isAfter(DateTime.now())) {
      return 'upcoming_auctions';
    }
    return 'live_auctions';
  }

  /// Lowercase vehicle type code ('4w', 'cv') the vehicle list filters on.
  String get listVehicleType =>
      (redirectVehicleType.isNotEmpty ? redirectVehicleType : vehicleType)
          .trim()
          .toLowerCase();

  /// When the auction ends (local time), or null if [endAt] can't be read.
  DateTime? get endDateTime => parseAuctionEnd(endAt);

  /// True once [now] is at or past the end time. An unreadable end time
  /// counts as not ended, so a card is never hidden by a parsing problem.
  bool hasEndedAt(DateTime now) {
    final end = endDateTime;
    return end != null && !now.isBefore(end);
  }

  /// Arguments for [AppRoutes.vehicleListings]: this auction's vehicles only,
  /// on the same screen a category tap opens.
  Map<String, dynamic> vehicleListArguments() => {
    'auctionId': auctionId,
    'auctionType': listAuctionType,
    'initialTab': listAuctionType == 'upcoming_auctions' ? 2 : 0,
    'vehicleType': listVehicleType,
    'auctionTitle': auctionTitle,
    if (bidIncrementAmount != null) 'bidIncrementAmount': bidIncrementAmount,
  };
}

const _months = {
  'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
  'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
};

/// Reads an auction end time in either format the API sends:
/// ISO ("2026-11-23T17:30:00+05:30") or IST text ("29 Jun 2029 - 06:00PM").
/// Returns local time, or null when it can't be read.
DateTime? parseAuctionEnd(String endAt) {
  final text = endAt.trim();
  if (text.isEmpty) return null;
  try {
    if (text.contains('T')) return DateTime.parse(text).toLocal();
    final parts = text.split(' - ');
    final dp = parts[0].trim().split(' ');
    final day = int.parse(dp[0]);
    final month = _months[dp[1]] ?? 1;
    final year = int.parse(dp[2]);
    int h = 0, min = 0;
    if (parts.length > 1) {
      final t = parts[1].trim().toUpperCase();
      final isPm = t.endsWith('PM');
      final nums = t.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      h = int.parse(nums[0]);
      min = int.parse(nums[1]);
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
    }
    return DateTime(year, month, day, h, min);
  } catch (_) {
    return null;
  }
}

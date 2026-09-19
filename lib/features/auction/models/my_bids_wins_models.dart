import 'vehicle_listing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared date parsing
// ─────────────────────────────────────────────────────────────────────────────

const _monthMap = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

/// Safely converts any JSON value to an int.
///
/// The API sometimes sends numeric bid fields as strings (e.g. "122000") or
/// even non-numeric strings ("high"). Returns null for anything unparseable.
int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Like [_asIntOrNull] but falls back to [fallback] (default 0).
int _asInt(dynamic value, [int fallback = 0]) =>
    _asIntOrNull(value) ?? fallback;

/// Safely converts any JSON value to a bool. Accepts real bools and the
/// strings "true"/"false" (case-insensitive).
bool _asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) {
    final v = value.trim().toLowerCase();
    if (v == 'true') return true;
    if (v == 'false') return false;
  }
  return fallback;
}

/// Parses auction date strings from the API.
///
/// Supports both ISO-8601 (`2025-10-15T18:00:00Z`) and the display format
/// `15 Oct 2025 - 06:00PM`. Returns null when parsing fails.
DateTime? parseAuctionDate(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  try {
    if (s.contains('T')) {
      return DateTime.parse(s).toLocal();
    }
    final parts = s.split(' - ');
    final dateParts = parts[0].trim().split(RegExp(r'\s+'));
    if (dateParts.length < 3) return null;
    final day = int.parse(dateParts[0]);
    final month = _monthMap[dateParts[1].toLowerCase()];
    if (month == null) return null;
    final year = int.parse(dateParts[2]);
    int hour = 0, minute = 0;
    if (parts.length > 1) {
      final timePart = parts[1].trim().toUpperCase();
      final isPm = timePart.endsWith('PM');
      final isAm = timePart.endsWith('AM');
      final timeNum = timePart.replaceAll('AM', '').replaceAll('PM', '').trim();
      final hm = timeNum.split(':');
      hour = int.parse(hm[0]);
      minute = hm.length > 1 ? int.parse(hm[1]) : 0;
      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
    }
    return DateTime(year, month, day, hour, minute);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Bid Item — single entry from auction-my-bids-pagination
// ─────────────────────────────────────────────────────────────────────────────

class MyBidItem {
  final int bidId;
  final String auctionId;
  final String auctionTitle;
  final String vehicleId;
  final VehicleListing vehicleDetails;
  final int userBidAmount;
  final int userBidCount;
  final int currentHighestBid;
  final int? currentBid;
  final String bidStatus; // approved, rejected, pending
  final String auctionStatus;
  final String auctionEndTime;
  final String bidPlacedAt;
  final String lastUpdatedAt;
  final String userAuctionStatus;
  final bool isAuctionActive;

  const MyBidItem({
    required this.bidId,
    required this.auctionId,
    required this.auctionTitle,
    required this.vehicleId,
    required this.vehicleDetails,
    required this.userBidAmount,
    required this.userBidCount,
    required this.currentHighestBid,
    this.currentBid,
    required this.bidStatus,
    required this.auctionStatus,
    required this.auctionEndTime,
    required this.bidPlacedAt,
    required this.lastUpdatedAt,
    required this.userAuctionStatus,
    required this.isAuctionActive,
  });

  factory MyBidItem.fromJson(Map<String, dynamic> json) {
    final vd = json['vehicle_details'] as Map<String, dynamic>? ?? {};
    return MyBidItem(
      bidId: _asInt(json['bid_id']),
      auctionId: json['auction_id']?.toString() ?? '',
      auctionTitle: json['auction_title']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      vehicleDetails: VehicleListing.fromJson(vd),
      userBidAmount: _asInt(json['user_bid_amount']),
      userBidCount: _asInt(json['user_bid_count']),
      currentHighestBid: _asInt(json['current_highest_bid']),
      currentBid: _asIntOrNull(json['current_bid']),
      bidStatus: json['bid_status']?.toString() ?? '',
      auctionStatus: json['auction_status']?.toString() ?? '',
      auctionEndTime: json['auction_end_time']?.toString() ?? '',
      bidPlacedAt: json['bid_placed_at']?.toString() ?? '',
      lastUpdatedAt: json['last_updated_at']?.toString() ?? '',
      userAuctionStatus: json['user_auction_status']?.toString() ?? '',
      isAuctionActive: _asBool(json['is_auction_active']),
    );
  }

  bool get isWinning => userBidAmount > 0 && userBidAmount >= currentHighestBid;

  /// Convenience getter for the user's current bid amount
  int get yourBid => userBidAmount;

  /// Convenience getter for minimum bid price from vehicle details
  int get minimumPrice => vehicleDetails.minimumPrice;

  /// Parsed auction end time, or null if it can't be parsed.
  DateTime? get auctionEndDateTime => parseAuctionDate(auctionEndTime);

  /// True when the auction end time has passed.
  bool get isEnded {
    final end = auctionEndDateTime;
    if (end == null) return !isAuctionActive;
    return DateTime.now().isAfter(end);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Win Item — single entry from auction-my-wins-pagination
// ─────────────────────────────────────────────────────────────────────────────

class MyWinItem {
  final int bidId;
  final String auctionId;
  final String auctionTitle;
  final String vehicleId;
  final VehicleListing vehicleDetails;
  final int winningBidAmount;
  final int bidCount;
  final String paymentStatus;
  final String winningLetterStatus;
  final String auctionStatus;
  final String auctionEndTime;
  final String bidApprovedAt;
  final String paymentReference;
  final String userAuctionStatus;

  const MyWinItem({
    required this.bidId,
    required this.auctionId,
    required this.auctionTitle,
    required this.vehicleId,
    required this.vehicleDetails,
    required this.winningBidAmount,
    required this.bidCount,
    required this.paymentStatus,
    required this.winningLetterStatus,
    required this.auctionStatus,
    required this.auctionEndTime,
    required this.bidApprovedAt,
    required this.paymentReference,
    required this.userAuctionStatus,
  });

  factory MyWinItem.fromJson(Map<String, dynamic> json) {
    final vd = json['vehicle_details'] as Map<String, dynamic>? ?? {};
    return MyWinItem(
      bidId: _asInt(json['bid_id']),
      auctionId: json['auction_id']?.toString() ?? '',
      auctionTitle: json['auction_title']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      vehicleDetails: VehicleListing.fromJson(vd),
      winningBidAmount: _asInt(json['winning_bid_amount']),
      bidCount: _asInt(json['bid_count']),
      paymentStatus: json['payment_status']?.toString() ?? '',
      winningLetterStatus: json['winning_letter_status']?.toString() ?? '',
      auctionStatus: json['auction_status']?.toString() ?? '',
      auctionEndTime: json['auction_end_time']?.toString() ?? '',
      bidApprovedAt: json['bid_approved_at']?.toString() ?? '',
      paymentReference: json['payment_reference']?.toString() ?? '',
      userAuctionStatus: json['user_auction_status']?.toString() ?? '',
    );
  }

  bool get isPaid =>
      paymentStatus.toLowerCase() == 'done' ||
      paymentStatus.toLowerCase() == 'paid';
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination metadata (reused for both)
// ─────────────────────────────────────────────────────────────────────────────

class BidsWinsPagination {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;

  const BidsWinsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory BidsWinsPagination.empty() => const BidsWinsPagination(
    currentPage: 1,
    totalPages: 1,
    totalCount: 0,
    hasNext: false,
    hasPrevious: false,
  );

  factory BidsWinsPagination.fromJson(Map<String, dynamic> json) =>
      BidsWinsPagination(
        currentPage: _asInt(json['current_page'], 1),
        totalPages: _asInt(json['total_pages'], 1),
        totalCount: _asInt(json['total_count']),
        hasNext: _asBool(json['has_next']),
        hasPrevious: _asBool(json['has_previous']),
      );
}

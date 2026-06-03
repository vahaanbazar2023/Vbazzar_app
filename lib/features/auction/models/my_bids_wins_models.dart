import 'vehicle_listing.dart';

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
      bidId: (json['bid_id'] as num?)?.toInt() ?? 0,
      auctionId: json['auction_id'] as String? ?? '',
      auctionTitle: json['auction_title'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      vehicleDetails: VehicleListing.fromJson(vd),
      userBidAmount: (json['user_bid_amount'] as num?)?.toInt() ?? 0,
      userBidCount: (json['user_bid_count'] as num?)?.toInt() ?? 0,
      currentHighestBid: (json['current_highest_bid'] as num?)?.toInt() ?? 0,
      bidStatus: json['bid_status'] as String? ?? '',
      auctionStatus: json['auction_status'] as String? ?? '',
      auctionEndTime: json['auction_end_time'] as String? ?? '',
      bidPlacedAt: json['bid_placed_at'] as String? ?? '',
      lastUpdatedAt: json['last_updated_at'] as String? ?? '',
      userAuctionStatus: json['user_auction_status'] as String? ?? '',
      isAuctionActive: json['is_auction_active'] as bool? ?? false,
    );
  }

  bool get isWinning => userBidAmount > 0 && userBidAmount >= currentHighestBid;
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
      bidId: (json['bid_id'] as num?)?.toInt() ?? 0,
      auctionId: json['auction_id'] as String? ?? '',
      auctionTitle: json['auction_title'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      vehicleDetails: VehicleListing.fromJson(vd),
      winningBidAmount: (json['winning_bid_amount'] as num?)?.toInt() ?? 0,
      bidCount: (json['bid_count'] as num?)?.toInt() ?? 0,
      paymentStatus: json['payment_status'] as String? ?? '',
      winningLetterStatus: json['winning_letter_status'] as String? ?? '',
      auctionStatus: json['auction_status'] as String? ?? '',
      auctionEndTime: json['auction_end_time'] as String? ?? '',
      bidApprovedAt: json['bid_approved_at'] as String? ?? '',
      paymentReference: json['payment_reference'] as String? ?? '',
      userAuctionStatus: json['user_auction_status'] as String? ?? '',
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
        currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
        totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
        totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
        hasNext: json['has_next'] as bool? ?? false,
        hasPrevious: json['has_previous'] as bool? ?? false,
      );
}

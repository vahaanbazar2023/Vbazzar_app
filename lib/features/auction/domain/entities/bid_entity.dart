/// Domain entity for a placed bid.
class BidEntity {
  final String bidId;
  final String vehicleId;
  final String auctionId;
  final int bidAmount;
  final String bidStatus;

  const BidEntity({
    required this.bidId,
    required this.vehicleId,
    required this.auctionId,
    required this.bidAmount,
    required this.bidStatus,
  });
}

/// Domain entity for a user's bid.
class MyBidEntity {
  final String bidId;
  final String vehicleId;
  final String auctionId;
  final int bidAmount;
  final String bidStatus;
  final String vehicleName;
  final String? make;
  final String? model;
  final String? manufacturingYear;
  final String? auctionName;
  final String? bidDate;

  const MyBidEntity({
    required this.bidId,
    required this.vehicleId,
    required this.auctionId,
    required this.bidAmount,
    required this.bidStatus,
    required this.vehicleName,
    this.make,
    this.model,
    this.manufacturingYear,
    this.auctionName,
    this.bidDate,
  });
}

/// Domain entity for a user's auction win.
class MyWinEntity {
  final String winId;
  final String vehicleId;
  final String auctionId;
  final int winAmount;
  final String vehicleName;
  final String? make;
  final String? model;
  final String? manufacturingYear;
  final String? auctionName;
  final String? winDate;
  final bool insuranceInterest;

  const MyWinEntity({
    required this.winId,
    required this.vehicleId,
    required this.auctionId,
    required this.winAmount,
    required this.vehicleName,
    this.make,
    this.model,
    this.manufacturingYear,
    this.auctionName,
    this.winDate,
    this.insuranceInterest = false,
  });
}

/// Exception thrown when a bid operation fails.
class BidException implements Exception {
  final String message;
  final String code;

  const BidException(this.message, this.code);

  @override
  String toString() => 'BidException[$code]: $message';
}
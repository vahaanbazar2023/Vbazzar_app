import '../../domain/entities/bid_entity.dart';

/// Data model for [BidEntity] – handles JSON serialization.
class BidModel extends BidEntity {
  const BidModel({
    required super.bidId,
    required super.vehicleId,
    required super.auctionId,
    required super.bidAmount,
    required super.bidStatus,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      bidId: json['bid_id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      auctionId: json['auction_id']?.toString() ?? '',
      bidAmount: (json['bid_amount'] as num?)?.toInt() ?? 0,
      bidStatus: json['bid_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bid_id': bidId,
      'vehicle_id': vehicleId,
      'auction_id': auctionId,
      'bid_amount': bidAmount,
      'bid_status': bidStatus,
    };
  }
}

/// Data model for [MyBidEntity].
class MyBidModel extends MyBidEntity {
  const MyBidModel({
    required super.bidId,
    required super.vehicleId,
    required super.auctionId,
    required super.bidAmount,
    required super.bidStatus,
    required super.vehicleName,
    super.make,
    super.model,
    super.manufacturingYear,
    super.auctionName,
    super.bidDate,
  });

  factory MyBidModel.fromJson(Map<String, dynamic> json) {
    return MyBidModel(
      bidId: json['bid_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      bidAmount: (json['bid_amount'] as num?)?.toInt() ?? 0,
      bidStatus: json['bid_status'] as String? ?? '',
      vehicleName: json['vehicle_name'] as String? ?? '',
      make: json['make'] as String?,
      model: json['model'] as String?,
      manufacturingYear: json['manufacturing_year'] as String?,
      auctionName: json['auction_name'] as String?,
      bidDate: json['bid_date'] as String?,
    );
  }
}

/// Data model for [MyWinEntity].
class MyWinModel extends MyWinEntity {
  const MyWinModel({
    required super.winId,
    required super.vehicleId,
    required super.auctionId,
    required super.winAmount,
    required super.vehicleName,
    super.make,
    super.model,
    super.manufacturingYear,
    super.auctionName,
    super.winDate,
    super.insuranceInterest,
  });

  factory MyWinModel.fromJson(Map<String, dynamic> json) {
    return MyWinModel(
      winId: json['win_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      winAmount: (json['win_amount'] as num?)?.toInt() ?? 0,
      vehicleName: json['vehicle_name'] as String? ?? '',
      make: json['make'] as String?,
      model: json['model'] as String?,
      manufacturingYear: json['manufacturing_year'] as String?,
      auctionName: json['auction_name'] as String?,
      winDate: json['win_date'] as String?,
      insuranceInterest: json['insurance_interest'] as bool? ?? false,
    );
  }
}

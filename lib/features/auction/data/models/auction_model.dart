import '../../domain/entities/auction_entity.dart';

/// Data model for [RegionEntity].
class RegionModel extends RegionEntity {
  const RegionModel({
    required super.regionId,
    required super.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      regionId: json['region_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// Data model for [StateByRegionEntity].
class StateByRegionModel extends StateByRegionEntity {
  const StateByRegionModel({
    required super.stateId,
    required super.stateName,
    required super.regionId,
  });

  factory StateByRegionModel.fromJson(Map<String, dynamic> json) {
    return StateByRegionModel(
      stateId: json['state_id'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      regionId: json['region_id'] as String? ?? '',
    );
  }
}

/// Data model for [AuctionEntity] – handles JSON serialization.
class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required super.auctionId,
    required super.auctionType,
    required super.categoryType,
    required super.vehicleType,
    required super.auctionName,
    required super.startDate,
    required super.endDate,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.totalVehicles,
    super.regionId,
    super.stateId,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      auctionId: json['auction_id'] as String? ?? '',
      auctionType: json['auction_type'] as String? ?? '',
      categoryType: json['category_type'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      auctionName: json['auction_name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalVehicles: (json['total_vehicles'] as num?)?.toInt() ?? 0,
      regionId: json['region_id'] as String?,
      stateId: json['state_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auction_id': auctionId,
      'auction_type': auctionType,
      'category_type': categoryType,
      'vehicle_type': vehicleType,
      'auction_name': auctionName,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'total_vehicles': totalVehicles,
      'region_id': regionId,
      'state_id': stateId,
    };
  }
}
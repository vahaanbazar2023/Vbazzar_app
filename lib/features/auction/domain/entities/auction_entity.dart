/// Domain entity representing an auction listing.
class AuctionEntity {
  final String auctionId;
  final String auctionType;
  final String categoryType;
  final String vehicleType;
  final String auctionName;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String status;
  final int totalVehicles;
  final String? regionId;
  final String? stateId;

  const AuctionEntity({
    required this.auctionId,
    required this.auctionType,
    required this.categoryType,
    required this.vehicleType,
    required this.auctionName,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalVehicles,
    this.regionId,
    this.stateId,
  });
}

/// Pagination metadata from API responses.
class PaginationEntity {
  final int totalCount;
  final int page;
  final int limit;
  final bool hasNext;

  const PaginationEntity({
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasNext,
  });
}

/// Region entity for auction filter.
class RegionEntity {
  final String regionId;
  final String name;

  const RegionEntity({
    required this.regionId,
    required this.name,
  });
}

/// State by region entity for auction filter.
class StateByRegionEntity {
  final String stateId;
  final String stateName;
  final String regionId;

  const StateByRegionEntity({
    required this.stateId,
    required this.stateName,
    required this.regionId,
  });
}
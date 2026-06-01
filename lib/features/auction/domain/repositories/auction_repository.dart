import '../entities/auction_entity.dart';
import '../entities/bid_entity.dart';
import '../entities/vehicle_listing_entity.dart';

/// Abstract repository interface for auction-related data operations.
///
/// Implemented by [AuctionRepositoryImpl] in the data layer.
abstract class AuctionRepository {
  /// Fetch paginated auction listings.
  Future<({List<AuctionEntity> auctions, PaginationEntity pagination})>
      fetchAuctionListings({
    required String userId,
    required String auctionType,
    String categoryType = '',
    String vehicleType = '',
    String regionId = '',
    String stateId = '',
    int page = 1,
    int limit = 10,
  });

  /// Fetch paginated vehicle listings for a given auction.
  Future<({List<VehicleListingEntity> vehicles, PaginationEntity pagination})>
      fetchVehicleListings({
    required String userId,
    required String auctionId,
    int page = 1,
    int limit = 10,
    String searchValue = '',
    String categoryType = '',
    String stateCode = '',
    String cityCode = '',
    int? minPrice,
    int? maxPrice,
    int? yearFrom,
    int? yearTo,
  });

  /// Place a bid on a vehicle in an auction.
  Future<BidEntity> placeBid({
    required String userId,
    required String vehicleId,
    required String auctionId,
    required int bidAmount,
  });

  /// Fetch the current user's bids.
  Future<({List<MyBidEntity> bids, PaginationEntity pagination})> fetchMyBids({
    required String userId,
    int page = 1,
    int limit = 10,
  });

  /// Fetch the current user's auction wins.
  Future<({List<MyWinEntity> wins, PaginationEntity pagination})> fetchMyWins({
    required String userId,
    int page = 1,
    int limit = 10,
  });

  /// Download the winning letter PDF bytes.
  Future<List<int>> downloadWinningLetter({
    required String winId,
    required String vehicleId,
    required String auctionId,
  });

  /// Update insurance interest for a won vehicle.
  Future<bool> updateInsuranceInterest({
    required String vehicleId,
    required String auctionId,
    required bool insuranceInterest,
  });

  /// Fetch all regions.
  Future<List<RegionEntity>> fetchRegions();

  /// Fetch states for a given region.
  Future<List<StateByRegionEntity>> fetchStatesByRegion({
    required String regionId,
  });

  /// Search vehicles by keyword within an auction.
  Future<List<VehicleListingEntity>> searchVehicles({
    required String searchValue,
    required String auctionId,
  });

  /// Initiate a refund for auction deposit.
  Future<bool> initiateRefund({
    required String userId,
    required String accHolderName,
    required String accountNumber,
    required String bankName,
    required String branchName,
    required String ifscCode,
  });

  /// Download vehicle Excel for an auction.
  Future<List<int>> downloadVehicleExcel({
    required String auctionId,
    String categoryType = '',
    String stateCode = '',
  });
}
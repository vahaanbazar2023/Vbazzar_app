import 'package:dio/dio.dart' as dio;
import '../../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../entities/approved_vehicle_category_entity.dart';
import '../entities/approved_vehicle_listing_entity.dart';
import '../entities/auction_vehicle_match.dart';

/// Contract for the Approved Vehicles data layer.
///
/// Implementations live in the `data` layer and talk to the
/// remote API (or local cache in the future).
abstract class ApprovedVehicleRepository {
  // ── Categories ──────────────────────────────────────────────

  Future<PaginatedCategoriesResult> getCategories({
    required String userId,
    String status = 'Active',
    int page = 1,
    int limit = 100,
  });

  // ── Listings ────────────────────────────────────────────────

  Future<PaginatedListingsResult> getListings({
    required String userId,
    String status = 'approved',
    String categoryType = '',
    String stateCode = '',
    String cityCode = '',
    double? minPrice,
    double? maxPrice,
    int? yearFrom,
    int? yearTo,
    String searchRegistration = '',
    int page = 1,
    int limit = 20,
  });

  /// One listing by its approved vehicle id (AVEH...), or null if not found.
  /// Used to open a shared link.
  Future<ApprovedVehicleListingEntity?> getListingByVehicleId({
    required String userId,
    required String approvedVehicleId,
  });

  // ── User Interest ───────────────────────────────────────────

  Future<UserInterestResult> updateUserInterest({
    required String userId,
    required String approvedVehicleId,
    required String isInterested,
    required String isBooked,
  });

  // ── User Booked / Inspected Vehicles ────────────────────────

  Future<PaginatedListingsResult> getUserBookedVehicles({
    required String userId,
    String? bookedVehicles,
    String? inspectionRequested,
    int page = 1,
    int limit = 20,
  });

  // ── Auction lookup (sell form prefill) ─────────────────────

  /// The vehicle with this registration number in our auction listings, or
  /// null when there is none.
  Future<AuctionVehicleMatch?> findAuctionVehicle({
    required String userId,
    required String registrationNumber,
  });

  // ── Submit Vehicle ──────────────────────────────────────────

  /// Submits the sell form. Throws [SubmitVehicleRejected] with the server's
  /// own message when it refuses (validation, wrong file, not a vendor…).
  Future<void> submitVehicle(dio.FormData formData);
}

/// The server refused a sell form; [message] is its exact reason.
class SubmitVehicleRejected implements Exception {
  final String message;
  const SubmitVehicleRejected(this.message);

  @override
  String toString() => message;
}

/// Typed result for paginated categories.
class PaginatedCategoriesResult {
  final List<ApprovedVehicleCategoryEntity> categories;
  final int totalCount;

  const PaginatedCategoriesResult({
    required this.categories,
    required this.totalCount,
  });
}

/// Typed result for paginated listings.
class PaginatedListingsResult {
  final List<ApprovedVehicleListingEntity> listings;
  final List<ListingAd> ads;
  final int totalCount;

  const PaginatedListingsResult({
    required this.listings,
    this.ads = const [],
    required this.totalCount,
  });
}

/// Typed result for user interest update.
class UserInterestResult {
  final int subscriptionId;
  final String approvedVehicleId;
  final String userId;
  final String inspectionRequested;
  final String isBooked;
  final String status;

  const UserInterestResult({
    required this.subscriptionId,
    required this.approvedVehicleId,
    required this.userId,
    required this.inspectionRequested,
    required this.isBooked,
    required this.status,
  });
}

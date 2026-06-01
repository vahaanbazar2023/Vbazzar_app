import 'dart:io';
import '../entities/vehicle_category_entity.dart';
import '../entities/vehicle_brand_entity.dart';
import '../entities/vehicle_tire_entity.dart';
import '../entities/subscribed_vehicle_entity.dart';
import '../entities/sell_vehicle_entity.dart';
import '../entities/filter_option_entity.dart';
import '../entities/paginated_buy_vehicles_response.dart';
import '../entities/paginated_subscribed_vehicles_response.dart';
import '../entities/paginated_sell_vehicles_response.dart';

abstract class BuySellRepository {
  /// Fetches vehicle categories for the buy & sell landing page
  Future<List<VehicleCategoryEntity>> getVehicleCategories({String? userId});

  /// Fetches vehicle brands for a given category
  Future<List<VehicleBrandEntity>> getVehicleBrands({
    required String categoryCode,
    String? userId,
  });

  /// Fetches tyre options
  Future<List<VehicleTireEntity>> getTyres({String? userId});

  /// Fetches vehicles filtered by category and dynamic filters
  Future<Map<String, dynamic>> getVehiclesByFilters({
    required String categoryCode,
    String? userId,
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 10,
  });

  /// Fetches dynamic filter options for a given category
  Future<Map<String, FilterConfigEntity>> getVehicleCategoryFilters({
    required String categoryCode,
    String? userId,
  });

  /// Fetches subscribed vehicles
  Future<List<SubscribedVehicleEntity>> getSubscribedVehicles({String? userId});

  /// Fetches vehicles the user is selling
  Future<List<SellVehicleEntity>> getSellVehicles({String? userId});

  /// Submits a vehicle for sale
  Future<Map<String, dynamic>> sellVehicle({
    required Map<String, dynamic> vehicleData,
    String? userId,
  });

  /// Registers user interest for a vehicle
  Future<Map<String, dynamic>> userInterest({
    required String vehicleId,
    String? userId,
  });

  // ─── New methods used by controllers ──────────────────────

  /// Fetches category filter options (raw map for controller consumption)
  Future<Map<String, dynamic>> getCategoryFilters({
    required String categoryCode,
    required String userId,
  });

  /// Lists vehicles by category with pagination and optional filters
  Future<PaginatedBuyVehiclesResponse> listVehiclesByCategoryFilters({
    required String userId,
    required String categoryCode,
    required int limit,
    required int page,
    Map<String, dynamic>? filters,
  });

  /// Lists subscribed vehicles with pagination
  Future<PaginatedSubscribedVehiclesResponse> listSubscribedVehicles({
    required String userId,
    required int limit,
    required int page,
  });

  /// Lists sell vehicles with pagination
  Future<PaginatedSellVehiclesResponse> listSellVehicles({
    required String userId,
    required int limit,
    required int page,
  });

  /// Fetches dynamic form fields for a category
  Future<List<FormFieldConfigEntity>> getFormFieldsByCategory({
    required String categoryCode,
  });

  /// Creates a new sell vehicle listing
  Future<void> createSellVehicle({
    required String userId,
    required String categoryCode,
    required String brandCode,
    required String assetDescOrModel,
    required String registrationNumber,
    required int manufacturingYear,
    required String chassisNumber,
    required double price,
    required String ownerMobile,
    required String stateCode,
    required String cityCode,
    List<File>? vehicleImages,
    File? rcDocument,
    File? insuranceDocument,
    dynamic odometer,
    dynamic noOfTyres,
    bool fitness = false,
    dynamic insurance,
    bool originalInvoice = false,
    bool gstApplicability = false,
    dynamic tonnage,
    dynamic hours,
    dynamic bodyType,
    dynamic fuelType,
    dynamic kv,
    dynamic otherBrand,
    dynamic otherTipper,
    dynamic otherBodyType,
    dynamic otherTyre,
  });

  /// Updates an existing sell vehicle listing
  Future<void> updateSellVehicle({
    required String sbVehicleId,
    required String userId,
    required String categoryCode,
    required String brandCode,
    required String assetDescOrModel,
    required String registrationNumber,
    required int manufacturingYear,
    required String chassisNumber,
    required double price,
    required String ownerMobile,
    required String stateCode,
    required String cityCode,
    List<File>? vehicleImages,
    File? rcDocument,
    File? insuranceDocument,
    dynamic odometer,
    dynamic noOfTyres,
    bool fitness = false,
    dynamic insurance,
    bool originalInvoice = false,
    bool gstApplicability = false,
    dynamic tonnage,
    dynamic hours,
    dynamic bodyType,
    dynamic fuelType,
    dynamic kv,
    dynamic otherBrand,
    dynamic otherTipper,
    dynamic otherBodyType,
    dynamic otherTyre,
  });

  /// Updates the sold status of a vehicle
  Future<void> updateVehicleSoldStatus({
    required String sbVehicleId,
    required String isSold,
    required String userId,
  });
}
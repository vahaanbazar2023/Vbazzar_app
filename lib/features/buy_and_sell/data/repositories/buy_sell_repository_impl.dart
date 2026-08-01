import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/network_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/repositories/buy_sell_repository.dart';
import '../../domain/entities/vehicle_category_entity.dart';
import '../../domain/entities/vehicle_brand_entity.dart';
import '../../domain/entities/vehicle_tire_entity.dart';
import '../../domain/entities/subscribed_vehicle_entity.dart';
import '../../domain/entities/sell_vehicle_entity.dart';
import '../../domain/entities/filter_option_entity.dart';
import '../../domain/entities/paginated_buy_vehicles_response.dart';
import '../../domain/entities/paginated_subscribed_vehicles_response.dart';
import '../../domain/entities/paginated_sell_vehicles_response.dart';
import '../models/vehicle_category_model.dart';
import '../models/vehicle_brand_model.dart';
import '../models/vehicle_tire_model.dart';
import '../models/subscribed_vehicle_model.dart';
import '../models/sell_vehicle_model.dart';
import '../models/buy_vehicle_model.dart';
import '../models/filter_option_model.dart';

class BuySellRepositoryImpl implements BuySellRepository {
  final NetworkService _network = NetworkService.to;

  Future<String?> _getUserId() async {
    try {
      return await SecureStorageService.to.read(StorageKeys.userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<VehicleCategoryEntity>> getVehicleCategories({
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.post(
        ApiEndpoints.vehicleCategories,
        data: {if (uid != null) 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        print('🔵 getVehicleCategories runtimeType: ${raw.runtimeType}');
        print('🔵 getVehicleCategories full: $raw');

        List<dynamic> categories = [];

        if (raw is List) {
          // Response is a bare list
          categories = raw;
        } else if (raw is Map<String, dynamic>) {
          final dataField = raw['data'];
          final resultField = raw['result'];
          final categoriesField = raw['categories'];

          if (dataField is List) {
            categories = dataField;
          } else if (dataField is Map) {
            final inner = dataField as Map<String, dynamic>;
            categories =
                inner['categories'] as List<dynamic>? ??
                inner['data'] as List<dynamic>? ??
                inner['items'] as List<dynamic>? ??
                [];
          } else if (resultField is List) {
            categories = resultField;
          } else if (categoriesField is List) {
            categories = categoriesField;
          }
        }

        print('🔵 getVehicleCategories parsed ${categories.length} items');
        if (categories.isNotEmpty) {
          return categories
              .map(
                (json) =>
                    VehicleCategoryModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ getVehicleCategories error: ${e.message}');
      return [];
    }
  }

  @override
  Future<List<VehicleBrandEntity>> getVehicleBrands({
    required String categoryCode,
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.post(
        ApiEndpoints.vehicleBrands,
        data: {
          'category_code': categoryCode,
          if (uid != null) 'user_id': uid,
          'status': 'active',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        // API returns: { "brands": [...], "total_count": N, "category_code": "..." }
        // or wrapped: { "status": "success", "data": { ... } }
        List<dynamic> brands = [];
        if (data is Map<String, dynamic>) {
          if (data['brands'] is List) {
            brands = data['brands'] as List<dynamic>;
          } else if (data['data'] is Map<String, dynamic> &&
              (data['data'] as Map)['brands'] is List) {
            brands = (data['data'] as Map)['brands'] as List<dynamic>;
          } else if (data['data'] is List) {
            brands = data['data'] as List<dynamic>;
          }
        }
        return brands
            .map(
              (json) =>
                  VehicleBrandModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ getVehicleBrands error: ${e.message}');
      return [];
    }
  }

  @override
  Future<List<VehicleTireEntity>> getTyres({String? userId}) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.get(
        ApiEndpoints.vehicleTyres,
        queryParameters: {if (uid != null) 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> tyres = data['data'] is List ? data['data'] : [];
          return tyres
              .map(
                (json) =>
                    VehicleTireModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ getTyres error: ${e.message}');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getVehiclesByFilters({
    required String categoryCode,
    String? userId,
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 10,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final body = <String, dynamic>{
        'category_code': categoryCode,
        'page': page,
        'limit': limit,
        if (uid != null) 'user_id': uid,
      };
      if (filters != null) {
        body.addAll(filters);
      }
      final response = await _network.post(
        ApiEndpoints.vehicleCategoryListByFilters,
        data: body,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } on DioException catch (e) {
      print('❌ getVehiclesByFilters error: ${e.message}');
      return {};
    }
  }

  @override
  Future<Map<String, FilterConfigEntity>> getVehicleCategoryFilters({
    required String categoryCode,
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final body = <String, dynamic>{
        'category_code': categoryCode,
        if (uid != null) 'user_id': uid,
      };
      final response = await _network.post(
        ApiEndpoints.vehicleCategoryFilters,
        data: body,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final filterOptions =
              data['data']['filter_options'] as Map<String, dynamic>? ?? {};
          final result = <String, FilterConfigEntity>{};
          filterOptions.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              result[key] = FilterConfigModel.fromJson(key, value);
            }
          });
          return result;
        }
      }
      return {};
    } on DioException catch (e) {
      print('❌ getVehicleCategoryFilters error: ${e.message}');
      return {};
    }
  }

  @override
  Future<List<SubscribedVehicleEntity>> getSubscribedVehicles({
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.get(
        ApiEndpoints.listBuySubscribedVehicles,
        queryParameters: {if (uid != null) 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> items = data['data'] is List ? data['data'] : [];
          return items
              .map(
                (json) => SubscribedVehicleModel.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ getSubscribedVehicles error: ${e.message}');
      return [];
    }
  }

  @override
  Future<List<SellVehicleEntity>> getSellVehicles({String? userId}) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.post(
        ApiEndpoints.listSellVehicles,
        data: {if (uid != null) 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> items = data['data'] is List ? data['data'] : [];
          return items
              .map(
                (json) =>
                    SellVehicleModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ getSellVehicles error: ${e.message}');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> sellVehicle({
    required Map<String, dynamic> vehicleData,
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final body = Map<String, dynamic>.from(vehicleData);
      if (uid != null) body['user_id'] = uid;
      final response = await _network.post(
        ApiEndpoints.sellVehicle,
        data: body,
      );
      return response.data as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      print('❌ sellVehicle error: ${e.message}');
      return {'status': 'error', 'message': e.message};
    }
  }

  @override
  Future<Map<String, dynamic>> userInterest({
    required String vehicleId,
    String? userId,
    int? vehicleOffer,
    String? isInterested,
    String? ownerDetailsAccess,
    String? vehicleDetailsAccess,
    String? inspectionRequest,
  }) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _network.post(
        ApiEndpoints.userInterest,
        data: {
          'user_id': uid ?? '',
          'vehicle_id': vehicleId,
          'vehicle_offer': vehicleOffer,
          'is_interested': isInterested ?? '',
          'owner_details_access': ownerDetailsAccess ?? '',
          'vehicle_details_access': vehicleDetailsAccess ?? '',
          'inspection_request': inspectionRequest ?? '',
        },
      );
      return response.data as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      print('❌ userInterest error: ${e.message}');
      // Return structured error so caller can handle offer validation
      if (e.response != null) {
        return e.response!.data as Map<String, dynamic>? ??
            {'status': 'error', 'message': e.message};
      }
      return {'status': 'error', 'message': e.message};
    }
  }

  // ─── New methods ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getCategoryFilters({
    required String categoryCode,
    required String userId,
  }) async {
    try {
      final body = <String, dynamic>{
        'category_code': categoryCode,
        'user_id': userId,
      };
      final response = await _network.post(
        ApiEndpoints.vehicleCategoryFilters,
        data: body,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } on DioException catch (e) {
      print('❌ getCategoryFilters error: ${e.message}');
      return {};
    }
  }

  @override
  Future<PaginatedBuyVehiclesResponse> listVehiclesByCategoryFilters({
    required String userId,
    required String categoryCode,
    required int limit,
    required int page,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final body = <String, dynamic>{
        'category_code': categoryCode,
        'page': page,
        'limit': limit,
        'user_id': userId,
      };
      if (filters != null && filters.isNotEmpty) {
        body.addAll(filters);
      }
      final response = await _network.post(
        ApiEndpoints.vehicleCategoryListByFilters,
        data: body,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final resultData = data['data'] as Map<String, dynamic>;
          final List<dynamic> items = resultData['vehicles'] is List
              ? resultData['vehicles']
              : resultData['data'] is List
              ? resultData['data']
              : [];
          final vehicles = items
              .map(
                (json) =>
                    BuyVehicleModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          final totalPages = _parseInt(
            resultData['total_pages'] ?? resultData['totalPages'] ?? 1,
          );
          final totalCount = _parseInt(
            resultData['total_count'] ?? resultData['totalCount'] ?? 0,
          );
          final currentPage = _parseInt(
            resultData['current_page'] ?? resultData['currentPage'] ?? page,
          );
          return PaginatedBuyVehiclesResponse(
            vehicles: vehicles,
            totalPages: totalPages,
            totalCount: totalCount,
            currentPage: currentPage,
            hasMore: currentPage < totalPages,
          );
        }
      }
      return PaginatedBuyVehiclesResponse(
        vehicles: [],
        totalPages: 1,
        totalCount: 0,
        currentPage: page,
        hasMore: false,
      );
    } on DioException catch (e) {
      print('❌ listVehiclesByCategoryFilters error: ${e.message}');
      throw Exception('Failed to load vehicles: ${e.message}');
    }
  }

  @override
  Future<PaginatedSubscribedVehiclesResponse> listSubscribedVehicles({
    required String userId,
    required int limit,
    required int page,
  }) async {
    try {
      final response = await _network.post(
        ApiEndpoints.listBuySubscribedVehicles,
        data: {'user_id': userId, 'page': page, 'limit': limit},
      );
      print('📤 listSubscribedVehicles request data: user_id=$userId, page=$page, limit=$limit');
      print('🔵 listSubscribedVehicles raw response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final resultData = data['data'];
          List<dynamic> items = [];
          int totalPages = 1, totalCount = 0, currentPageVal = page;

          if (resultData is Map<String, dynamic>) {
            items = resultData['vehicles'] is List
                ? resultData['vehicles']
                : [];
            // New API uses data.pagination object
            final pagination =
                resultData['pagination'] as Map<String, dynamic>?;
            if (pagination != null) {
              totalPages = _parseInt(pagination['total_pages'] ?? 1);
              totalCount = _parseInt(pagination['total_count'] ?? 0);
              currentPageVal = _parseInt(pagination['page'] ?? page);
            } else {
              totalPages = _parseInt(
                resultData['total_pages'] ?? resultData['totalPages'] ?? 1,
              );
              totalCount = _parseInt(
                resultData['total_count'] ?? resultData['totalCount'] ?? 0,
              );
              currentPageVal = _parseInt(
                resultData['current_page'] ?? resultData['currentPage'] ?? page,
              );
            }
          } else if (resultData is List) {
            items = resultData;
            totalCount = items.length;
          }

          final vehicles = items
              .map(
                (json) => SubscribedVehicleModel.fromJson(
                  json as Map<String, dynamic>,
                ),
              )
              .toList();
          return PaginatedSubscribedVehiclesResponse(
            vehicles: vehicles,
            totalPages: totalPages,
            totalCount: totalCount,
            currentPage: currentPageVal,
            hasMore: currentPageVal < totalPages,
          );
        }
      }
      return PaginatedSubscribedVehiclesResponse(
        vehicles: [],
        totalPages: 1,
        totalCount: 0,
        currentPage: page,
        hasMore: false,
      );
    } on DioException catch (e) {
      print('❌ listSubscribedVehicles error: ${e.message}');
      throw Exception('Failed to load subscribed vehicles: ${e.message}');
    }
  }

  @override
  Future<PaginatedSellVehiclesResponse> listSellVehicles({
    required String userId,
    required int limit,
    required int page,
  }) async {
    try {
      final response = await _network.post(
        ApiEndpoints.listSellVehicles,
        data: {'user_id': userId, 'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final resultData = data['data'];
          List<dynamic> items;
          int totalPages, totalCount, currentPageVal;

          if (resultData is Map<String, dynamic>) {
            items = resultData['vehicles'] is List
                ? resultData['vehicles']
                : resultData['data'] is List
                ? resultData['data']
                : [];
            totalPages = _parseInt(
              resultData['total_pages'] ?? resultData['totalPages'] ?? 1,
            );
            totalCount = _parseInt(
              resultData['total_count'] ?? resultData['totalCount'] ?? 0,
            );
            currentPageVal = _parseInt(
              resultData['current_page'] ?? resultData['currentPage'] ?? page,
            );
          } else if (resultData is List) {
            items = resultData;
            totalPages = 1;
            totalCount = items.length;
            currentPageVal = 1;
          } else {
            items = [];
            totalPages = 1;
            totalCount = 0;
            currentPageVal = page;
          }

          final vehicles = items
              .map(
                (json) =>
                    SellVehicleModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return PaginatedSellVehiclesResponse(
            vehicles: vehicles,
            totalPages: totalPages,
            totalCount: totalCount,
            currentPage: currentPageVal,
            hasMore: currentPageVal < totalPages,
          );
        }
      }
      return PaginatedSellVehiclesResponse(
        vehicles: [],
        totalPages: 1,
        totalCount: 0,
        currentPage: page,
        hasMore: false,
      );
    } on DioException catch (e) {
      print('❌ listSellVehicles error: ${e.message}');
      throw Exception('Failed to load sell vehicles: ${e.message}');
    }
  }

  @override
  Future<List<FormFieldConfigEntity>> getFormFieldsByCategory({
    required String categoryCode,
  }) async {
    final uid = await _getUserId();
    try {
      final response = await _network.post(
        ApiEndpoints.vehicleCategoryFormFields,
        data: {'category_code': categoryCode, if (uid != null) 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final dataMap = data['data'] as Map<String, dynamic>;
          // API returns: { "category_code": "...", "form_fields": { "Field Label": { "type": "text", "mandatory": true, ... } } }
          final formFieldsMap = dataMap['form_fields'] as Map<String, dynamic>?;
          if (formFieldsMap == null) return [];

          return formFieldsMap.entries.map((entry) {
            final fieldLabel = entry.key;
            final fieldDef = entry.value as Map<String, dynamic>? ?? {};
            final fieldType = fieldDef['type']?.toString() ?? 'text';
            final mandatory = fieldDef['mandatory'] == true;
            final source = fieldDef['source']?.toString();
            final rawOptions = fieldDef['options'];
            final List<String>? options = rawOptions is List
                ? rawOptions.map((e) => e.toString()).toList()
                : null;

            return FormFieldConfigModel(
              fieldName: fieldLabel,
              fieldType: fieldType,
              required: mandatory,
              options: options,
              placeholder: null,
              defaultValue: null,
              validationRegex: null,
              // Store source and extra metadata in apiFieldName for UI use
              apiFieldName: source != null ? 'source:$source' : null,
            );
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ getFormFieldsByCategory error: ${e.message}');
      return [];
    }
  }

  @override
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
    dynamic bodyLength,
    dynamic fuelType,
    dynamic insuranceDates,
    dynamic kv,
    dynamic otherBrand,
    dynamic otherTipper,
    dynamic otherBodyType,
    dynamic otherTyre,
  }) async {
    try {
      // Build JSON data using proper field mapping (matching SellVehicleRequest.toJson)
      final jsonData = <String, dynamic>{
        'user_id': userId,
        'category_code': categoryCode,
        'brand_code': brandCode,
        'asset_desc_or_model': assetDescOrModel,
        'registration_number': registrationNumber,
        'manufacturing_year': manufacturingYear,
        'price': price,
        'owner_mobile': ownerMobile,
        'state_code': stateCode,
        'city_code': cityCode,
        'fitness': fitness,
        'original_invoice': originalInvoice,
        'gst_applicability': gstApplicability,
        'insurance': insurance == true,
      };

      // Add optional fields only if not null and not empty
      if (chassisNumber.isNotEmpty) jsonData['chassis_number'] = chassisNumber;
      if (odometer != null && odometer.toString().isNotEmpty) jsonData['odometer'] = odometer;
      if (noOfTyres != null && noOfTyres.toString().isNotEmpty) jsonData['no_of_tyres'] = noOfTyres;
      if (tonnage != null && tonnage.toString().isNotEmpty) jsonData['tonnage'] = tonnage;
      if (hours != null && hours.toString().isNotEmpty) jsonData['hours'] = hours;
      if (bodyType != null && bodyType.toString().isNotEmpty) jsonData['body_type'] = bodyType;
      if (bodyLength != null && bodyLength.toString().isNotEmpty) jsonData['body_length'] = bodyLength;
      if (fuelType != null && fuelType.toString().isNotEmpty) jsonData['fuel_type'] = fuelType;
      if (insuranceDates != null && insuranceDates.toString().isNotEmpty) jsonData['insurance_dates'] = insuranceDates;
      if (kv != null && kv.toString().isNotEmpty) jsonData['kv'] = kv;
      if (otherBrand != null && otherBrand.toString().isNotEmpty) jsonData['other_brand'] = otherBrand;
      if (otherTipper != null && otherTipper.toString().isNotEmpty) jsonData['other_tipper'] = otherTipper;
      if (otherBodyType != null && otherBodyType.toString().isNotEmpty) jsonData['other_body_type'] = otherBodyType;
      if (otherTyre != null && otherTyre.toString().isNotEmpty) jsonData['other_tyre'] = otherTyre;

      // Build FormData combining JSON data with file uploads
      final formDataMap = <String, dynamic>{...jsonData};

      if (vehicleImages != null && vehicleImages.isNotEmpty) {
        formDataMap['vehicle_images'] = vehicleImages
            .map(
              (f) => MultipartFile.fromFileSync(
                f.path,
                filename: f.path.split('/').last,
              ),
            )
            .toList();
      }
      if (rcDocument != null) {
        formDataMap['rc_document'] = MultipartFile.fromFileSync(
          rcDocument.path,
          filename: rcDocument.path.split('/').last,
        );
      }
      if (insuranceDocument != null) {
        formDataMap['insurance_document'] = MultipartFile.fromFileSync(
          insuranceDocument.path,
          filename: insuranceDocument.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      print('📤 [createSellVehicle] Sending data: $jsonData');
      print('📤 [createSellVehicle] Files - images:${vehicleImages?.length ?? 0}, rc:${rcDocument != null}, insurance:${insuranceDocument != null}');

      final response = await _network.post(
        ApiEndpoints.sellVehicle,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] != 'success') {
          throw Exception(data['message'] ?? 'Failed to create vehicle');
        }
      } else {
        throw Exception('Failed to create vehicle');
      }
    } on DioException catch (e) {
      print('❌ createSellVehicle error: ${e.message}');
      if (e.response != null) {
        print('❌ createSellVehicle response status: ${e.response?.statusCode}');
        print('❌ createSellVehicle response data: ${e.response?.data}');
        print('❌ createSellVehicle request data: ${e.requestOptions.data}');
      }
      throw Exception('Failed to create vehicle: ${e.response?.data ?? e.message}');
    }
  }

  @override
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
    dynamic bodyLength,
    dynamic fuelType,
    dynamic insuranceDates,
    dynamic kv,
    dynamic otherBrand,
    dynamic otherTipper,
    dynamic otherBodyType,
    dynamic otherTyre,
  }) async {
    try {
      final formData = FormData.fromMap({
        'sb_vehicle_id': sbVehicleId,
        'user_id': userId,
        'category_code': categoryCode,
        'brand_code': brandCode,
        'asset_desc_or_model': assetDescOrModel,
        'registration_number': registrationNumber,
        'manufacturing_year': manufacturingYear,
        'chassis_number': chassisNumber,
        'price': price,
        'owner_mobile': ownerMobile,
        'state_code': stateCode,
        'city_code': cityCode,
        'fitness': fitness,
        'original_invoice': originalInvoice,
        'gst_applicability': gstApplicability,
        if (odometer != null) 'odometer': odometer,
        if (noOfTyres != null) 'no_of_tyres': noOfTyres,
        if (insurance != null) 'insurance': insurance,
        if (insuranceDates != null) 'insurance_dates': insuranceDates,
        if (tonnage != null) 'tonnage': tonnage,
        if (hours != null) 'hours': hours,
        if (bodyType != null) 'body_type': bodyType,
        if (bodyLength != null) 'body_length': bodyLength,
        if (fuelType != null) 'fuel_type': fuelType,
        if (kv != null) 'kv': kv,
        if (otherBrand != null) 'other_brand': otherBrand,
        if (otherTipper != null) 'other_tipper': otherTipper,
        if (otherBodyType != null) 'other_body_type': otherBodyType,
        if (otherTyre != null) 'other_tyre': otherTyre,
        if (vehicleImages != null && vehicleImages.isNotEmpty)
          'vehicle_images': vehicleImages
              .map(
                (f) => MultipartFile.fromFileSync(
                  f.path,
                  filename: f.path.split('/').last,
                ),
              )
              .toList(),
        if (rcDocument != null)
          'rc_document': MultipartFile.fromFileSync(
            rcDocument.path,
            filename: rcDocument.path.split('/').last,
          ),
        if (insuranceDocument != null)
          'insurance_document': MultipartFile.fromFileSync(
            insuranceDocument.path,
            filename: insuranceDocument.path.split('/').last,
          ),
      });

      final response = await _network.post(
        ApiEndpoints.updateSellVehicles,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] != 'success') {
          throw Exception(data['message'] ?? 'Failed to update vehicle');
        }
      } else {
        throw Exception('Failed to update vehicle');
      }
    } on DioException catch (e) {
      print('❌ updateSellVehicle error: ${e.message}');
      throw Exception('Failed to update vehicle: ${e.message}');
    }
  }

  @override
  Future<void> updateVehicleSoldStatus({
    required String sbVehicleId,
    required String isSold,
    required String userId,
  }) async {
    try {
      final response = await _network.post(
        ApiEndpoints.sbVehicleSold,
        data: {
          'sb_vehicle_id': sbVehicleId,
          'is_sold': isSold,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] != 'success') {
          throw Exception(data['message'] ?? 'Failed to update sold status');
        }
      } else {
        throw Exception('Failed to update sold status');
      }
    } on DioException catch (e) {
      print('❌ updateVehicleSoldStatus error: ${e.message}');
      throw Exception('Failed to update sold status: ${e.message}');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

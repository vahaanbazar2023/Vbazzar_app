import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/network_service.dart';
import '../models/agent_inspection_request.dart';
import '../models/customer_inspection_request.dart';

/// Service layer for Inspection & Valuation API operations.
class InspectionService {
  final NetworkService _network;

  InspectionService({NetworkService? network})
      : _network = network ?? NetworkService.to;

  /// Fetch valuation dropdown options for forms (agent form only).
  Future<dio.Response> getValuationDropdownOptions({
    required String userId,
  }) async {
    return _network.get(
      ApiEndpoints.valuationDropdownOptions,
      queryParameters: {'user_id': userId},
    );
  }

  /// Fetch vehicle categories from buy-sell API (POST with user_id).
  Future<dio.Response> getVehicleCategories({required String userId}) async {
    return _network.post(
      ApiEndpoints.vehicleCategories,
      data: {'user_id': userId},
    );
  }

  /// Fetch vehicle brands from buy-sell API (POST with category_code + user_id).
  Future<dio.Response> getVehicleBrands({
    required String categoryCode,
    required String userId,
  }) async {
    return _network.post(
      ApiEndpoints.vehicleBrands,
      data: {
        'category_code': categoryCode,
        'user_id': userId,
        'status': 'active',
      },
    );
  }

  /// Fetch states from location API.
  Future<dio.Response> getStates() async {
    return _network.get(ApiEndpoints.states);
  }

  /// Fetch cities from location API filtered by state_id.
  Future<dio.Response> getCities({required String stateId}) async {
    return _network.get(
      ApiEndpoints.cities,
      queryParameters: {'state_id': stateId},
    );
  }

  /// Submit customer inspection form with multipart file uploads.
  Future<dio.Response> submitCustomerInspectionForm({
    required CustomerInspectionRequest request,
  }) async {
    final fields = request.toFields();
    final fileKeys = <String>[];

    // Build FormData manually to support multiple files with the same key
    final formData = dio.FormData.fromMap(fields);

    // RC files (required) — API expects 'rc_file' field name
    for (int i = 0; i < request.rcFiles.length; i++) {
      final file = request.rcFiles[i];
      if (file.path != null) {
        final key = 'rc_file[]';
        fileKeys.add(key);
        formData.files.add(
          MapEntry(
            key,
            await dio.MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    // Insurance files (optional) — API expects 'insurance_file' field name
    for (int i = 0; i < request.insuranceFiles.length; i++) {
      final file = request.insuranceFiles[i];
      if (file.path != null) {
        final key = 'insurance_file[]';
        fileKeys.add(key);
        formData.files.add(
          MapEntry(
            key,
            await dio.MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    // Company GST files (optional) — API expects 'company_gst_file' field name
    for (int i = 0; i < request.companyGstFiles.length; i++) {
      final file = request.companyGstFiles[i];
      if (file.path != null) {
        final key = 'company_gst_file[]';
        fileKeys.add(key);
        formData.files.add(
          MapEntry(
            key,
            await dio.MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    debugPrint('══════════════════════════════════════════');
    debugPrint('📤 CUSTOMER INSPECTION FORM');
    debugPrint('URL: ${ApiEndpoints.customerInspectionForm}');
    debugPrint('Fields: $fields');
    debugPrint('Files: $fileKeys');
    debugPrint('FormData files count: ${formData.files.length}');
    debugPrint('FormData fields count: ${formData.fields.length}');
    debugPrint('══════════════════════════════════════════');

    final response = await _network.upload(
      ApiEndpoints.customerInspectionForm,
      formData,
    );

    debugPrint('══════════════════════════════════════════');
    debugPrint('📥 CUSTOMER INSPECTION RESPONSE');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    debugPrint('══════════════════════════════════════════');

    return response;
  }

  /// Submit agent valuation form with multipart file uploads.
  Future<dio.Response> submitAgentValuationForm({
    required AgentInspectionRequest request,
  }) async {
    final fields = request.toFields();
    final multipartFiles = <String, dio.MultipartFile>{};

    // Convert all file lists to MultipartFile
    for (final entry in request.fileFields.entries) {
      for (int i = 0; i < entry.value.length; i++) {
        multipartFiles['${entry.key}[$i]'] =
            await dio.MultipartFile.fromFile(
          entry.value[i].path,
          filename: entry.value[i].path.split('/').last,
        );
      }
    }

    final formData = dio.FormData.fromMap({
      ...fields,
      ...multipartFiles,
    });

    debugPrint('══════════════════════════════════════════');
    debugPrint('📤 AGENT VALUATION FORM');
    debugPrint('URL: ${ApiEndpoints.agentValuationForm}');
    debugPrint('Fields: $fields');
    debugPrint('Files: ${request.fileFields.keys.toList()}');
    debugPrint('══════════════════════════════════════════');

    final response = await _network.upload(
      ApiEndpoints.agentValuationForm,
      formData,
    );

    debugPrint('══════════════════════════════════════════');
    debugPrint('📥 AGENT VALUATION RESPONSE');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    debugPrint('══════════════════════════════════════════');

    return response;
  }

  /// Fetch paginated list of user's inspections (POST).
  Future<dio.Response> getMyInspections({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final requestData = {
      'user_id': userId,
      'page': page,
      'limit': limit,
    };

    debugPrint('══════════════════════════════════════════');
    debugPrint('📤 MY INSPECTIONS REQUEST');
    debugPrint('URL: ${ApiEndpoints.myInspections}');
    debugPrint('Body: $requestData');
    debugPrint('══════════════════════════════════════════');

    final response = await _network.post(
      ApiEndpoints.myInspections,
      data: requestData,
    );

    debugPrint('══════════════════════════════════════════');
    debugPrint('📥 MY INSPECTIONS RESPONSE');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');
    debugPrint('══════════════════════════════════════════');

    return response;
  }
}
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/network_service.dart';
import '../../domain/entities/finance_request_entity.dart';
import '../../domain/entities/insurance_request_entity.dart';
import '../../domain/entities/quote_entity.dart';
import '../../domain/repositories/insurance_finance_repository.dart';
import '../models/insurance_response_model.dart';
import '../models/finance_response_model.dart';
import '../models/vehicle_quotes_model.dart';

class InsuranceFinanceRepositoryImpl implements InsuranceFinanceRepository {
  final NetworkService _networkService;

  InsuranceFinanceRepositoryImpl(this._networkService);

  @override
  Future<SubmissionResult> submitInsuranceRequest({
    required InsuranceRequestEntity request,
    required Map<String, dio.MultipartFile> files,
  }) async {
    try {
      // Build multipart form data
      final formData = dio.FormData.fromMap({
        'user_id': request.userId,
        'vehicle_no': request.vehicleNo,
        'insurance_type': request.insuranceType,
        'claim_type': request.claimType,
        'accepted_terms': request.acceptedTerms,
        ...files,
      });

      // ── Debug logging ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📤 INSURANCE REQUEST');
      debugPrint('URL: ${ApiEndpoints.insuranceRequest}');
      debugPrint('Fields:');
      debugPrint('  user_id: ${request.userId}');
      debugPrint('  vehicle_no: ${request.vehicleNo}');
      debugPrint('  insurance_type: ${request.insuranceType}');
      debugPrint('  claim_type: ${request.claimType}');
      debugPrint('  accepted_terms: ${request.acceptedTerms}');
      debugPrint('Files:');
      for (final entry in files.entries) {
        final multipart = entry.value;
        debugPrint('  ${entry.key}: ${multipart.filename} (${multipart.length} bytes)');
      }
      debugPrint('══════════════════════════════════════════');

      final response = await _networkService.upload(
        ApiEndpoints.insuranceRequest,
        formData,
      );

      // ── Debug logging: response ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📥 INSURANCE RESPONSE');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('══════════════════════════════════════════');

      final data = response.data as Map<String, dynamic>;
      final insuranceResponse = InsuranceResponseModel.fromJson(data);

      if (insuranceResponse.isSuccess) {
        return SubmissionResult(
          success: true,
          message: insuranceResponse.message.isNotEmpty
              ? insuranceResponse.message
              : 'Insurance request submitted successfully',
          data: data['data'] as Map<String, dynamic>?,
        );
      } else {
        return SubmissionResult(
          success: false,
          message: insuranceResponse.message.isNotEmpty
              ? insuranceResponse.message
              : 'Failed to submit insurance request',
          errorMessage: insuranceResponse.error?.toString(),
        );
      }
    } on dio.DioException catch (e) {
      // ── Debug logging: error ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('❌ INSURANCE ERROR');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('══════════════════════════════════════════');
      return _handleDioError(e);
    } catch (e) {
      debugPrint('❌ INSURANCE UNEXPECTED ERROR: $e');
      return SubmissionResult(
        success: false,
        message: 'An unexpected error occurred',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<SubmissionResult> submitFinanceRequest({
    required FinanceRequestEntity request,
    required Map<String, dio.MultipartFile> files,
  }) async {
    try {
      // Build multipart form data — only include non-empty optional fields
      final fields = <String, dynamic>{
        'user_id': request.userId,
        'vehicle_no': request.vehicleNo,
        'vehicle_state': request.vehicleState,
        'vehicle_city': request.vehicleCity,
        'vehicle_location': request.vehicleLocation,
        'applicant_mobile_num': request.applicantMobileNum,
        'co_applicant_details': request.coApplicantDetails,
      };

      // Only include fleet_size if provided
      if (request.fleetSize.isNotEmpty) {
        fields['fleet_size'] = request.fleetSize;
      }

      // Only include co_applicant_mobile_num when co-applicant is checked
      if (request.coApplicantDetails == 'checked' &&
          request.coApplicantMobileNum.isNotEmpty) {
        fields['co_applicant_mobile_num'] = request.coApplicantMobileNum;
      }

      fields.addAll(files);

      final formData = dio.FormData.fromMap(fields);

      // ── Debug logging ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📤 FINANCE REQUEST');
      debugPrint('URL: ${ApiEndpoints.financeRequest}');
      debugPrint('Fields:');
      debugPrint('  user_id: ${request.userId}');
      debugPrint('  vehicle_no: ${request.vehicleNo}');
      debugPrint('  vehicle_state: ${request.vehicleState}');
      debugPrint('  vehicle_city: ${request.vehicleCity}');
      debugPrint('  fleet_size: ${request.fleetSize}');
      debugPrint('  vehicle_location: ${request.vehicleLocation}');
      debugPrint('  applicant_mobile_num: ${request.applicantMobileNum}');
      debugPrint('  co_applicant_details: ${request.coApplicantDetails}');
      debugPrint('  co_applicant_mobile_num: ${request.coApplicantMobileNum}');
      debugPrint('Files:');
      for (final entry in files.entries) {
        final multipart = entry.value;
        debugPrint('  ${entry.key}: ${multipart.filename} (${multipart.length} bytes)');
      }
      debugPrint('══════════════════════════════════════════');

      final response = await _networkService.upload(
        ApiEndpoints.financeRequest,
        formData,
      );

      // ── Debug logging: response ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📥 FINANCE RESPONSE');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
      debugPrint('══════════════════════════════════════════');

      final data = response.data as Map<String, dynamic>;
      final financeResponse = FinanceResponseModel.fromJson(data);

      if (financeResponse.isSuccess) {
        return SubmissionResult(
          success: true,
          message: financeResponse.message.isNotEmpty
              ? financeResponse.message
              : 'Finance request submitted successfully',
          data: data['data'] as Map<String, dynamic>?,
        );
      } else {
        return SubmissionResult(
          success: false,
          message: financeResponse.message.isNotEmpty
              ? financeResponse.message
              : 'Failed to submit finance request',
          errorMessage: financeResponse.error?.toString(),
        );
      }
    } on dio.DioException catch (e) {
      // ── Debug logging: error ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('❌ FINANCE ERROR');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('══════════════════════════════════════════');
      return _handleDioError(e);
    } catch (e) {
      debugPrint('❌ FINANCE UNEXPECTED ERROR: $e');
      return SubmissionResult(
        success: false,
        message: 'An unexpected error occurred',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<List<VehicleQuoteItemEntity>> getVehicleListingsQuotes({
    required String userId,
  }) async {
    try {
      final response = await _networkService.post(
        ApiEndpoints.vehicleListingsQuotes,
        data: {'user_id': userId},
      );

      final data = response.data as Map<String, dynamic>;
      final quotesResponse = VehicleListingsQuotesResponseModel.fromJson(data);

      if (quotesResponse.isSuccess && quotesResponse.data != null) {
        return quotesResponse.data!.vehicles;
      } else {
        throw Exception(
          quotesResponse.message.isNotEmpty
              ? quotesResponse.message
              : 'Failed to load quotes',
        );
      }
    } on dio.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      switch (statusCode) {
        case 401:
          throw Exception('Session expired. Please login again.');
        case 403:
          throw Exception('You don\'t have permission to view quotes.');
        case 404:
          throw Exception('Quotes service not found.');
        case 500:
          throw Exception('Server error. Please try again later.');
        default:
          throw Exception(
            e.message ?? 'Network error. Please check your connection.',
          );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to load quotes: $e');
    }
  }

  /// Parse Dio errors into user-friendly messages.
  SubmissionResult _handleDioError(dio.DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String message;
    switch (statusCode) {
      case 400:
        message = _extractServerMessage(responseData) ?? 'Invalid request data';
        break;
      case 401:
        message = 'Session expired. Please login again.';
        break;
      case 403:
        message = 'You don\'t have permission to perform this action.';
        break;
      case 404:
        message = 'Service not found. Please try again later.';
        break;
      case 422:
        message = _extractServerMessage(responseData) ?? 'Validation error';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      default:
        message = e.message ?? 'Network error. Please check your connection.';
    }

    return SubmissionResult(
      success: false,
      message: message,
      errorMessage: responseData?.toString(),
    );
  }

  /// Extract the message field from server response.
  String? _extractServerMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] as String?;
    }
    return null;
  }
}
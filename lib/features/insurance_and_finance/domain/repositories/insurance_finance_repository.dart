import 'package:dio/dio.dart';

import '../entities/finance_request_entity.dart';
import '../entities/insurance_request_entity.dart';
import '../entities/quote_entity.dart';

/// Result wrapper for submission responses.
class SubmissionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const SubmissionResult({
    required this.success,
    required this.message,
    this.data,
    this.errorMessage,
  });
}

/// Abstract repository for Insurance & Finance operations.
abstract class InsuranceFinanceRepository {
  /// Submit an insurance request with multipart form data.
  Future<SubmissionResult> submitInsuranceRequest({
    required InsuranceRequestEntity request,
    required Map<String, MultipartFile> files,
  });

  /// Submit a finance request with multipart form data.
  Future<SubmissionResult> submitFinanceRequest({
    required FinanceRequestEntity request,
    required Map<String, MultipartFile> files,
  });

  /// Get all vehicle listings quotes for a user.
  Future<List<VehicleQuoteItemEntity>> getVehicleListingsQuotes({
    required String userId,
  });
}
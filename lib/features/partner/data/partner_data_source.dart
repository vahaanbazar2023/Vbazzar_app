import 'package:dio/dio.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/partner_models.dart';

class PartnerDataSource {
  NetworkService? _networkService;
  NetworkService get _network => _networkService ??= NetworkService.to;

  PartnerDataSource({NetworkService? networkService})
    : _networkService = networkService;

  /// POST /api/v1/partner/request
  Future<PartnerApiResult<PartnerRequest>> submit(
    PartnerRequestPayload payload,
  ) async {
    try {
      final res = await _network.post(
        ApiEndpoints.partnerRequest,
        data: payload.toJson(),
      );
      final body = res.data as Map<String, dynamic>? ?? {};
      final data = body['data'];
      return PartnerApiResult(
        success: body['status'] == 'success',
        code: body['code'] as int? ?? res.statusCode ?? 0,
        message: body['message'] as String? ?? '',
        errorCode: _errorCode(body),
        data: data is Map<String, dynamic>
            ? PartnerRequest.fromJson(data)
            : null,
      );
    } on DioException catch (e) {
      LoggerService.to.error('partner submit DioException: ${e.message}');
      throw Exception(_message(e, 'Failed to submit request'));
    }
  }

  /// GET /api/v1/partner/my-request — `data` is null when the user never applied.
  Future<PartnerRequest?> fetchMyRequest() async {
    try {
      final res = await _network.get(ApiEndpoints.partnerMyRequest);
      final body = res.data as Map<String, dynamic>? ?? {};
      final data = body['data'];
      return data is Map<String, dynamic>
          ? PartnerRequest.fromJson(data)
          : null;
    } on DioException catch (e) {
      LoggerService.to.error('partner my-request DioException: ${e.message}');
      throw Exception(_message(e, 'Failed to load request status'));
    }
  }

  String? _errorCode(Map<String, dynamic> body) {
    final err = body['error'];
    if (err is Map && err['details'] is Map) {
      return (err['details'] as Map)['code'] as String?;
    }
    return null;
  }

  String _message(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return e.message ?? fallback;
  }
}

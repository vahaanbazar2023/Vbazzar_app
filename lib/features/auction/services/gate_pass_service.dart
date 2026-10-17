import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart' show DioException, MultipartFile, Options, ResponseType;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

/// An inspection request raised by the user for an auction vehicle.
class InspectionRequestSummary {
  final String inspectionId;
  final String vehicleId;
  final String inspectionType;
  final String status;

  const InspectionRequestSummary({
    required this.inspectionId,
    required this.vehicleId,
    required this.inspectionType,
    required this.status,
  });

  factory InspectionRequestSummary.fromJson(Map<String, dynamic> j) =>
      InspectionRequestSummary(
        inspectionId: j['inspection_id']?.toString() ?? '',
        vehicleId: j['vehicle_id']?.toString() ?? '',
        inspectionType: j['inspection_type']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
      );
}

class GatePassInfo {
  final String gatePassId;
  final String status;
  final String pdfUrl;
  final String verificationCode;
  final String expiresAt; // auction end (IST); pass is void after this

  const GatePassInfo({
    required this.gatePassId,
    required this.status,
    required this.pdfUrl,
    required this.verificationCode,
    this.expiresAt = '',
  });

  bool get isActive => status == 'ACTIVE';
  bool get isExpired => status == 'EXPIRED';

  factory GatePassInfo.fromJson(Map<String, dynamic> j) => GatePassInfo(
    gatePassId: j['gate_pass_id']?.toString() ?? '',
    status: j['status']?.toString() ?? '',
    pdfUrl: j['pdf_url']?.toString() ?? '',
    verificationCode: j['verification_code']?.toString() ?? '',
    expiresAt: j['expires_at']?.toString() ?? '',
  );
}

/// Amounts for paying a mechanic inspection (all values are rupee strings).
class InspectionPaymentOptions {
  final double charge;
  final double walletBalance;
  final double maxWallet; // min(balance, 50% of charge)
  final String planCode; // category plan code, e.g. AUCI01

  const InspectionPaymentOptions({
    required this.charge,
    required this.walletBalance,
    required this.maxWallet,
    this.planCode = 'INSPCHARGE',
  });

  factory InspectionPaymentOptions.fromJson(Map<String, dynamic> j) =>
      InspectionPaymentOptions(
        charge: double.tryParse('${j['inspection_charge']}') ?? 0,
        walletBalance: double.tryParse('${j['wallet_balance']}') ?? 0,
        maxWallet: double.tryParse('${j['maximum_redeemable_amount']}') ?? 0,
        planCode: (j['plan_code']?.toString().isNotEmpty ?? false)
            ? j['plan_code'].toString()
            : 'INSPCHARGE',
      );
}

/// Category charge shown before a mechanic request is created.
class ChargeEstimate {
  final String? category;
  final String? planCode;
  final double? amount;
  final double walletBalance;
  final double maxWallet; // min(balance, 50% of the charge)

  const ChargeEstimate({
    this.category,
    this.planCode,
    this.amount,
    this.walletBalance = 0,
    this.maxWallet = 0,
  });
}

/// One row of the "My Gate Passes" list.
class GatePassListItem {
  final String gatePassId;
  final String status;
  final String inspectionId;
  final String inspectionType;
  final String auctionId;
  final String vehicleId;
  final String make;
  final String model;
  final String registrationNo;
  final String verificationCode;
  final String insertedAt;
  final String expiresAt;

  const GatePassListItem({
    required this.gatePassId,
    required this.status,
    required this.inspectionId,
    required this.inspectionType,
    required this.auctionId,
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.registrationNo,
    required this.verificationCode,
    required this.insertedAt,
    this.expiresAt = '',
  });

  bool get isActive => status == 'ACTIVE';
  bool get isExpired => status == 'EXPIRED';

  String get vehicleTitle {
    final t = '$make $model'.trim();
    return t.isEmpty ? vehicleId : t;
  }

  factory GatePassListItem.fromJson(Map<String, dynamic> j) => GatePassListItem(
    gatePassId: j['gate_pass_id']?.toString() ?? '',
    status: j['status']?.toString() ?? '',
    inspectionId: j['inspection_id']?.toString() ?? '',
    inspectionType: j['inspection_type']?.toString() ?? '',
    auctionId: j['auction_id']?.toString() ?? '',
    vehicleId: j['vehicle_id']?.toString() ?? '',
    make: j['make']?.toString() ?? '',
    model: j['model']?.toString() ?? '',
    registrationNo: j['registration_no']?.toString() ?? '',
    verificationCode: j['verification_code']?.toString() ?? '',
    insertedAt: j['inserted_at']?.toString() ?? '',
    expiresAt: j['expires_at']?.toString() ?? '',
  );
}

class GatePassException implements Exception {
  final String message;
  final String? code;
  GatePassException(this.message, {this.code});
  @override
  String toString() => message;
}

class AuthorizedPersonInput {
  final String name;
  final String mobileNumber;
  final String aadhaarNumber;
  final String idProofUrl;
  final String photographUrl;

  const AuthorizedPersonInput({
    required this.name,
    required this.mobileNumber,
    required this.aadhaarNumber,
    required this.idProofUrl,
    required this.photographUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile_number': mobileNumber,
    'aadhaar_number': aadhaarNumber,
    'id_proof_url': idProofUrl,
    'photograph_url': photographUrl,
  };
}

/// Client for the auction-inspection (Gate Pass) APIs.
class GatePassService {
  static const mechanicType = 'VAHAAN_BAZAR_MECHANIC';
  static const userType = 'USER_OR_AUTHORIZED_PERSON';

  final NetworkService _network;

  GatePassService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  GatePassException _toException(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final details = (data['error'] is Map)
            ? (data['error']['details'] as Map?)
            : null;
        return GatePassException(
          data['message']?.toString() ?? 'Something went wrong',
          code: details?['code']?.toString(),
        );
      }
    }
    return GatePassException('Something went wrong. Please try again.');
  }

  /// The caller's most recent request for [vehicleId], or null.
  Future<InspectionRequestSummary?> findRequestForVehicle(
    String vehicleId,
  ) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.inspectionRequests,
        queryParameters: {'page': 1, 'limit': 100},
      );
      final items = (res.data?['data']?['items'] as List?) ?? const [];
      final matches = items
          .map((e) => InspectionRequestSummary.fromJson(e as Map<String, dynamic>))
          .where((r) => r.vehicleId == vehicleId)
          .toList();
      return matches.isEmpty ? null : matches.first;
    } catch (e) {
      throw _toException(e);
    }
  }

  /// Returns null when no Gate Pass has been generated yet.
  Future<GatePassInfo?> fetchGatePass(String inspectionId) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.inspectionGatePass(inspectionId),
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) return null;
      return GatePassInfo.fromJson(data);
    } catch (e) {
      final ex = _toException(e);
      if (ex.code == 'GATE_PASS_NOT_FOUND') return null;
      throw ex;
    }
  }

  /// Uploads ID proof + photograph; returns (idProofUrl, photographUrl).
  Future<({String idProofUrl, String photographUrl})> uploadDocuments({
    required String idProofPath,
    required String photographPath,
  }) async {
    try {
      final form = dio.FormData.fromMap({
        'id_proof': await MultipartFile.fromFile(idProofPath),
        'photograph': await MultipartFile.fromFile(photographPath),
      });
      final res = await _network.upload<Map<String, dynamic>>(
        ApiEndpoints.inspectionDocumentsUpload,
        form,
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw GatePassException(
          res.data?['message']?.toString() ?? 'Document upload failed',
        );
      }
      return (
        idProofUrl: data['id_proof_url'].toString(),
        photographUrl: data['photograph_url'].toString(),
      );
    } catch (e) {
      if (e is GatePassException) rethrow;
      throw _toException(e);
    }
  }

  Future<InspectionRequestSummary> createRequest({
    required String userId,
    required String vehicleId,
    required String auctionId,
    required String inspectionType,
    String? inspectorMode,
    AuthorizedPersonInput? authorizedPerson,
  }) async {
    try {
      final res = await _network.post<Map<String, dynamic>>(
        ApiEndpoints.inspectionRequests,
        data: {
          'user_id': userId,
          'vehicle_id': vehicleId,
          'auction_id': auctionId,
          'inspection_type': inspectionType,
          if (inspectorMode != null) 'inspector_mode': inspectorMode,
          if (authorizedPerson != null)
            'authorized_person': authorizedPerson.toJson(),
        },
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw GatePassException(
          res.data?['message']?.toString() ?? 'Could not create request',
        );
      }
      return InspectionRequestSummary(
        inspectionId: data['inspection_id'].toString(),
        vehicleId: vehicleId,
        inspectionType: data['inspection_type'].toString(),
        status: data['status'].toString(),
      );
    } catch (e) {
      if (e is GatePassException) rethrow;
      throw _toException(e);
    }
  }

  /// All of the caller's Gate Passes, newest first.
  Future<({List<GatePassListItem> items, int totalPages})> fetchMyGatePasses({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.myGatePasses,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      final raw = (data?['items'] as List?) ?? const [];
      return (
        items: raw
            .map((e) => GatePassListItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalPages: (data?['total_pages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      throw _toException(e);
    }
  }

  /// Downloads the Gate Pass PDF via the API, saves it on the device and
  /// returns the file path.
  Future<String> downloadPdf({
    required String inspectionId,
    required String gatePassId,
  }) async {
    try {
      final res = await _network.get<List<int>>(
        ApiEndpoints.inspectionGatePassDownload(inspectionId),
        options: Options(responseType: ResponseType.bytes),
      );
      final contentType = res.headers.value('content-type') ?? '';
      if (!contentType.contains('pdf') || res.data == null) {
        throw GatePassException('Gate Pass is not available for download yet');
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$gatePassId.pdf');
      await file.writeAsBytes(res.data!, flush: true);
      return file.path;
    } catch (e) {
      if (e is GatePassException) rethrow;
      throw _toException(e);
    }
  }

  /// Download then open in the device's PDF viewer.
  Future<void> downloadAndOpen({
    required String inspectionId,
    required String gatePassId,
  }) async {
    final path = await downloadPdf(
      inspectionId: inspectionId,
      gatePassId: gatePassId,
    );
    final result = await OpenFilex.open(path, type: 'application/pdf');
    if (result.type != ResultType.done) {
      throw GatePassException('Saved to $path, but no PDF viewer was found');
    }
  }

  /// Category charge for the auction's vehicle type plus the caller's wallet
  /// numbers (amount/wallet fields are null when no charge is configured).
  Future<ChargeEstimate> fetchChargeEstimate(String auctionId) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.inspectionChargeEstimate,
        queryParameters: {'auction_id': auctionId},
      );
      final d = res.data?['data'];
      if (d is! Map<String, dynamic>) return const ChargeEstimate();
      return ChargeEstimate(
        category: d['category']?.toString(),
        planCode: d['plan_code']?.toString(),
        amount: double.tryParse('${d['amount']}'),
        walletBalance: double.tryParse('${d['wallet_balance']}') ?? 0,
        maxWallet: double.tryParse('${d['maximum_redeemable_amount']}') ?? 0,
      );
    } catch (_) {
      return const ChargeEstimate(); // estimate is optional
    }
  }

  /// Charge + payment link for a mechanic request (link only while payment is pending).
  Future<({String? charge, String? paymentLink})> fetchPaymentInfo(
    String inspectionId,
  ) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.inspectionRequestDetail(inspectionId),
      );
      final d = res.data?['data'] as Map<String, dynamic>?;
      return (
        charge: d?['inspection_charge']?.toString(),
        paymentLink: d?['payment_link']?.toString(),
      );
    } catch (e) {
      throw _toException(e);
    }
  }

  /// Charge, wallet balance and the 50%-capped wallet amount for [inspectionId].
  /// Throws [GatePassException] (with the server's reason) when unavailable,
  /// e.g. no charge configured for the vehicle's category.
  Future<InspectionPaymentOptions?> fetchPaymentOptions(
    String inspectionId,
  ) async {
    try {
      final res = await _network.get<Map<String, dynamic>>(
        ApiEndpoints.inspectionPaymentOptions(inspectionId),
      );
      final d = res.data?['data'];
      if (d is! Map<String, dynamic>) {
        // Business errors come back as HTTP 200 with status=error.
        throw GatePassException(
          res.data?['message']?.toString() ??
              'Payment details are not available right now',
          code: res.data?['error']?['details']?['code']?.toString(),
        );
      }
      return InspectionPaymentOptions.fromJson(d);
    } catch (e) {
      throw _toException(e);
    }
  }
}

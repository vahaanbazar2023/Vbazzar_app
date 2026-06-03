import '../../domain/entities/quote_entity.dart';

/// Model for a single quote from a provider.
class QuoteModel extends QuoteEntity {
  const QuoteModel({
    required super.providerName,
    required super.price,
    required super.downloadablePdfUrl,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      providerName: json['provider_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      downloadablePdfUrl: json['downloadable_pdf_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'provider_name': providerName,
    'price': price,
    'downloadable_pdf_url': downloadablePdfUrl,
  };
}

/// Model for file URLs associated with a vehicle.
class FileUrlsModel extends FileUrlsEntity {
  const FileUrlsModel({
    super.aadharFile,
    super.panFile,
    super.rcFile,
    super.previousPolicyFile,
  });

  factory FileUrlsModel.fromJson(Map<String, dynamic> json) {
    return FileUrlsModel(
      aadharFile: json['aadhar_file'],
      panFile: json['pan_file'],
      rcFile: json['rc_file'],
      previousPolicyFile: json['previous_policy_file'],
    );
  }
}

/// Model for a vehicle item with its quotes.
class VehicleQuoteItemModel extends VehicleQuoteItemEntity {
  const VehicleQuoteItemModel({
    required super.vehicleId,
    required super.vehicleNo,
    required super.serviceType,
    required super.quotes,
    required super.totalQuotes,
    super.fileUrls,
  });

  factory VehicleQuoteItemModel.fromJson(Map<String, dynamic> json) {
    return VehicleQuoteItemModel(
      vehicleId: json['vehicle_id'] ?? '',
      vehicleNo: json['vehicle_no'] ?? '',
      serviceType: json['service_type'] ?? '',
      quotes: (json['quotes'] as List<dynamic>? ?? [])
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuotes: json['total_quotes'] ?? 0,
      fileUrls: json['file_urls'] != null
          ? FileUrlsModel.fromJson(json['file_urls'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Full response model for vehicle listings quotes.
class VehicleListingsQuotesResponseModel {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final VehicleListingsQuotesDataModel? data;
  final Map<String, dynamic>? error;

  VehicleListingsQuotesResponseModel({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory VehicleListingsQuotesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VehicleListingsQuotesResponseModel(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null
          ? VehicleListingsQuotesDataModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      error: json['error'] as Map<String, dynamic>?,
    );
  }
}

/// Data portion of vehicle listings quotes response.
class VehicleListingsQuotesDataModel {
  final String userId;
  final List<VehicleQuoteItemModel> vehicles;
  final int totalVehicles;
  final int totalQuotesAcrossAllVehicles;

  VehicleListingsQuotesDataModel({
    required this.userId,
    required this.vehicles,
    required this.totalVehicles,
    required this.totalQuotesAcrossAllVehicles,
  });

  factory VehicleListingsQuotesDataModel.fromJson(Map<String, dynamic> json) {
    return VehicleListingsQuotesDataModel(
      userId: json['user_id'] ?? '',
      vehicles: (json['vehicles'] as List<dynamic>? ?? [])
          .map((e) => VehicleQuoteItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalVehicles: json['total_vehicles'] ?? 0,
      totalQuotesAcrossAllVehicles:
          json['total_quotes_across_all_vehicles'] ?? 0,
    );
  }
}
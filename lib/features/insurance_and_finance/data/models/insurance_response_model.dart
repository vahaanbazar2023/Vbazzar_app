/// Model for insurance submission response uploaded file.
class UploadedFileInsuranceModel {
  final String fieldName;
  final String originalFilename;
  final String s3Url;
  final int fileSize;

  UploadedFileInsuranceModel({
    required this.fieldName,
    required this.originalFilename,
    required this.s3Url,
    required this.fileSize,
  });

  factory UploadedFileInsuranceModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileInsuranceModel(
      fieldName: json['field_name'] ?? '',
      originalFilename: json['original_filename'] ?? '',
      s3Url: json['s3_url'] ?? '',
      fileSize: json['file_size'] ?? 0,
    );
  }
}

/// Model for insurance response data.
class InsuranceDataModel {
  final String insVehicleId;
  final String vehicleNo;
  final String insuranceType;
  final String claimType;
  final String acceptedTerms;
  final List<UploadedFileInsuranceModel> uploadedFiles;
  final String createdAt;
  final String status;

  InsuranceDataModel({
    required this.insVehicleId,
    required this.vehicleNo,
    required this.insuranceType,
    required this.claimType,
    required this.acceptedTerms,
    required this.uploadedFiles,
    required this.createdAt,
    required this.status,
  });

  factory InsuranceDataModel.fromJson(Map<String, dynamic> json) {
    return InsuranceDataModel(
      insVehicleId: json['ins_vehicle_id'] ?? '',
      vehicleNo: json['vehicle_no'] ?? '',
      insuranceType: json['insurance_type'] ?? '',
      claimType: json['claim_type'] ?? '',
      acceptedTerms: json['accepted_terms'] ?? '',
      uploadedFiles: (json['uploaded_files'] as List<dynamic>? ?? [])
          .map((e) => UploadedFileInsuranceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

/// Full insurance response model.
class InsuranceResponseModel {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final InsuranceDataModel? data;
  final String? error;

  InsuranceResponseModel({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && (code == 200 || code == 201);

  factory InsuranceResponseModel.fromJson(Map<String, dynamic> json) {
    return InsuranceResponseModel(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null
          ? InsuranceDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error']?.toString(),
    );
  }
}
/// Model for finance submission response uploaded file.
/// Note: Finance has an extra `file_key` field compared to Insurance.
class UploadedFileFinanceModel {
  final String fieldName;
  final String originalFilename;
  final String s3Url;
  final String fileKey;
  final int fileSize;

  UploadedFileFinanceModel({
    required this.fieldName,
    required this.originalFilename,
    required this.s3Url,
    required this.fileKey,
    required this.fileSize,
  });

  factory UploadedFileFinanceModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileFinanceModel(
      fieldName: json['field_name'] ?? '',
      originalFilename: json['original_filename'] ?? '',
      s3Url: json['s3_url'] ?? '',
      fileKey: json['file_key'] ?? '',
      fileSize: json['file_size'] ?? 0,
    );
  }
}

/// Model for finance response data.
class FinanceDataModel {
  final String finVehicleId;
  final String vehicleNo;
  final String vehicleState;
  final String vehicleCity;
  final String? fleetSize;
  final String? vehicleLocation;
  final String? applicantMobileNum;
  final String coApplicantDetails;
  final String? coApplicantMobileNum;
  final List<UploadedFileFinanceModel>? uploadedFiles;
  final String createdAt;
  final String status;

  FinanceDataModel({
    required this.finVehicleId,
    required this.vehicleNo,
    required this.vehicleState,
    required this.vehicleCity,
    this.fleetSize,
    this.vehicleLocation,
    this.applicantMobileNum,
    required this.coApplicantDetails,
    this.coApplicantMobileNum,
    this.uploadedFiles,
    required this.createdAt,
    required this.status,
  });

  factory FinanceDataModel.fromJson(Map<String, dynamic> json) {
    return FinanceDataModel(
      finVehicleId: json['fin_vehicle_id'] ?? '',
      vehicleNo: json['vehicle_no'] ?? '',
      vehicleState: json['vehicle_state'] ?? '',
      vehicleCity: json['vehicle_city'] ?? '',
      fleetSize: json['fleet_size'],
      vehicleLocation: json['vehicle_location'],
      applicantMobileNum: json['applicant_mobile_num'],
      coApplicantDetails: json['co_applicant_details'] ?? 'no',
      coApplicantMobileNum: json['co_applicant_mobile_num'],
      uploadedFiles: (json['uploaded_files'] as List<dynamic>?)
          ?.map(
            (e) => UploadedFileFinanceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

/// Full finance response model.
class FinanceResponseModel {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final FinanceDataModel? data;
  final dynamic error;

  FinanceResponseModel({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory FinanceResponseModel.fromJson(Map<String, dynamic> json) {
    return FinanceResponseModel(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      data: json['data'] != null
          ? FinanceDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}
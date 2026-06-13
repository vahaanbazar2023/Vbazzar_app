import 'package:file_picker/file_picker.dart';

class CustomerInspectionRequest {
  final String userId;
  final String vehicleNo;
  final String chasisNo;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleState;
  final String vehicleCity;
  final String vehicleOwnerNumber;
  final String? companyName;
  final List<PlatformFile> rcFiles;
  final List<PlatformFile> insuranceFiles;
  final List<PlatformFile> companyGstFiles;

  const CustomerInspectionRequest({
    required this.userId,
    required this.vehicleNo,
    required this.chasisNo,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleState,
    required this.vehicleCity,
    required this.vehicleOwnerNumber,
    this.companyName,
    required this.rcFiles,
    this.insuranceFiles = const [],
    this.companyGstFiles = const [],
  });

  Map<String, String> toFields() {
    return {
      'user_id': userId,
      'vehicle_no': vehicleNo,
      'chasis_no': chasisNo,
      'vehicle_type': vehicleType,
      'vehicle_brand': vehicleBrand,
      'vehicle_state': vehicleState,
      'vehicle_city': vehicleCity,
      'vehicle_owner_number': vehicleOwnerNumber,
      if (companyName != null && companyName!.isNotEmpty)
        'company_name': companyName!,
    };
  }
}

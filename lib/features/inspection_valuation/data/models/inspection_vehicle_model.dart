class InspectionVehicleModel {
  final String vehicleNo;
  final String chasisNo;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleState;
  final String vehicleCity;
  final String vehicleOwnerNumber;
  final String? webUrl;
  final String status;

  const InspectionVehicleModel({
    required this.vehicleNo,
    required this.chasisNo,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleState,
    required this.vehicleCity,
    required this.vehicleOwnerNumber,
    this.webUrl,
    required this.status,
  });

  factory InspectionVehicleModel.fromJson(Map<String, dynamic> json) {
    return InspectionVehicleModel(
      vehicleNo: json['vehicle_no']?.toString() ?? '',
      chasisNo: json['chasis_no']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      vehicleBrand: json['vehicle_brand']?.toString() ?? '',
      vehicleState: json['vehicle_state']?.toString() ?? '',
      vehicleCity: json['vehicle_city']?.toString() ?? '',
      vehicleOwnerNumber: json['vehicle_owner_number']?.toString() ?? '',
      webUrl: json['web_url']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_no': vehicleNo,
      'chasis_no': chasisNo,
      'vehicle_type': vehicleType,
      'vehicle_brand': vehicleBrand,
      'vehicle_state': vehicleState,
      'vehicle_city': vehicleCity,
      'vehicle_owner_number': vehicleOwnerNumber,
      'web_url': webUrl,
      'status': status,
    };
  }
}
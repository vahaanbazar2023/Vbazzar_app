import '../../domain/entities/vehicle_tire_entity.dart';

class VehicleTireModel extends VehicleTireEntity {
  const VehicleTireModel({
    required super.tireCode,
    required super.tireLabel,
  });

  factory VehicleTireModel.fromJson(Map<String, dynamic> json) {
    return VehicleTireModel(
      tireCode: json['tyre_code']?.toString() ?? json['tire_code']?.toString() ?? '',
      tireLabel: json['display_name']?.toString() ?? json['tire_label']?.toString() ?? '',
    );
  }
}

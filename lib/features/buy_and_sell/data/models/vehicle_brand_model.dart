import '../../domain/entities/vehicle_brand_entity.dart';

class VehicleBrandModel extends VehicleBrandEntity {
  const VehicleBrandModel({
    required super.brandCode,
    required super.brandName,
    super.categoryCode,
  });

  factory VehicleBrandModel.fromJson(Map<String, dynamic> json) {
    return VehicleBrandModel(
      brandCode: json['brand_code']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      categoryCode: json['category_code']?.toString(),
    );
  }
}

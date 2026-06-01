import '../../domain/entities/subscribed_vehicle_entity.dart';

class SubscribedVehicleModel extends SubscribedVehicleEntity {
  const SubscribedVehicleModel({
    required super.id,
    required super.vehicleId,
    super.categoryCode,
    super.categoryName,
    super.brandName,
    super.model,
    super.year,
    super.imageUrl,
    super.subscriptionDate,
    super.status,
  });

  factory SubscribedVehicleModel.fromJson(Map<String, dynamic> json) {
    return SubscribedVehicleModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['sb_vehicle_id']?.toString() ?? json['vehicle_id']?.toString() ?? '',
      categoryCode: json['category_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      model: json['model']?.toString() ?? json['model_name']?.toString(),
      year: json['manufacturing_year']?.toString() ?? json['year']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['primary_image']?.toString(),
      subscriptionDate: json['subscription_date']?.toString() ?? json['created_at']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

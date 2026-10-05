import '../../domain/entities/sell_vehicle_entity.dart';

class SellVehicleModel extends SellVehicleEntity {
  const SellVehicleModel({
    required super.id,
    super.categoryCode,
    super.categoryName,
    super.brandCode,
    super.brandName,
    super.model,
    super.year,
    super.status,
    super.imageUrl,
    super.createdAt,
    super.askingPrice,
    super.registrationNumber,
    super.approved,
    super.isSold,
    super.price,
    super.vehicleFiles,
  });

  factory SellVehicleModel.fromJson(Map<String, dynamic> json) {
    // Parse vehicle_files array
    List<VehicleFile>? files;
    if (json['vehicle_files'] is List) {
      files = (json['vehicle_files'] as List)
          .map((f) => VehicleFile.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    return SellVehicleModel(
      id: json['sb_vehicle_id']?.toString() ?? json['id']?.toString() ?? '',
      categoryCode: json['category_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandCode: json['brand_code']?.toString(),
      brandName: json['brand_name']?.toString(),
      model:
          json['model']?.toString() ??
          json['model_name']?.toString() ??
          json['asset_desc_or_model']?.toString(),
      year: json['manufacturing_year']?.toString() ?? json['year']?.toString(),
      status: json['status']?.toString(),
      imageUrl:
          json['image_url']?.toString() ?? json['primary_image']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['inserted_at']?.toString(),
      askingPrice: json['asking_price'] is num
          ? (json['asking_price'] as num).toDouble()
          : null,
      registrationNumber: json['registration_number']?.toString(),
      approved: json['approved']?.toString(),
      isSold: json['is_sold']?.toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : json['price'] is String
          ? double.tryParse(json['price'] as String)
          : null,
      vehicleFiles: files,
    );
  }
}

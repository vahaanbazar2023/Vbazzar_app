import '../../domain/entities/vehicle_detail_entity.dart';

class VehicleDetailModel extends VehicleDetailEntity {
  const VehicleDetailModel({
    required super.id,
    super.categoryCode,
    super.categoryName,
    super.brandCode,
    super.brandName,
    super.model,
    super.year,
    super.tonnage,
    super.kv,
    super.noOfTyres,
    super.fuelType,
    super.bodyType,
    super.state,
    super.imageUrl,
    super.images,
    super.description,
    super.price,
    super.sellerName,
    super.sellerPhone,
  });

  factory VehicleDetailModel.fromJson(Map<String, dynamic> json) {
    List<String>? imagesList;
    if (json['images'] is List) {
      imagesList = (json['images'] as List).map((e) => e.toString()).toList();
    }
    return VehicleDetailModel(
      id: json['sb_vehicle_id']?.toString() ?? json['id']?.toString() ?? '',
      categoryCode: json['category_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandCode: json['brand_code']?.toString(),
      brandName: json['brand_name']?.toString(),
      model: json['model']?.toString() ?? json['model_name']?.toString(),
      year: json['manufacturing_year']?.toString() ?? json['year']?.toString(),
      tonnage: json['tonnage']?.toString(),
      kv: json['kv']?.toString(),
      noOfTyres: json['no_of_tyres']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      bodyType: json['body_type']?.toString(),
      state: json['state']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['primary_image']?.toString(),
      images: imagesList,
      description: json['description']?.toString(),
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      sellerName: json['seller_name']?.toString(),
      sellerPhone: json['seller_phone']?.toString(),
    );
  }
}

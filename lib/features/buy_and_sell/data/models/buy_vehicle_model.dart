import '../../domain/entities/buy_vehicle_entity.dart';

class BuyVehicleModel extends BuyVehicleEntity {
  const BuyVehicleModel({
    required super.id,
    required super.categoryCode,
    required super.categoryName,
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
    super.status,
    super.price,
    super.city,
    super.imageUrls,
    super.vehicleFileUrls,
    super.sellerPhone,
    super.ownerDetailsAccess,
    super.categoryPlan,
    super.subscriptionAmount,
    super.inspectionRequested,
  });

  factory BuyVehicleModel.fromJson(Map<String, dynamic> json) {
    // Parse image URLs from vehicle_files array
    final vehicleFiles = <String>[];
    if (json['vehicle_files'] is List) {
      for (final file in json['vehicle_files'] as List) {
        if (file is Map<String, dynamic>) {
          final url = file['file_url']?.toString();
          if (url != null && url.isNotEmpty) {
            vehicleFiles.add(url);
          }
        }
      }
    }

    // Parse additional image URLs
    final images = <String>[];
    if (json['image_urls'] is List) {
      for (final url in json['image_urls'] as List) {
        if (url is String && url.isNotEmpty) {
          images.add(url);
        }
      }
    }

    return BuyVehicleModel(
      id: json['sb_vehicle_id']?.toString() ?? json['id']?.toString() ?? '',
      categoryCode: json['category_code']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      brandCode: json['brand_code']?.toString(),
      brandName: json['brand_name']?.toString(),
      model: json['model']?.toString() ?? json['model_name']?.toString(),
      year: json['manufacturing_year']?.toString() ?? json['year']?.toString(),
      tonnage: json['tonnage']?.toString(),
      kv: json['kv']?.toString(),
      noOfTyres: json['no_of_tyres']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      bodyType: json['body_type']?.toString(),
      state: json['state']?.toString() ?? json['state_name']?.toString(),
      city: json['city']?.toString() ?? json['city_name']?.toString(),
      imageUrl:
          json['image_url']?.toString() ?? json['primary_image']?.toString(),
      status: json['status']?.toString(),
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      imageUrls: images,
      vehicleFileUrls: vehicleFiles,
      // Owner phone from user_info.mobile — only meaningful when
      // owner_details_access == "yes"
      sellerPhone:
          (json['user_info'] as Map<String, dynamic>?)?['mobile']?.toString() ??
          json['seller_phone']?.toString() ??
          json['owner_mobile']?.toString(),
      ownerDetailsAccess: json['owner_details_access']?.toString(),
      categoryPlan: json['category_plan']?.toString(),
      subscriptionAmount: json['subscription_amount'] is num
          ? (json['subscription_amount'] as num).toDouble()
          : double.tryParse(json['subscription_amount']?.toString() ?? ''),
      inspectionRequested: json['inspection_requested']?.toString() ?? 'no',
    );
  }
}

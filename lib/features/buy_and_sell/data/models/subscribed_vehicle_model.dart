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
    super.price,
    super.ownerMobile,
    super.location,
    super.manufacturingYear,
    super.registrationNumber,
    super.imageUrls,
    super.ownerDetailsAccess,
    super.inspectionRequested,
    super.subscriptionStatus,
  });

  factory SubscribedVehicleModel.fromJson(Map<String, dynamic> json) {
    // Build image URLs from vehicle_files + image_urls + image_url
    final List<String> imageUrls = [];
    final vehicleFiles = json['vehicle_files'];
    if (vehicleFiles is List) {
      for (final f in vehicleFiles) {
        final url = f['file_url']?.toString() ?? f['url']?.toString() ?? '';
        if (url.isNotEmpty) imageUrls.add(url);
      }
    }
    final rawImageUrls = json['image_urls'];
    if (rawImageUrls is List) {
      for (final u in rawImageUrls) {
        final url = u.toString();
        if (url.isNotEmpty && !imageUrls.contains(url)) imageUrls.add(url);
      }
    }
    final singleUrl =
        json['image_url']?.toString() ??
        json['primary_image']?.toString() ??
        '';
    if (singleUrl.isNotEmpty && !imageUrls.contains(singleUrl)) {
      imageUrls.insert(0, singleUrl);
    }

    return SubscribedVehicleModel(
      id: json['id']?.toString() ?? json['subscription_id']?.toString() ?? '',
      vehicleId:
          json['sb_vehicle_id']?.toString() ??
          json['vehicle_id']?.toString() ??
          '',
      categoryCode: json['category_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      model:
          json['asset_desc_or_model']?.toString() ?? json['model']?.toString(),
      year: json['manufacturing_year']?.toString(),
      imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
      imageUrls: imageUrls,
      subscriptionDate:
          json['subscribed_at']?.toString() ??
          json['subscription_date']?.toString(),
      status: json['status']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      ownerMobile: json['owner_mobile']?.toString(),
      location: json['location']?.toString(),
      manufacturingYear: json['manufacturing_year'] is int
          ? json['manufacturing_year']
          : int.tryParse(json['manufacturing_year']?.toString() ?? ''),
      registrationNumber: json['registration_number']?.toString(),
      ownerDetailsAccess: json['owner_details_access']?.toString(),
      inspectionRequested: json['inspection_requested']?.toString(),
      subscriptionStatus: json['subscription_status']?.toString(),
    );
  }
}

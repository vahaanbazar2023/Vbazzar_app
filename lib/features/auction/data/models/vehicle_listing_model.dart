import '../../domain/entities/vehicle_listing_entity.dart';

/// Data model for [VehicleListingEntity] – handles JSON serialization.
class VehicleListingModel extends VehicleListingEntity {
  const VehicleListingModel({
    required super.vehicleId,
    required super.auctionId,
    required super.make,
    required super.model,
    super.variant,
    super.manufacturingYear,
    required super.minimumPrice,
    super.currentBid,
    super.totalBids,
    super.bidsLeft,
    super.imageUrl,
    super.imageUrls,
    super.categoryType,
    super.vehicleType,
    super.state,
    super.city,
    super.registrationNumber,
    super.fuelType,
    super.bodyType,
    super.tonnage,
    super.noOfTyres,
    super.kv,
    super.lotNumber,
    super.status,
    super.isInterested,
    super.vehicleDetails,
  });

  factory VehicleListingModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((e) {
      if (e is Map) {
        return (e['url'] ?? e['image_url'] ?? e['path'] ?? '').toString();
      }
      return e.toString();
    }).where((url) => url.isNotEmpty).toList();

    final primaryImage = imageUrls.isNotEmpty ? imageUrls.first : null;

    return VehicleListingModel(
      vehicleId: json['vehicle_id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      variant: json['variant'] as String?,
      manufacturingYear: (json['manufacturing_year'] ?? json['year'])?.toString(),
      minimumPrice: (json['minimum_price'] as num?)?.toInt() ?? 0,
      currentBid: (json['current_bid'] as num?)?.toInt(),
      totalBids: (json['total_bids'] as num?)?.toInt() ?? 0,
      bidsLeft: (json['bids_left'] as num?)?.toInt() ?? 0,
      imageUrl: primaryImage,
      imageUrls: imageUrls,
      categoryType: json['category_type'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      registrationNumber: json['registration_no'] as String?,
      fuelType: json['fuel_type'] as String?,
      bodyType: json['body_type'] as String?,
      tonnage: (json['tonnage'] as num?)?.toInt(),
      noOfTyres: (json['no_of_tyres'] as num?)?.toInt(),
      kv: (json['kv'] as num?)?.toInt(),
      lotNumber: json['lot_number'] as String?,
      status: json['status'] as String?,
      isInterested: json['is_interested'] as bool?,
      vehicleDetails: json['vehicle_details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'auction_id': auctionId,
      'make': make,
      'model': model,
      'variant': variant,
      'manufacturing_year': manufacturingYear,
      'minimum_price': minimumPrice,
      'current_bid': currentBid,
      'total_bids': totalBids,
      'bids_left': bidsLeft,
      'images': imageUrls,
      'category_type': categoryType,
      'vehicle_type': vehicleType,
      'state': state,
      'city': city,
      'registration_no': registrationNumber,
      'fuel_type': fuelType,
      'body_type': bodyType,
      'tonnage': tonnage,
      'no_of_tyres': noOfTyres,
      'kv': kv,
      'lot_number': lotNumber,
      'status': status,
      'is_interested': isInterested,
      'vehicle_details': vehicleDetails,
    };
  }
}


import '../../domain/entities/vehicle_detail_entity.dart';

class VehicleDetailModel extends VehicleDetailEntity {
  const VehicleDetailModel({
    required super.id,
    super.numericId,
    super.registrationNumber,
    super.chassisNumber,
    super.categoryCode,
    super.categoryName,
    super.brandCode,
    super.brandName,
    super.model,
    super.assetDescOrModel,
    super.year,
    super.tonnage,
    super.kv,
    super.noOfTyres,
    super.fuelType,
    super.bodyType,
    super.odometer,
    super.hours,
    super.state,
    super.city,
    super.location,
    super.stateCode,
    super.cityCode,
    super.imageUrl,
    super.images,
    super.vehicleFiles,
    super.price,
    super.categoryPlan,
    super.subscriptionAmount,
    super.ownerDetailsAccess,
    super.ownerMobile,
    super.originalInvoice,
    super.fitness,
    super.insurance,
    super.gstApplicability,
    super.insuranceDates,
    super.isSold,
    super.isInterested,
    super.inspectionRequested,
    super.vehicleOffer,
    super.status,
    super.description,
    super.sellerName,
    super.otherBrand,
    super.tyresName,
  });

  factory VehicleDetailModel.fromJson(Map<String, dynamic> json) {
    // ── Vehicle files ────────────────────────────────────────────────────────
    final files = <VehicleFileDetail>[];
    if (json['vehicle_files'] is List) {
      for (final f in json['vehicle_files'] as List) {
        if (f is Map<String, dynamic>) {
          files.add(
            VehicleFileDetail(
              id: _parseInt(f['id']),
              fileType: f['file_type']?.toString() ?? '',
              bucketName: f['bucket_name']?.toString() ?? '',
              fileKey: f['file_key']?.toString() ?? '',
              fileUrl: f['file_url']?.toString() ?? '',
              status: f['status']?.toString() ?? '',
              uploadedAt: f['uploaded_at']?.toString() ?? '',
            ),
          );
        }
      }
    }

    // ── Legacy images list ───────────────────────────────────────────────────
    List<String>? imagesList;
    if (json['images'] is List) {
      imagesList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    // ── Owner mobile — from top-level or user_info ───────────────────────────
    final ownerMobile = json['owner_mobile']?.toString().isNotEmpty == true
        ? json['owner_mobile'].toString()
        : (json['user_info'] as Map<String, dynamic>?)?['mobile']?.toString();

    return VehicleDetailModel(
      id: json['sb_vehicle_id']?.toString() ?? json['id']?.toString() ?? '',
      numericId: _parseInt(json['id']),
      registrationNumber: json['registration_number']?.toString(),
      chassisNumber: json['chassis_number']?.toString(),
      categoryCode: json['category_code']?.toString(),
      categoryName: json['category_name']?.toString(),
      brandCode: json['brand_code']?.toString(),
      brandName: json['brand_name']?.toString(),
      model:
          json['model']?.toString() ??
          json['model_name']?.toString() ??
          json['asset_desc_or_model']?.toString(),
      assetDescOrModel: json['asset_desc_or_model']?.toString(),
      year: json['manufacturing_year'] is num
          ? (json['manufacturing_year'] as num).toInt()
          : int.tryParse(json['manufacturing_year']?.toString() ?? ''),
      tonnage: json['tonnage']?.toString(),
      kv: json['kv']?.toString(),
      noOfTyres: json['no_of_tyres']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      bodyType: json['body_type']?.toString(),
      odometer: json['odometer']?.toString(),
      hours: json['hours']?.toString(),
      state: json['state_name']?.toString() ?? json['state']?.toString(),
      city: json['city_name']?.toString() ?? json['city']?.toString(),
      location: json['location']?.toString(),
      stateCode: json['state_code']?.toString(),
      cityCode: json['city_code']?.toString(),
      imageUrl:
          json['image_url']?.toString() ?? json['primary_image']?.toString(),
      images: imagesList,
      vehicleFiles: files,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? ''),
      categoryPlan: json['category_plan']?.toString(),
      subscriptionAmount: json['subscription_amount'] is num
          ? (json['subscription_amount'] as num).toInt()
          : int.tryParse(json['subscription_amount']?.toString() ?? ''),
      ownerDetailsAccess: json['owner_details_access']?.toString() ?? 'no',
      ownerMobile: ownerMobile,
      originalInvoice:
          json['original_invoice'] == true ||
          json['original_invoice'] == 'true',
      fitness: json['fitness'] == true || json['fitness'] == 'true',
      insurance: json['insurance'] == true || json['insurance'] == 'true',
      gstApplicability:
          json['gst_applicability'] == true ||
          json['gst_applicability'] == 'true',
      insuranceDates: json['insurance_dates']?.toString(),
      isSold: json['is_sold']?.toString(),
      isInterested: json['is_interested']?.toString() ?? 'no',
      inspectionRequested: json['inspection_requested']?.toString() ?? 'no',
      vehicleOffer: json['vehicle_offer'],
      status: json['status']?.toString(),
      description: json['description']?.toString(),
      sellerName: json['seller_name']?.toString(),
      otherBrand: json['other_brand']?.toString(),
      tyresName: json['tyres_name']?.toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

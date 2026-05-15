import '../../domain/entities/approved_vehicle_listing_entity.dart';

/// Data Transfer Object for Approved Vehicle Listing.
/// Handles JSON deserialization and maps to the domain entity.
class ApprovedVehicleListingModel extends ApprovedVehicleListingEntity {
  const ApprovedVehicleListingModel({
    required super.id,
    required super.approvedVehicleId,
    required super.categoryType,
    required super.registrationNumber,
    required super.stateName,
    required super.cityName,
    required super.fitnessAvailable,
    super.brand,
    required super.chassisNumber,
    required super.originalInvoiceAvailable,
    required super.ownerMobileNumber,
    required super.assetDescription,
    required super.yearOfManufacturing,
    required super.vehicleInsuranceDate,
    required super.price,
    required super.vehicleStatus,
    required super.gstApplicable,
    required super.offerEndDate,
    required super.offerEndTime,
    required super.insertedAt,
    required super.modifiedAt,
    required super.insertedBy,
    required super.modifiedBy,
    required super.isBooked,
    required super.inspectionRequested,
    super.inspectionSubscription,
    super.categorySubscription,
    super.files,
  });

  factory ApprovedVehicleListingModel.fromJson(Map<String, dynamic> json) {
    return ApprovedVehicleListingModel(
      id: _parseInt(json['id']),
      approvedVehicleId: json['approved_vehicle_id']?.toString() ?? '',
      categoryType: json['category_type']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
      fitnessAvailable: json['fitness_available']?.toString() ?? '',
      brand: json['brand']?.toString(),
      chassisNumber: json['chassis_number']?.toString() ?? '',
      originalInvoiceAvailable:
          json['original_invoice_available']?.toString() ?? '',
      ownerMobileNumber: json['owner_mobile_number']?.toString() ?? '',
      assetDescription: json['asset_description']?.toString() ?? '',
      yearOfManufacturing: _parseInt(json['year_of_manufacturing']),
      vehicleInsuranceDate: json['vehicle_insurance_date']?.toString() ?? '',
      price: _parseDouble(json['price']),
      vehicleStatus: json['vehicle_status']?.toString() ?? '',
      gstApplicable: json['gst_applicable']?.toString() ?? '',
      offerEndDate: json['offer_end_date']?.toString() ?? '',
      offerEndTime: json['offer_end_time']?.toString() ?? '',
      insertedAt: json['inserted_at']?.toString() ?? '',
      modifiedAt: json['modified_at']?.toString() ?? '',
      insertedBy: json['inserted_by']?.toString() ?? '',
      modifiedBy: json['modified_by']?.toString() ?? '',
      isBooked: json['is_booked']?.toString() ?? 'no',
      inspectionRequested: json['inspection_requested']?.toString() ?? 'no',
      inspectionSubscription: json['inspection_subscription'] != null
          ? _InspectionSubscriptionModel.fromJson(
              json['inspection_subscription'] as Map<String, dynamic>)
          : null,
      categorySubscription: json['category_subscription'] != null
          ? _CategorySubscriptionModel.fromJson(
              json['category_subscription'] as Map<String, dynamic>)
          : null,
      files: json['files'] != null
          ? _VehicleFilesModel.fromJson(json['files'] as Map<String, dynamic>)
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class _InspectionSubscriptionModel extends InspectionSubscriptionEntity {
  const _InspectionSubscriptionModel({
    required super.inspectionAmount,
    required super.categoryPlan,
  });

  factory _InspectionSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return _InspectionSubscriptionModel(
      inspectionAmount: json['inspection_amount'] is double
          ? json['inspection_amount'] as double
          : double.tryParse(json['inspection_amount']?.toString() ?? '0') ??
              0.0,
      categoryPlan: json['category_plan']?.toString() ?? '',
    );
  }
}

class _CategorySubscriptionModel extends CategorySubscriptionEntity {
  const _CategorySubscriptionModel({
    required super.subscriptionAmount,
    required super.apprVehCommonSubPlan,
  });

  factory _CategorySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return _CategorySubscriptionModel(
      subscriptionAmount: json['subscription_amount'] is double
          ? json['subscription_amount'] as double
          : double.tryParse(json['subscription_amount']?.toString() ?? '0') ??
              0.0,
      apprVehCommonSubPlan: json['appr_veh_common_sub_plan']?.toString() ?? '',
    );
  }
}

class _VehicleFilesModel extends VehicleFilesEntity {
  const _VehicleFilesModel({
    required super.images,
    required super.rcDocuments,
    required super.insuranceDocuments,
  });

  factory _VehicleFilesModel.fromJson(Map<String, dynamic> json) {
    return _VehicleFilesModel(
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => _VehicleFileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rcDocuments: (json['rc_documents'] as List<dynamic>?)
              ?.map((e) => _VehicleFileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      insuranceDocuments: (json['insurance_documents'] as List<dynamic>?)
              ?.map((e) => _VehicleFileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class _VehicleFileModel extends VehicleFileEntity {
  const _VehicleFileModel({
    required super.id,
    required super.fileType,
    required super.fileUrl,
    required super.status,
    required super.uploadedAt,
  });

  factory _VehicleFileModel.fromJson(Map<String, dynamic> json) {
    return _VehicleFileModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fileType: json['file_type']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      uploadedAt: json['uploaded_at']?.toString() ?? '',
    );
  }
}
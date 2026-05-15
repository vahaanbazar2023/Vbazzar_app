/// Pure domain entity for Approved Vehicle Listing.
/// Has no dependency on JSON or API concerns.
class ApprovedVehicleListingEntity {
  final int id;
  final String approvedVehicleId;
  final String categoryType;
  final String registrationNumber;
  final String stateName;
  final String cityName;
  final String fitnessAvailable;
  final String? brand;
  final String chassisNumber;
  final String originalInvoiceAvailable;
  final String ownerMobileNumber;
  final String assetDescription;
  final int yearOfManufacturing;
  final String vehicleInsuranceDate;
  final double price;
  final String vehicleStatus;
  final String gstApplicable;
  final String offerEndDate;
  final String offerEndTime;
  final String insertedAt;
  final String modifiedAt;
  final String insertedBy;
  final String modifiedBy;
  final String isBooked;
  final String inspectionRequested;
  final InspectionSubscriptionEntity? inspectionSubscription;
  final CategorySubscriptionEntity? categorySubscription;
  final VehicleFilesEntity? files;

  const ApprovedVehicleListingEntity({
    required this.id,
    required this.approvedVehicleId,
    required this.categoryType,
    required this.registrationNumber,
    required this.stateName,
    required this.cityName,
    required this.fitnessAvailable,
    this.brand,
    required this.chassisNumber,
    required this.originalInvoiceAvailable,
    required this.ownerMobileNumber,
    required this.assetDescription,
    required this.yearOfManufacturing,
    required this.vehicleInsuranceDate,
    required this.price,
    required this.vehicleStatus,
    required this.gstApplicable,
    required this.offerEndDate,
    required this.offerEndTime,
    required this.insertedAt,
    required this.modifiedAt,
    required this.insertedBy,
    required this.modifiedBy,
    required this.isBooked,
    required this.inspectionRequested,
    this.inspectionSubscription,
    this.categorySubscription,
    this.files,
  });

  // ── Derived helpers ──────────────────────────────────────────

  bool get isBookedVehicle => isBooked.toLowerCase() == 'yes';
  bool get isInspectionRequested => inspectionRequested.toLowerCase() == 'yes';
  bool get hasFitnessCertificate => fitnessAvailable.toLowerCase() == 'yes';
  bool get hasOriginalInvoice => originalInvoiceAvailable.toLowerCase() == 'yes';
  bool get isGstApplicable => gstApplicable.toLowerCase() == 'yes';

  /// Returns the first image URL or null if no images exist
  String? get primaryImageUrl =>
      (files?.images.isNotEmpty == true) ? files!.images.first.fileUrl : null;

  /// Whether the vehicle has an RC document
  bool get hasRcDocument =>
      files?.rcDocuments.isNotEmpty == true;

  /// Whether the vehicle has an insurance document
  bool get hasInsuranceDocument =>
      files?.insuranceDocuments.isNotEmpty == true;

  /// Display title combining brand and year
  String get displayTitle {
    final parts = <String>[
      if (brand != null && brand!.isNotEmpty) brand!,
      if (yearOfManufacturing > 0) yearOfManufacturing.toString(),
    ];
    return parts.join(' • ');
  }

  /// Whether the booking subscription is available
  bool get canBook => categorySubscription != null;

  /// Whether the inspection subscription is available
  bool get canInspect => inspectionSubscription != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovedVehicleListingEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Nested entity for inspection subscription info.
class InspectionSubscriptionEntity {
  final double inspectionAmount;
  final String categoryPlan;

  const InspectionSubscriptionEntity({
    required this.inspectionAmount,
    required this.categoryPlan,
  });
}

/// Nested entity for category subscription info.
class CategorySubscriptionEntity {
  final double subscriptionAmount;
  final String apprVehCommonSubPlan;

  const CategorySubscriptionEntity({
    required this.subscriptionAmount,
    required this.apprVehCommonSubPlan,
  });
}

/// Container for vehicle file references.
class VehicleFilesEntity {
  final List<VehicleFileEntity> images;
  final List<VehicleFileEntity> rcDocuments;
  final List<VehicleFileEntity> insuranceDocuments;

  const VehicleFilesEntity({
    required this.images,
    required this.rcDocuments,
    required this.insuranceDocuments,
  });
}

/// A single file reference (image or document).
class VehicleFileEntity {
  final int id;
  final String fileType;
  final String fileUrl;
  final String status;
  final String uploadedAt;

  const VehicleFileEntity({
    required this.id,
    required this.fileType,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
  });
}
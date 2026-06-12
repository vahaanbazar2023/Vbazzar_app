import 'dart:io';

class AgentInspectionRequest {
  // Basic Vehicle Information
  final String? ownerName;
  final String vehicleRegistrationNumber;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleState;
  final String vehicleCity;
  final String? chasisNumber;
  final String? manufacturingYear;
  final String? engineNumber;
  final String? rtoLocation;
  final String? ownerNumber;

  // Vehicle Condition & Documentation
  final String? vehicleConditionText;
  final String? vehicleConditionDropdown;
  final String? insuranceValidTill;
  final String? fitnessValidTill;
  final String? taxPending;
  final String? hypothecation;
  final String? hypothecatedTo;
  final String? caseType;
  final String? hours;
  final String? odometer;
  final String? fuel;
  final String? transmissionType;
  final String? accidentalStatus;

  // Inspection Categories - Condition & Remarks
  final String? engineCondition;
  final String? engineRemarks;
  final String? transmissionCondition;
  final String? transmissionRemarks;
  final String? suspensionCondition;
  final String? suspensionRemarks;
  final String? bodyCondition;
  final String? bodyRemarks;
  final String? cabinInteriorCondition;
  final String? cabinInteriorRemarks;
  final String? electricalCondition;
  final String? electricalRemarks;
  final String? chasisCondition;
  final String? chasisRemarks;
  final String? odometerRemarks;

  // Tyre Specific
  final int? frontAxleTyresPercentage;
  final int? rearAxleTyresPercentage;

  // Valuation & Summary
  final double? assetMarketValue;
  final String? otherRemarks;
  final String? webUrl;

  // Image Uploads
  final List<File> engineImages;
  final List<File> transmissionImages;
  final List<File> suspensionImages;
  final List<File> tyreImages;
  final List<File> bodyFrontImage;
  final List<File> bodyBackImage;
  final List<File> bodyLeftImage;
  final List<File> bodyRightImage;
  final List<File> cabinInteriorImages;
  final List<File> electricalImages;
  final List<File> chasisImages;
  final List<File> odometerImages;

  const AgentInspectionRequest({
    this.ownerName,
    required this.vehicleRegistrationNumber,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleState,
    required this.vehicleCity,
    this.chasisNumber,
    this.manufacturingYear,
    this.engineNumber,
    this.rtoLocation,
    this.ownerNumber,
    this.vehicleConditionText,
    this.vehicleConditionDropdown,
    this.insuranceValidTill,
    this.fitnessValidTill,
    this.taxPending,
    this.hypothecation,
    this.hypothecatedTo,
    this.caseType,
    this.hours,
    this.odometer,
    this.fuel,
    this.transmissionType,
    this.accidentalStatus,
    this.engineCondition,
    this.engineRemarks,
    this.transmissionCondition,
    this.transmissionRemarks,
    this.suspensionCondition,
    this.suspensionRemarks,
    this.bodyCondition,
    this.bodyRemarks,
    this.cabinInteriorCondition,
    this.cabinInteriorRemarks,
    this.electricalCondition,
    this.electricalRemarks,
    this.chasisCondition,
    this.chasisRemarks,
    this.odometerRemarks,
    this.frontAxleTyresPercentage,
    this.rearAxleTyresPercentage,
    this.assetMarketValue,
    this.otherRemarks,
    this.webUrl,
    this.engineImages = const [],
    this.transmissionImages = const [],
    this.suspensionImages = const [],
    this.tyreImages = const [],
    this.bodyFrontImage = const [],
    this.bodyBackImage = const [],
    this.bodyLeftImage = const [],
    this.bodyRightImage = const [],
    this.cabinInteriorImages = const [],
    this.electricalImages = const [],
    this.chasisImages = const [],
    this.odometerImages = const [],
  });

  Map<String, String> toFields() {
    return {
      if (ownerName != null) 'owner_name': ownerName!,
      'vehicle_registration_number': vehicleRegistrationNumber,
      'vehicle_type': vehicleType,
      'vehicle_brand': vehicleBrand,
      'vehicle_state': vehicleState,
      'vehicle_city': vehicleCity,
      if (chasisNumber != null) 'chasis_number': chasisNumber!,
      if (manufacturingYear != null) 'manufacturing_year': manufacturingYear!,
      if (engineNumber != null) 'engine_number': engineNumber!,
      if (rtoLocation != null) 'rto_location': rtoLocation!,
      if (ownerNumber != null) 'owner_number': ownerNumber!,
      if (vehicleConditionText != null)
        'vehicle_condition_text': vehicleConditionText!,
      if (vehicleConditionDropdown != null)
        'vehicle_condition_dropdown': vehicleConditionDropdown!,
      if (insuranceValidTill != null)
        'insurance_valid_till': insuranceValidTill!,
      if (fitnessValidTill != null) 'fitness_valid_till': fitnessValidTill!,
      if (taxPending != null) 'tax_pending': taxPending!,
      if (hypothecation != null) 'hypothecation': hypothecation!,
      if (hypothecatedTo != null) 'hypothecated_to': hypothecatedTo!,
      if (caseType != null) 'case_type': caseType!,
      if (hours != null) 'hours': hours!,
      if (odometer != null) 'odometer': odometer!,
      if (fuel != null) 'fuel': fuel!,
      if (transmissionType != null) 'transmission_type': transmissionType!,
      if (accidentalStatus != null) 'accidental_status': accidentalStatus!,
      if (engineCondition != null) 'engine_condition': engineCondition!,
      if (engineRemarks != null) 'engine_remarks': engineRemarks!,
      if (transmissionCondition != null)
        'transmission_condition': transmissionCondition!,
      if (transmissionRemarks != null)
        'transmission_remarks': transmissionRemarks!,
      if (suspensionCondition != null)
        'suspension_condition': suspensionCondition!,
      if (suspensionRemarks != null) 'suspension_remarks': suspensionRemarks!,
      if (bodyCondition != null) 'body_condition': bodyCondition!,
      if (bodyRemarks != null) 'body_remarks': bodyRemarks!,
      if (cabinInteriorCondition != null)
        'cabin_interior_condition': cabinInteriorCondition!,
      if (cabinInteriorRemarks != null)
        'cabin_interior_remarks': cabinInteriorRemarks!,
      if (electricalCondition != null)
        'electrical_condition': electricalCondition!,
      if (electricalRemarks != null) 'electrical_remarks': electricalRemarks!,
      if (chasisCondition != null) 'chasis_condition': chasisCondition!,
      if (chasisRemarks != null) 'chasis_remarks': chasisRemarks!,
      if (odometerRemarks != null) 'odometer_remarks': odometerRemarks!,
      if (frontAxleTyresPercentage != null)
        'front_axle_tyres_percentage': frontAxleTyresPercentage.toString(),
      if (rearAxleTyresPercentage != null)
        'rear_axle_tyres_percentage': rearAxleTyresPercentage.toString(),
      if (assetMarketValue != null)
        'asset_market_value': assetMarketValue.toString(),
      if (otherRemarks != null) 'other_remarks': otherRemarks!,
      if (webUrl != null) 'web_url': webUrl!,
    };
  }

  Map<String, List<File>> get fileFields => {
    if (engineImages.isNotEmpty) 'engine_images': engineImages,
    if (transmissionImages.isNotEmpty)
      'transmission_images': transmissionImages,
    if (suspensionImages.isNotEmpty) 'suspension_images': suspensionImages,
    if (tyreImages.isNotEmpty) 'tyre_images': tyreImages,
    if (bodyFrontImage.isNotEmpty) 'body_front_image': bodyFrontImage,
    if (bodyBackImage.isNotEmpty) 'body_back_image': bodyBackImage,
    if (bodyLeftImage.isNotEmpty) 'body_left_image': bodyLeftImage,
    if (bodyRightImage.isNotEmpty) 'body_right_image': bodyRightImage,
    if (cabinInteriorImages.isNotEmpty)
      'cabin_interior_images': cabinInteriorImages,
    if (electricalImages.isNotEmpty) 'electrical_images': electricalImages,
    if (chasisImages.isNotEmpty) 'chasis_images': chasisImages,
    if (odometerImages.isNotEmpty) 'odometer_images': odometerImages,
  };
}
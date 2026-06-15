class VehicleFileDetail {
  final int id;
  final String fileType;
  final String bucketName;
  final String fileKey;
  final String fileUrl;
  final String status;
  final String uploadedAt;

  const VehicleFileDetail({
    required this.id,
    required this.fileType,
    required this.bucketName,
    required this.fileKey,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
  });
}

class VehicleDetailEntity {
  // ── Identifiers ────────────────────────────────────────────────────────────
  final String id; // sb_vehicle_id
  final int? numericId;
  final String? registrationNumber;
  final String? chassisNumber;

  // ── Classification ─────────────────────────────────────────────────────────
  final String? categoryCode;
  final String? categoryName;
  final String? brandCode;
  final String? brandName;
  final String? model;
  final String? assetDescOrModel;

  // ── Specs ──────────────────────────────────────────────────────────────────
  final int? year; // manufacturing_year
  final String? tonnage;
  final String? kv;
  final String? noOfTyres;
  final String? fuelType;
  final String? bodyType;
  final String? odometer;
  final String? hours;

  // ── Location ───────────────────────────────────────────────────────────────
  final String? state; // state_name
  final String? city; // city_name
  final String? location;
  final String? stateCode;
  final String? cityCode;

  // ── Media ──────────────────────────────────────────────────────────────────
  final String? imageUrl;
  final List<String>? images;
  final List<VehicleFileDetail> vehicleFiles;

  // ── Pricing & subscription ─────────────────────────────────────────────────
  final double? price;
  final String? categoryPlan;
  final int? subscriptionAmount;

  // ── Owner contact ─────────────────────────────────────────────────────────
  /// "yes" if the current user has already purchased access to the owner's
  /// mobile number for this vehicle.
  final String ownerDetailsAccess;

  /// Owner's mobile — populated when [ownerDetailsAccess] == "yes" or from
  /// the top-level `owner_mobile` field returned by the single-vehicle API.
  final String? ownerMobile;

  // ── Condition / documents ─────────────────────────────────────────────────
  final bool originalInvoice;
  final bool fitness;
  final bool insurance;
  final bool gstApplicability;
  final String? insuranceDates;
  final String? isSold;

  // ── Interaction state ─────────────────────────────────────────────────────
  final String isInterested;
  final String inspectionRequested;
  final dynamic vehicleOffer;

  // ── Misc ───────────────────────────────────────────────────────────────────
  final String? status;
  final String? description;
  final String? sellerName;
  final String? otherBrand;
  final String? tyresName;

  const VehicleDetailEntity({
    required this.id,
    this.numericId,
    this.registrationNumber,
    this.chassisNumber,
    this.categoryCode,
    this.categoryName,
    this.brandCode,
    this.brandName,
    this.model,
    this.assetDescOrModel,
    this.year,
    this.tonnage,
    this.kv,
    this.noOfTyres,
    this.fuelType,
    this.bodyType,
    this.odometer,
    this.hours,
    this.state,
    this.city,
    this.location,
    this.stateCode,
    this.cityCode,
    this.imageUrl,
    this.images,
    this.vehicleFiles = const [],
    this.price,
    this.categoryPlan,
    this.subscriptionAmount,
    this.ownerDetailsAccess = 'no',
    this.ownerMobile,
    this.originalInvoice = false,
    this.fitness = false,
    this.insurance = false,
    this.gstApplicability = false,
    this.insuranceDates,
    this.isSold,
    this.isInterested = 'no',
    this.inspectionRequested = 'no',
    this.vehicleOffer,
    this.status,
    this.description,
    this.sellerName,
    this.otherBrand,
    this.tyresName,
  });

  /// True when the owner's phone number is accessible.
  bool get hasOwnerAccess => ownerDetailsAccess.toLowerCase() == 'yes';

  /// Returns all image URLs — vehicle files (images only) first, then
  /// the legacy images list, then the single imageUrl fallback.
  List<String> get allImageUrls {
    final urls = <String>[];
    for (final f in vehicleFiles) {
      if (f.fileType == 'image' && f.fileUrl.isNotEmpty) {
        urls.add(f.fileUrl);
      }
    }
    if (images != null) urls.addAll(images!.where((u) => u.isNotEmpty));
    if (urls.isEmpty && imageUrl != null && imageUrl!.isNotEmpty) {
      urls.add(imageUrl!);
    }
    return urls;
  }

  String get formattedPrice {
    if (price == null || price! <= 0) return 'Price on request';
    return '₹${_fmt(price!.toInt())}';
  }

  static String _fmt(int n) {
    if (n <= 0) return '0';
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    int c = 0;
    for (int i = rest.length - 1; i >= 0; i--) {
      if (c > 0 && c % 2 == 0) buf.write(',');
      buf.write(rest[i]);
      c++;
    }
    return '${buf.toString().split('').reversed.join()},$last3';
  }
}

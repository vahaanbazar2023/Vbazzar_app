class VehicleListing {
  final int id;
  final String vehicleId;
  final String auctionId;
  final String sellerReference;
  final String repoDate;
  final String make;
  final String model;
  final int year;
  final String registrationNo;
  final String chassisNo;
  final String engineNo;
  final String registeredRto;
  final String variant;
  final String transmission;
  final String vehicleType;
  final String fuelType;
  final int kilometers;
  final String colour;
  final String marketValue;
  final int maxBids;
  final List<String> images;
  final int minimumPrice;
  final int reservePrice;
  final String owner;
  final String remarks;
  final String category;
  final String yardName;
  final String yardLocation;
  final String contactPersonName;
  final String contactPersonNumber;
  final int yourBid;
  final int bidsLeft;
  final int bidsReceived;
  final int? currentHighestBid;
  final int? currentBid;
  final int availableBalance;
  final int maxUserVehiclesBidLimit;
  final int userVehicleBidCount;
  final String status;
  final String insertedAt;
  final String updatedAt;

  const VehicleListing({
    required this.id,
    required this.vehicleId,
    required this.auctionId,
    required this.sellerReference,
    required this.repoDate,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNo,
    required this.chassisNo,
    required this.engineNo,
    required this.registeredRto,
    required this.variant,
    required this.transmission,
    required this.vehicleType,
    required this.fuelType,
    required this.kilometers,
    required this.colour,
    required this.marketValue,
    required this.maxBids,
    required this.images,
    required this.minimumPrice,
    required this.reservePrice,
    required this.owner,
    required this.remarks,
    required this.category,
    required this.yardName,
    required this.yardLocation,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.yourBid,
    required this.bidsLeft,
    required this.bidsReceived,
    this.currentHighestBid,
    this.currentBid,
    required this.availableBalance,
    required this.maxUserVehiclesBidLimit,
    required this.userVehicleBidCount,
    required this.status,
    required this.insertedAt,
    required this.updatedAt,
  });

  static String _resolveImageUrl(dynamic e) {
    String raw;
    if (e is Map) {
      raw = (e['url'] ?? e['image_url'] ?? e['path'] ?? '').toString();
    } else {
      raw = e.toString();
    }
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    const baseUrl = 'https://api.staging.vahaanbazar.in';
    return '$baseUrl${raw.startsWith('/') ? '' : '/'}$raw';
  }

  factory VehicleListing.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    return VehicleListing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vehicleId: json['vehicle_id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      sellerReference: json['seller_reference'] as String? ?? '',
      repoDate: json['repo_date'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      registrationNo: json['registration_no'] as String? ?? '',
      chassisNo: json['chassis_no'] as String? ?? '',
      engineNo: json['engine_no'] as String? ?? '',
      registeredRto: json['registered_rto'] as String? ?? '',
      variant: json['variant'] as String? ?? '',
      transmission: json['transmission'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      fuelType: json['fuel_type'] as String? ?? '',
      kilometers: (json['kilometers'] as num?)?.toInt() ?? 0,
      colour: json['colour'] as String? ?? '',
      marketValue: json['market_value'] as String? ?? '0.00',
      maxBids: (json['max_bids'] as num?)?.toInt() ?? 0,
      images: rawImages
          .map(_resolveImageUrl)
          .where((url) => url.isNotEmpty)
          .toList(),
      minimumPrice: (json['minimum_price'] as num?)?.toInt() ?? 0,
      reservePrice: (json['reserve_price'] as num?)?.toInt() ?? 0,
      owner: json['owner'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      category: json['category'] as String? ?? '',
      yardName: json['yard_name'] as String? ?? '',
      yardLocation: json['yard_location'] as String? ?? '',
      contactPersonName: json['contact_person_name'] as String? ?? '',
      contactPersonNumber: json['contact_person_number'] as String? ?? '',
      yourBid: (json['your_bid'] as num?)?.toInt() ?? 0,
      bidsLeft: (json['bids_left'] as num?)?.toInt() ?? 0,
      bidsReceived: (json['bids_received'] as num?)?.toInt() ?? 0,
      currentHighestBid: (json['current_highest_bid'] as num?)?.toInt(),
      currentBid: (json['current_bid'] as num?)?.toInt(),
      availableBalance: (json['available_balance'] as num?)?.toInt() ?? 0,
      maxUserVehiclesBidLimit:
          (json['max_user_vehicles_bid_limit'] as num?)?.toInt() ?? 10,
      userVehicleBidCount:
          (json['user_vehicle_bid_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      insertedAt: json['inserted_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  String get displayTitle => '$make $model'.trim();
}

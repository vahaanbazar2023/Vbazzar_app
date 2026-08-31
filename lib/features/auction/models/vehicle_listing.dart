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
  final int? minimumNextBid;
  final int? bidIncrementAmount;
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
    this.minimumNextBid,
    this.bidIncrementAmount,
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
      vehicleId: json['vehicle_id']?.toString() ?? '',
      auctionId: json['auction_id']?.toString() ?? '',
      sellerReference: json['seller_reference']?.toString() ?? '',
      repoDate: json['repo_date']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      registrationNo: json['registration_no']?.toString() ?? '',
      chassisNo: json['chassis_no']?.toString() ?? '',
      engineNo: json['engine_no']?.toString() ?? '',
      registeredRto: json['registered_rto']?.toString() ?? '',
      variant: json['variant']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      fuelType: json['fuel_type']?.toString() ?? '',
      kilometers: (json['kilometers'] as num?)?.toInt() ?? 0,
      colour: json['colour']?.toString() ?? '',
      marketValue: json['market_value']?.toString() ?? '0.00',
      maxBids: (json['max_bids'] as num?)?.toInt() ?? 0,
      images: rawImages
          .map(_resolveImageUrl)
          .where((url) => url.isNotEmpty)
          .toList(),
      minimumPrice: (json['minimum_price'] as num?)?.toInt() ?? 0,
      reservePrice: (json['reserve_price'] as num?)?.toInt() ?? 0,
      owner: json['owner']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      yardName: json['yard_name']?.toString() ?? '',
      yardLocation: json['yard_location']?.toString() ?? '',
      contactPersonName: json['contact_person_name']?.toString() ?? '',
      contactPersonNumber: json['contact_person_number']?.toString() ?? '',
      yourBid: (json['your_bid'] as num?)?.toInt() ?? 0,
      bidsLeft: (json['bids_left'] as num?)?.toInt() ?? 0,
      bidsReceived: (json['bids_received'] as num?)?.toInt() ?? 0,
      currentHighestBid: _parseInt(json['current_highest_bid']),
      currentBid: _parseInt(json['current_bid']),
      minimumNextBid: _parseInt(json['minimum_next_bid']),
      bidIncrementAmount: _parseInt(json['bid_increment_amount']),
      availableBalance: (json['available_balance'] as num?)?.toInt() ?? 0,
      maxUserVehiclesBidLimit:
          (json['max_user_vehicles_bid_limit'] as num?)?.toInt() ?? 10,
      userVehicleBidCount:
          (json['user_vehicle_bid_count'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      insertedAt: json['inserted_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  String get displayTitle => '$make $model'.trim();

  /// Safely converts any value to int — returns null for non-numeric strings
  /// like "high" that the API sometimes sends for bid fields.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    return parsed; // null for "high", "low", etc.
  }
}

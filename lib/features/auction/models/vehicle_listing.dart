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

  /// Bank the vehicle belongs to; the API sends "NIL" when not applicable.
  final String bankName;
  final String yardLocation;
  final String contactPersonName;
  final String contactPersonNumber;
  final String rcAvailability;
  final String transactionFees;
  final String parkingCharges;
  final int yourBid;
  final int bidsLeft;
  final int bidsReceived;
  final int? currentHighestBid;
  final int? currentBid;
  final int? minimumNextBid;
  final int? bidIncrementAmount;
  final String auctionEndDate;
  final int availableBalance;
  final int maxUserVehiclesBidLimit;
  final int userVehicleBidCount;
  final bool isWishlisted;

  /// On the user's auction watchlist (separate from the wishlist).
  final bool isWatchlisted;

  /// Auto-bid is switched on: the server re-bids for the user whenever they are outbid.
  final bool isAutoBidEnabled;

  /// The user's auto-bid limit for this vehicle while auto-bid is on; null = up to the whole buying limit.
  final int? autoBidMaxAmount;
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
    this.rcAvailability = '',
    this.bankName = '',
    this.transactionFees = '0.00',
    this.parkingCharges = '0.00',
    required this.yourBid,
    required this.bidsLeft,
    required this.bidsReceived,
    this.currentHighestBid,
    this.currentBid,
    this.minimumNextBid,
    this.bidIncrementAmount,
    this.auctionEndDate = '',
    required this.availableBalance,
    required this.maxUserVehiclesBidLimit,
    required this.userVehicleBidCount,
    this.isWishlisted = false,
    this.isWatchlisted = false,
    this.isAutoBidEnabled = false,
    this.autoBidMaxAmount,
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
    const baseUrl = 'https://q7imfgydpj.ap-south-1.awsapprunner.com';
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
      bankName: json['bank_name']?.toString() ?? '',
      yardLocation: json['yard_location']?.toString() ?? '',
      contactPersonName: json['contact_person_name']?.toString() ?? '',
      contactPersonNumber: json['contact_person_number']?.toString() ?? '',
      rcAvailability: json['rc_availability']?.toString() ?? '',
      transactionFees: json['transaction_fees']?.toString() ?? '0.00',
      parkingCharges: json['parking_charges']?.toString() ?? '0.00',
      yourBid: (json['your_bid'] as num?)?.toInt() ?? 0,
      bidsLeft: (json['bids_left'] as num?)?.toInt() ?? 0,
      bidsReceived: (json['bids_received'] as num?)?.toInt() ?? 0,
      currentHighestBid: _parseInt(json['current_highest_bid']),
      currentBid: _parseInt(json['current_bid']),
      minimumNextBid: _parseInt(json['minimum_next_bid']),
      bidIncrementAmount: _parseInt(json['bid_increment_amount']),
      auctionEndDate: json['auction_end_date']?.toString() ?? '',
      availableBalance: (json['available_balance'] as num?)?.toInt() ?? 0,
      maxUserVehiclesBidLimit:
          (json['max_user_vehicles_bid_limit'] as num?)?.toInt() ?? 10,
      userVehicleBidCount:
          (json['user_vehicle_bid_count'] as num?)?.toInt() ?? 0,
      isWishlisted: json['is_wishlisted'] == true,
      isWatchlisted: json['is_watchlisted'] == true,
      isAutoBidEnabled: json['is_auto_bid_enabled'] == true,
      autoBidMaxAmount: _parseInt(json['auto_bid_max_amount']),
      status: json['status']?.toString() ?? '',
      insertedAt: json['inserted_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  String get displayTitle => '$make $model'.trim();

  static const Object _keep = Object();

  /// What the user can spend on this vehicle: free buying limit plus the bid already held on it.
  int get buyingLimitForVehicle => availableBalance + yourBid;

  /// Lowest auto-bid limit worth setting: the next bid if losing, one step above own bid if on top.
  int get minimumAutoBidLimit {
    final step = (bidIncrementAmount ?? 0) > 0 ? bidIncrementAmount! : 1;
    final onTop = yourBid > 0 && yourBid >= (currentHighestBid ?? 0);
    if (onTop) return yourBid + step;
    return minimumNextBid ??
        ((currentHighestBid ?? 0) > 0
            ? currentHighestBid! + step
            : minimumPrice);
  }

  /// Copy with the fields that change on the client after an action (wishlist / watchlist / auto-bid / bid).
  VehicleListing copyWith({
    bool? isWishlisted,
    bool? isWatchlisted,
    bool? isAutoBidEnabled,
    int? yourBid,
    int? userVehicleBidCount,
    int? currentHighestBid,
    int? availableBalance,
    // Nullable field: pass a value (or null to clear); leave out to keep the current one.
    Object? autoBidMaxAmount = _keep,
  }) => VehicleListing(
    id: id,
    vehicleId: vehicleId,
    auctionId: auctionId,
    sellerReference: sellerReference,
    repoDate: repoDate,
    make: make,
    model: model,
    year: year,
    registrationNo: registrationNo,
    chassisNo: chassisNo,
    engineNo: engineNo,
    registeredRto: registeredRto,
    variant: variant,
    transmission: transmission,
    vehicleType: vehicleType,
    fuelType: fuelType,
    kilometers: kilometers,
    colour: colour,
    marketValue: marketValue,
    maxBids: maxBids,
    images: images,
    minimumPrice: minimumPrice,
    reservePrice: reservePrice,
    owner: owner,
    remarks: remarks,
    category: category,
    yardName: yardName,
    bankName: bankName,
    yardLocation: yardLocation,
    contactPersonName: contactPersonName,
    contactPersonNumber: contactPersonNumber,
    rcAvailability: rcAvailability,
    transactionFees: transactionFees,
    parkingCharges: parkingCharges,
    yourBid: yourBid ?? this.yourBid,
    bidsLeft: bidsLeft,
    bidsReceived: bidsReceived,
    currentHighestBid: currentHighestBid ?? this.currentHighestBid,
    currentBid: currentBid,
    minimumNextBid: minimumNextBid,
    bidIncrementAmount: bidIncrementAmount,
    auctionEndDate: auctionEndDate,
    availableBalance: availableBalance ?? this.availableBalance,
    maxUserVehiclesBidLimit: maxUserVehiclesBidLimit,
    userVehicleBidCount: userVehicleBidCount ?? this.userVehicleBidCount,
    isWishlisted: isWishlisted ?? this.isWishlisted,
    isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    isAutoBidEnabled: isAutoBidEnabled ?? this.isAutoBidEnabled,
    autoBidMaxAmount: identical(autoBidMaxAmount, _keep)
        ? this.autoBidMaxAmount
        : autoBidMaxAmount as int?,
    status: status,
    insertedAt: insertedAt,
    updatedAt: updatedAt,
  );

  /// Bank to show in the UI: empty when there is none (the API sends "NIL" for "not applicable").
  String get displayBankName {
    final t = bankName.trim();
    return t.toUpperCase() == 'NIL' ? '' : t;
  }

  /// Safely converts any value to int — returns null for non-numeric strings
  /// like "high" that the API sometimes sends for bid fields.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    return parsed; // null for "high", "low", etc.
  }
}

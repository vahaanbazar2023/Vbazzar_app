import '../../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';

/// Mechanic entity returned by the list-mechanics API.
class Mechanic {
  final int id;
  final String mechanicId;
  final String description;
  final String garageName;
  final String mechanicName;
  final String addressLine1;
  final String addressLine2;
  final String state;
  final String pinCode;
  final String mobileNumber;
  final double latitude;
  final double longitude;
  final String priority;
  final String starRating;
  final double distanceKm;

  const Mechanic({
    required this.id,
    required this.mechanicId,
    required this.description,
    required this.garageName,
    required this.mechanicName,
    required this.addressLine1,
    required this.addressLine2,
    required this.state,
    required this.pinCode,
    required this.mobileNumber,
    required this.latitude,
    required this.longitude,
    required this.priority,
    required this.starRating,
    required this.distanceKm,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) => Mechanic(
    id: (json['id'] as num?)?.toInt() ?? 0,
    mechanicId: json['mechanic_id']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    garageName: json['garage_name']?.toString() ?? '',
    mechanicName: json['mechanic_name']?.toString() ?? '',
    addressLine1: json['address_line_1']?.toString() ?? '',
    addressLine2: json['address_line_2']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    pinCode: json['pin_code']?.toString() ?? '',
    mobileNumber: json['mobile_number']?.toString() ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    priority: json['priority']?.toString() ?? '',
    starRating: json['star_rating']?.toString() ?? '0',
    distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mechanic_id': mechanicId,
    'description': description,
    'garage_name': garageName,
    'mechanic_name': mechanicName,
    'address_line_1': addressLine1,
    'address_line_2': addressLine2,
    'state': state,
    'pin_code': pinCode,
    'mobile_number': mobileNumber,
    'latitude': latitude,
    'longitude': longitude,
    'priority': priority,
    'star_rating': starRating,
    'distance_km': distanceKm,
  };

  // ── computed helpers ──────────────────────────────────────────────

  /// Full comma-separated address (skips empty parts).
  String get fullAddress {
    final parts = <String>[
      if (addressLine1.isNotEmpty) addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      if (state.isNotEmpty) state,
      if (pinCode.isNotEmpty) pinCode,
    ];
    return parts.join(', ');
  }

  /// Star rating parsed to double.
  double get rating => double.tryParse(starRating) ?? 0.0;

  /// Whether the mobile number is a real usable number.
  bool get hasValidMobile =>
      mobileNumber.isNotEmpty && mobileNumber != 'null' && mobileNumber != '0';

  /// Whether this mechanic has high priority.
  bool get isPriorityHigh => priority.toLowerCase() == 'high';

  /// Human-readable distance label.
  String get distanceLabel {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Service specializations as a list.
  List<String> get serviceTypes {
    if (description.isEmpty) return [];
    return description
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

// ── Paginated wrapper ──────────────────────────────────────────────

class MechanicsData {
  final UserLocation? userLocation;
  final int count;
  final List<Mechanic> mechanics;
  final List<ListingAd> ads;
  final PaginationInfo pagination;

  const MechanicsData({
    this.userLocation,
    required this.count,
    required this.mechanics,
    this.ads = const [],
    required this.pagination,
  });

  factory MechanicsData.fromJson(Map<String, dynamic> json) {
    final rawList = json['mechanics'] as List<dynamic>? ?? [];
    final mechanicsList = <Mechanic>[];
    final adsList = <ListingAd>[];

    for (final item in rawList) {
      final map = item as Map<String, dynamic>;
      if (map['is_advertisement'] == true) {
        adsList.add(ListingAd.fromJson(map));
      } else {
        mechanicsList.add(Mechanic.fromJson(map));
      }
    }

    return MechanicsData(
      userLocation: json['user_location'] != null
          ? UserLocation.fromJson(json['user_location'] as Map<String, dynamic>)
          : null,
      count: (json['count'] as num?)?.toInt() ?? 0,
      mechanics: mechanicsList,
      ads: adsList,
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>)
          : const PaginationInfo(),
    );
  }
}

class UserLocation {
  final double lat;
  final double lon;

  const UserLocation({required this.lat, required this.lon});

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
    lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
    lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
  );
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationInfo({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.limit = 20,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
    totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    limit: (json['limit'] as num?)?.toInt() ?? 20,
    hasNext: json['has_next'] as bool? ?? false,
    hasPrevious: json['has_previous'] as bool? ?? false,
  );
}

// ── Mechanic subscription data ─────────────────────────────────────

class MechanicSubscriptionData {
  final int id;
  final String userId;
  final String mechanicId;
  final String mechanicNumberAccess;
  final String operation;
  final String insertedAt;
  final String modifiedAt;

  const MechanicSubscriptionData({
    required this.id,
    required this.userId,
    required this.mechanicId,
    required this.mechanicNumberAccess,
    required this.operation,
    required this.insertedAt,
    required this.modifiedAt,
  });

  factory MechanicSubscriptionData.fromJson(Map<String, dynamic> json) =>
      MechanicSubscriptionData(
        id: (json['id'] as num?)?.toInt() ?? 0,
        userId: json['user_id']?.toString() ?? '',
        mechanicId: json['mechanic_id']?.toString() ?? '',
        mechanicNumberAccess: json['mechanic_number_access']?.toString() ?? '',
        operation: json['operation']?.toString() ?? '',
        insertedAt: json['inserted_at']?.toString() ?? '',
        modifiedAt: json['modified_at']?.toString() ?? '',
      );
}

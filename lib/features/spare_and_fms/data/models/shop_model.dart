import '../../domain/entities/shop_entity.dart';

/// Data model for [ShopEntity] – handles JSON serialization.
class ShopModel extends ShopEntity {
  const ShopModel({
    required super.id,
    required super.shopId,
    required super.shopName,
    required super.addressLine1,
    required super.addressLine2,
    required super.state,
    required super.mobileNumber,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.category,
    required super.status,
    required super.priority,
    required super.starRating,
    required super.distanceKm,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      shopId: json['shop_id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? '',
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String? ?? '',
      state: json['state'] as String? ?? '',
      mobileNumber: json['mobile_number'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      starRating: json['star_rating'] as String? ?? '0',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'shop_name': shopName,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'state': state,
      'mobile_number': mobileNumber,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'category': category,
      'status': status,
      'priority': priority,
      'star_rating': starRating,
      'distance_km': distanceKm,
    };
  }
}

/// Pagination model for shops list.
class ShopPaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const ShopPaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ShopPaginationModel.fromJson(Map<String, dynamic> json) {
    return ShopPaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }
}

/// Data model for [UserLocationEntity].
class UserLocationModel extends UserLocationEntity {
  const UserLocationModel({
    required super.latitude,
    required super.longitude,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Wrapper for the list-shops API response data.
class ShopListData {
  final UserLocationModel? userLocation;
  final int count;
  final List<ShopModel> shops;
  final ShopPaginationModel pagination;

  const ShopListData({
    this.userLocation,
    required this.count,
    required this.shops,
    required this.pagination,
  });

  factory ShopListData.fromJson(Map<String, dynamic> json) {
    return ShopListData(
      userLocation: json['user_location'] != null
          ? UserLocationModel.fromJson(
              json['user_location'] as Map<String, dynamic>)
          : null,
      count: (json['count'] as num?)?.toInt() ?? 0,
      shops: (json['shops'] as List<dynamic>? ?? [])
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: ShopPaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
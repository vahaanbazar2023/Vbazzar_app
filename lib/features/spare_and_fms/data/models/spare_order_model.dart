import '../../domain/entities/spare_order_entity.dart';
/// Data model for [SpareOrderEntity] – handles JSON serialization.
class SpareOrderModel extends SpareOrderEntity {
  const SpareOrderModel({
    required super.id,
    required super.spareOrderId,
    required super.orderStatus,
    required super.orderInsertedAt,
    required super.orderModifiedAt,
    required super.spareId,
    required super.spareName,
    required super.spareDescription,
    required super.suitsFor,
    required super.price,
    required super.photos,
    required super.spareStatus,
    required super.starRating,
    required super.spareInsertedAt,
    required super.spareModifiedAt,
  });

  factory SpareOrderModel.fromJson(Map<String, dynamic> json) {
    return SpareOrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      spareOrderId: json['spare_order_id'] as String? ?? '',
      orderStatus: json['order_status'] as String? ?? '',
      orderInsertedAt: json['order_inserted_at'] as String? ?? '',
      orderModifiedAt: json['order_modified_at'] as String? ?? '',
      spareId: json['spare_id'] as String? ?? '',
      spareName: json['spare_name'] as String? ?? '',
      spareDescription: json['spare_description'] as String? ?? '',
      suitsFor: json['suits_for'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      photos: _parsePhotos(json['photos']),
      spareStatus: json['spare_status'] as String? ?? '',
      starRating: json['star_rating'] as String? ?? '0',
      spareInsertedAt: json['spare_inserted_at'] as String? ?? '',
      spareModifiedAt: json['spare_modified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spare_order_id': spareOrderId,
      'order_status': orderStatus,
      'order_inserted_at': orderInsertedAt,
      'order_modified_at': orderModifiedAt,
      'spare_id': spareId,
      'spare_name': spareName,
      'spare_description': spareDescription,
      'suits_for': suitsFor,
      'price': price,
      'photos': photos.join(','),
      'spare_status': spareStatus,
      'star_rating': starRating,
      'spare_inserted_at': spareInsertedAt,
      'spare_modified_at': spareModifiedAt,
    };
  }

  /// Photos can be a comma-separated string OR a JSON list.
  static List<String> _parsePhotos(dynamic photos) {
    if (photos == null) return [];
    if (photos is String) {
      return photos
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (photos is List) {
      return List<String>.from(photos.map((e) => e.toString()));
    }
    return [];
  }
}

/// Pagination model for spare orders list.
class SpareOrderPaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const SpareOrderPaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory SpareOrderPaginationModel.fromJson(Map<String, dynamic> json) {
    return SpareOrderPaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }
}

/// Wrapper for the user-spares-orders-listing API response data.
class SpareOrderListData {
  final List<SpareOrderModel> orders;
  final SpareOrderPaginationModel pagination;

  const SpareOrderListData({
    required this.orders,
    required this.pagination,
  });

  factory SpareOrderListData.fromJson(Map<String, dynamic> json) {
    return SpareOrderListData(
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((e) => SpareOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: SpareOrderPaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
import '../../domain/entities/spare_part_entity.dart';

/// Data model for [SparePartEntity] – handles JSON serialization.
class SparePartModel extends SparePartEntity {
  const SparePartModel({
    required super.id,
    required super.sparePartId,
    required super.spareName,
    required super.spareDescription,
    required super.suitsFor,
    required super.price,
    required super.photos,
    required super.status,
    required super.starRating,
    required super.insertedAt,
    required super.modifiedBy,
    required super.modifiedAt,
  });

  factory SparePartModel.fromJson(Map<String, dynamic> json) {
    return SparePartModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sparePartId: json['spare_part_id'] as String? ?? '',
      spareName: json['spare_name'] as String? ?? '',
      spareDescription: json['spare_description'] as String? ?? '',
      suitsFor: json['suits_for'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      photos: _parsePhotos(json['photos']),
      status: json['status'] as String? ?? '',
      starRating: json['star_rating'] as String? ?? '0',
      insertedAt: json['inserted_at'] as String? ?? '',
      modifiedBy: json['modified_by'] as String? ?? '',
      modifiedAt: json['modified_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spare_part_id': sparePartId,
      'spare_name': spareName,
      'spare_description': spareDescription,
      'suits_for': suitsFor,
      'price': price,
      'photos': photos.join(','),
      'status': status,
      'star_rating': starRating,
      'inserted_at': insertedAt,
      'modified_by': modifiedBy,
      'modified_at': modifiedAt,
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

/// Pagination model for spare parts list.
class SparePartPaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const SparePartPaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory SparePartPaginationModel.fromJson(Map<String, dynamic> json) {
    return SparePartPaginationModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }
}

/// Wrapper for the list-spares API response data.
class SparePartListData {
  final int count;
  final List<SparePartModel> spares;
  final SparePartPaginationModel pagination;

  const SparePartListData({
    required this.count,
    required this.spares,
    required this.pagination,
  });

  factory SparePartListData.fromJson(Map<String, dynamic> json) {
    return SparePartListData(
      count: (json['count'] as num?)?.toInt() ?? 0,
      spares: (json['spares'] as List<dynamic>? ?? [])
          .map((e) => SparePartModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: SparePartPaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
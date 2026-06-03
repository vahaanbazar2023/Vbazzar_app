import 'spare_part_entity.dart';

/// Domain entity representing a user's spare part order/booking.
class SpareOrderEntity {
  final int id;
  final String spareOrderId;
  final String orderStatus;
  final String orderInsertedAt;
  final String orderModifiedAt;
  final String spareId;
  final String spareName;
  final String spareDescription;
  final String suitsFor;
  final String price;
  final List<String> photos;
  final String spareStatus;
  final String starRating;
  final String spareInsertedAt;
  final String spareModifiedAt;

  const SpareOrderEntity({
    required this.id,
    required this.spareOrderId,
    required this.orderStatus,
    required this.orderInsertedAt,
    required this.orderModifiedAt,
    required this.spareId,
    required this.spareName,
    required this.spareDescription,
    required this.suitsFor,
    required this.price,
    required this.photos,
    required this.spareStatus,
    required this.starRating,
    required this.spareInsertedAt,
    required this.spareModifiedAt,
  });

  /// First photo URL or empty string.
  String get primaryPhoto => photos.isNotEmpty ? photos.first : '';

  /// Parsed price as double.
  double get priceAsDouble => double.tryParse(price) ?? 0;

  /// Convert to [SparePartEntity] for detail view compatibility.
  SparePartEntity toSparePartEntity() {
    return SparePartEntity(
      id: id,
      sparePartId: spareId,
      spareName: spareName,
      spareDescription: spareDescription,
      suitsFor: suitsFor,
      price: price,
      photos: photos,
      status: spareStatus,
      starRating: starRating,
      insertedAt: spareInsertedAt,
      modifiedBy: '',
      modifiedAt: spareModifiedAt,
    );
  }

  /// Formatted price string.
  String get formattedPrice {
    final p = priceAsDouble;
    if (p <= 0) return '₹0';
    return '₹${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}
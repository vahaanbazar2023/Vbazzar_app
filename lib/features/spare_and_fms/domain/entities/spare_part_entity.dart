/// Domain entity representing a spare part item.
class SparePartEntity {
  final int id;
  final String sparePartId;
  final String spareName;
  final String spareDescription;
  final String suitsFor;
  final String price;
  final List<String> photos;
  final String status;
  final String starRating;
  final String insertedAt;
  final String modifiedBy;
  final String modifiedAt;

  const SparePartEntity({
    required this.id,
    required this.sparePartId,
    required this.spareName,
    required this.spareDescription,
    required this.suitsFor,
    required this.price,
    required this.photos,
    required this.status,
    required this.starRating,
    required this.insertedAt,
    required this.modifiedBy,
    required this.modifiedAt,
  });

  /// First photo URL or empty string.
  String get primaryPhoto => photos.isNotEmpty ? photos.first : '';

  /// Parsed price as double.
  double get priceAsDouble => double.tryParse(price) ?? 0;

  /// Parsed rating as double.
  double get ratingAsDouble => double.tryParse(starRating) ?? 0;

  /// Formatted price string.
  String get formattedPrice {
    final p = priceAsDouble;
    if (p <= 0) return '₹0';
    return '₹${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}
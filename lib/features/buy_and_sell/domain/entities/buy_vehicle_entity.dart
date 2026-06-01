class BuyVehicleEntity {
  final String id;
  final String categoryCode;
  final String categoryName;
  final String? brandCode;
  final String? brandName;
  final String? model;
  final String? year;
  final String? tonnage;
  final String? kv;
  final String? noOfTyres;
  final String? fuelType;
  final String? bodyType;
  final String? state;
  final String? imageUrl;
  final String? status;
  final double? price;
  final String? city;
  final List<String> imageUrls;
  final List<String> vehicleFileUrls;

  const BuyVehicleEntity({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    this.brandCode,
    this.brandName,
    this.model,
    this.year,
    this.tonnage,
    this.kv,
    this.noOfTyres,
    this.fuelType,
    this.bodyType,
    this.state,
    this.imageUrl,
    this.status,
    this.price,
    this.city,
    this.imageUrls = const [],
    this.vehicleFileUrls = const [],
  });

  /// Backward-compatible alias used by some views.
  String get sbVehicleId => id;

  /// Backward-compatible alias for year as int.
  int get manufacturingYear => int.tryParse(year ?? '') ?? 0;

  /// All image URLs merged (vehicle files first, then additional imageUrls).
  List<String> get allImageUrls {
    final all = <String>[...vehicleFileUrls, ...imageUrls];
    if (all.isEmpty && imageUrl != null && imageUrl!.isNotEmpty) {
      all.add(imageUrl!);
    }
    return all;
  }

  /// Formatted price string, e.g. "₹12,50,000".
  String get formattedPrice {
    if (price == null || price! <= 0) return 'Price on request';
    return '₹${_formatNumber(price!.toInt())}';
  }

  static String _formatNumber(int n) {
    if (n >= 10000000) {
      return '${(n / 10000000).toStringAsFixed(2)} Cr';
    } else if (n >= 100000) {
      return '${(n / 100000).toStringAsFixed(2)} L';
    } else if (n >= 1000) {
      final s = n.toString();
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return rest.isNotEmpty ? '$rest,$last3' : last3;
    }
    return n.toString();
  }
}
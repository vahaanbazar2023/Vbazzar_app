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

  /// Formatted price string with Indian comma formatting, e.g. "₹25,00,000".
  String get formattedPrice {
    if (price == null || price! <= 0) return 'Price on request';
    return '₹${_formatNumber(price!.toInt())}';
  }

  /// Indian number formatting — inserts commas at thousands, then every 2 digits.
  static String _formatNumber(int n) {
    if (n <= 0) return '0';
    final s = n.toString();
    if (s.length <= 3) return s;

    // Last 3 digits
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);

    // Remaining digits grouped in pairs from the right
    final buffer = StringBuffer();
    int count = 0;
    for (int i = rest.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
      count++;
    }
    final prefix = buffer.toString().split('').reversed.join();
    return '$prefix,$last3';
  }
}

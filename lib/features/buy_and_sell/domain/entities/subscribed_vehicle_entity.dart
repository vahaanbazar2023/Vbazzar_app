class SubscribedVehicleEntity {
  final String id;
  final String vehicleId;
  final String? categoryCode;
  final String? categoryName;
  final String? brandName;
  final String? model;
  final String? year;
  final String? imageUrl;
  final String? subscriptionDate;
  final String? status;
  // Extended fields from new API
  final double? price;
  final String? ownerMobile;
  final String? location;
  final int? manufacturingYear;
  final String? registrationNumber;
  final List<String> imageUrls;
  final String? ownerDetailsAccess;
  final String? inspectionRequested;
  final String? subscriptionStatus;

  const SubscribedVehicleEntity({
    required this.id,
    required this.vehicleId,
    this.categoryCode,
    this.categoryName,
    this.brandName,
    this.model,
    this.year,
    this.imageUrl,
    this.subscriptionDate,
    this.status,
    this.price,
    this.ownerMobile,
    this.location,
    this.manufacturingYear,
    this.registrationNumber,
    this.imageUrls = const [],
    this.ownerDetailsAccess,
    this.inspectionRequested,
    this.subscriptionStatus,
  });

  String get sbVehicleId => vehicleId;

  String get formattedPrice {
    if (price == null || price! <= 0) return 'Price on request';
    return '₹${_formatNumber(price!.toInt())}';
  }

  static String _formatNumber(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(2)} Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(2)} L';
    if (n >= 1000) {
      final s = n.toString();
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return rest.isNotEmpty ? '$rest,$last3' : last3;
    }
    return n.toString();
  }
}

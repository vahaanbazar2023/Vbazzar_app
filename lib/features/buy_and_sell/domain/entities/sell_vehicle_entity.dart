class SellVehicleEntity {
  final String id;
  final String? categoryCode;
  final String? categoryName;
  final String? brandCode;
  final String? brandName;
  final String? model;
  final String? year;
  final String? status;
  final String? imageUrl;
  final String? createdAt;
  final double? askingPrice;
  final String? registrationNumber;
  final String? approved;
  final String? isSold;
  final double? price;

  const SellVehicleEntity({
    required this.id,
    this.categoryCode,
    this.categoryName,
    this.brandCode,
    this.brandName,
    this.model,
    this.year,
    this.status,
    this.imageUrl,
    this.createdAt,
    this.askingPrice,
    this.registrationNumber,
    this.approved,
    this.isSold,
    this.price,
  });

  /// Backward-compatible alias used by views.
  String get sbVehicleId => id;

  /// Primary image URL for display.
  String get primaryImageUrl => imageUrl ?? '';

  /// Formatted price string, e.g. "₹12,50,000".
  String get formattedPrice {
    final p = price ?? askingPrice;
    if (p == null || p <= 0) return 'Price on request';
    return '₹${_formatNumber(p.toInt())}';
  }

  /// Human-readable status label.
  String get statusLabel {
    if (isSold == 'yes') return 'Sold';
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  /// Whether the vehicle has been marked as sold.
  bool get isVehicleSold => isSold == 'yes';

  /// Whether the vehicle status is pending.
  bool get isPending => status == 'pending';

  /// Whether the vehicle status is approved.
  bool get isApproved => status == 'approved' || approved == 'yes';

  /// Whether the vehicle status is rejected.
  bool get isRejected => status == 'rejected';

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
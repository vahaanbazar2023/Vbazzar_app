/// Domain entity representing a shop in the FMS system.
class ShopEntity {
  final int id;
  final String shopId;
  final String shopName;
  final String addressLine1;
  final String addressLine2;
  final String state;
  final String mobileNumber;
  final double latitude;
  final double longitude;
  final String type;
  final String category;
  final String status;
  final String priority;
  final String starRating;
  final double distanceKm;

  /// "yes" if the current user has already paid for mobile number access.
  final String numberAccessSubscription;

  /// Per-category plan code for the contact subscription (SUBT006).
  final String? subscriptionPlanCode;

  /// Subscription amount for this shop's contact plan.
  final double? subscriptionAmount;

  const ShopEntity({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.addressLine1,
    required this.addressLine2,
    required this.state,
    required this.mobileNumber,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.category,
    required this.status,
    required this.priority,
    required this.starRating,
    required this.distanceKm,
    this.numberAccessSubscription = 'no',
    this.subscriptionPlanCode,
    this.subscriptionAmount,
  });

  /// True when the user has paid for mobile number access.
  bool get hasMobileAccess => numberAccessSubscription.toLowerCase() == 'yes';

  /// Parsed rating as double.
  double get ratingAsDouble => double.tryParse(starRating) ?? 0;

  /// Full address string.
  String get fullAddress {
    final parts = <String>[];
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2.isNotEmpty) parts.add(addressLine2);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  /// Whether the shop has a valid mobile number.
  bool get hasValidMobileNumber =>
      mobileNumber.isNotEmpty && mobileNumber != 'null' && mobileNumber != '0';

  /// Formatted distance string.
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
}

/// User GPS location entity.
class UserLocationEntity {
  final double latitude;
  final double longitude;

  const UserLocationEntity({required this.latitude, required this.longitude});
}

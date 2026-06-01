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
  });

  /// Alias for [vehicleId] to match controller expectations.
  String get sbVehicleId => vehicleId;
}

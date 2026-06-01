class VehicleBrandEntity {
  final String brandCode;
  final String brandName;
  final String? categoryCode;

  const VehicleBrandEntity({
    required this.brandCode,
    required this.brandName,
    this.categoryCode,
  });
}

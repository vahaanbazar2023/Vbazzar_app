/// Pure domain entity for Approved Vehicle Category.
/// Has no dependency on JSON or API concerns.
class ApprovedVehicleCategoryEntity {
  final int id;
  final String categoryCode;
  final String categoryName;
  final String status;
  final double subscriptionAmount;
  final String categoryPlan;
  final int sortingOrder;
  final String iconName;
  final int approvedVehAvailableCount;
  final DateTime? insertedAt;
  final DateTime? modifiedAt;
  final String insertedBy;
  final String? modifiedBy;

  const ApprovedVehicleCategoryEntity({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    required this.status,
    required this.subscriptionAmount,
    required this.categoryPlan,
    required this.sortingOrder,
    required this.iconName,
    required this.approvedVehAvailableCount,
    this.insertedAt,
    this.modifiedAt,
    required this.insertedBy,
    this.modifiedBy,
  });

  /// Whether this category has active listings
  bool get hasAvailableVehicles => approvedVehAvailableCount > 0;

  /// Whether this category is active
  bool get isActive => status.toLowerCase() == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovedVehicleCategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ApprovedVehicleCategoryEntity(id: $id, code: $categoryCode, name: $categoryName)';
}
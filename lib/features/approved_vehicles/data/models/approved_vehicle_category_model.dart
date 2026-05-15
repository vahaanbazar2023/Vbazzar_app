import '../../domain/entities/approved_vehicle_category_entity.dart';

/// Data Transfer Object for Approved Vehicle Category.
/// Handles JSON deserialization and maps to the domain entity.
class ApprovedVehicleCategoryModel extends ApprovedVehicleCategoryEntity {
  const ApprovedVehicleCategoryModel({
    required super.id,
    required super.categoryCode,
    required super.categoryName,
    required super.status,
    required super.subscriptionAmount,
    required super.categoryPlan,
    required super.sortingOrder,
    required super.iconName,
    required super.approvedVehAvailableCount,
    super.insertedAt,
    super.modifiedAt,
    required super.insertedBy,
    super.modifiedBy,
  });

  factory ApprovedVehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    return ApprovedVehicleCategoryModel(
      id: _parseInt(json['id']),
      categoryCode: json['category_code']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subscriptionAmount: _parseDouble(json['subscription_amount']),
      categoryPlan: json['category_plan']?.toString() ?? '',
      sortingOrder: _parseInt(json['sorting_order']),
      iconName: json['icon_name']?.toString() ?? '',
      approvedVehAvailableCount:
          _parseInt(json['approved_veh_available_count']),
      insertedAt: _parseDateTime(json['inserted_at']),
      modifiedAt: _parseDateTime(json['modified_at']),
      insertedBy: json['inserted_by']?.toString() ?? '',
      modifiedBy: json['modified_by']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
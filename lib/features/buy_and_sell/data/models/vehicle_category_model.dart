import '../../domain/entities/vehicle_category_entity.dart';

/// Data model for [VehicleCategoryEntity].
class VehicleCategoryModel extends VehicleCategoryEntity {
  const VehicleCategoryModel({
    required super.categoryCode,
    required super.categoryName,
    super.description,
    super.imageUrl,
    super.iconUrl,
    super.sortOrder,
    super.vehicleCount,
    super.categoryPlan,
    super.subscriptionAmount,
  });

  factory VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryModel(
      categoryCode: json['category_code']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      iconUrl: json['icon_url']?.toString() ?? json['icon_name']?.toString(),
      sortOrder: _parseInt(json['sort_order'] ?? json['sorting_order']),
      vehicleCount: _parseInt(json['vehicle_count']),
      categoryPlan: json['category_plan']?.toString(),
      subscriptionAmount: json['subscription_amount'] is num
          ? (json['subscription_amount'] as num).toDouble()
          : double.tryParse(json['subscription_amount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'category_code': categoryCode,
    'category_name': categoryName,
    'description': description,
    'image_url': imageUrl,
    'icon_url': iconUrl,
    'sort_order': sortOrder,
    'vehicle_count': vehicleCount,
  };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Data model for [FormFieldConfigEntity].
class FormFieldConfigModel extends FormFieldConfigEntity {
  const FormFieldConfigModel({
    required super.fieldName,
    required super.fieldType,
    super.required,
    super.options,
    super.placeholder,
    super.defaultValue,
    super.validationRegex,
    super.apiFieldName,
  });

  factory FormFieldConfigModel.fromJson(Map<String, dynamic> json) {
    return FormFieldConfigModel(
      fieldName: json['field_name']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? 'text',
      required: json['required'] == true || json['required'] == 'true',
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      placeholder: json['placeholder']?.toString(),
      defaultValue: json['default_value'],
      validationRegex: json['validation_regex']?.toString(),
      apiFieldName: json['api_field_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'field_name': fieldName,
    'field_type': fieldType,
    'required': required,
    'options': options,
    'placeholder': placeholder,
    'default_value': defaultValue,
    'validation_regex': validationRegex,
    'api_field_name': apiFieldName,
  };
}

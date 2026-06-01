class VehicleCategoryEntity {
  final String categoryCode;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final String? iconUrl;
  final int sortOrder;
  final int vehicleCount;

  const VehicleCategoryEntity({
    required this.categoryCode,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.iconUrl,
    this.sortOrder = 0,
    this.vehicleCount = 0,
  });
}

/// Configuration for a dynamic form field returned by the API.
class FormFieldConfigEntity {
  final String fieldName;
  final String fieldType;
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final dynamic defaultValue;
  final String? validationRegex;
  final String? apiFieldName;

  const FormFieldConfigEntity({
    required this.fieldName,
    required this.fieldType,
    this.required = false,
    this.options,
    this.placeholder,
    this.defaultValue,
    this.validationRegex,
    this.apiFieldName,
  });
}

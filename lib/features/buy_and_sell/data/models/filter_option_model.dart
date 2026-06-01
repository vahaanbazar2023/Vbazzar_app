import '../../domain/entities/filter_option_entity.dart';

class FilterOptionModel extends FilterOptionEntity {
  const FilterOptionModel({
    required super.label,
    required super.value,
  });

  factory FilterOptionModel.fromJson(Map<String, dynamic> json) {
    return FilterOptionModel(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class FilterConfigModel extends FilterConfigEntity {
  const FilterConfigModel({
    required super.filterName,
    required super.type,
    super.source,
    super.options,
  });

  factory FilterConfigModel.fromJson(String name, Map<String, dynamic> json) {
    List<FilterOptionEntity>? optionsList;
    if (json['options'] is List) {
      optionsList = (json['options'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => FilterOptionModel.fromJson(e))
          .toList();
    }
    return FilterConfigModel(
      filterName: name,
      type: json['type']?.toString() ?? 'dropdown',
      source: json['source']?.toString(),
      options: optionsList,
    );
  }
}

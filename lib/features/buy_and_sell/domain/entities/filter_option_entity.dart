class FilterOptionEntity {
  final String label;
  final String value;

  const FilterOptionEntity({
    required this.label,
    required this.value,
  });
}

class FilterConfigEntity {
  final String filterName;
  final String type;
  final String? source;
  final List<FilterOptionEntity>? options;

  const FilterConfigEntity({
    required this.filterName,
    required this.type,
    this.source,
    this.options,
  });
}

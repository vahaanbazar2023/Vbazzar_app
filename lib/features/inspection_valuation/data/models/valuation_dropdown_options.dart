/// Represents a dropdown option with a display label and an API value.
class DropdownItem {
  final String label;
  final String value;

  const DropdownItem({required this.label, required this.value});

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  /// Parse a list of API dropdown objects into a list of [DropdownItem]s.
  ///
  /// Handles two formats:
  ///  - Map entries: `[{"Excellent": "excellent"}, ...]`
  ///  - Simple strings: `["Yes", "No"]`
  static List<DropdownItem> parseList(List<dynamic>? raw) {
    if (raw == null) return [];
    final items = <DropdownItem>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        for (final e in entry.entries) {
          items.add(DropdownItem(label: e.key, value: e.value.toString()));
        }
      } else if (entry is String) {
        // Handle simple string arrays like ["Yes", "No"]
        items.add(DropdownItem(label: entry, value: entry.toLowerCase()));
      }
    }
    return items;
  }
}

class ValuationDropdownOptions {
  final List<DropdownItem> yesNo;
  final List<DropdownItem> condition;
  final List<DropdownItem> fuel;
  final List<DropdownItem> transmissionType;
  final List<DropdownItem> caseType;
  final List<DropdownItem> accidentalStatus;
  final List<DropdownItem> tyreCondition;
  final List<DropdownItem> hypothecation;

  const ValuationDropdownOptions({
    this.yesNo = const [],
    this.condition = const [],
    this.fuel = const [],
    this.transmissionType = const [],
    this.caseType = const [],
    this.accidentalStatus = const [],
    this.tyreCondition = const [],
    this.hypothecation = const [],
  });

  factory ValuationDropdownOptions.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ValuationDropdownOptions(
      yesNo: DropdownItem.parseList(data['yes_no'] as List<dynamic>?),
      condition: DropdownItem.parseList(data['condition'] as List<dynamic>?),
      fuel: DropdownItem.parseList(data['fuel'] as List<dynamic>?),
      transmissionType:
          DropdownItem.parseList(data['transmission_type'] as List<dynamic>?),
      caseType: DropdownItem.parseList(data['case_type'] as List<dynamic>?),
      accidentalStatus: DropdownItem.parseList(
          data['accidental_status'] as List<dynamic>?),
      tyreCondition:
          DropdownItem.parseList(data['tyre_condition'] as List<dynamic>?),
      hypothecation: DropdownItem.parseList(
          (data['hypothecation'] ?? data['hypothecation_options'])
              as List<dynamic>?),
    );
  }
}

class LocationOption {
  final String id;
  final String name;
  final String? stateId;

  const LocationOption({
    required this.id,
    required this.name,
    this.stateId,
  });

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: (json['id'] ?? json['city_id'] ?? json['state_id'] ?? '').toString(),
      name: (json['name'] ?? json['city_name'] ?? json['state_name'] ?? '')
          .toString(),
      stateId: json['state_id']?.toString(),
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
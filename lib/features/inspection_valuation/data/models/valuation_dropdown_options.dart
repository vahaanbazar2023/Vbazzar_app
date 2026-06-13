class ValuationDropdownOptions {
  final List<String> vehicleTypes;
  final List<String> vehicleBrands;
  final List<LocationOption> states;
  final List<LocationOption> cities;
  final List<String> conditionOptions;
  final List<String> fuelTypes;
  final List<String> transmissionTypes;
  final List<String> caseTypes;
  final List<String> hypothecationOptions;
  final List<String> accidentalStatusOptions;
  final List<String> tyreConditionOptions;

  const ValuationDropdownOptions({
    this.vehicleTypes = const [],
    this.vehicleBrands = const [],
    this.states = const [],
    this.cities = const [],
    this.conditionOptions = const [],
    this.fuelTypes = const [],
    this.transmissionTypes = const [],
    this.caseTypes = const [],
    this.hypothecationOptions = const [],
    this.accidentalStatusOptions = const [],
    this.tyreConditionOptions = const [],
  });

  factory ValuationDropdownOptions.fromJson(Map<String, dynamic> json) {
    return ValuationDropdownOptions(
      vehicleTypes: (json['vehicle_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vehicleBrands: (json['vehicle_brands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      states: (json['states'] as List<dynamic>?)
              ?.map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      conditionOptions: (json['condition_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fuelTypes: (json['fuel_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      transmissionTypes: (json['transmission_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      caseTypes: (json['case_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hypothecationOptions: (json['hypothecation_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      accidentalStatusOptions:
          (json['accidental_status_options'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      tyreConditionOptions: (json['tyre_condition_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
      name: (json['name'] ?? json['city_name'] ?? json['state_name'] ?? '').toString(),
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
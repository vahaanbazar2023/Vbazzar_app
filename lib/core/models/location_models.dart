class StateResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final StateData? data;
  final dynamic error;

  const StateResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory StateResponse.fromJson(Map<String, dynamic> json) {
    return StateResponse(
      status: json['status'] as String,
      code: json['code'] as int,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      data: json['data'] != null
          ? StateData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'timestamp': timestamp,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class StateData {
  final List<StateModel> states;

  const StateData({required this.states});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      states: (json['states'] as List<dynamic>)
          .map((e) => StateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'states': states.map((e) => e.toJson()).toList()};
  }
}

class StateModel {
  final String stateId;
  final String stateName;
  final String regionId;

  const StateModel({
    required this.stateId,
    required this.stateName,
    required this.regionId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['state_id'] as String,
      stateName: json['state_name'] as String,
      regionId: json['region_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state_id': stateId,
      'state_name': stateName,
      'region_id': regionId,
    };
  }

  @override
  String toString() => stateName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateModel &&
          runtimeType == other.runtimeType &&
          stateId == other.stateId;

  @override
  int get hashCode => stateId.hashCode;
}

class CityResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final CityData? data;
  final dynamic error;

  const CityResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      status: json['status'] as String,
      code: json['code'] as int,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      data: json['data'] != null
          ? CityData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'timestamp': timestamp,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class CityData {
  final List<CityModel> cities;

  const CityData({required this.cities});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      cities: (json['cities'] as List<dynamic>)
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cities': cities.map((e) => e.toJson()).toList()};
  }
}

class CityModel {
  final String cityId;
  final String cityName;
  final String stateId;

  const CityModel({
    required this.cityId,
    required this.cityName,
    required this.stateId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: json['city_id'] as String,
      cityName: json['city_name'] as String,
      stateId: json['state_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'city_id': cityId, 'city_name': cityName, 'state_id': stateId};
  }

  @override
  String toString() => cityName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId;

  @override
  int get hashCode => cityId.hashCode;
}

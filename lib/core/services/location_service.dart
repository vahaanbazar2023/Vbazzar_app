import 'package:get/get.dart';
import '../models/location_models.dart';
import '../network/network_service.dart';
import '../services/logger_service.dart';

class LocationService extends GetxService {
  static LocationService get to {
    try {
      return Get.find<LocationService>();
    } catch (e) {
      // If not found, register it now and return
      print('⚠️ LocationService not found - registering now as fallback');
      final service = LocationService();
      Get.put<LocationService>(service, permanent: true);
      print('✅ LocationService registered via fallback');
      return service;
    }
  }

  final _networkService = NetworkService.to;

  // Cache for states and cities
  final RxList<StateModel> _states = <StateModel>[].obs;
  final RxMap<String, List<CityModel>> _citiesCache =
      <String, List<CityModel>>{}.obs;

  // Loading states
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;

  List<StateModel> get states => _states;

  List<CityModel> getCitiesForState(String stateId) {
    return _citiesCache[stateId] ?? [];
  }

  /// Fetch all states
  Future<List<StateModel>> fetchStates({bool forceRefresh = false}) async {
    // Return cached states if available and not forcing refresh
    if (_states.isNotEmpty && !forceRefresh) {
      LoggerService.to.info(
        'Returning cached states (${_states.length} states)',
      );
      return _states;
    }

    try {
      isLoadingStates.value = true;
      LoggerService.to.info('Fetching states from API');

      final response = await _networkService.get('/api/v1/locations/states');

      final stateResponse = StateResponse.fromJson(response.data);

      if (stateResponse.isSuccess && stateResponse.data != null) {
        _states.value = stateResponse.data!.states;
        LoggerService.to.info('Fetched ${_states.length} states successfully');
        return _states;
      } else {
        throw Exception(stateResponse.message);
      }
    } catch (e) {
      LoggerService.to.error('Error fetching states: $e');
      rethrow;
    } finally {
      isLoadingStates.value = false;
    }
  }

  /// Fetch cities for a specific state
  Future<List<CityModel>> fetchCities(
    String stateId, {
    bool forceRefresh = false,
  }) async {
    // Return cached cities if available and not forcing refresh
    if (_citiesCache.containsKey(stateId) && !forceRefresh) {
      LoggerService.to.info(
        'Returning cached cities for $stateId (${_citiesCache[stateId]!.length} cities)',
      );
      return _citiesCache[stateId]!;
    }

    try {
      isLoadingCities.value = true;
      LoggerService.to.info('Fetching cities for state: $stateId');

      final response = await _networkService.get(
        '/api/v1/locations/cities',
        queryParameters: {'state_id': stateId},
      );

      final cityResponse = CityResponse.fromJson(response.data);

      if (cityResponse.isSuccess && cityResponse.data != null) {
        final cities = cityResponse.data!.cities;
        _citiesCache[stateId] = cities;
        LoggerService.to.info('Fetched ${cities.length} cities for $stateId');
        return cities;
      } else {
        throw Exception(cityResponse.message);
      }
    } catch (e) {
      LoggerService.to.error('Error fetching cities for $stateId: $e');
      rethrow;
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// Clear all caches
  void clearCache() {
    _states.clear();
    _citiesCache.clear();
    LoggerService.to.info('Location cache cleared');
  }

  /// Clear cities cache for a specific state
  void clearCitiesCache(String stateId) {
    _citiesCache.remove(stateId);
    LoggerService.to.info('Cities cache cleared for $stateId');
  }
}

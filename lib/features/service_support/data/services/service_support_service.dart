import '../../../../core/network/network_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../models/mechanic_model.dart';

class ServiceSupportService {
  final NetworkService _network;

  ServiceSupportService({NetworkService? network})
      : _network = network ?? NetworkService.to;

  /// Fetches paginated mechanics near the given coordinates.
  Future<MechanicsData> listMechanics({
    required String userId,
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.listMechanics,
      data: {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const MechanicsData(
        count: 0,
        mechanics: [],
        pagination: PaginationInfo(),
      );
    }
    return MechanicsData.fromJson(data);
  }

  /// Creates a mechanic subscription after successful payment.
  Future<MechanicSubscriptionData?> createMechanicSubscription({
    required String userId,
    required String mechanicId,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.userMechanicSubscription,
      data: {
        'user_id': userId,
        'mechanic_id': mechanicId,
        'number_access_subscription': 'yes',
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return MechanicSubscriptionData.fromJson(data);
  }
}
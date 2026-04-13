import '../../../core/network/network_service.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_image.dart';

class SubscriptionService {
  static const String _listingPath =
      '/api/v1/subscription/subscription-listing';

  final NetworkService _network;

  SubscriptionService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  Future<({List<SubscriptionPlan> plans, List<SubscriptionImage> images})>
  fetchPlans({
    required String userId,
    required String subscriptionSource,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      _listingPath,
      data: {'user_id': userId, 'subscription_source': subscriptionSource},
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return (plans: <SubscriptionPlan>[], images: <SubscriptionImage>[]);
    }

    final rawPlans = data['plans'] as List<dynamic>? ?? [];
    final rawImages = data['images'] as List<dynamic>? ?? [];

    final plans =
        rawPlans
            .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final images =
        rawImages
            .map((e) => SubscriptionImage.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    return (plans: plans, images: images);
  }
}

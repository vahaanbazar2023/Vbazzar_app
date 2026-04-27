import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_image.dart';
import '../models/user_subscription.dart';
import '../models/wallet_eligibility.dart';

class SubscriptionService {
  final NetworkService _network;

  SubscriptionService({NetworkService? network})
    : _network = network ?? NetworkService.to;

  Future<({List<SubscriptionPlan> plans, List<SubscriptionImage> images})>
  fetchPlans({
    required String userId,
    required String subscriptionSource,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionListing,
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

  Future<MySubscriptionsData> fetchMySubscriptions({
    required String userId,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.mySubscriptions,
      data: {'user_id': userId},
    );

    final raw = response.data;
    debugPrint('📦 mySubscriptions raw: $raw');
    if (raw == null) {
      return const MySubscriptionsData(
        subscriptions: [],
        auctionBidLimitOverall: 0,
        totalCount: 0,
      );
    }
    return MySubscriptionsData.fromJson(raw);
  }

  Future<WalletEligibility> checkWalletEligibility({
    required String userId,
    required String planCode,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{'user_id': userId, 'plan_code': planCode};
    if (referralCode != null && referralCode.isNotEmpty) {
      body['referral_code'] = referralCode;
    }

    final response = await _network.post<Map<String, dynamic>>(
      ApiEndpoints.walletEligibility,
      data: body,
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return WalletEligibility(
        userId: userId,
        walletBalance: 0,
        planCode: planCode,
        planName: '',
        subscriptionPrice: 0,
        maximumRedeemableAmount: 0,
        commissionAmount: 0,
        referralCommissionPercentage: 0,
      );
    }
    return WalletEligibility.fromJson(data);
  }
}

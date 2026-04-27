/// Canonical type_code values from the backend.
/// Add new entries here as new subscription products are introduced.
abstract final class SubscriptionTypeCode {
  static const auction = 'SUBT001';
  static const buySell = 'SUBT002';
}

class UserSubscription {
  final String typeCode;
  final String subscriptionType;
  final String planName;
  final String? planMetric;
  final String? startDate;
  final String? endDate;
  final double? planBidAmount;
  final double? planAvailableBidAmount;
  final String userSubCode;
  final String status;

  const UserSubscription({
    required this.typeCode,
    required this.subscriptionType,
    required this.planName,
    this.planMetric,
    this.startDate,
    this.endDate,
    this.planBidAmount,
    this.planAvailableBidAmount,
    required this.userSubCode,
    required this.status,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      typeCode: json['type_code'] as String? ?? '',
      subscriptionType: json['subscription_type'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      planMetric: json['plan_metric'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      planBidAmount: (json['plan_bid_amount'] as num?)?.toDouble(),
      planAvailableBidAmount: (json['plan_available_bid_amount'] as num?)
          ?.toDouble(),
      userSubCode: json['user_sub_code'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  bool get isActive => status.toLowerCase() == 'active';

  /// True when `isActive` AND today falls within [startDate, endDate].
  /// If dates are absent the status field alone is trusted.
  bool get isCurrentlyValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null) {
      final start = DateTime.tryParse(startDate!);
      if (start != null && now.isBefore(start)) return false;
    }
    if (endDate != null) {
      final end = DateTime.tryParse(endDate!);
      // Allow through midnight of the end date
      if (end != null && now.isAfter(end.add(const Duration(days: 1)))) {
        return false;
      }
    }
    return true;
  }
}

class MySubscriptionsData {
  final List<UserSubscription> subscriptions;
  final int auctionBidLimitOverall;
  final int totalCount;

  const MySubscriptionsData({
    required this.subscriptions,
    required this.auctionBidLimitOverall,
    required this.totalCount,
  });

  factory MySubscriptionsData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData == null
        ? <String, dynamic>{}
        : (rawData is Map<String, dynamic>
              ? rawData
              : Map<String, dynamic>.from(rawData as Map));

    final rawSubs = data['subscriptions'];
    final subsList = rawSubs is List ? rawSubs : <dynamic>[];

    final rawAdditional = data['additional_details'];
    final additionalDetails = rawAdditional == null
        ? <String, dynamic>{}
        : (rawAdditional is Map<String, dynamic>
              ? rawAdditional
              : Map<String, dynamic>.from(rawAdditional as Map));

    return MySubscriptionsData(
      subscriptions: subsList
          .map(
            (e) => UserSubscription.fromJson(
              e is Map<String, dynamic>
                  ? e
                  : Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      auctionBidLimitOverall:
          (additionalDetails['auction_bid_limit_overall'] as num?)?.toInt() ??
          0,
      totalCount: (data['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}

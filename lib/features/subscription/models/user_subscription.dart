import 'package:flutter/foundation.dart';

/// Canonical type_code values from the backend.
/// Add new entries here as new subscription products are introduced.
abstract final class SubscriptionTypeCode {
  static const auction = 'SUBT001';
  static const auctionBidLimit = 'SUBT002';
  static const vehicleDetailsAccess = 'SUBT004';
  static const mechanicContact = 'SUBT006';
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

  /// Parses the date strings returned by the API.
  ///
  /// The API sends dates in two possible formats:
  ///   • "04 May 2026, 06:58AM"  (display format)
  ///   • ISO-8601 "2026-05-04T06:58:00" (fallback)
  ///
  /// Returns null when the string is null or cannot be parsed.
  static DateTime? parseApiDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // Try ISO-8601 first (covers future API changes)
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // Parse "dd MMM yyyy, hh:mmAM/PM"
    // Example: "03 May 2026, 06:58AM"
    try {
      const months = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'may': 5,
        'jun': 6,
        'jul': 7,
        'aug': 8,
        'sep': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12,
      };

      // Split on ", " to get "03 May 2026" and "06:58AM"
      final parts = raw.split(', ');
      if (parts.length != 2) {
        debugPrint('📅 parseApiDate: unexpected format (no ", ") → "$raw"');
        return null;
      }

      final dateParts = parts[0].trim().split(' ');
      if (dateParts.length != 3) {
        debugPrint('📅 parseApiDate: bad date portion → "${parts[0]}"');
        return null;
      }

      final day = int.tryParse(dateParts[0]);
      final month = months[dateParts[1].toLowerCase()];
      final year = int.tryParse(dateParts[2]);
      if (day == null || month == null || year == null) {
        debugPrint('📅 parseApiDate: could not parse d/m/y from "${parts[0]}"');
        return null;
      }

      final timePart = parts[1].trim().toUpperCase();
      final isPm = timePart.endsWith('PM');
      final isAm = timePart.endsWith('AM');
      if (!isPm && !isAm) {
        debugPrint('📅 parseApiDate: no AM/PM in time portion → "$timePart"');
        return null;
      }

      final timeStr = timePart.substring(0, timePart.length - 2);
      final timeSplit = timeStr.split(':');
      if (timeSplit.length != 2) {
        debugPrint('📅 parseApiDate: bad time format → "$timeStr"');
        return null;
      }

      var hour = int.tryParse(timeSplit[0]) ?? 0;
      final minute = int.tryParse(timeSplit[1]) ?? 0;

      // Convert 12-hour to 24-hour
      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      final result = DateTime(year, month, day, hour, minute);
      debugPrint('📅 parseApiDate: "$raw" → $result');
      return result;
    } catch (e) {
      debugPrint('📅 parseApiDate: exception parsing "$raw": $e');
      return null;
    }
  }

  /// True when `isActive` AND today falls within [startDate, endDate].
  /// If dates are absent the status field alone is trusted.
  bool get isCurrentlyValid {
    if (!isActive) {
      debugPrint(
        '🔒 [$typeCode/$planName] isCurrentlyValid=false — status="$status"',
      );
      return false;
    }
    final now = DateTime.now();

    final start = parseApiDate(startDate);
    if (start != null && now.isBefore(start)) {
      debugPrint(
        '🔒 [$typeCode/$planName] isCurrentlyValid=false — now($now) is before start($start)',
      );
      return false;
    }

    final end = parseApiDate(endDate);
    if (end != null && now.isAfter(end)) {
      debugPrint(
        '🔒 [$typeCode/$planName] isCurrentlyValid=false — now($now) is after end($end)',
      );
      return false;
    }

    debugPrint(
      '✅ [$typeCode/$planName] isCurrentlyValid=true — start=$start end=$end now=$now',
    );
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

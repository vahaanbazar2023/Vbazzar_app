class SubscriptionPlan {
  final String typeCode;
  final String planCode;
  final String name;
  final double price;
  final int displayOrder;
  final String status;
  final String featDescription;
  final String planMetric;
  final String planMetricValue;

  const SubscriptionPlan({
    required this.typeCode,
    required this.planCode,
    required this.name,
    required this.price,
    required this.displayOrder,
    required this.status,
    required this.featDescription,
    required this.planMetric,
    required this.planMetricValue,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      typeCode: json['type_code'] as String? ?? '',
      planCode: json['plan_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      displayOrder: json['display_order'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      featDescription: json['feat_description'] as String? ?? '',
      planMetric: json['plan_metric'] as String? ?? 'days',
      planMetricValue: json['plan_metric_value'] as String? ?? '',
    );
  }

  /// e.g. "99 Days" or "₹1,00,000 Limit"
  String get metricLabel {
    if (planMetric == 'days') {
      return '$planMetricValue Days';
    }
    final amount = int.tryParse(planMetricValue) ?? 0;
    return '₹${_formatAmount(amount)} Limit';
  }

  String _formatAmount(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final lastThree = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final result = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i != 0 && (rest.length - i) % 2 == 0) result.write(',');
      result.write(rest[i]);
    }
    return '${result.toString()},$lastThree';
  }
}

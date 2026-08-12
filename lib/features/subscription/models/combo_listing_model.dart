// ─────────────────────────────────────────────────────────────────────────────
// Combo listing models — mirrors /api/v1/subscription/combo-listing response
// ─────────────────────────────────────────────────────────────────────────────

class ComboIncludedPlan {
  final String planCode;
  final String typeCode;
  final String name;
  final double price;
  final String planMetric;
  final String planMetricValue;
  final String status;

  const ComboIncludedPlan({
    required this.planCode,
    required this.typeCode,
    required this.name,
    required this.price,
    required this.planMetric,
    required this.planMetricValue,
    required this.status,
  });

  factory ComboIncludedPlan.fromJson(Map<String, dynamic> j) =>
      ComboIncludedPlan(
        planCode: j['plan_code'] as String? ?? '',
        typeCode: j['type_code'] as String? ?? '',
        name: j['name'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        planMetric: j['plan_metric'] as String? ?? 'days',
        planMetricValue: j['plan_metric_value'] as String? ?? '',
        status: j['status'] as String? ?? '',
      );

  /// Human-readable label: "Auction Access", "Vehicle Details", etc.
  String get displayName {
    switch (typeCode.toUpperCase()) {
      case 'SUBT001': return 'Auction Access Plan';
      case 'SUBT002': return 'Bid Limit Plan';
      case 'SUBT003': return 'Owner Contact Plan';
      case 'SUBT004': return 'Vehicle Details Plan';
      case 'SUBT005': return 'Inspection Plan';
      case 'SUBT006': return 'Mechanic Contact Plan';
      default: return name;
    }
  }
}

class ComboProduct {
  final String comboCode;
  final String name;
  final String? description;
  final double actualPrice;
  final double sellingPrice;
  final double savings;
  final int displayOrder;
  final String status;
  final List<ComboIncludedPlan> plans;

  const ComboProduct({
    required this.comboCode,
    required this.name,
    this.description,
    required this.actualPrice,
    required this.sellingPrice,
    required this.savings,
    required this.displayOrder,
    required this.status,
    required this.plans,
  });

  factory ComboProduct.fromJson(Map<String, dynamic> j) => ComboProduct(
        comboCode: j['combo_code'] as String? ?? '',
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        actualPrice: (j['actual_price'] as num?)?.toDouble() ?? 0,
        sellingPrice: (j['selling_price'] as num?)?.toDouble() ?? 0,
        savings: (j['savings'] as num?)?.toDouble() ?? 0,
        displayOrder: (j['display_order'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? '',
        plans: ((j['plans'] as List<dynamic>?) ?? [])
            .map((e) => ComboIncludedPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  bool get isActive => status.toLowerCase() == 'active';
}

class OwnerPackProduct {
  final String planCode;
  final String typeCode;
  final String name;
  final double price;
  final int contactCount;
  final String planMetric;
  final String planMetricValue;
  final int displayOrder;
  final String status;

  const OwnerPackProduct({
    required this.planCode,
    required this.typeCode,
    required this.name,
    required this.price,
    required this.contactCount,
    required this.planMetric,
    required this.planMetricValue,
    required this.displayOrder,
    required this.status,
  });

  factory OwnerPackProduct.fromJson(Map<String, dynamic> j) => OwnerPackProduct(
        planCode: j['plan_code'] as String? ?? '',
        typeCode: j['type_code'] as String? ?? '',
        name: j['name'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        contactCount: (j['contact_count'] as num?)?.toInt() ?? 0,
        planMetric: j['plan_metric'] as String? ?? '',
        planMetricValue: j['plan_metric_value'] as String? ?? '',
        displayOrder: (j['display_order'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? '',
      );

  bool get isActive => status.toLowerCase() == 'active';
}

class ComboListingData {
  final List<ComboProduct> combos;
  final List<OwnerPackProduct> ownerPacks;
  final int totalCount;
  final int comboCount;
  final int ownerPackCount;

  const ComboListingData({
    required this.combos,
    required this.ownerPacks,
    required this.totalCount,
    required this.comboCount,
    required this.ownerPackCount,
  });

  factory ComboListingData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ComboListingData(
      combos: ((data['combos'] as List<dynamic>?) ?? [])
          .map((e) => ComboProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      ownerPacks: ((data['owner_packs'] as List<dynamic>?) ?? [])
          .map((e) => OwnerPackProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (data['total_count'] as num?)?.toInt() ?? 0,
      comboCount: (data['combo_count'] as num?)?.toInt() ?? 0,
      ownerPackCount: (data['owner_pack_count'] as num?)?.toInt() ?? 0,
    );
  }
}

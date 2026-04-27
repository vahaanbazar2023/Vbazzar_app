class WalletEligibility {
  final String userId;
  final double walletBalance;
  final String planCode;
  final String planName;
  final double subscriptionPrice;
  final double maximumRedeemableAmount;
  final double commissionAmount;
  final String? referralCode;
  final double referralCommissionPercentage;

  const WalletEligibility({
    required this.userId,
    required this.walletBalance,
    required this.planCode,
    required this.planName,
    required this.subscriptionPrice,
    required this.maximumRedeemableAmount,
    required this.commissionAmount,
    this.referralCode,
    required this.referralCommissionPercentage,
  });

  factory WalletEligibility.fromJson(Map<String, dynamic> json) {
    return WalletEligibility(
      userId: json['user_id'] as String? ?? '',
      walletBalance: _toDouble(json['wallet_balance']),
      planCode: json['plan_code'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      subscriptionPrice: _toDouble(json['subscription_price']),
      maximumRedeemableAmount: _toDouble(json['maximum_redeemable_amount']),
      commissionAmount: _toDouble(json['commission_amount']),
      referralCode: json['referral_code'] as String?,
      referralCommissionPercentage:
          _toDouble(json['referral_commission_percentage']),
    );
  }

  /// Safely converts a value that may be a [num] or [String] to [double].
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Price after applying wallet deduction
  double finalPrice(bool useWallet) => useWallet
      ? (subscriptionPrice - maximumRedeemableAmount)
      : subscriptionPrice;

  /// Remaining wallet balance after deduction
  double remainingBalance(bool useWallet) => useWallet
      ? (walletBalance - maximumRedeemableAmount).clamp(0.0, double.infinity)
      : walletBalance;

  bool get hasWalletBalance => walletBalance > 0;
  bool get hasRedeemableAmount => maximumRedeemableAmount > 0;
}

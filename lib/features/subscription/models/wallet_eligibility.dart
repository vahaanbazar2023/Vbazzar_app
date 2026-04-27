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
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      planCode: json['plan_code'] as String? ?? '',
      planName: json['plan_name'] as String? ?? '',
      subscriptionPrice:
          (json['subscription_price'] as num?)?.toDouble() ?? 0.0,
      maximumRedeemableAmount:
          (json['maximum_redeemable_amount'] as num?)?.toDouble() ?? 0.0,
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      referralCode: json['referral_code'] as String?,
      referralCommissionPercentage:
          (json['referral_commission_percentage'] as num?)?.toDouble() ?? 0.0,
    );
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

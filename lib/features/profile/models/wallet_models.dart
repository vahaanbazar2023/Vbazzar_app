class WalletDashboardResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final WalletDashboardData? data;
  final dynamic error;

  const WalletDashboardResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.timestamp,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success' && code == 200;

  factory WalletDashboardResponse.fromJson(Map<String, dynamic> json) {
    return WalletDashboardResponse(
      status: json['status'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      data: json['data'] != null
          ? WalletDashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }
}

class WalletDashboardData {
  final String myReferralCode;
  final double walletBalance;
  final double rewardCoinBalance;
  final List<WalletTransaction> transactions;
  final List<WalletTransaction> coinTransactions;
  final WalletReferralStats referralStats;

  const WalletDashboardData({
    required this.myReferralCode,
    this.walletBalance = 0,
    this.rewardCoinBalance = 0,
    required this.transactions,
    this.coinTransactions = const [],
    required this.referralStats,
  });

  factory WalletDashboardData.fromJson(Map<String, dynamic> json) {
    return WalletDashboardData(
      myReferralCode: json['my_referral_code'] as String? ?? '',
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0,
      rewardCoinBalance:
          double.tryParse(json['reward_coin_balance']?.toString() ?? '0') ?? 0,
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      coinTransactions: (json['coin_transactions'] as List<dynamic>? ?? [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      referralStats: json['referral_stats'] != null
          ? WalletReferralStats.fromJson(
              json['referral_stats'] as Map<String, dynamic>,
            )
          : const WalletReferralStats(),
    );
  }

  // Legacy compat getters used by existing view
  double get totalBalance => walletBalance;
  double get availableBalance => walletBalance;
  double get pendingBalance => 0;
  double get thisMonthEarned => 0;
}

class WalletReferralStats {
  final int totalReferrals;
  final int successfulRegistrations;
  final int activeReferrals;
  final double totalCoinsEarned;
  final double totalCommissionEarned;
  final double totalWalletEarnings;

  const WalletReferralStats({
    this.totalReferrals = 0,
    this.successfulRegistrations = 0,
    this.activeReferrals = 0,
    this.totalCoinsEarned = 0,
    this.totalCommissionEarned = 0,
    this.totalWalletEarnings = 0,
  });

  factory WalletReferralStats.fromJson(Map<String, dynamic> json) {
    return WalletReferralStats(
      totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
      successfulRegistrations:
          (json['successful_registrations'] as num?)?.toInt() ?? 0,
      activeReferrals: (json['active_referrals'] as num?)?.toInt() ?? 0,
      totalCoinsEarned:
          double.tryParse(json['total_coins_earned']?.toString() ?? '0') ?? 0,
      totalCommissionEarned:
          double.tryParse(json['total_commission_earned']?.toString() ?? '0') ??
          0,
      totalWalletEarnings:
          double.tryParse(json['total_wallet_earnings']?.toString() ?? '0') ??
          0,
    );
  }
}

class WalletTransaction {
  final String transactionName;
  final String transactionType; // 'credit' or 'debit'
  final String subscriptionName;
  final String transactionDate;
  final String transactionTime;
  final String amount;

  const WalletTransaction({
    required this.transactionName,
    required this.transactionType,
    required this.subscriptionName,
    required this.transactionDate,
    required this.transactionTime,
    required this.amount,
  });

  bool get isCredit => transactionType == 'credit';
  bool get isDebit => transactionType == 'debit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionName: json['transaction_name'] as String? ?? '',
      transactionType: json['transaction_type'] as String? ?? '',
      subscriptionName: json['subscription_name'] as String? ?? '',
      transactionDate: json['transaction_date'] as String? ?? '',
      transactionTime: json['transaction_time'] as String? ?? '',
      amount: json['amount'] as String? ?? '0.00',
    );
  }
}

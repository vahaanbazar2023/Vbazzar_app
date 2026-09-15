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
    this.walletBalance = 0.0,
    this.rewardCoinBalance = 0.0,
    required this.transactions,
    this.coinTransactions = const [],
    required this.referralStats,
  });

  factory WalletDashboardData.fromJson(Map<String, dynamic> json) {
    return WalletDashboardData(
      myReferralCode: json['my_referral_code'] as String? ?? '',
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0.0,
      rewardCoinBalance:
          double.tryParse(json['reward_coin_balance']?.toString() ?? '0') ??
          0.0,
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

// ─────────────────────────────────────────────────────────────────────────────
// Cash-Out Models
// ─────────────────────────────────────────────────────────────────────────────

/// GET /api/v1/wallet/cash-out/eligibility
class CashOutEligibility {
  final double walletBalance;
  final double maximumCashOut; // 50% of wallet
  final double minimumCashOut;
  final bool isEligible;
  final String? ineligibilityReason;

  const CashOutEligibility({
    this.walletBalance = 0.0,
    this.maximumCashOut = 0.0,
    this.minimumCashOut = 1.0,
    this.isEligible = false,
    this.ineligibilityReason,
  });

  factory CashOutEligibility.fromJson(Map<String, dynamic> json) {
    final balance =
        double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0.0;
    // API returns maximum_cashout_amount
    final maximum =
        double.tryParse(
          json['maximum_cashout_amount']?.toString() ??
              json['maximum_cash_out']?.toString() ??
              '0',
        ) ??
        0.0;
    // API returns minimum_amount
    final minimum =
        double.tryParse(
          json['minimum_amount']?.toString() ??
              json['minimum_cash_out']?.toString() ??
              '1',
        ) ??
        1.0;
    // API returns can_cash_out
    final eligible =
        json['can_cash_out'] as bool? ?? json['is_eligible'] as bool? ?? false;
    return CashOutEligibility(
      walletBalance: balance,
      maximumCashOut: maximum,
      minimumCashOut: minimum,
      isEligible: eligible,
      ineligibilityReason: json['ineligibility_reason'] as String?,
    );
  }
}

/// POST /api/v1/wallet/cash-out — request body
class CashOutRequest {
  final double amount;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String bankName;
  final String branchName;

  const CashOutRequest({
    required this.amount,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.bankName,
    this.branchName = '',
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'account_number': accountNumber,
    'ifsc_code': ifscCode,
    'account_holder_name': accountHolderName,
    'bank_name': bankName,
    'branch_name': branchName,
  };
}

/// Single cash-out history entry (GET /api/v1/wallet/cash-out/history)
class CashOutHistoryEntry {
  final String id;
  final double amount;
  final String status; // 'requested' | 'paid' | 'rejected'
  final String accountNumber;
  final String bankName;
  final String ifscCode;
  final String accountHolderName;
  final String requestedAt;

  const CashOutHistoryEntry({
    required this.id,
    required this.amount,
    required this.status,
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    required this.accountHolderName,
    required this.requestedAt,
  });

  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';
  bool get isPending => status == 'requested';

  factory CashOutHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CashOutHistoryEntry(
      id: json['payout_id']?.toString() ?? json['id']?.toString() ?? '',
      // API returns wallet_amount (amount debited from wallet)
      amount:
          double.tryParse(
            json['wallet_amount']?.toString() ??
                json['amount']?.toString() ??
                '0',
          ) ??
          0.0,
      status: json['status'] as String? ?? 'requested',
      accountNumber: json['account_number'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? json['bank'] as String? ?? '',
      ifscCode: json['ifsc_code'] as String? ?? '',
      accountHolderName:
          json['account_holder_name'] as String? ??
          json['name'] as String? ??
          '',
      requestedAt:
          json['requested_at'] as String? ??
          json['created_at'] as String? ??
          '',
    );
  }
}

/// Reward coin conversion eligibility (GET /api/v1/reward-coins/conversion-eligibility)
class CoinConversionEligibility {
  final double coinBalance;
  final double conversionRate; // coins per INR, e.g. 5 coins = ₹1
  final double minimumCoins; // minimum coins per conversion
  final bool canConvert; // can_convert from API
  final int hoursUntilNext; // hours_until_next_conversion (0 = ready)
  final double maxWalletCreditInr; // max_wallet_credit_inr

  const CoinConversionEligibility({
    this.coinBalance = 0.0,
    this.conversionRate = 5.0,
    this.minimumCoins = 5.0,
    this.canConvert = false,
    this.hoursUntilNext = 0,
    this.maxWalletCreditInr = 0.0,
  });

  factory CoinConversionEligibility.fromJson(Map<String, dynamic> json) {
    return CoinConversionEligibility(
      coinBalance:
          double.tryParse(json['reward_coin_balance']?.toString() ?? '0') ??
          0.0,
      conversionRate:
          double.tryParse(json['coin_to_wallet_rate']?.toString() ?? '5') ??
          5.0,
      minimumCoins:
          double.tryParse(json['minimum_coins']?.toString() ?? '5') ?? 5.0,
      canConvert: json['can_convert'] as bool? ?? false,
      hoursUntilNext:
          (json['hours_until_next_conversion'] as num?)?.toInt() ?? 0,
      maxWalletCreditInr:
          double.tryParse(json['max_wallet_credit_inr']?.toString() ?? '0') ??
          0.0,
    );
  }
}

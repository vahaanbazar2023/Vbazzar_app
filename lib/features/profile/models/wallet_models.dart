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
  final List<WalletTransaction> transactions;

  const WalletDashboardData({
    required this.myReferralCode,
    required this.transactions,
  });

  factory WalletDashboardData.fromJson(Map<String, dynamic> json) {
    return WalletDashboardData(
      myReferralCode: json['my_referral_code'] as String? ?? '',
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
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
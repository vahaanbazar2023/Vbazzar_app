import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/gradient_button.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/templates/shell_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/share_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/models/wallet_models.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with AutomaticKeepAliveClientMixin {
  late final ProfileController _ctrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ctrl.fetchWalletDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ShellLayout(
      title: 'Referral & Rewards',
      subtitle: context.l10n.shareCodeEarnCredits,
      showBack: false,
      actions: [],
      bodyColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (_ctrl.isLoadingWallet.value) {
          return const Center(child: CustomLoader());
        }
        final wallet = _ctrl.walletData.value;
        if (wallet == null) {
          return _EmptyState(onRetry: _ctrl.fetchWalletDashboard);
        }
        return RefreshIndicator(
          onRefresh: () => _ctrl.fetchWalletDashboard(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Total wallet balance card ─────────────────────
                _WalletBalanceCard(wallet: wallet),
                SizedBox(height: 14.h),

                // ── Available / Pending balance row ───────────────

                // ── Referral banner ───────────────────────────────
                _ReferralBanner(referralCode: wallet.myReferralCode),
                SizedBox(height: 20.h),
                // ── Recent Transactions ───────────────────────────
                _SectionHeader(
                  title: 'Recent Transactions',
                  actionLabel: 'View All',
                  onAction: () {},
                ),
                SizedBox(height: 10.h),
                if (wallet.transactions.isEmpty)
                  _NoTransactions()
                else
                  ...wallet.transactions
                      .take(5)
                      .map((t) => _TransactionCard(tx: t)),
                SizedBox(height: 20.h),
                // ── How it works ──────────────────────────────────
                _SectionHeader(title: 'How it works'),
                SizedBox(height: 14.h),
                _HowItWorks(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet balance card
// ─────────────────────────────────────────────────────────────────────────────

class _WalletBalanceCard extends StatelessWidget {
  final WalletDashboardData wallet;
  const _WalletBalanceCard({required this.wallet});

  String _fmt(double v) {
    return v
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Wallet icon
              Image.asset(
                AppAssets.subIconWallet111,
                width: 64.r,
                height: 64.r,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Wallet Balance',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${_fmt(wallet.totalBalance)}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 14.r,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '₹${_fmt(wallet.thisMonthEarned)} this month',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Withdraw button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Withdraw',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(height: 1, thickness: 1, color: AppColors.grey300),
          SizedBox(height: 14.h),
          _BalanceRow(wallet: wallet),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Available / Pending balance row
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceRow extends StatelessWidget {
  final WalletDashboardData wallet;
  const _BalanceRow({required this.wallet});

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _BalanceChip(
              iconAsset: AppAssets.subIconWallet,
              label: 'Available Balance',
              value: '₹${_fmt(wallet.availableBalance)}',
              valueColor: AppColors.primary,
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.grey300),
          SizedBox(width: 8.w),
          Expanded(
            child: _BalanceChip(
              iconAsset: AppAssets.subIconPending,
              label: 'Pending Balance',
              value: '₹${_fmt(wallet.pendingBalance)}',
              valueColor: const Color(0xFFFF9800),
              showInfo: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;
  final Color valueColor;
  final bool showInfo;

  const _BalanceChip({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.valueColor,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(14.r),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withValues(alpha: 0.04),
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconAsset,
                width: 28.r,
                height: 28.r,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Referral banner
// ─────────────────────────────────────────────────────────────────────────────

class _ReferralBanner extends StatelessWidget {
  final String referralCode;
  const _ReferralBanner({required this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.lightOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.subIconGift,
            width: 40.r,
            height: 40.r,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn more, grow your wallet!',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Invite more friends and earn exciting rewards.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () async {
              if (Get.isRegistered<ShareService>()) {
                await ShareService.to.shareReferral(referralCode: referralCode);
              } else if (referralCode.isNotEmpty) {
                // Fallback — copy to clipboard
                await Clipboard.setData(ClipboardData(text: referralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Referral code copied!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Refer Now',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.r,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: AppColors.black,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction card
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final color = isCredit ? AppColors.success : AppColors.error;
    final prefix = isCredit ? '+' : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          // Name + sub-name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.transactionName,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                if (tx.subscriptionName.isNotEmpty)
                  Text(
                    'From ${tx.subscriptionName}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Amount + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix₹${tx.amount}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${tx.transactionDate}, ${tx.transactionTime}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9.sp,
                  color: AppColors.grey400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How it works
// ─────────────────────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    _Step(
      n: '1',
      imageAsset: AppAssets.subIconStep1,
      title: 'Refer Friends',
      desc: 'Share your referral link with your friends',
    ),
    _Step(
      n: '2',
      imageAsset: AppAssets.subIconStep2,
      title: 'They Join',
      desc: 'Your friends sign up using your link',
    ),
    _Step(
      n: '3',
      imageAsset: AppAssets.subIconStep3,
      title: 'They Actively Use',
      desc: 'They explore, participate and place bids',
    ),
    _Step(
      n: '4',
      imageAsset: AppAssets.subIconStep4,
      title: 'You Earn',
      desc: 'You earn rewards which reflect in your wallet',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _steps.asMap().entries.map((e) {
        final step = e.value;
        final isLast = e.key == _steps.length - 1;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightOrange.withOpacity(0.3),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              step.imageAsset,
                              width: 22.r,
                              height: 22.r,
                              fit: BoxFit.contain,
                            ),
                          ),

                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 14.r,
                              height: 14.r,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.ctaGradientStart,
                              ),
                              child: Center(
                                child: Text(
                                  step.n,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      step.desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.sp,
                        color: AppColors.grey500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(top: 18.h),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightOrange.withOpacity(0.3),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16.r,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Step {
  final String n;
  final String imageAsset;
  final String title;
  final String desc;
  const _Step({
    required this.n,
    required this.imageAsset,
    required this.title,
    required this.desc,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / no transactions
// ─────────────────────────────────────────────────────────────────────────────

class _NoTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          'No transactions yet',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey400,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.subIconWallet111, width: 80.r, height: 80.r),
            SizedBox(height: 16.h),
            Text(
              'Unable to load wallet',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please try again later.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

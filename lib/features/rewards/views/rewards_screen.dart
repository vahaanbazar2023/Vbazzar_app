import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/templates/shell_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/share_service.dart';
import '../../../routes/app_routes.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchWalletDashboard();
      _ctrl.fetchCoinConversionEligibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ShellLayout(
      title: context.l10n.apprReferralAndRewards,
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
                _WalletBalanceCard(wallet: wallet, ctrl: _ctrl),
                SizedBox(height: 14.h),

                // ── Referral banner ───────────────────────────────
                _ReferralBanner(referralCode: wallet.myReferralCode),
                SizedBox(height: 20.h),
                // ── Recent Transactions ───────────────────────────
                _SectionHeader(
                  title: context.l10n.apprRecentTransactions,
                  actionLabel: context.l10n.viewAll,
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
                _SectionHeader(title: context.l10n.apprHowItWorks),
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
  final ProfileController ctrl;
  const _WalletBalanceCard({required this.wallet, required this.ctrl});

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
                      context.l10n.apprTotalWalletBalance,
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
                        Flexible(
                          child: Text(
                            context.l10n.apprThisMonth(
                              '₹${_fmt(wallet.thisMonthEarned)}',
                            ),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Withdraw button
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 120.w),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.cashOut),
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
                        Flexible(
                          child: Text(
                            context.l10n.apprWithdraw,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(height: 1, thickness: 1, color: AppColors.grey300),
          SizedBox(height: 14.h),
          _BalanceRow(wallet: wallet, ctrl: ctrl),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Available / Reward coins balance row
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceRow extends StatelessWidget {
  final WalletDashboardData wallet;
  final ProfileController ctrl;
  const _BalanceRow({required this.wallet, required this.ctrl});

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

  void _showConvertDialog(BuildContext context) {
    final coinBalance = wallet.rewardCoinBalance;
    final eligibility = ctrl.coinConversionEligibility.value;
    final rate = eligibility?.conversionRate ?? 5.0;
    // Always calculate from current balance — API's max_wallet_credit_inr
    // may be stale if eligibility was fetched before coins were earned.
    final rupeesValue = coinBalance / rate;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          context.l10n.apprConvertCoins,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          context.l10n.apprConvertCoinsMessage(
            coinBalance.toStringAsFixed(0),
            '₹${rupeesValue.toStringAsFixed(2)}',
            rate.toInt(),
          ),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.grey600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.back();
              ctrl.convertCoins(coinBalance.toInt());
            },
            child: Text(
              context.l10n.apprConfirm,
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // ── Wallet balance chip ───────────────────────────
          Expanded(
            child: _BalanceChip(
              iconAsset: AppAssets.subIconWallet,
              label: context.l10n.apprWalletBalance,
              value: '₹${_fmt(wallet.walletBalance)}',
              valueColor: AppColors.primary,
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.grey300),
          SizedBox(width: 8.w),
          // ── Reward Coins chip ─────────────────────────────
          Expanded(
            child: Obx(() {
              final loading = ctrl.isConvertingCoins.value;
              final eligibility = ctrl.coinConversionEligibility.value;
              final canConvert = eligibility?.canConvert ?? false;
              final hasCoins = wallet.rewardCoinBalance > 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.subIconPending,
                        width: 28.r,
                        height: 28.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.apprRewardCoins,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10.sp,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              wallet.rewardCoinBalance.toStringAsFixed(0),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Convert button below — only when coins > 0
                  if (hasCoins) ...[
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: loading ? null : () => _showConvertDialog(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: canConvert
                              ? const Color(0xFFFF9800)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: loading
                            ? SizedBox(
                                width: 10.r,
                                height: 10.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  canConvert
                                      ? context.l10n.apprConvertNow
                                      : context.l10n.apprConvert,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: canConvert
                                        ? Colors.white
                                        : AppColors.grey600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              );
            }),
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

  const _BalanceChip({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.valueColor,
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
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
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
                ), // Column
              ), // Flexible
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
                  context.l10n.apprEarnMoreGrowWallet,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.l10n.apprInviteMoreFriends,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120.w),
            child: GestureDetector(
              onTap: () async {
                if (Get.isRegistered<ShareService>()) {
                  await ShareService.to.shareReferral(
                    referralCode: referralCode,
                  );
                } else if (referralCode.isNotEmpty) {
                  // Fallback — copy to clipboard
                  await Clipboard.setData(ClipboardData(text: referralCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.referralCodeCopied),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
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
                    Flexible(
                      child: Text(
                        context.l10n.apprReferNow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
              color: AppColors.black,
            ),
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
                    context.l10n.apprFromName(tx.subscriptionName),
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
                  fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(
        n: '1',
        imageAsset: AppAssets.subIconStep1,
        title: context.l10n.apprStepReferFriendsTitle,
        desc: context.l10n.apprStepReferFriendsDesc,
      ),
      _Step(
        n: '2',
        imageAsset: AppAssets.subIconStep2,
        title: context.l10n.apprStepTheyJoinTitle,
        desc: context.l10n.apprStepTheyJoinDesc,
      ),
      _Step(
        n: '3',
        imageAsset: AppAssets.subIconStep3,
        title: context.l10n.apprStepTheyUseTitle,
        desc: context.l10n.apprStepTheyUseDesc,
      ),
      _Step(
        n: '4',
        imageAsset: AppAssets.subIconStep4,
        title: context.l10n.apprStepYouEarnTitle,
        desc: context.l10n.apprStepYouEarnDesc,
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((e) {
        final step = e.value;
        final isLast = e.key == steps.length - 1;
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
                        fontWeight: FontWeight.w600,
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
          context.l10n.noTransactionsYet,
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
              context.l10n.unableToLoadWallet,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.apprPleaseTryAgainLater,
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
                    fontWeight: FontWeight.w600,
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

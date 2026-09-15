import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../controllers/profile_controller.dart';
import '../models/wallet_models.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen>
    with SingleTickerProviderStateMixin {
  late final ProfileController _ctrl;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchCashOutEligibility();
      _ctrl.fetchCashOutHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          AppHeader(title: 'Withdraw to Bank'),
          // ── Balance strip ────────────────────────────────────
          _BalanceSummaryStrip(ctrl: _ctrl),
          // ── Tabs ─────────────────────────────────────────────
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CashOutRequestTab(ctrl: _ctrl),
                _CashOutHistoryTab(ctrl: _ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          fontSize: 13.sp,
        ),
        tabs: const [
          Tab(text: 'Withdraw'),
          Tab(text: 'History'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance summary strip
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceSummaryStrip extends StatelessWidget {
  final ProfileController ctrl;
  const _BalanceSummaryStrip({required this.ctrl});

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Obx(() {
        final wallet = ctrl.walletData.value;
        final balance = wallet?.walletBalance ?? 0.0;
        final eligibility = ctrl.cashOutEligibility.value;
        final max = eligibility?.maximumCashOut ?? (balance * 0.5);
        return Row(
          children: [
            Expanded(
              child: _StripItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet Balance',
                value: '₹${_fmt(balance)}',
              ),
            ),
            Container(
              width: 1,
              height: 36.h,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _StripItem(
                icon: Icons.south_rounded,
                label: 'Max Withdrawal',
                value: '₹${_fmt(max)}',
                sub: '50% of balance',
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StripItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  const _StripItem({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 17.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8.sp,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Withdraw tab
// ─────────────────────────────────────────────────────────────────────────────

class _CashOutRequestTab extends StatefulWidget {
  final ProfileController ctrl;
  const _CashOutRequestTab({required this.ctrl});

  @override
  State<_CashOutRequestTab> createState() => _CashOutRequestTabState();
}

class _CashOutRequestTabState extends State<_CashOutRequestTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _nameCtrl.dispose();
    _bankCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final eligibility = widget.ctrl.cashOutEligibility.value;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (eligibility != null) {
      if (amount > eligibility.maximumCashOut) {
        _snack('Maximum withdrawal is ₹${_fmt(eligibility.maximumCashOut)}');
        return;
      }
      if (amount < eligibility.minimumCashOut) {
        _snack('Minimum withdrawal is ₹${_fmt(eligibility.minimumCashOut)}');
        return;
      }
    }
    final req = CashOutRequest(
      amount: amount,
      accountNumber: _accountCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim().toUpperCase(),
      accountHolderName: _nameCtrl.text.trim(),
      bankName: _bankCtrl.text.trim(),
      branchName: _branchCtrl.text.trim(),
    );
    final success = await widget.ctrl.requestCashOut(req);
    if (success && mounted) {
      _formKey.currentState?.reset();
      for (final c in [
        _amountCtrl,
        _accountCtrl,
        _ifscCtrl,
        _nameCtrl,
        _bankCtrl,
        _branchCtrl,
      ]) {
        c.clear();
      }
      widget.ctrl.fetchCashOutEligibility();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Montserrat')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (widget.ctrl.isLoadingCashOutEligibility.value) {
        return const Center(child: CustomLoader());
      }
      final eligibility = widget.ctrl.cashOutEligibility.value;
      final canCashOut = eligibility?.isEligible ?? true;

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Limits banner ────────────────────────────────
            if (!canCashOut && eligibility?.ineligibilityReason != null)
              _Banner(
                icon: Icons.warning_amber_rounded,
                text: eligibility!.ineligibilityReason!,
                bgColor: AppColors.warningBackground,
                borderColor: AppColors.warningBorder,
                iconColor: AppColors.warningDark,
                textColor: AppColors.warningDark,
              ),
            if (eligibility != null) ...[
              _Banner(
                icon: Icons.info_outline_rounded,
                text:
                    'Withdraw ₹${_fmt(eligibility.minimumCashOut)} – '
                    '₹${_fmt(eligibility.maximumCashOut)} (max 50% of balance)',
                bgColor: AppColors.successBackground,
                borderColor: AppColors.success.withValues(alpha: 0.25),
                iconColor: AppColors.success,
                textColor: AppColors.successDark,
                bold: true,
              ),
              SizedBox(height: 14.h),
            ],
            // ── Form card ────────────────────────────────────
            _buildFormCard(canCashOut),
          ],
        ),
      );
    });
  }

  Widget _buildFormCard(bool canCashOut) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section label ─────────────────────────────────
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Bank Account Details',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // ── Amount ────────────────────────────────────────
            _Field(
              controller: _amountCtrl,
              label: 'Amount (₹)',
              hint: 'Enter withdrawal amount',
              icon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final a = double.tryParse(v.trim());
                if (a == null || a <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            SizedBox(height: 12.h),
            // ── Name ──────────────────────────────────────────
            _Field(
              controller: _nameCtrl,
              label: 'Account Holder Name',
              hint: 'As per bank records',
              icon: Icons.person_outline_rounded,
              cap: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 3) return 'Enter full name';
                return null;
              },
            ),
            SizedBox(height: 12.h),
            // ── Bank + Branch row ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _bankCtrl,
                    label: 'Bank Name',
                    hint: 'e.g. SBI',
                    icon: Icons.account_balance_outlined,
                    cap: TextCapitalization.words,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _Field(
                    controller: _branchCtrl,
                    label: 'Branch (opt.)',
                    hint: 'Branch name',
                    icon: Icons.store_outlined,
                    cap: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // ── Account number ────────────────────────────────
            _Field(
              controller: _accountCtrl,
              label: 'Account Number',
              hint: 'Enter account number',
              icon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 9) return 'Invalid account number';
                return null;
              },
            ),
            SizedBox(height: 12.h),
            // ── IFSC ─────────────────────────────────────────
            _Field(
              controller: _ifscCtrl,
              label: 'IFSC Code',
              hint: 'e.g. SBIN0001234',
              icon: Icons.tag_rounded,
              cap: TextCapitalization.characters,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(
                  r'^[A-Z]{4}0[A-Z0-9]{6}$',
                ).hasMatch(v.trim().toUpperCase())) {
                  return 'Invalid IFSC';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            // ── Submit ────────────────────────────────────────
            Obx(() {
              final loading = widget.ctrl.isSubmittingCashOut.value;
              return GradientButton(
                text: loading ? 'Submitting…' : 'Request Withdrawal',
                onPressed: canCashOut && !loading ? _submit : null,
                isLoading: loading,
              );
            }),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Processed within 2–3 business days',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10.sp,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable info/warning banner
// ─────────────────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final bool bold;

  const _Banner({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11.sp,
                color: textColor,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History tab
// ─────────────────────────────────────────────────────────────────────────────

class _CashOutHistoryTab extends StatelessWidget {
  final ProfileController ctrl;
  const _CashOutHistoryTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingCashOutHistory.value) {
        return const Center(child: CustomLoader());
      }
      final history = ctrl.cashOutHistory;
      if (history.isEmpty) {
        return _EmptyHistory();
      }
      return RefreshIndicator(
        onRefresh: ctrl.fetchCashOutHistory,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
          itemCount: history.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => _HistoryCard(entry: history[i]),
        ),
      );
    });
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 56.r,
              color: AppColors.grey300,
            ),
            SizedBox(height: 12.h),
            Text(
              'No withdrawals yet',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your withdrawal requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CashOutHistoryEntry entry;
  const _HistoryCard({required this.entry});

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

  Color get _statusColor {
    if (entry.isPaid) return AppColors.success;
    if (entry.isRejected) return AppColors.error;
    return AppColors.warning;
  }

  Color get _statusBg {
    if (entry.isPaid) return AppColors.successBackground;
    if (entry.isRejected) return AppColors.error.withValues(alpha: 0.08);
    return AppColors.warningBackground;
  }

  String get _statusLabel {
    if (entry.isPaid) return 'Paid';
    if (entry.isRejected) return 'Rejected';
    return 'Requested';
  }

  IconData get _statusIcon {
    if (entry.isPaid) return Icons.check_circle_rounded;
    if (entry.isRejected) return Icons.cancel_rounded;
    return Icons.access_time_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top row: amount + status ───────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: amount + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${_fmt(entry.amount)}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: AppColors.black,
                        ),
                      ),
                      if (entry.requestedAt.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          entry.requestedAt,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Right: status chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 12.r, color: _statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Divider ───────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: AppColors.grey100),
          // ── Bank details grid ─────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Detail(
                        label: 'Account Holder',
                        value: entry.accountHolderName,
                      ),
                    ),
                    Expanded(
                      child: _Detail(
                        label: 'Account No.',
                        value: _mask(entry.accountNumber),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _Detail(label: 'Bank', value: entry.bankName),
                    ),
                    Expanded(
                      child: _Detail(label: 'IFSC', value: entry.ifscCode),
                    ),
                  ],
                ),
                if (entry.id.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _Detail(label: 'Payout ID', value: entry.id, fullWidth: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _mask(String acc) {
    if (acc.length <= 4) return acc;
    return '${'•' * (acc.length - 4)}${acc.substring(acc.length - 4)}';
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  const _Detail({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 9.sp,
            color: AppColors.grey500,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            color: AppColors.grey800,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared form field
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization cap;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.formatters,
    this.cap = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          textCapitalization: cap,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              color: AppColors.grey400,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 17.r),
            filled: true,
            fillColor: AppColors.grey50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 11.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

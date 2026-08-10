import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../services/subscription_guard_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/auction/controllers/vehicle_listing_controller.dart';
import '../../../features/auction/controllers/my_bids_wins_controller.dart';
import '../../../features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Combo plan data model (UI-only, no backend yet)
// ─────────────────────────────────────────────────────────────────────────────
class _ComboItem {
  final String name;
  final String description;
  final IconData iconData;
  final Color iconBg;
  final List<_ComboFeature> features;
  final double price;
  final double originalPrice;

  const _ComboItem({
    required this.name,
    required this.description,
    required this.iconData,
    required this.iconBg,
    required this.features,
    required this.price,
    required this.originalPrice,
  });
}

class _ComboFeature {
  final IconData icon;
  final String label;
  const _ComboFeature(this.icon, this.label);
}

const _combos = [
  _ComboItem(
    name: 'All Access Combo',
    description: 'Get complete access to all features and benefits',
    iconData: Icons.workspace_premium_rounded,
    iconBg: Color(0xFFFFE0E0),
    features: [
      _ComboFeature(Icons.gavel_rounded, 'Auction Access Plan'),
      _ComboFeature(Icons.shield_rounded, 'Vehicle Details Plan'),
      _ComboFeature(Icons.headset_mic_rounded, 'Priority Support'),
    ],
    price: 1999,
    originalPrice: 2499,
  ),
  _ComboItem(
    name: 'Essential Combo',
    description: 'Access the essentials you need to stay ahead',
    iconData: Icons.star_half_rounded,
    iconBg: Color(0xFFE8E8FF),
    features: [
      _ComboFeature(Icons.gavel_rounded, 'Auction Access Plan'),
      _ComboFeature(Icons.shield_rounded, 'Vehicle Details Plan'),
      _ComboFeature(Icons.headset_mic_rounded, 'Standard Support'),
    ],
    price: 1299,
    originalPrice: 1599,
  ),
  _ComboItem(
    name: 'Value Combo',
    description: 'Great value combo for smart bidders',
    iconData: Icons.layers_rounded,
    iconBg: Color(0xFFFFEEDD),
    features: [
      _ComboFeature(Icons.gavel_rounded, 'Auction Access Plan'),
      _ComboFeature(Icons.shield_rounded, 'Vehicle Details Plan'),
      _ComboFeature(Icons.email_rounded, 'Email Support'),
    ],
    price: 1599,
    originalPrice: 1999,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────
class SubscriptionScreen extends StatefulWidget {
  final String subscriptionSource;
  final String title;
  final String subtitle;
  final SubscriptionPlan? prebuiltPlan;
  final Map<String, dynamic> extraArgs;

  const SubscriptionScreen({
    super.key,
    required this.subscriptionSource,
    this.title = 'Subscription',
    this.subtitle = '',
    this.prebuiltPlan,
    this.extraArgs = const {},
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SubscriptionController _ctrl;
  late final MySubscriptionController _myCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ctrl = Get.put(
      SubscriptionController(
        subscriptionSource: widget.subscriptionSource,
        prebuiltPlan: widget.prebuiltPlan,
        extraArgs: widget.extraArgs,
      ),
      tag: widget.subscriptionSource,
    );
    _myCtrl = Get.isRegistered<MySubscriptionController>()
        ? Get.find<MySubscriptionController>()
        : Get.put(MySubscriptionController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (widget.subscriptionSource != 'SUBT002') {
      if (Get.isRegistered<VehicleListingController>()) {
        Get.find<VehicleListingController>().pendingBid.value = null;
      }
      if (Get.isRegistered<MyBidsController>()) {
        Get.find<MyBidsController>().pendingBid.value = null;
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: Obx(() {
        final shell = Get.isRegistered<MainShellController>()
            ? Get.find<MainShellController>()
            : null;
        return AppBottomNavBar(
          currentTab: shell != null
              ? BottomNavTab.values[shell.currentIndex.value]
              : BottomNavTab.categories,
          onTabSelected: (tab) {
            shell?.changePage(tab.index);
            Get.until((route) => route.isFirst);
          },
        );
      }),
      body: Column(
        children: [
          // ── Red gradient header ────────────────────────────────────────
          _Header(topPad: topPad, title: widget.title),
          // ── White body with tabs ───────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _TabBar(controller: _tabController),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _MyPlansTab(
                          ctrl: _myCtrl,
                          tabController: _tabController,
                        ),
                        _ExplorePlansTab(
                          ctrl: _ctrl,
                          subscriptionSource: widget.subscriptionSource,
                          extraArgs: widget.extraArgs,
                        ),
                        const _ComboPlansTab(),
                      ],
                    ),
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
// Red gradient header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double topPad;
  final String title;
  const _Header({required this.topPad, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authHeaderGradientStart,
            AppColors.authHeaderGradientEnd,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
                border: Border.all(color: const Color(0xFFD41F1F), width: 1),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Manage your plans',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  color: Colors.white70,
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
// Tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.grey500,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: AppColors.grey200,
      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      labelStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(text: 'My Plans'),
        Tab(text: 'Explore Plans'),
        Tab(text: 'Combo Plans'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — My Plans
// ─────────────────────────────────────────────────────────────────────────────
class _MyPlansTab extends StatelessWidget {
  final MySubscriptionController ctrl;
  final TabController tabController;
  const _MyPlansTab({required this.ctrl, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (ctrl.errorMessage.value != null) {
        return _ErrorWidget(
          message: ctrl.errorMessage.value!,
          onRetry: ctrl.retry,
        );
      }
      if (ctrl.mySubscriptions.isEmpty) {
        return _EmptyPlans(onExplore: () => tabController.animateTo(1));
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ctrl.fetchMySubscriptions,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          itemCount: ctrl.mySubscriptions.length + 1,
          itemBuilder: (_, i) {
            if (i == ctrl.mySubscriptions.length) {
              return _ExploreBanner(onTap: () => tabController.animateTo(1));
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _MyPlanCard(sub: ctrl.mySubscriptions[i]),
            );
          },
        ),
      );
    });
  }
}

class _MyPlanCard extends StatelessWidget {
  final UserSubscription sub;
  const _MyPlanCard({required this.sub});

  IconData get _icon {
    switch (sub.typeCode) {
      case 'SUBT001':
        return Icons.gavel_rounded;
      case 'SUBT002':
        return Icons.bar_chart_rounded;
      case 'SUBT003':
        return Icons.handshake_rounded;
      case 'SUBT004':
        return Icons.shield_rounded;
      case 'SUBT005':
        return Icons.search_rounded;
      case 'SUBT006':
        return Icons.build_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = UserSubscription.parseApiDate(raw);
    if (dt == null) return raw;
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final active = sub.isActive;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(_icon, color: AppColors.primary, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub.subscriptionType,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: active ? const Color(0xFF81C784) : AppColors.grey300,
                  ),
                ),
                child: Text(
                  active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: active ? const Color(0xFF2E7D32) : AppColors.grey500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.r,
                color: AppColors.grey400,
              ),
              SizedBox(width: 6.w),
              Text(
                'Valid Until',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11.sp,
                  color: AppColors.grey500,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDate(sub.endDate),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.r,
                color: AppColors.grey400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ExploreBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need more benefits?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Explore our other plans and choose the one that fits your needs.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyPlans({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56.r,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Active Plans',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You don\'t have any active subscriptions yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onExplore,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Explore Plans',
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

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Explore Plans (plan picker with radio cards + proceed button)
// ─────────────────────────────────────────────────────────────────────────────
class _ExplorePlansTab extends StatefulWidget {
  final SubscriptionController ctrl;
  final String subscriptionSource;
  final Map<String, dynamic> extraArgs;
  const _ExplorePlansTab({
    required this.ctrl,
    required this.subscriptionSource,
    required this.extraArgs,
  });

  @override
  State<_ExplorePlansTab> createState() => _ExplorePlansTabState();
}

class _ExplorePlansTabState extends State<_ExplorePlansTab> {
  final _referralCtrl = TextEditingController();

  @override
  void dispose() {
    _referralCtrl.dispose();
    super.dispose();
  }

  void _onProceed() async {
    final plan = widget.ctrl.selectedPlan;
    if (plan == null) return;
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', 'Please login to continue');
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      _navigateAfterPayment(widget.subscriptionSource);
      SubscriptionGuardService.to.invalidateAndReload();
    };
    pc.onFailure = (msg, __) => Get.snackbar(
      'Payment Failed',
      msg,
      backgroundColor: Colors.red.shade100,
    );
    pc.onCancelled = () => Get.snackbar(
      'Cancelled',
      'You cancelled the payment',
      backgroundColor: Colors.orange.shade100,
    );
    await pc.initiatePayment(
      userId: userId,
      planCode: plan.planCode,
      forPayment: plan.price,
      referralCode: _referralCtrl.text.trim().isNotEmpty
          ? _referralCtrl.text.trim()
          : null,
    );
  }

  void _navigateAfterPayment(String source) {
    if (!mounted) return;
    final until = (route) =>
        route.settings.name != AppRoutes.subscription &&
        route.settings.name != AppRoutes.subscriptionConfirm &&
        route.settings.name != AppRoutes.walletPayment;
    if (source == 'SUBT001') {
      Get.until(until);
      Get.toNamed(AppRoutes.auctionType);
      CustomSnackbar.show(
        message: context.l10n.auctionAccessActivated,
        type: SnackbarType.success,
      );
    } else if (source == 'SUBT002') {
      Get.until(until);
      if (Get.isRegistered<VehicleListingController>())
        _runSUBT002(Get.find<VehicleListingController>());
      if (Get.isRegistered<MyBidsController>())
        _runMyBidsSUBT002(Get.find<MyBidsController>());
    } else if (source == 'SUBT003') {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final vehicleId = args['pending_vehicle_id'] as String?;
      Get.until(until);
      CustomSnackbar.show(
        message: context.l10n.membershipActivated,
        type: SnackbarType.success,
      );
      SubscriptionGuardService.to.invalidateAndReload();
      if (vehicleId != null && Get.isRegistered<BuyVehicleController>())
        Get.find<BuyVehicleController>().unlockOwnerContactAndRefresh(
          vehicleId,
          categoryCode: args['category_code'] as String? ?? '',
        );
    } else if (source == 'SUBT004') {
      final pendingVehicle =
          (Get.arguments as Map<String, dynamic>? ?? {})['pending_vehicle'];
      Get.until(until);
      if (pendingVehicle != null)
        Get.toNamed(
          AppRoutes.buyVehicleDetail,
          arguments: {'vehicle': pendingVehicle},
        );
      CustomSnackbar.show(
        message: context.l10n.vehicleDetailsUnlocked,
        type: SnackbarType.success,
      );
      SubscriptionGuardService.to.invalidateAndReload();
    } else if (source == 'SUBT005' || source == 'INSPECTION') {
      final vehicleId =
          (Get.arguments as Map<String, dynamic>? ?? {})['pending_vehicle_id']
              as String?;
      Get.until(until);
      if (vehicleId != null && Get.isRegistered<BuyVehicleController>())
        Get.find<BuyVehicleController>().unlockInspectionAndRequest(vehicleId);
      else
        CustomSnackbar.show(
          message: context.l10n.inspectionSubmitted,
          type: SnackbarType.success,
        );
      SubscriptionGuardService.to.invalidateAndReload();
    } else {
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: context.l10n.subscriptionActivated,
        type: SnackbarType.success,
      );
    }
  }

  Future<void> _runSUBT002(VehicleListingController ctrl) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      return;
    }
    await ctrl.silentRefresh();
    await ctrl.revalidatePendingBid();
  }

  Future<void> _runMyBidsSUBT002(MyBidsController ctrl) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      return;
    }
    await ctrl.revalidatePendingBid();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.ctrl.isLoading.value)
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      if (widget.ctrl.errorMessage.value.isNotEmpty)
        return _ErrorWidget(
          message: widget.ctrl.errorMessage.value,
          onRetry: widget.ctrl.retry,
        );
      if (widget.ctrl.plans.isEmpty)
        return Center(
          child: Text(
            'No plans available',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              itemCount: widget.ctrl.plans.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ExploreCard(
                  plan: widget.ctrl.plans[i],
                  isSelected: widget.ctrl.selectedPlanIndex.value == i,
                  onTap: () => widget.ctrl.selectPlan(i),
                ),
              ),
            ),
          ),
          _ProceedBar(
            ctrl: widget.ctrl,
            subscriptionSource: widget.subscriptionSource,
            extraArgs: widget.extraArgs,
            onProceed: _onProceed,
            referralCtrl: _referralCtrl,
          ),
        ],
      );
    });
  }
}

class _ExploreCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  const _ExploreCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (plan.typeCode) {
      case 'SUBT001':
        return Icons.gavel_rounded;
      case 'SUBT002':
        return Icons.bar_chart_rounded;
      case 'SUBT003':
        return Icons.handshake_rounded;
      case 'SUBT004':
        return Icons.shield_rounded;
      case 'SUBT005':
        return Icons.search_rounded;
      case 'SUBT006':
        return Icons.build_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(_icon, color: Colors.white, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    plan.featDescription.isNotEmpty
                        ? plan.featDescription
                        : 'Unlock unlimited access to live auctions',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            // Radio circle
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.r, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProceedBar extends StatelessWidget {
  final SubscriptionController ctrl;
  final String subscriptionSource;
  final Map<String, dynamic> extraArgs;
  final VoidCallback onProceed;
  final TextEditingController referralCtrl;
  const _ProceedBar({
    required this.ctrl,
    required this.subscriptionSource,
    required this.extraArgs,
    required this.onProceed,
    required this.referralCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPlan = ctrl.selectedPlan != null;
      return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPlan) ...[
              TextField(
                controller: referralCtrl,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter referral code (optional)',
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    color: AppColors.grey400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
            GestureDetector(
              onTap: hasPlan ? onProceed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: hasPlan
                      ? const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: hasPlan ? null : AppColors.grey200,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: hasPlan ? Colors.white : AppColors.grey400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                final plan = ctrl.selectedPlan;
                if (plan == null) return;
                final args = Get.arguments as Map<String, dynamic>? ?? {};
                Get.toNamed(
                  AppRoutes.walletPayment,
                  arguments: {
                    ...args,
                    'plan': plan,
                    'source': subscriptionSource,
                  },
                );
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
                  ),
                  children: [
                    const TextSpan(text: 'Or pay from '),
                    TextSpan(
                      text: 'My Wallet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: hasPlan ? AppColors.primary : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Combo Plans (static UI)
// ─────────────────────────────────────────────────────────────────────────────
class _ComboPlansTab extends StatelessWidget {
  const _ComboPlansTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: _combos.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: _ComboCard(combo: _combos[i]),
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  final _ComboItem combo;
  const _ComboCard({required this.combo});

  String _formatPrice(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    return '$rest,$last';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: combo.iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  combo.iconData,
                  color: AppColors.primary,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      combo.description,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Feature chips
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: combo.features
                .map(
                  (f) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(f.icon, size: 12.r, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text(
                          f.label,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 10.h),
          // Price row
          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.currency_rupee_rounded,
                    size: 18.r,
                    color: AppColors.primary,
                  ),
                  Text(
                    _formatPrice(combo.price),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '₹${_formatPrice(combo.originalPrice)}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      color: AppColors.grey400,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.grey400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 9.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.ctaGradientStart,
                        AppColors.ctaGradientEnd,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Pay Now',
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: error widget
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
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

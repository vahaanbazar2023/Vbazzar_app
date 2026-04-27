import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_models.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF0F0),
        body: Column(
          children: [
            _ProfileHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          controller.errorMessage.value!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton.icon(
                          onPressed: controller.fetchProfile,
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Retry',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileCard(profile: controller.profile.value),
                      SizedBox(height: 24.h),
                      _MenuSection(
                        title: 'Account',
                        items: [
                          const _MenuItem(
                            icon: Icons.person_outline,
                            label: 'Manage Profile',
                          ),
                          const _MenuItem(
                            icon: Icons.lock_outline,
                            label: 'Password & Security',
                          ),
                          const _MenuItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'My Wallet',
                          ),
                          _MenuItem(
                            icon: Icons.card_membership_outlined,
                            label: 'My Subscriptions',
                            onTap: () => Get.toNamed(AppRoutes.mySubscriptions),
                          ),
                          const _MenuItem(
                            icon: Icons.language_outlined,
                            label: 'Language',
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _MenuSection(
                        title: 'Auctions',
                        items: const [
                          _MenuItem(
                            icon: Icons.emoji_events_outlined,
                            label: 'My Wins',
                          ),
                          _MenuItem(
                            icon: Icons.gavel_outlined,
                            label: 'My Bids',
                          ),
                          _MenuItem(
                            icon: Icons.currency_rupee_outlined,
                            label: 'Initiate Refund',
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _MenuSection(
                        title: 'Buy & Sell',
                        items: const [
                          _MenuItem(
                            icon: Icons.directions_car_outlined,
                            label: 'My Vehicles',
                          ),
                          _MenuItem(
                            icon: Icons.bookmark_outlined,
                            label: 'My Subscribed Vehicles',
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _MenuSection(
                        title: 'Spare & FMS',
                        items: const [
                          _MenuItem(
                            icon: Icons.build_outlined,
                            label: 'My Spare Parts',
                          ),
                          _MenuItem(
                            icon: Icons.local_shipping_outlined,
                            label: 'My FMS',
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _LogoutButton(controller: controller),
                      SizedBox(height: 16.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + 12.h,
        bottom: 20.h,
        left: 16.w,
        right: 16.w,
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
            child: Icon(Icons.arrow_back, color: AppColors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Text(
            'Profile',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final ProfileData? profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5E5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: 32.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? '—',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  profile?.username != null ? '@${profile!.username}' : '—',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (profile?.phoneNumber != null &&
                    profile!.phoneNumber.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    profile!.phoneNumber,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Section ──────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              return Column(
                children: [
                  _MenuItemTile(item: items[i]),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      indent: 52.w,
                      endIndent: 0,
                      color: AppColors.divider,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(item.icon, size: 22.sp, color: AppColors.textPrimary),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20.sp, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final ProfileController controller;

  const _LogoutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoggingOut.value
            ? null
            : () => _confirmLogout(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: controller.isLoggingOut.value
              ? SizedBox(
                  height: 20.h,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20.sp, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(
                      'Logout',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.headingSmall.copyWith(fontSize: 18.sp),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

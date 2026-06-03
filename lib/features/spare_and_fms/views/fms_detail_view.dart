import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/spare_and_fms_controller.dart';

/// Spare part detail view — mirrors the auction vehicle detail layout:
/// image carousel, centered title with accent underline, 2×2 info grid,
/// section card with pricing info, expandable description accordion,
/// fixed bottom bar with price + CTA.
class FmsDetailView extends GetView<SpareAndFmsController> {
  const FmsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final sparePart = args['sparePart'];
    final isFromOrders = args['isFromOrders'] as bool? ?? false;
    final orderStatus = args['orderStatus'] as String? ?? '';
    final orderId = args['orderId'] as String? ?? '';

    if (sparePart == null) {
      return AppLayout(
        title: 'Spare Detail',
        showBack: true,
        body: const Center(child: Text('No spare part data')),
      );
    }

    final rating = double.tryParse(sparePart.starRating ?? '0') ?? 0;

    return AppLayout(
      title: isFromOrders ? 'Order Detail' : 'Spare Part',
      subtitle: isFromOrders ? 'Order #$orderId' : 'Product details',
      showBack: true,
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image carousel ────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        NetworkImageCarousel(
                          imageUrls: sparePart.photos as List<String>,
                          height: 200.h,
                          placeholderIcon: Icons.build_outlined,
                        ),
                        if (rating > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _RatingBadge(rating: rating),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Spare title (centered + accent underline) ──
                  Center(
                    child: Text(
                      sparePart.spareName as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5.h, bottom: AppSpacing.sm),
                      height: 3.h,
                      width: 55.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ── Order status banner (if from orders) ──
                  if (isFromOrders) ...[
                    _OrderStatusBanner(status: orderStatus, orderId: orderId),
                    SizedBox(height: 8.h),
                  ],

                  // ── 2×2 Info boxes ────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.price_change_outlined,
                            label: 'Price',
                            value: '₹${sparePart.price}',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.star_outline_rounded,
                            label: 'Rating',
                            value: rating > 0 ? '$rating / 5.0' : 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.category_outlined,
                            label: 'Status',
                            value: (sparePart.status as String).isNotEmpty
                                ? sparePart.status as String
                                : 'N/A',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.info_outline,
                            label: 'Part ID',
                            value: (sparePart.sparePartId as String).isNotEmpty
                                ? sparePart.sparePartId as String
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Product info card ─────────────────────
                  _SectionCard(
                    children: [
                      _InfoRow(
                        label: 'Spare Name',
                        value: sparePart.spareName as String,
                      ),
                      _InfoRow(label: 'Price', value: '₹${sparePart.price}'),
                      _InfoRow(
                        label: 'Rating',
                        value: rating > 0 ? '⭐ $rating' : 'N/A',
                      ),
                      _InfoRow(
                        label: 'Status',
                        value: (sparePart.status as String).toUpperCase(),
                      ),
                      _InfoRow(
                        label: 'Suits For',
                        value: (sparePart.suitsFor as String).isNotEmpty
                            ? sparePart.suitsFor as String
                            : 'N/A',
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Description accordion ─────────────────
                  _DescriptionAccordion(
                    description: sparePart.spareDescription as String,
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed bottom: price + CTA button ───────────────
          if (!isFromOrders)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.grey200)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x14000000),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          '₹${sparePart.price}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Obx(
                      () => GradientButton.filled(
                        text: 'Show Interest',
                        isLoading: controller.isRecordingInterest.value,
                        onPressed: controller.isRecordingInterest.value
                            ? null
                            : () => controller.recordSpareInterest(sparePart),
                      ),
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
// Rating badge overlay
// ─────────────────────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (i) {
            if (i < fullStars) {
              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Icon(Icons.star, size: 14.r, color: AppColors.white),
              );
            } else if (i == fullStars && hasHalf) {
              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Icon(
                  Icons.star_half,
                  size: 14.r,
                  color: AppColors.white,
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Icon(
                  Icons.star_border,
                  size: 14.r,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              );
            }
          }),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order status banner
// ─────────────────────────────────────────────────────────────────────────────

class _OrderStatusBanner extends StatelessWidget {
  final String status;
  final String orderId;
  const _OrderStatusBanner({required this.status, required this.orderId});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'pending':
        badgeColor = AppColors.warning;
        statusIcon = Icons.hourglass_top;
        break;
      case 'confirmed':
        badgeColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        badgeColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        badgeColor = AppColors.grey400;
        statusIcon = Icons.info_outline;
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 22.r, color: badgeColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status: ${status.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Order #$orderId',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
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
// Info box (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 12.r, 16.r),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.r, color: AppColors.grey600),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10.sp,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row (label : value)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label :',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.sp,
                  color: AppColors.grey700,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey100,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Description accordion
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionAccordion extends StatefulWidget {
  final String description;
  const _DescriptionAccordion({required this.description});

  @override
  State<_DescriptionAccordion> createState() => _DescriptionAccordionState();
}

class _DescriptionAccordionState extends State<_DescriptionAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header tap row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14.h,
              ),
              color: _expanded
                  ? AppColors.lightOrange.withValues(alpha: 0.18)
                  : AppColors.white,
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.r,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Text(
                widget.description.isNotEmpty
                    ? widget.description
                    : 'No description available for this spare part.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.sp,
                  color: AppColors.grey700,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

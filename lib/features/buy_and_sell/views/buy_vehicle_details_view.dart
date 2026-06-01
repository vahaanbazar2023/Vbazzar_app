import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../domain/entities/buy_vehicle_entity.dart';

class BuyVehicleDetailsView extends StatelessWidget {
  const BuyVehicleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final vehicle = args['vehicle'] as BuyVehicleEntity?;

    if (vehicle == null) {
      return AppLayout(
        title: 'Vehicle Details',
        body: const Center(child: Text('Vehicle not found')),
      );
    }

    final images = vehicle.allImageUrls;

    return AppLayout(
      title: vehicle.categoryName,
      subtitle: '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'.trim(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Carousel ──────────────────────────────────────────────
            if (images.isNotEmpty)
              SizedBox(
                height: 240.h,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.grey100,
                      child: Center(
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200.h,
                color: AppColors.grey100,
                child: Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 64,
                    color: AppColors.grey300,
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + Price ─────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
                                  .trim()
                                  .isEmpty
                              ? vehicle.categoryName
                              : '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
                                    .trim(),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        vehicle.formattedPrice,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Location ──────────────────────────────────────────────
                  if (vehicle.city != null || vehicle.state != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.grey500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          [
                            vehicle.city,
                            vehicle.state,
                          ].where((s) => s != null && s.isNotEmpty).join(', '),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Specs Card ────────────────────────────────────────────
                  _InfoCard(
                    title: 'Vehicle Specifications',
                    icon: Icons.info_outline,
                    children: [
                      if (vehicle.year != null) _SpecRow('Year', vehicle.year!),
                      if (vehicle.fuelType != null)
                        _SpecRow('Fuel Type', vehicle.fuelType!),
                      if (vehicle.bodyType != null)
                        _SpecRow('Body Type', vehicle.bodyType!),
                      if (vehicle.tonnage != null)
                        _SpecRow('Tonnage', vehicle.tonnage!),
                      if (vehicle.noOfTyres != null)
                        _SpecRow('No. of Tyres', vehicle.noOfTyres!),
                      if (vehicle.kv != null)
                        _SpecRow('KV Rating', vehicle.kv!),
                      _SpecRow('Category', vehicle.categoryName),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Actions Card ──────────────────────────────────────────
                  _InfoCard(
                    title: 'Actions',
                    icon: Icons.star_outline,
                    children: [
                      _ActionTile(
                        icon: Icons.favorite_border_rounded,
                        label: 'Show Interest',
                        color: const Color(0xFFEF4444),
                        onTap: () => Get.snackbar(
                          'Interest',
                          'Interest recorded',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        ),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.local_offer_outlined,
                        label: 'Make an Offer',
                        color: const Color(0xFF10B981),
                        onTap: () => _showOfferDialog(context),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.search_outlined,
                        label: 'Request Inspection',
                        color: const Color(0xFF3B82F6),
                        onTap: () => Get.snackbar(
                          'Inspection',
                          'Inspection request sent',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        ),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.lock_outline,
                        label: 'Request Owner Details',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => Get.snackbar(
                          'Access',
                          'Access request sent',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── Contact Button ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.ctaGradientStart,
                          AppColors.ctaGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(27),
                        onTap: () => Get.snackbar(
                          'Contact',
                          'Subscribe to view owner details',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.grey900,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Contact Seller',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfferDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Make an Offer',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter offer amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey600)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Offer Submitted',
                'Your offer of ₹${ctrl.text} has been submitted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final nonEmpty = children.where((w) => w is! SizedBox).toList();
    if (nonEmpty.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

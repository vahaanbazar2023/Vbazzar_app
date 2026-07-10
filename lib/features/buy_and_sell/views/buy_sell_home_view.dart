import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../controllers/buy_sell_home_controller.dart';
import '../domain/entities/filter_option_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';

class BuySellHomeView extends GetView<BuySellHomeController> {
  const BuySellHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Buy & Sell',
      subtitle: 'Browse & post commercial vehicles',
      body: _buildBuyTab(),
    );
  }

  // ── Buy Tab — shows all categories as cards ───────────────────────────────
  Widget _buildBuyTab() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (controller.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined, size: 64, color: AppColors.grey300),
              SizedBox(height: AppSpacing.md),
              Text(
                'No categories available',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.sp,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _CategoryCard(category: controller.categories[index]),
          );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Card — same UI as the old VehicleCard (dealer name, image, Buy/Sell)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final VehicleCategoryEntity category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Category image / icon ───────────────────────────────────
                category.iconUrl != null && category.iconUrl!.isNotEmpty
                    ? Image.network(
                        category.iconUrl!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          _iconForCategory(category.categoryCode),
                          color: AppColors.primary,
                          size: 56,
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Icon(
                        _iconForCategory(category.categoryCode),
                        color: AppColors.primary,
                        size: 56,
                      ),
                SizedBox(width: AppSpacing.lg),
                // ── Category info ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.categoryName,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category.description != null &&
                          category.description!.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          category.description!,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.sp,
                            color: AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Available Vehicles : ${category.vehicleCount}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.sp,
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            // ── Buy / Sell buttons ──────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _buildBuyButton()),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildSellButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.buyVehicleListings,
        arguments: {'category': category},
      ),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Buy',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.sellVehicle,
        arguments: {
          'categoryCode': category.categoryCode,
          'categoryName': category.categoryName,
        },
      ),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Center(
          child: Text(
            'Sell',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String code) {
    switch (code.toUpperCase()) {
      case 'CARS':
      case 'CAR':
        return Icons.directions_car;
      case 'TRUCKS':
      case 'TRUCK':
      case 'LCV':
      case 'ICV':
        return Icons.local_shipping;
      case 'BIKES':
      case 'MOTORCYCLES':
        return Icons.two_wheeler;
      case 'BUS':
        return Icons.directions_bus;
      case 'TRACTOR':
        return Icons.agriculture;
      case 'JCB':
      case 'CE':
      case 'CRANE':
      case 'EXCAVATOR':
      case 'ROLLER':
        return Icons.construction;
      case 'TIPPER':
        return Icons.local_shipping;
      case 'GENERATOR':
        return Icons.electrical_services;
      default:
        return Icons.directions_car;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBottomSheet extends StatefulWidget {
  final BuySellHomeController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Map<String, dynamic> _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = Map.from(widget.controller.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _tempFilters.clear()),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (widget.controller.isLoadingFilters.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (widget.controller.filterConfigs.isEmpty) {
                return Center(
                  child: Text(
                    'No filters available',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.grey500,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: widget.controller.filterConfigs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entry = widget.controller.filterConfigs.entries
                      .elementAt(index);
                  return _buildFilterField(entry.key, entry.value);
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.selectedFilters.assignAll(_tempFilters);
                  widget.controller.loadVehicles();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(String name, FilterConfigEntity config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey300),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: _tempFilters[name]?.toString(),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: Text(
              'Select $name',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.grey500,
                fontSize: 13.sp,
              ),
            ),
            items: (config.options ?? []).map((opt) {
              return DropdownMenuItem(
                value: opt.value,
                child: Text(
                  opt.label,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.sp),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                if (val == null) {
                  _tempFilters.remove(name);
                } else {
                  _tempFilters[name] = val;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

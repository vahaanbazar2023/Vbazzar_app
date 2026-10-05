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
      body: _buildCategoryGrid(),
    );
  }

  // ── Category Grid — 2 columns ─────────────────────────────────────────────
  Widget _buildCategoryGrid() {
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

      return GridView.builder(
        padding: EdgeInsets.all(AppSpacing.sm),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.25, // Shorter cards
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          return _CategoryCard(category: controller.categories[index]);
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Category image with count badge ──────────────────────────
          Stack(
            children: [
              Container(
                height: 70.h,
                decoration: BoxDecoration(
                  // color: AppColors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Center(
                  child:
                      category.iconUrl != null && category.iconUrl!.isNotEmpty
                      ? Image.network(
                          category.iconUrl!,
                          height: 65.h,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            _iconForCategory(category.categoryCode),
                            color: AppColors.white,
                            size: 38.r,
                          ),
                        )
                      : Icon(
                          _iconForCategory(category.categoryCode),
                          color: AppColors.white,
                          size: 38.r,
                        ),
                ),
              ),
              // Count badge - top right
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.ctaGradientStart,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ctaGradientStart.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${category.vehicleCount}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Category name and buttons ─────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    category.categoryName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 5.h),
                // Buy + Sell buttons
                Row(
                  children: [
                    Expanded(child: _buildBuyButton()),
                    SizedBox(width: 6.w),
                    Expanded(child: _buildSellButton()),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        height: 26.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          ),
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ctaGradientStart.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Buy',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
        height: 26.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: AppColors.ctaGradientStart, width: 1.5),
        ),
        child: Center(
          child: Text(
            'Sell',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.ctaGradientStart,
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
      case 'BACKHOE':
        return Icons.construction;
      case 'TIPPER':
        return Icons.local_shipping;
      case 'CONCRETE':
      case 'MIXER':
        return Icons.local_shipping;
      case 'FUEL':
      case 'TANKER':
        return Icons.local_gas_station;
      case 'CARGO':
        return Icons.local_shipping;
      case 'REFUSE':
      case 'GARBAGE':
        return Icons.delete_outline;
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
                    fontWeight: FontWeight.w600,
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

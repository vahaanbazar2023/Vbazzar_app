import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../controllers/auction_list_controller.dart';
import '../domain/entities/auction_entity.dart';
import '../domain/entities/bid_entity.dart';
import '../utils/auction_utils.dart';

/// A modern, stylish filter bottom sheet for the Auction screen.
/// Shows 4 filter dropdowns: Category, Vehicle Type, Region, State.
class AuctionFilterBottomSheet extends StatelessWidget {
  const AuctionFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final controller = Get.find<AuctionListController>();
    controller.backupCurrentFilters();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuctionFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuctionListController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag handle ────────────────────────────────────────
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              16.h,
              AppSpacing.md,
              8.h,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Filter Auctions',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  if (!controller.hasActiveFilters) return const SizedBox();
                  return GestureDetector(
                    onTap: () {
                      controller.resetFiltersWithoutReload();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14.r,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Divider(color: AppColors.grey200, height: 1),

          // ── Filter fields ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category ────────────────────────────────────
                  _FilterSectionLabel(label: 'Category', icon: Icons.category_outlined),
                  SizedBox(height: 8.h),
                  _CategoryDropdown(controller: controller),
                  SizedBox(height: 20.h),

                  // ── Vehicle Type ────────────────────────────────
                  _FilterSectionLabel(
                    label: 'Vehicle Type',
                    icon: Icons.directions_car_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _VehicleTypeDropdown(controller: controller),
                  SizedBox(height: 20.h),

                  // ── Region ──────────────────────────────────────
                  _FilterSectionLabel(
                    label: 'Region',
                    icon: Icons.map_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _RegionDropdown(controller: controller),
                  SizedBox(height: 20.h),

                  // ── State ───────────────────────────────────────
                  _FilterSectionLabel(
                    label: 'State',
                    icon: Icons.location_city_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _StateDropdown(controller: controller),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Action buttons ─────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              12.h,
              AppSpacing.md,
              MediaQuery.of(context).padding.bottom + 16.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Reset button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.resetFilters();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Center(
                        child: Text(
                          'Reset Filters',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Apply button
                Expanded(
                  flex: 2,
                  child: GradientButton.filled(
                    text: 'Apply Filters',
                    onPressed: () {
                      controller.applyFilters();
                      Navigator.of(context).pop();
                    },
                    height: 48.h,
                    isLoading: false,
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

// ─── Section Label ─────────────────────────────────────────────────────────

class _FilterSectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterSectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}

// ─── Styled Dropdown Wrapper ───────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isLoading;
  final bool isDisabled;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    this.onChanged,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.grey100 : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value != null && !isDisabled
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.grey300,
          width: value != null && !isDisabled ? 1.5 : 1,
        ),
      ),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Row(
                  children: [
                    Icon(icon, size: 18.r, color: AppColors.grey400),
                    SizedBox(width: 10.w),
                    Text(
                      hint,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                isExpanded: true,
                icon: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDisabled ? AppColors.grey400 : AppColors.grey600,
                    size: 22.r,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                borderRadius: BorderRadius.circular(12.r),
                dropdownColor: AppColors.white,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  color: AppColors.grey900,
                ),
                items: items,
                onChanged: isDisabled ? null : onChanged,
              ),
            ),
    );
  }
}

// ─── Category Dropdown ─────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final AuctionListController controller;

  const _CategoryDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _StyledDropdown<String>(
        value: controller.selectedCategory.value,
        hint: 'Select Category',
        icon: Icons.category_outlined,
        items: AuctionUtils.categoryOptions
            .map(
              (cat) => DropdownMenuItem<String>(
                value: cat,
                child: Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(cat),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (val) => controller.onCategoryChanged(val),
      );
    });
  }
}

// ─── Vehicle Type Dropdown ─────────────────────────────────────────────────

class _VehicleTypeDropdown extends StatelessWidget {
  final AuctionListController controller;

  const _VehicleTypeDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _StyledDropdown<String>(
        value: controller.selectedVehicleType.value,
        hint: 'Select Vehicle Type',
        icon: Icons.directions_car_outlined,
        items: AuctionUtils.vehicleTypeOptions
            .map(
              (type) => DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        type,
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
            )
            .toList(),
        onChanged: (val) => controller.onVehicleTypeChanged(val),
      );
    });
  }
}

// ─── Region Dropdown ───────────────────────────────────────────────────────

class _RegionDropdown extends StatelessWidget {
  final AuctionListController controller;

  const _RegionDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _StyledDropdown<RegionEntity>(
        value: controller.selectedRegion.value,
        hint: 'Select Region',
        icon: Icons.map_outlined,
        isLoading: controller.isLoadingRegions.value,
        items: controller.regions
            .map(
              (region) => DropdownMenuItem<RegionEntity>(
                value: region,
                child: Text(region.name),
              ),
            )
            .toList(),
        onChanged: (val) => controller.onRegionChanged(val),
      );
    });
  }
}

// ─── State Dropdown ────────────────────────────────────────────────────────

class _StateDropdown extends StatelessWidget {
  final AuctionListController controller;

  const _StateDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDisabled = controller.selectedRegion.value == null;
      final isValidState = controller.statesByRegion.contains(
        controller.selectedState.value,
      );

      return _StyledDropdown<StateByRegionEntity>(
        value: isValidState ? controller.selectedState.value : null,
        hint: isDisabled ? 'Select Region First' : 'Select State',
        icon: Icons.location_city_outlined,
        isLoading: controller.isLoadingStatesByRegion.value,
        isDisabled: isDisabled,
        items: controller.statesByRegion
            .map(
              (state) => DropdownMenuItem<StateByRegionEntity>(
                value: state,
                child: Text(state.stateName),
              ),
            )
            .toList(),
        onChanged: isDisabled
            ? null
            : (val) => controller.onStateChanged(val),
      );
    });
  }
}
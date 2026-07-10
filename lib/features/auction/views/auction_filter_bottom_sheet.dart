import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auction_list_controller.dart';
import '../domain/entities/auction_entity.dart';
import '../utils/auction_utils.dart';

/// A modern, stylish filter bottom sheet for the Auction screen.
/// Shows 4 filter dropdowns: Category, Vehicle Type, Region, State.
class AuctionFilterBottomSheet extends StatelessWidget {
  const AuctionFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final controller = Get.isRegistered<AuctionListController>()
        ? Get.find<AuctionListController>()
        : Get.put(AuctionListController());
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
    final controller = Get.isRegistered<AuctionListController>()
        ? Get.find<AuctionListController>()
        : Get.put(AuctionListController());

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
                  context.l10n.filterAuctions,
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
                            context.l10n.clearFilters,
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
                  _FilterSectionLabel(
                    label: context.l10n.category,
                    icon: Icons.category_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _CategoryField(controller: controller),
                  SizedBox(height: 20.h),

                  // ── Region ──────────────────────────────────────
                  _FilterSectionLabel(
                    label: context.l10n.selectRegion,
                    icon: Icons.map_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _RegionField(controller: controller),
                  SizedBox(height: 20.h),

                  // ── State (CustomAutocompleteField) ─────────────
                  _FilterSectionLabel(
                    label: context.l10n.state,
                    icon: Icons.location_city_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _StateField(controller: controller),
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
                          context.l10n.resetFilters,
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
                    text: context.l10n.applyFilters,
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

// ─── Category — InlineDropdownField ────────────────────────────────────────

class _CategoryField extends StatelessWidget {
  final AuctionListController controller;
  const _CategoryField({required this.controller});

  /// Reverse-lookup: given the stored API value, find the display label.
  String _labelForValue(String? apiValue) {
    if (apiValue == null || apiValue.isEmpty) return 'All';
    return AuctionUtils.auctionCategoryOptions.entries
        .firstWhere(
          (e) => e.value == apiValue,
          orElse: () => const MapEntry('All', ''),
        )
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentLabel = _labelForValue(controller.selectedCategory.value);
      return InlineDropdownField<String>(
        value: currentLabel == 'All' ? null : currentLabel,
        items: AuctionUtils.auctionCategoryLabels,
        placeholder: context.l10n.selectCategory,
        prefixIcon: Icons.business_outlined,
        itemLabel: (v) => v,
        onChanged: (label) {
          if (label == null) {
            controller.onCategoryChanged(null);
          } else {
            final apiValue = AuctionUtils.auctionCategoryApiValue(label);
            controller.onCategoryChanged(apiValue.isEmpty ? null : apiValue);
          }
        },
      );
    });
  }
}

// ─── Region — InlineDropdownField ──────────────────────────────────────────

class _RegionField extends StatelessWidget {
  final AuctionListController controller;
  const _RegionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InlineDropdownField<RegionEntity>(
        value: controller.selectedRegion.value,
        items: controller.regions,
        placeholder: context.l10n.selectRegion,
        prefixIcon: Icons.map_outlined,
        isLoading: controller.isLoadingRegions.value,
        itemLabel: (r) => r.name,
        onChanged: (val) => controller.onRegionChanged(val),
      ),
    );
  }
}

// ─── State — CustomAutocompleteField (region-dependent) ────────────────────

class _StateField extends StatefulWidget {
  final AuctionListController controller;
  const _StateField({required this.controller});

  @override
  State<_StateField> createState() => _StateFieldState();
}

class _StateFieldState extends State<_StateField> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(
      text: widget.controller.selectedState.value?.stateName ?? '',
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDisabled = widget.controller.selectedRegion.value == null;
      final states = widget.controller.statesByRegion;
      final isLoading = widget.controller.isLoadingStatesByRegion.value;

      if (isDisabled && _textCtrl.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _textCtrl.clear();
        });
      }

      return CustomAutocompleteField<StateByRegionEntity>(
        controller: _textCtrl,
        options: states,
        placeholder: isDisabled
            ? context.l10n.selectStateFirst
            : context.l10n.searchState,
        prefixIcon: Icons.location_city_outlined,
        isLoading: isLoading,
        enabled: !isDisabled,
        displayStringForOption: (s) => s.stateName,
        forceSelection: true,
        maxDropdownHeight: 220,
        onSelected: (s) => widget.controller.onStateChanged(s),
        onChanged: (_) {},
      );
    });
  }
}

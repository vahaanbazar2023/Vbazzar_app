import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../subscription/models/user_subscription.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../domain/entities/buy_vehicle_entity.dart';

class BuyVehicleDetailsView extends StatefulWidget {
  const BuyVehicleDetailsView({super.key});

  @override
  State<BuyVehicleDetailsView> createState() => _BuyVehicleDetailsViewState();
}

class _BuyVehicleDetailsViewState extends State<BuyVehicleDetailsView> {
  bool _showOfferField = false;
  final _offerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final vehicle = args['vehicle'] as BuyVehicleEntity?;
    final vehicleId =
        vehicle?.sbVehicleId ?? args['sb_vehicle_id'] as String? ?? '';
    final categoryCode =
        vehicle?.categoryCode ?? args['category_code'] as String? ?? '';
    if (vehicleId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = Get.find<BuyVehicleController>();
        // Skip fetch if we already have fresh data for this vehicle.
        if (ctrl.currentVehicleDetail.value?.sbVehicleId == vehicleId &&
            !ctrl.isLoadingDetail.value) {
          return;
        }
        ctrl.fetchVehicleDetail(vehicleId, categoryCode: categoryCode);
      });
    }
  }

  @override
  void dispose() {
    _offerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BuyVehicleController>();

    return Obx(() {
      // While loading show a spinner inside the layout
      if (ctrl.isLoadingDetail.value) {
        return AppLayout(
          title: context.l10n.vehicleDetailsTitle,
          subtitle: '',
          showBack: true,
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      // Error state
      if (ctrl.detailError.value.isNotEmpty &&
          ctrl.currentVehicleDetail.value == null) {
        return AppLayout(
          title: context.l10n.vehicleDetailsTitle,
          subtitle: '',
          showBack: true,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctrl.detailError.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      color: AppColors.grey600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  GradientButton.filled(
                    text: context.l10n.retry,
                    onPressed: () {
                      final args = Get.arguments as Map<String, dynamic>? ?? {};
                      final v = args['vehicle'] as BuyVehicleEntity?;
                      final vehicleId =
                          v?.sbVehicleId ??
                          args['sb_vehicle_id'] as String? ??
                          '';
                      final catCode =
                          v?.categoryCode ??
                          args['category_code'] as String? ??
                          '';
                      if (vehicleId.isNotEmpty) {
                        ctrl.fetchVehicleDetail(
                          vehicleId,
                          categoryCode: catCode,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final vehicle = ctrl.currentVehicleDetail.value;
      if (vehicle == null) {
        return AppLayout(
          title: context.l10n.vehicleDetailsTitle,
          subtitle: '',
          showBack: true,
          body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      return _buildDetail(context, vehicle, ctrl);
    });
  }

  Widget _buildDetail(
    BuildContext context,
    BuyVehicleEntity vehicle,
    BuyVehicleController ctrl,
  ) {
    final title = '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'.trim();

    return AppLayout(
      title: title.isEmpty ? vehicle.categoryName : title,
      subtitle: vehicle.sbVehicleId.isNotEmpty ? vehicle.sbVehicleId : '',
      showBack: true,
      bodyColor: AppColors.cardBackground,
      body: Column(
        children: [
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
                  // ── Image carousel ───────────────────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        NetworkImageCarousel(
                          imageUrls: vehicle.allImageUrls,
                          height: 220.h,
                        ),
                        // Category badge top-left
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              vehicle.categoryName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        // Status badge top-right
                        if (vehicle.status != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _StatusBadge(status: vehicle.status!),
                          ),
                        // Wishlist button — below status badge
                        Positioned(
                          top: vehicle.status != null ? 48 : 10,
                          right: 10,
                          child: Obx(
                            () => WishlistButton(
                              isWishlisted: ctrl.isWishlisted(
                                vehicle.sbVehicleId,
                              ),
                              onTap: () => ctrl.toggleWishlist(vehicle),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Vehicle title + location ─────────────────────────────
                  Center(
                    child: Text(
                      title.isEmpty ? vehicle.categoryName : title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Red underline accent
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

                  // // Location row
                  // if ((vehicle.city ?? '').isNotEmpty ||
                  //     (vehicle.state ?? '').isNotEmpty)
                  //   Center(
                  //     child: Padding(
                  //       padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Icon(
                  //             Icons.location_on_rounded,
                  //             size: 14.sp,
                  //             color: AppColors.primary,
                  //           ),
                  //           SizedBox(width: 4.w),
                  //           Text(
                  //             [vehicle.city, vehicle.state]
                  //                 .where((s) => s != null && s.isNotEmpty)
                  //                 .join(', '),
                  //             style: TextStyle(
                  //               fontFamily: 'Plus Jakarta Sans',
                  //               fontSize: 13.sp,
                  //               color: AppColors.grey600,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),

                  // ── 2×2 Info boxes ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.fingerprint_rounded,
                            label: context.l10n.vehicle_id,
                            value: vehicle.sbVehicleId,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.category_outlined,
                            label: context.l10n.category,
                            value: vehicle.categoryName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.location_city_outlined,
                            label: context.l10n.location,
                            value:
                                [vehicle.city, vehicle.state]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(', ')
                                    .isEmpty
                                ? context.l10n.na
                                : [vehicle.city, vehicle.state]
                                      .where((s) => s != null && s.isNotEmpty)
                                      .join(', '),
                          ),
                        ),

                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.calendar_month_rounded,
                            label: context.l10n.modelYear,
                            value: vehicle.year ?? context.l10n.na,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // // ── Key specs card ───────────────────────────────────────
                  // _KeySpecsCard(vehicle: vehicle),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle details accordion ────────────────────────────
                  _VehicleDetailsAccordion(vehicle: vehicle),
                  SizedBox(height: AppSpacing.md),

                  // ── Actions label ────────────────────────────────────────
                  _SectionLabel(
                    icon: Icons.bolt_rounded,
                    title: context.l10n.actions,
                  ),
                  SizedBox(height: 12.h),

                  // ── Action card 1: Show Interest ──────────────────────────
                  _ActionCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F9B8E), Color(0xFF16C79A)],
                    ),
                    icon: Icons.favorite_rounded,
                    title: context.l10n.letUsKnow,
                    subtitle: context.l10n.youreInterested,
                    buttonText: context.l10n.interested,
                    buttonColor: Colors.white,
                    buttonTextColor: const Color(0xFF0F9B8E),
                    onTap: () {
                      final c = Get.find<BuyVehicleController>();
                      c.submitInterest(vehicle);
                    },
                  ),
                  SizedBox(height: 10.h),

                  // ── Action card 2: Become a Member / Connect with Owner ──
                  _ConnectWithOwnerCard(vehicle: vehicle),
                  SizedBox(height: 10.h),

                  // ── Action card 3: Make Offer (expands inline) ──────────
                  _OfferCard(
                    offerCtrl: _offerCtrl,
                    expanded: _showOfferField,
                    onToggle: () => setState(() {
                      _showOfferField = !_showOfferField;
                      if (!_showOfferField) _offerCtrl.clear();
                    }),
                    onSubmit: () async {
                      final amount = int.tryParse(
                        _offerCtrl.text.replaceAll(',', '').trim(),
                      );
                      if (amount == null || amount <= 0) {
                        Get.snackbar(
                          context.l10n.invalidAmount,
                          context.l10n.pleaseEnterValidOfferAmount,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }
                      // Client-side 60% validation
                      if (vehicle.price != null && vehicle.price! > 0) {
                        final minRequired = (vehicle.price! * 0.6).ceil();
                        if (amount < minRequired) {
                          Get.snackbar(
                            context.l10n.offerTooLow,
                            context.l10n.minimumOfferPercent(_fmt(minRequired)),
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red.shade700,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 4),
                          );
                          return;
                        }
                      }
                      final c = Get.find<BuyVehicleController>();
                      final error = await c.submitOffer(vehicle, amount);
                      if (error == null) {
                        setState(() {
                          _showOfferField = false;
                          _offerCtrl.clear();
                        });
                        CustomSnackbar.show(
                          message: context.l10n.offerSent,
                          type: SnackbarType.success,
                        );
                      } else {
                        Get.snackbar(
                          context.l10n.offerFailed,
                          error,
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade700,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 50.h),

                  // ── Inspection button ────────────────────────────────────
                  vehicle.isInspectionRequested
                      ? Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                context.l10n.inspectionRequested,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GradientButton.filled(
                          text: context.l10n.requestVehicleInspection,
                          width: double.infinity,
                          onPressed: () {
                            Get.find<BuyVehicleController>().requestInspection(
                              vehicle,
                            );
                          },
                        ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indian number formatting for display in snackbar messages
  static String _fmt(int n) {
    if (n <= 0) return '0';
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    int count = 0;
    for (int i = rest.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0) buf.write(',');
      buf.write(rest[i]);
      count++;
    }
    return '${buf.toString().split('').reversed.join()},$last3';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge overlay on image
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.9)
            : Colors.grey.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info box — matches auction detail _InfoBox exactly
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
// Key Specs card — horizontal grid of spec chips
// ─────────────────────────────────────────────────────────────────────────────

class _KeySpecsCard extends StatelessWidget {
  final BuyVehicleEntity vehicle;
  const _KeySpecsCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = <_SpecItem>[];
    if (vehicle.year != null)
      specs.add(
        _SpecItem(
          Icons.calendar_month_rounded,
          context.l10n.year,
          vehicle.year!,
        ),
      );
    if (vehicle.fuelType != null)
      specs.add(
        _SpecItem(
          Icons.local_gas_station_outlined,
          context.l10n.fuelType,
          vehicle.fuelType!,
        ),
      );
    if (vehicle.bodyType != null)
      specs.add(
        _SpecItem(
          Icons.view_in_ar_outlined,
          context.l10n.bodyType,
          vehicle.bodyType!,
        ),
      );
    if (vehicle.tonnage != null)
      specs.add(
        _SpecItem(
          Icons.fitness_center_outlined,
          context.l10n.tonnage,
          vehicle.tonnage!,
        ),
      );
    if (vehicle.noOfTyres != null)
      specs.add(
        _SpecItem(
          Icons.radio_button_unchecked_rounded,
          context.l10n.noOfTyres,
          vehicle.noOfTyres!,
        ),
      );
    if (vehicle.kv != null)
      specs.add(
        _SpecItem(Icons.bolt_rounded, context.l10n.kvRating, vehicle.kv!),
      );

    if (specs.isEmpty) return const SizedBox.shrink();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              14.h,
              AppSpacing.md,
              10.h,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.speed_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  context.l10n.keySpecifications,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.grey100),
          // Spec chips grid
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: specs
                  .map(
                    (s) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 14.r, color: AppColors.primary),
                          SizedBox(width: 6.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.label,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9.sp,
                                  color: AppColors.grey500,
                                ),
                              ),
                              Text(
                                s.value,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem(this.icon, this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Details Accordion — expandable, matches auction style
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleDetailsAccordion extends StatefulWidget {
  final BuyVehicleEntity vehicle;
  const _VehicleDetailsAccordion({required this.vehicle});

  @override
  State<_VehicleDetailsAccordion> createState() =>
      _VehicleDetailsAccordionState();
}

class _VehicleDetailsAccordionState extends State<_VehicleDetailsAccordion> {
  bool _expanded = true; // open by default so user sees the details

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
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
                    Icons.directions_car_outlined,
                    size: 18.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.l10n.vehicleDetailsTitle,
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
            secondChild: _buildDetails(v),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuyVehicleEntity v) {
    final rows = <_DetailRowData>[];
    if (v.brandName != null)
      rows.add(
        _DetailRowData(
          Icons.branding_watermark_outlined,
          context.l10n.brand,
          v.brandName!,
        ),
      );
    if (v.model != null)
      rows.add(
        _DetailRowData(
          Icons.directions_car_outlined,
          context.l10n.model,
          v.model!,
        ),
      );
    if (v.year != null)
      rows.add(
        _DetailRowData(
          Icons.calendar_today_outlined,
          context.l10n.yearOfManufacture,
          v.year!,
        ),
      );
    rows.add(
      _DetailRowData(
        Icons.category_outlined,
        context.l10n.category,
        v.categoryName,
      ),
    );
    rows.add(
      _DetailRowData(
        Icons.code_rounded,
        context.l10n.categoryCode,
        v.categoryCode,
      ),
    );
    if (v.brandCode != null)
      rows.add(
        _DetailRowData(Icons.tag_rounded, context.l10n.brandCode, v.brandCode!),
      );
    if (v.fuelType != null)
      rows.add(
        _DetailRowData(
          Icons.local_gas_station_outlined,
          context.l10n.fuelType,
          v.fuelType!,
        ),
      );
    if (v.bodyType != null)
      rows.add(
        _DetailRowData(
          Icons.view_in_ar_outlined,
          context.l10n.bodyType,
          v.bodyType!,
        ),
      );
    if (v.tonnage != null)
      rows.add(
        _DetailRowData(
          Icons.fitness_center_outlined,
          context.l10n.tonnage,
          v.tonnage!,
        ),
      );
    if (v.noOfTyres != null)
      rows.add(
        _DetailRowData(
          Icons.radio_button_unchecked_rounded,
          context.l10n.noOfTyres,
          v.noOfTyres!,
        ),
      );
    if (v.kv != null)
      rows.add(
        _DetailRowData(
          Icons.electrical_services_outlined,
          context.l10n.kvRating,
          v.kv!,
        ),
      );
    if (v.city != null)
      rows.add(
        _DetailRowData(
          Icons.location_city_outlined,
          context.l10n.city,
          v.city!,
        ),
      );
    if (v.state != null)
      rows.add(
        _DetailRowData(Icons.map_outlined, context.l10n.state, v.state!),
      );
    if (v.status != null)
      rows.add(
        _DetailRowData(Icons.info_outline, context.l10n.status, v.status!),
      );

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: AppColors.grey100),
        ...rows.asMap().entries.map(
          (entry) => _DetailRow(
            icon: entry.value.icon,
            label: entry.value.label,
            value: entry.value.value,
            isLast: entry.key == rows.length - 1,
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRowData(this.icon, this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row — matches auction _DetailRow
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.icon,
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
            children: [
              Icon(icon, size: 16.r, color: AppColors.grey500),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  softWrap: true,
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
// Section label row
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 22.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action card — preserved exactly (gradient colored cards)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84.h,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                // Text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Offer card — orange gradient card that expands to show inline amount field
// ─────────────────────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final TextEditingController offerCtrl;
  final bool expanded;
  final VoidCallback onToggle;
  final Future<void> Function() onSubmit;

  const _OfferCard({
    required this.offerCtrl,
    required this.expanded,
    required this.onToggle,
    required this.onSubmit,
  });

  static const _g1 = Color(0xFFE8882A);
  static const _g2 = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_g1, _g2]),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _g1.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row (always visible) ──────────────────────────────
            InkWell(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
                bottom: expanded ? Radius.zero : Radius.circular(16.r),
              ),
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 0),
                child: SizedBox(
                  height: 72.h,
                  child: Row(
                    children: [
                      // Icon box
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // Title / subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.submitYour,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              context.l10n.bestVehicleOffer,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Toggle pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          expanded ? context.l10n.cancel : context.l10n.submit,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Inline offer input (expands below header) ────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(36.w, 0, 14.w, 12.h),
                child: TextField(
                  controller: offerCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: context.l10n.enterAmount,
                    hintStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    prefixText: '₹  ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: onSubmit,
                      child: Container(
                        margin: EdgeInsets.all(6.r),
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: _g1,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.18),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 6.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(48.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(48.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(48.r),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
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
// Become a Member / Connect with Owner card
//
// State machine (priority order):
//   1. vehicle.hasOwnerAccess == true   → phone already revealed by API
//   2. ownerPhones[vehicleId] != null   → phone fetched after payment
//   3. isFetchingOwnerPhone == true     → payment just happened, fetching
//   4. default                          → show Subscribe button
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectWithOwnerCard extends StatefulWidget {
  final BuyVehicleEntity vehicle;
  const _ConnectWithOwnerCard({required this.vehicle});

  @override
  State<_ConnectWithOwnerCard> createState() => _ConnectWithOwnerCardState();
}

class _ConnectWithOwnerCardState extends State<_ConnectWithOwnerCard> {
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<BuyVehicleController>();
    final vehicleId = widget.vehicle.sbVehicleId;

    // Seed immediately if API already granted access on this load.
    if (widget.vehicle.hasOwnerAccess) {
      final phone = widget.vehicle.sellerPhone ?? '';
      if (phone.isNotEmpty) {
        ctrl.ownerPhones[vehicleId] = phone;
      }
    }

    // Watch for future fetchVehicleDetail completions (e.g. after payment).
    // When currentVehicleDetail updates with owner access, seed the phone.
    _worker = ever(ctrl.currentVehicleDetail, (fresh) {
      if (fresh == null) return;
      if (fresh.sbVehicleId != vehicleId) return;
      if (!fresh.hasOwnerAccess) return;
      final phone = fresh.sellerPhone ?? '';
      if (phone.isNotEmpty && !ctrl.ownerPhones.containsKey(vehicleId)) {
        ctrl.ownerPhones[vehicleId] = phone;
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BuyVehicleController>();
    final vehicleId = widget.vehicle.sbVehicleId;
    final planCode = widget.vehicle.categoryPlan;

    return Obx(() {
      final cachedPhone = ctrl.ownerPhones[vehicleId];
      final isFetching = ctrl.isLoadingDetail.value;
      final hasPhone = cachedPhone != null && cachedPhone.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A0CA3), Color(0xFF7209B7)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A0CA3).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // ── Icon ─────────────────────────────────────────────────────
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFetching
                    ? Icons.hourglass_empty_rounded
                    : hasPhone
                    ? Icons.phone_rounded
                    : Icons.stars_rounded,
                color: Colors.white,
                size: 22.r,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // ── Text ─────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.becomeMember,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    isFetching
                        ? context.l10n.fetchingContact
                        : hasPhone
                        ? cachedPhone
                        : context.l10n.connectWithOwner,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: hasPhone ? 16.sp : 12.sp,
                      fontWeight: hasPhone ? FontWeight.w700 : FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: hasPhone ? 1.2 : 0,
                    ),
                  ),
                ],
              ),
            ),

            // ── Action ───────────────────────────────────────────────────
            if (isFetching)
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else if (hasPhone)
              // Phone is revealed — show Call button
              GestureDetector(
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: cachedPhone);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    CustomSnackbar.show(
                      message: '${context.l10n.owner}: $cachedPhone',
                      type: SnackbarType.success,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call_rounded,
                        size: 14.r,
                        color: const Color(0xFF3A0CA3),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        context.l10n.callButton,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3A0CA3),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Not yet subscribed — show Subscribe button with price
              GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.subscription,
                  arguments: {
                    'subscription_source': SubscriptionTypeCode.ownerContact,
                    'title': context.l10n.connectWithOwnerTitle,
                    'subtitle': context.l10n.connectWithOwnerSubtitle,
                    'pending_vehicle_id': vehicleId,
                    'category_code': widget.vehicle.categoryCode,
                    if (planCode != null) 'plan_code_override': planCode,
                  },
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    context.l10n.subscribe,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7209B7),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

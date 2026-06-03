import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/insurance_finance_controller.dart';
import '../domain/entities/quote_entity.dart' show QuoteEntity, VehicleQuoteItemEntity;

/// My Quotes view — displays all insurance/finance quotes for the user's vehicles.
///
/// Features:
/// - Pull-to-refresh
/// - Expandable vehicle cards with quote details
/// - Download PDF for each quote
/// - Loading, error, and empty states
class MyQuotesView extends StatefulWidget {
  const MyQuotesView({super.key});

  @override
  State<MyQuotesView> createState() => _MyQuotesViewState();
}

class _MyQuotesViewState extends State<MyQuotesView> {
  final controller = Get.find<InsuranceFinanceController>();

  @override
  void initState() {
    super.initState();
    controller.loadVehicleQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Quotes',
      subtitle: 'View your insurance and finance quotes',
      showBack: true,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // Loading state
      if (controller.isLoadingQuotes.value &&
          controller.vehicleQuotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading quotes...',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        );
      }

      // Error state
      if (controller.quotesErrorMessage.value.isNotEmpty &&
          controller.vehicleQuotes.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.quotesErrorMessage.value,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => controller.loadVehicleQuotes(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Retry',
                      style: AppFonts.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Empty state
      if (controller.vehicleQuotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                'No quotes available',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Submit an insurance or finance request to get quotes',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Data state
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.refreshQuotes(),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: controller.vehicleQuotes.length,
          itemBuilder: (context, index) {
            final vehicle = controller.vehicleQuotes[index];
            return _buildVehicleCard(vehicle);
          },
        ),
      );
    });
  }

  Widget _buildVehicleCard(VehicleQuoteItemEntity vehicle) {
    final isExpanded =
        controller.expandedVehicleIds.contains(vehicle.vehicleId);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE4E5E7).withValues(alpha: 0.24),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          InkWell(
            onTap: () => controller.toggleVehicleExpansion(vehicle.vehicleId),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: vehicle.serviceType == 'insurance'
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      vehicle.serviceType == 'insurance'
                          ? Icons.shield_outlined
                          : Icons.account_balance_outlined,
                      color: vehicle.serviceType == 'insurance'
                          ? AppColors.primary
                          : AppColors.secondary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNo,
                          style: AppFonts.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            _buildBadge(
                              vehicle.serviceType.toUpperCase(),
                              vehicle.serviceType == 'insurance'
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${vehicle.totalQuotes} ${vehicle.totalQuotes == 1 ? 'Quote' : 'Quotes'}',
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Quotes ───────────────────────────────────
          if (isExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.grey200,
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicle.quotes.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: Text(
                          'No quotes received yet',
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    ...vehicle.quotes.asMap().entries.map((entry) {
                      return _buildQuoteCard(entry.value, entry.key, vehicle);
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteCard(QuoteEntity quote, int index, VehicleQuoteItemEntity vehicle) {
    // Gradient color schemes alternating per provider
    final gradients = [
      [const Color(0xFFFF00CC), const Color(0xFFC80EBE), const Color(0xFF333399)],
      [const Color(0xFF2E3393), const Color(0xFF1CFAFC)],
      [const Color(0xFF833AB4), const Color(0xFFFD1D1D), const Color(0xFFFCB045)],
      [const Color(0xFFEFD30D), const Color(0xFF81B65A), const Color(0xFF1097AD)],
    ];
    final gradientColors = gradients[index % gradients.length];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.providerName,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${_formatPrice(quote.price)}',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.downloadQuote(
                quote.downloadablePdfUrl,
                quote.providerName,
                vehicle.vehicleNo,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(90.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    size: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Download',
                    style: AppFonts.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: AppFonts.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  /// Format price with Indian comma grouping (e.g., 8500 → 8,500)
  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    final result = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return result;
  }
}
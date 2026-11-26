import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../payment/controllers/payment_controller.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';

/// What an approved-vehicle payment is for.
enum ApprovedVehiclePaymentPurpose { booking, inspection }

/// Booking / inspection payment for one approved vehicle.
///
/// A one-time payment (no plan validity). The amount is the vehicle's own fee
/// worked out on the server (`booking_amount` / `inspection_amount`); the server
/// checks it again on /payments/initiate. Booking also tells the buyer that the
/// 2% commission + GST is charged with the full payment, not now.
class ApprovedVehiclePaymentScreen extends StatefulWidget {
  final ApprovedVehicleListingEntity listing;
  final ApprovedVehiclePaymentPurpose purpose;
  final double amount;
  final String planCode;
  final VoidCallback onPaymentSuccess;

  const ApprovedVehiclePaymentScreen({
    super.key,
    required this.listing,
    required this.purpose,
    required this.amount,
    required this.planCode,
    required this.onPaymentSuccess,
  });

  @override
  State<ApprovedVehiclePaymentScreen> createState() =>
      _ApprovedVehiclePaymentScreenState();
}

/// "₹2,00,000" / "₹1,250.50" (Indian grouping, paise only when present).
String formatRupees(double amount) {
  final whole = amount % 1 == 0;
  final f = NumberFormat(whole ? '#,##,##0' : '#,##,##0.00', 'en_IN');
  return '₹${f.format(amount)}';
}

class _ApprovedVehiclePaymentScreenState
    extends State<ApprovedVehiclePaymentScreen> {
  bool _isProcessing = false;
  late final PaymentController _paymentCtrl;

  bool get _isBooking =>
      widget.purpose == ApprovedVehiclePaymentPurpose.booking;

  @override
  void initState() {
    super.initState();
    _paymentCtrl = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());
  }

  Future<void> _pay() async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (!mounted) return;
    if (userId == null || userId.isEmpty) {
      CustomSnackbar.show(
        message: context.l10n.pleaseLoginToContinue,
        type: SnackbarType.error,
      );
      return;
    }
    setState(() => _isProcessing = true);

    _paymentCtrl.onSuccess = (data, callback) {
      if (mounted) setState(() => _isProcessing = false);
      widget.onPaymentSuccess();
    };
    _paymentCtrl.onFailure = (message, callback) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      CustomSnackbar.show(
        message: context.l10n.profSubPaymentFailedMsg(message),
        type: SnackbarType.error,
      );
    };
    _paymentCtrl.onCancelled = () {
      if (mounted) setState(() => _isProcessing = false);
    };

    final started = await _paymentCtrl.initiatePayment(
      userId: userId,
      planCode: widget.planCode,
      forPayment: widget.amount,
      approvedVehicleId: widget.listing.approvedVehicleId,
      purpose: _isBooking ? 'booking' : 'inspection',
    );
    if (!started && mounted && _isProcessing) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppLayout(
      title: _isBooking ? l10n.apprBookVehicle : l10n.requestInspection,
      body: ApprovedVehiclePaymentView(
        listing: widget.listing,
        purpose: widget.purpose,
        amount: widget.amount,
        busy: _isProcessing,
        onPay: _isProcessing ? null : _pay,
      ),
    );
  }
}

/// The screen's content (without the app frame): vehicle, amount ticket,
/// commission note (booking), how it works, trust row and the pay bar.
class ApprovedVehiclePaymentView extends StatelessWidget {
  final ApprovedVehicleListingEntity listing;
  final ApprovedVehiclePaymentPurpose purpose;
  final double amount;
  final bool busy;
  final VoidCallback? onPay;

  const ApprovedVehiclePaymentView({
    super.key,
    required this.listing,
    required this.purpose,
    required this.amount,
    required this.busy,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBooking = purpose == ApprovedVehiclePaymentPurpose.booking;
    final steps = isBooking
        ? [l10n.apprPayBookStep1, l10n.apprPayBookStep2, l10n.apprPayBookStep3]
        : [l10n.apprPayInspStep1, l10n.apprPayInspStep2, l10n.apprPayInspStep3];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VehicleCard(listing: listing),
                SizedBox(height: 16.h),
                _AmountTicket(
                  icon: isBooking
                      ? Icons.event_available_rounded
                      : Icons.fact_check_rounded,
                  headline: isBooking
                      ? l10n.apprPayBookingHeadline
                      : l10n.apprPayInspectionHeadline,
                  intro: isBooking
                      ? l10n.apprPayBookingIntro
                      : l10n.apprPayInspectionIntro,
                  amountLabel: isBooking
                      ? l10n.apprPayBookingAmount
                      : l10n.apprPayInspectionFee,
                  amount: formatRupees(amount),
                ),
                if (isBooking) ...[
                  SizedBox(height: 14.h),
                  _CommissionNote(
                    title: l10n.apprPayCommissionTitle,
                    note: l10n.apprPayCommissionNote,
                  ),
                ],
                SizedBox(height: 18.h),
                _StepsCard(title: l10n.apprPayHowItWorks, steps: steps),
                SizedBox(height: 18.h),
                _TrustRow(
                  secureTitle: l10n.profSubSecureTrusted,
                  secureSub: l10n.profSubHundredSafe,
                  payuSub: l10n.coreSecurePaymentPoweredByPayU,
                ),
              ],
            ),
          ),
        ),
        _PayBar(
          label: l10n.apprPayToPayNow,
          amount: formatRupees(amount),
          button: l10n.apprPayNow,
          busy: busy,
          onPay: onPay,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle being paid for
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final ApprovedVehicleListingEntity listing;
  const _VehicleCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final images =
        listing.files?.images
            .map((e) => e.fileUrl)
            .where((u) => u.isNotEmpty)
            .toList() ??
        const <String>[];
    final title = listing.displayTitle.isNotEmpty
        ? listing.displayTitle
        : listing.registrationNumber;
    final place = [
      listing.cityName,
      listing.stateName,
    ].where((p) => p.trim().isNotEmpty).join(', ');

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 78.r,
              height: 78.r,
              child: images.isEmpty
                  ? _placeholder()
                  : Image.network(
                      images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    if (listing.registrationNumber.isNotEmpty)
                      _chip(Icons.badge_outlined, listing.registrationNumber),
                    if (listing.yearOfManufacturing > 0)
                      _chip(
                        Icons.calendar_today_outlined,
                        '${listing.yearOfManufacturing}',
                      ),
                  ],
                ),
                if (place.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 13.r,
                        color: AppColors.grey650,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.grey650,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 6.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${context.l10n.apprPayVehiclePrice}  ',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.grey650,
                        ),
                      ),
                      TextSpan(
                        text: formatRupees(listing.price),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primary.withValues(alpha: 0.08),
    child: Icon(
      Icons.local_shipping_outlined,
      color: AppColors.primary,
      size: 30.r,
    ),
  );

  Widget _chip(IconData icon, String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.r, color: AppColors.grey650),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket-style amount card (brand gradient, punched notches, dashed tear line)
// ─────────────────────────────────────────────────────────────────────────────

class _AmountTicket extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String intro;
  final String amountLabel;
  final String amount;

  const _AmountTicket({
    required this.icon,
    required this.headline,
    required this.intro,
    required this.amountLabel,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final notch = 11.r;
    final page = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                // soft decorative rings
                Positioned(right: -40.r, top: -40.r, child: _ring(130.r, 0.10)),
                Positioned(
                  right: 30.r,
                  bottom: -50.r,
                  child: _ring(110.r, 0.07),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(icon, color: Colors.white, size: 24.r),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              headline,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        intro,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CustomPaint(
                        size: Size(double.infinity, 1.h),
                        painter: _DashPainter(
                          Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  amountLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10.5.sp,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    amount,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ticket notches on both sides of the tear line
        Positioned(left: -notch, bottom: 62.h, child: _notch(notch, page)),
        Positioned(right: -notch, bottom: 62.h, child: _notch(notch, page)),
      ],
    );
  }

  Widget _ring(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: alpha),
        width: 14,
      ),
    ),
  );

  Widget _notch(double r, Color color) => Container(
    width: r * 2,
    height: r * 2,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dash = 6.0, gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Commission note (booking)
// ─────────────────────────────────────────────────────────────────────────────

class _CommissionNote extends StatelessWidget {
  final String title;
  final String note;
  const _CommissionNote({required this.title, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFE0A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE7B8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.percent_rounded,
              size: 16.r,
              color: const Color(0xFFB26A00),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A4A00),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  note,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color: const Color(0xFF8A5A10),
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
// How it works — numbered timeline
// ─────────────────────────────────────────────────────────────────────────────

class _StepsCard extends StatelessWidget {
  final String title;
  final List<String> steps;
  const _StepsCard({required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 26.r,
                    child: Column(
                      children: [
                        Container(
                          width: 26.r,
                          height: 26.r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: i == 0
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.ctaGradientStart,
                                      AppColors.ctaGradientEnd,
                                    ],
                                  )
                                : null,
                            color: i == 0
                                ? null
                                : AppColors.primary.withValues(alpha: 0.10),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: i == 0 ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: EdgeInsets.symmetric(vertical: 3.h),
                              color: AppColors.primary.withValues(alpha: 0.18),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h, bottom: 14.h),
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.5.sp,
                          height: 1.4,
                          fontWeight: i == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: i == 0
                              ? AppColors.textPrimary
                              : AppColors.grey650,
                        ),
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
// Trust row + sticky pay bar
// ─────────────────────────────────────────────────────────────────────────────

class _TrustRow extends StatelessWidget {
  final String secureTitle;
  final String secureSub;
  final String payuSub;
  const _TrustRow({
    required this.secureTitle,
    required this.secureSub,
    required this.payuSub,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String sub) => Expanded(
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(icon, size: 17.r, color: AppColors.primary),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9.5.sp,
                    color: AppColors.grey650,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Row(
      children: [
        item(Icons.lock_outline_rounded, secureTitle, secureSub),
        SizedBox(width: 10.w),
        item(Icons.verified_user_outlined, 'PayU', payuSub),
      ],
    );
  }
}

class _PayBar extends StatelessWidget {
  final String label;
  final String amount;
  final String button;
  final bool busy;
  final VoidCallback? onPay;

  const _PayBar({
    required this.label,
    required this.amount,
    required this.button,
    required this.busy,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Extra bottom space: the app's bottom bar raises its Home button into
      // the area just above it, which would cover the amount.
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 34.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11.sp,
                  color: AppColors.grey650,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: GradientButton.filled(
              text: button,
              onPressed: onPay,
              isLoading: busy,
              height: 40.h,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

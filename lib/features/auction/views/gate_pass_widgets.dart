import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';

// ── Brand surfaces shared with the bottom nav / auction cards ────────────────
const Color kGpInk = Color(0xFF1E1E1E);
const Color kGpInkSoft = Color(0xFF2A1414);

enum GpTone { success, neutral, pending, danger }

({Color fg, Color bg}) _tone(GpTone t) => switch (t) {
  GpTone.success => (fg: AppColors.successDark, bg: AppColors.successBackground),
  GpTone.neutral => (fg: AppColors.grey700, bg: AppColors.grey200),
  GpTone.pending => (fg: const Color(0xFF9A5B00), bg: const Color(0xFFFFEFC2)),
  GpTone.danger => (fg: AppColors.errorDark, bg: const Color(0xFFFFE1E1)),
};

/// Rounded status pill with a leading dot (colour is never the only cue: the
/// label text always carries the meaning).
class GpStatusPill extends StatelessWidget {
  final String label;
  final GpTone tone;
  final bool onDark;
  const GpStatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = _tone(tone);
    final fg = onDark ? Colors.white : c.fg;
    final bg = onDark ? Colors.white.withValues(alpha: 0.14) : c.bg;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: onDark ? c.bg : c.fg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps an inspection status to a pill.
({String label, GpTone tone}) gpRequestStatus(String s) {
  switch (s) {
    case 'APPROVED':
    case 'MECHANIC_ASSIGNED':
      return (label: 'Approved', tone: GpTone.success);
    case 'INSPECTION_COMPLETED':
      return (label: 'Completed', tone: GpTone.neutral);
    case 'REJECTED':
      return (label: 'Rejected', tone: GpTone.danger);
    case 'CANCELLED':
      return (label: 'Cancelled', tone: GpTone.danger);
    case 'PAYMENT_PENDING':
    case 'CHARGES_FINALIZED':
      return (label: 'Payment due', tone: GpTone.pending);
    default:
      return (label: 'In review', tone: GpTone.pending);
  }
}

// ── Ticket ────────────────────────────────────────────────────────────────────

/// Boarding-pass style Gate Pass: dark brand header, perforated tear line,
/// QR + details below. [notchColor] must match the surface behind the ticket
/// so the side notches read as cut-outs.
class GatePassTicket extends StatelessWidget {
  final String vehicleTitle;
  final String registrationNo;
  final String gatePassId;
  final String auctionId;
  final String issuedAt;
  final String verificationCode;
  final bool active;
  final bool expired;
  final String expiresAt;
  final Color notchColor;
  final VoidCallback? onDownload;
  final bool downloading;

  const GatePassTicket({
    super.key,
    required this.vehicleTitle,
    this.registrationNo = '',
    required this.gatePassId,
    required this.auctionId,
    this.issuedAt = '',
    required this.verificationCode,
    required this.active,
    this.expired = false,
    this.expiresAt = '',
    this.notchColor = Colors.white,
    this.onDownload,
    this.downloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final notch = 12.r;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Column(
              children: [
                _header(),
                _tearLine(notch),
                _body(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kGpInk, kGpInkSoft],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.local_police_rounded, size: 14.r, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Text(
                'GATE PASS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11.sp,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              GpStatusPill(
                label: expired ? 'Expired' : (active ? 'Active' : 'Inactive'),
                tone: expired
                    ? GpTone.danger
                    : (active ? GpTone.success : GpTone.neutral),
                onDark: true,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            vehicleTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (registrationNo.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                registrationNo,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tearLine(double notch) {
    return SizedBox(
      height: notch * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: ColoredBox(color: Colors.white)),
          // dashed line
          LayoutBuilder(
            builder: (_, c) {
              final dashes = (c.maxWidth / 12).floor();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: notch + 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    dashes,
                    (_) => Container(width: 5, height: 1.5, color: AppColors.grey300),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: -notch,
            child: Container(
              width: notch * 2,
              height: notch * 2,
              decoration: BoxDecoration(color: notchColor, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -notch,
            child: Container(
              width: notch * 2,
              height: notch * 2,
              decoration: BoxDecoration(color: notchColor, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Pass ID', gatePassId),
                    _kv('Auction', auctionId),
                    if (issuedAt.isNotEmpty) _kv('Issued', issuedAt),
                    if (expiresAt.isNotEmpty)
                      _kv(expired ? 'Expired on' : 'Valid until', expiresAt),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Opacity(
                  opacity: active ? 1 : 0.35,
                  child: QrImageView(
                    data: verificationCode,
                    size: 92.r,
                    padding: EdgeInsets.zero,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: kGpInk,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: kGpInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (expired)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded, size: 18.r, color: AppColors.error),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This auction has ended, so the gate pass is no longer valid for yard entry.',
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.grey800),
                    ),
                  ),
                ],
              ),
            ),
          _CodeRow(code: verificationCode),
          if (onDownload != null) ...[
            SizedBox(height: 12.h),
            _GradientAction(
              label: 'Download PDF',
              icon: Icons.download_rounded,
              loading: downloading,
              onTap: onDownload,
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11.sp,
            color: AppColors.grey600,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    ),
  );
}

class _CodeRow extends StatelessWidget {
  final String code;
  const _CodeRow({required this.code});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy verification code',
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: () {
          HapticFeedback.selectionClick();
          Clipboard.setData(ClipboardData(text: code));
          CustomSnackbar.show(
            message: 'Verification code copied',
            type: SnackbarType.success,
          );
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 44.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.copy_rounded, size: 16.r, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Brand-gradient call to action, 48px tall (≥44px touch target).
class GpGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;
  const GpGradientButton({
    super.key,
    required this.label,
    this.icon,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) =>
      _GradientAction(label: label, icon: icon, loading: loading, onTap: onTap);
}

class _GradientAction extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onTap;
  const _GradientAction({
    required this.label,
    this.icon,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 48.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: enabled
                  ? () {
                      HapticFeedback.lightImpact();
                      onTap!();
                    }
                  : null,
              child: Center(
                child: loading
                    ? SizedBox(
                        height: 20.r,
                        width: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18.r, color: Colors.white),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Progress timeline ─────────────────────────────────────────────────────────

/// Vertical stepper for the request journey.
class GpTimeline extends StatelessWidget {
  final List<String> steps;
  final int current; // index of the step in progress (== steps.length → all done)
  final bool failed; // current step ended in rejection / cancellation
  const GpTimeline({
    super.key,
    required this.steps,
    required this.current,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final done = i < current;
        final active = i == current;
        final isFail = active && failed;
        final color = isFail
            ? AppColors.error
            : (done || active)
            ? AppColors.primary
            : AppColors.grey300;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28.w,
                child: Column(
                  children: [
                    Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        color: done || isFail ? color : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: done
                          ? Icon(Icons.check, size: 13.r, color: Colors.white)
                          : isFail
                          ? Icon(Icons.close, size: 13.r, color: Colors.white)
                          : active
                          ? Center(
                              child: Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (i != steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: done ? AppColors.primary : AppColors.grey200,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 14.h),
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13.sp,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: (done || active) ? AppColors.black : AppColors.grey500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Journey position for an inspection request.
({List<String> steps, int current, bool failed}) gpJourney(
  String type,
  String status,
) {
  final mechanic = type == 'VAHAAN_BAZAR_MECHANIC';
  final steps = mechanic
      ? ['Request sent', 'Payment', 'Admin approval', 'Mechanic assigned', 'Inspection done']
      : ['Request sent', 'Admin approval', 'Gate pass issued', 'Inspection done'];
  final failed = status == 'REJECTED' || status == 'CANCELLED';
  int idx;
  if (mechanic) {
    idx = switch (status) {
      'SALES_TEAM_CONTACT_PENDING' => 1,
      'CHARGES_FINALIZED' || 'PAYMENT_PENDING' => 1,
      'PAYMENT_RECEIVED' || 'PENDING_ADMIN_APPROVAL' => 2,
      'APPROVED' => 3,
      'MECHANIC_ASSIGNED' => 4,
      'INSPECTION_COMPLETED' => 5,
      'REJECTED' || 'CANCELLED' => 2,
      _ => 0,
    };
  } else {
    idx = switch (status) {
      'PENDING_ADMIN_APPROVAL' => 1,
      'APPROVED' => 3,
      'INSPECTION_COMPLETED' => 4,
      'REJECTED' || 'CANCELLED' => 1,
      _ => 0,
    };
  }
  return (steps: steps, current: idx, failed: failed);
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

/// Pulsing placeholder shown while data loads (reserves space, avoids a bare
/// spinner and layout jump).
class GpSkeleton extends StatefulWidget {
  final double height;
  const GpSkeleton({super.key, required this.height});

  @override
  State<GpSkeleton> createState() => _GpSkeletonState();
}

class _GpSkeletonState extends State<GpSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(AppColors.grey100, AppColors.grey200, _c.value),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

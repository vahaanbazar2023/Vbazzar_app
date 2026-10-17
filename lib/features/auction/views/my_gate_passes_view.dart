import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../services/gate_pass_service.dart';
import 'gate_pass_widgets.dart';

/// "My Gate Passes": every Gate Pass the user has, with direct PDF download.
class MyGatePassesView extends StatefulWidget {
  const MyGatePassesView({super.key});

  @override
  State<MyGatePassesView> createState() => _MyGatePassesViewState();
}

class _MyGatePassesViewState extends State<MyGatePassesView> {
  final _service = GatePassService();
  final _scroll = ScrollController();
  final List<GatePassListItem> _items = [];

  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String? _downloadingId;
  String _filter = 'all'; // all | active | inactive

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _service.fetchMyGatePasses(page: 1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(r.items);
        _page = 1;
        _totalPages = r.totalPages;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    try {
      final r = await _service.fetchMyGatePasses(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(r.items);
        _page += 1;
        _totalPages = r.totalPages;
      });
    } catch (_) {
      // keep what we have; the next scroll retries
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _download(GatePassListItem item) async {
    setState(() => _downloadingId = item.gatePassId);
    try {
      await _service.downloadAndOpen(
        inspectionId: item.inspectionId,
        gatePassId: item.gatePassId,
      );
    } catch (e) {
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  static const Color _bg = Color(0xFFF6F6F8);

  List<GatePassListItem> get _visible => switch (_filter) {
    'active' => _items.where((e) => e.isActive).toList(),
    'inactive' => _items.where((e) => !e.isActive).toList(),
    _ => _items,
  };

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Gate Passes',
      subtitle: 'Your yard entry passes',
      showBack: true,
      bodyColor: _bg,
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          GpSkeleton(height: 44.h),
          SizedBox(height: 14.h),
          GpSkeleton(height: 300.h),
          SizedBox(height: 14.h),
          GpSkeleton(height: 300.h),
        ],
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40.r, color: AppColors.grey500),
              SizedBox(height: 10.h),
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 14.h),
              SizedBox(
                width: 180.w,
                child: GpGradientButton(
                  label: 'Try again',
                  icon: Icons.refresh,
                  onTap: _load,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) return _empty();

    final list = _visible;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        itemCount: list.length + 2,
        itemBuilder: (_, i) {
          if (i == 0) return _filters();
          if (i == list.length + 1) {
            return _loadingMore
                ? Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : (list.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: Center(
                            child: Text(
                              'No $_filter gate passes',
                              style: TextStyle(color: AppColors.grey600),
                            ),
                          ),
                        )
                      : const SizedBox.shrink());
          }
          final g = list[i - 1];
          return Padding(
            padding: EdgeInsets.only(bottom: 18.h),
            child: GatePassTicket(
              vehicleTitle: g.vehicleTitle,
              registrationNo: g.registrationNo,
              gatePassId: g.gatePassId,
              auctionId: g.auctionId,
              issuedAt: g.insertedAt,
              verificationCode: g.verificationCode,
              active: g.isActive,
              expired: g.isExpired,
              expiresAt: g.expiresAt,
              notchColor: _bg,
              onDownload: () => _download(g),
              downloading: _downloadingId == g.gatePassId,
            ),
          );
        },
      ),
    );
  }

  Widget _filters() {
    final active = _items.where((e) => e.isActive).length;
    Widget chip(String key, String label) {
      final sel = _filter == key;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Semantics(
          button: true,
          selected: sel,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filter = key);
            },
            child: Container(
              constraints: BoxConstraints(minHeight: 40.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.grey300,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.grey800,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          chip('all', 'All (${_items.length})'),
          chip('active', 'Active ($active)'),
          chip('inactive', 'Expired / Inactive'),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(22.r),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.qr_code_2_rounded, size: 44.r, color: Colors.white),
            ),
            SizedBox(height: 18.h),
            Text(
              'No gate passes yet',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Open an auction vehicle, tap Gate Pass and request an inspection. Your pass will show up here after approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

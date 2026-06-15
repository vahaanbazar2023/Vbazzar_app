import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';

/// Landing page for the Inspection & Valuation module.
/// Displays the form directly based on user_type:
///   - CUSTOMER → Customer Valuation Form
///   - AGENT    → Agent Valuation Form
/// Falls back to showing both options if user_type cannot be determined.
class InspectionHomeView extends StatefulWidget {
  const InspectionHomeView({super.key});

  @override
  State<InspectionHomeView> createState() => _InspectionHomeViewState();
}

class _InspectionHomeViewState extends State<InspectionHomeView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveUserTypeAndNavigate();
  }

  Future<void> _resolveUserTypeAndNavigate() async {
    final userType =
        await SecureStorageService.to.read(StorageKeys.userType) ?? '';
    final normalized = userType.toUpperCase().trim();

    if (!mounted) return;

    if (normalized == 'AGENT') {
      // Navigate directly to Agent form, replace this route
      Get.offNamed(AppRoutes.agentValuationForm);
    } else if (normalized == 'CUSTOMER') {
      // Navigate directly to Customer form, replace this route
      Get.offNamed(AppRoutes.customerValuationForm);
    } else {
      // Cannot determine user type – show fallback with both options
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppLayout(
        title: context.l10n.inspectionValuation,
        subtitle: context.l10n.professionalVehicleInspection,
        showBack: true,
        body: const Center(child: CustomLoader()),
      );
    }

    return AppLayout(
      title: context.l10n.inspectionValuation,
      subtitle: context.l10n.professionalVehicleInspection,
      showBack: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context),
            SizedBox(height: 20.h),
            _buildServiceCard(
              context: context,
              icon: Icons.request_quote_outlined,
              title: context.l10n.requestInspectionCard,
              description: context.l10n.requestInspectionDesc,
              buttonText: context.l10n.getStarted,
              onPressed: () => Get.toNamed(AppRoutes.customerValuationForm),
            ),
            SizedBox(height: 14.h),
            _buildServiceCard(
              context: context,
              icon: Icons.search_outlined,
              title: context.l10n.agentInspection,
              description: context.l10n.agentInspectionDesc,
              buttonText: context.l10n.startInspection,
              onPressed: () => Get.toNamed(AppRoutes.agentValuationForm),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        image: DecorationImage(
          image: AssetImage(AppAssets.inspection),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.vehicleInspectionHero,
            style: AppFonts.headlineMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.inspectionHeroSubtitle,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 24.r, color: AppColors.primary),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 14.h),
          GradientButton.filled(
            text: buttonText,
            onPressed: onPressed,
            width: double.infinity,
            height: 42.h,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }
}

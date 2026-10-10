import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/agent_inspection_controller.dart';
import '../../../core/extensions/context_extensions.dart';

/// Summary card shown at Step 6 of the agent inspection form.
/// Displays a recap of all entered data across all steps.
class ValuationSummaryCard extends StatelessWidget {
  final AgentInspectionController controller;

  const ValuationSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSection(appL10n.inspVehicleInfo, _vehicleInfoRows()),
          _buildSection(appL10n.inspDocumentation, _documentationRows()),
          _buildSection(appL10n.inspMechanicalInspection, _mechanicalRows()),
          _buildSection(appL10n.inspBodyAndInterior, _bodyRows()),
          _buildSection(appL10n.inspPhotos, _photoRows()),
          if (controller.assetMarketValueController.text.isNotEmpty)
            _buildSection(appL10n.inspValuation, _valuationRows()),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize, size: 20.r, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              appL10n.inspInspectionSummary,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(children: rows),
        ),
        Divider(
          color: AppColors.grey200,
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRow(String label, List<PlatformFile> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                images.length > 1
                    ? appL10n.inspPhotosCount(images.length)
                    : appL10n.inspPhotoCount(images.length),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _vehicleInfoRows() {
    return [
      _buildRow(appL10n.regNumber, controller.vehicleRegNoController.text),
      _buildRow(appL10n.vehicleType, controller.selectedVehicleType.value),
      _buildRow(
        appL10n.inspVehicleBrand,
        controller.selectedVehicleBrand.value,
      ),
      _buildRow(appL10n.state, controller.selectedState.value?.name ?? ''),
      _buildRow(appL10n.city, controller.selectedCity.value?.name ?? ''),
      _buildRow(appL10n.ownerName, controller.ownerNameController.text),
      _buildRow(appL10n.chassis_no, controller.chasisNumberController.text),
      _buildRow(appL10n.mfgYear, controller.manufacturingYearController.text),
      _buildRow(appL10n.engine_no, controller.engineNumberController.text),
      _buildRow(appL10n.inspRto, controller.rtoLocationController.text),
    ];
  }

  List<Widget> _documentationRows() {
    return [
      _buildRow(appL10n.inspCondition, controller.selectedCondition.value),
      _buildRow(
        appL10n.inspInsuranceValid,
        controller.insuranceValidTill.value,
      ),
      _buildRow(appL10n.inspFitnessValid, controller.fitnessValidTill.value),
      _buildRow(appL10n.taxPending, controller.taxPendingController.text),
      _buildRow(appL10n.hypothecation, controller.selectedHypothecation.value),
      if (controller.selectedHypothecation.value == 'Yes')
        _buildRow(
          appL10n.hypothecatedTo,
          controller.hypothecatedToController.text,
        ),
      _buildRow(appL10n.caseType, controller.selectedCaseType.value),
      _buildRow(appL10n.odometer, controller.odometerController.text),
      _buildRow(appL10n.fuel, controller.selectedFuel.value),
      _buildRow(appL10n.transmission, controller.selectedTransmission.value),
      _buildRow(
        appL10n.inspAccidental,
        controller.selectedAccidentalStatus.value,
      ),
    ];
  }

  List<Widget> _mechanicalRows() {
    return [
      _buildRow(appL10n.engine, controller.engineCondition.value),
      _buildRow(appL10n.transmission, controller.transmissionCondition.value),
      _buildRow(appL10n.inspSuspension, controller.suspensionCondition.value),
      if (controller.frontAxleTyresPercent.value > 0 ||
          controller.rearAxleTyresPercent.value > 0)
        _buildRow(
          appL10n.tyres,
          appL10n.inspFrontRearTyres(
            controller.frontAxleTyresPercent.value,
            controller.rearAxleTyresPercent.value,
          ),
        ),
    ];
  }

  List<Widget> _bodyRows() {
    return [
      _buildRow(appL10n.body, controller.bodyCondition.value),
      _buildRow(
        appL10n.inspCabinInterior,
        controller.cabinInteriorCondition.value,
      ),
      _buildRow(appL10n.electrical, controller.electricalCondition.value),
      _buildRow(appL10n.chassis, controller.chasisCondition.value),
    ];
  }

  List<Widget> _photoRows() {
    return [
      _buildPhotoRow(appL10n.engine, controller.engineImages),
      _buildPhotoRow(appL10n.transmission, controller.transmissionImages),
      _buildPhotoRow(appL10n.inspSuspension, controller.suspensionImages),
      _buildPhotoRow(appL10n.tyres, controller.tyreImages),
      _buildPhotoRow(appL10n.inspBodyFront, controller.bodyFrontImages),
      _buildPhotoRow(appL10n.inspBodyBack, controller.bodyBackImages),
      _buildPhotoRow(appL10n.inspBodyLeft, controller.bodyLeftImages),
      _buildPhotoRow(appL10n.inspBodyRight, controller.bodyRightImages),
      _buildPhotoRow(appL10n.inspCabinInterior, controller.cabinInteriorImages),
      _buildPhotoRow(appL10n.electrical, controller.electricalImages),
      _buildPhotoRow(appL10n.chassis, controller.chasisImages),
      _buildPhotoRow(appL10n.odometer, controller.odometerImages),
    ];
  }

  List<Widget> _valuationRows() {
    return [
      _buildRow(
        appL10n.market_value,
        appL10n.inspMarketValueRupee(
          controller.assetMarketValueController.text,
        ),
      ),
      _buildRow(appL10n.remarks, controller.otherRemarksController.text),
    ];
  }
}

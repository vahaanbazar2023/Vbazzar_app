import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/agent_inspection_controller.dart';

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
          _buildSection('Vehicle Info', _vehicleInfoRows()),
          _buildSection('Documentation', _documentationRows()),
          _buildSection('Mechanical Inspection', _mechanicalRows()),
          _buildSection('Body & Interior', _bodyRows()),
          _buildSection('Photos', _photoRows()),
          if (controller.assetMarketValueController.text.isNotEmpty)
            _buildSection('Valuation', _valuationRows()),
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
          Text(
            'Inspection Summary',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
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
        Divider(color: AppColors.grey200, height: 1, indent: 16.w, endIndent: 16.w),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${images.length} photo${images.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _vehicleInfoRows() {
    return [
      _buildRow('Reg. Number', controller.vehicleRegNoController.text),
      _buildRow('Vehicle Type', controller.selectedVehicleType.value),
      _buildRow('Vehicle Brand', controller.selectedVehicleBrand.value),
      _buildRow('State', controller.selectedState.value?.name ?? ''),
      _buildRow('City', controller.selectedCity.value?.name ?? ''),
      _buildRow('Owner Name', controller.ownerNameController.text),
      _buildRow('Chassis No', controller.chasisNumberController.text),
      _buildRow('Mfg Year', controller.manufacturingYearController.text),
      _buildRow('Engine No', controller.engineNumberController.text),
      _buildRow('RTO', controller.rtoLocationController.text),
    ];
  }

  List<Widget> _documentationRows() {
    return [
      _buildRow('Condition', controller.selectedCondition.value),
      _buildRow('Insurance Valid', controller.insuranceValidTill.value),
      _buildRow('Fitness Valid', controller.fitnessValidTill.value),
      _buildRow('Tax Pending', controller.taxPendingController.text),
      _buildRow('Hypothecation', controller.selectedHypothecation.value),
      if (controller.selectedHypothecation.value == 'Yes')
        _buildRow('Hypothecated To', controller.hypothecatedToController.text),
      _buildRow('Case Type', controller.selectedCaseType.value),
      _buildRow('Odometer', controller.odometerController.text),
      _buildRow('Fuel', controller.selectedFuel.value),
      _buildRow('Transmission', controller.selectedTransmission.value),
      _buildRow('Accidental', controller.selectedAccidentalStatus.value),
    ];
  }

  List<Widget> _mechanicalRows() {
    return [
      _buildRow('Engine', controller.engineCondition.value),
      _buildRow('Transmission', controller.transmissionCondition.value),
      _buildRow('Suspension', controller.suspensionCondition.value),
      if (controller.frontAxleTyresPercent.value > 0 ||
          controller.rearAxleTyresPercent.value > 0)
        _buildRow(
          'Tyres',
          'Front: ${controller.frontAxleTyresPercent.value}%, Rear: ${controller.rearAxleTyresPercent.value}%',
        ),
    ];
  }

  List<Widget> _bodyRows() {
    return [
      _buildRow('Body', controller.bodyCondition.value),
      _buildRow('Cabin/Interior', controller.cabinInteriorCondition.value),
      _buildRow('Electrical', controller.electricalCondition.value),
      _buildRow('Chassis', controller.chasisCondition.value),
    ];
  }

  List<Widget> _photoRows() {
    return [
      _buildPhotoRow('Engine', controller.engineImages),
      _buildPhotoRow('Transmission', controller.transmissionImages),
      _buildPhotoRow('Suspension', controller.suspensionImages),
      _buildPhotoRow('Tyres', controller.tyreImages),
      _buildPhotoRow('Body Front', controller.bodyFrontImages),
      _buildPhotoRow('Body Back', controller.bodyBackImages),
      _buildPhotoRow('Body Left', controller.bodyLeftImages),
      _buildPhotoRow('Body Right', controller.bodyRightImages),
      _buildPhotoRow('Cabin/Interior', controller.cabinInteriorImages),
      _buildPhotoRow('Electrical', controller.electricalImages),
      _buildPhotoRow('Chassis', controller.chasisImages),
      _buildPhotoRow('Odometer', controller.odometerImages),
    ];
  }

  List<Widget> _valuationRows() {
    return [
      _buildRow('Market Value', '₹ ${controller.assetMarketValueController.text}'),
      _buildRow('Remarks', controller.otherRemarksController.text),
    ];
  }
}
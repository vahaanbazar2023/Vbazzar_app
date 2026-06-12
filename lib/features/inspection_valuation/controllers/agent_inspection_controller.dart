import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../routes/app_routes.dart';
import '../data/models/agent_inspection_request.dart';
import '../data/models/valuation_dropdown_options.dart';
import '../data/services/inspection_service.dart';
import 'inspection_valuation_controller.dart';

/// Controller for the Agent Valuation multi-step inspection form.
/// Manages 6-step wizard state, image uploads, condition ratings, and submission.
class AgentInspectionController extends GetxController {
  // ── dependencies ──────────────────────────────────────────────────
  late final InspectionService _service;
  final ImagePicker _imagePicker = ImagePicker();

  // ── general state ─────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── step management ───────────────────────────────────────────────
  final currentStep = 0.obs;
  static const int totalSteps = 6;

  // ── step 1: vehicle info ──────────────────────────────────────────
  final ownerNameController = TextEditingController();
  final vehicleRegNoController = TextEditingController();
  final chasisNumberController = TextEditingController();
  final manufacturingYearController = TextEditingController();
  final engineNumberController = TextEditingController();
  final rtoLocationController = TextEditingController();
  final ownerNumberController = TextEditingController();
  final selectedVehicleType = ''.obs;
  final selectedVehicleBrand = ''.obs;
  final selectedState = Rx<LocationOption?>(null);
  final selectedCity = Rx<LocationOption?>(null);

  // ── step 2: documentation & condition ─────────────────────────────
  final vehicleConditionTextController = TextEditingController();
  final selectedCondition = ''.obs;
  final insuranceValidTill = ''.obs;
  final fitnessValidTill = ''.obs;
  final taxPendingController = TextEditingController();
  final selectedHypothecation = ''.obs;
  final hypothecatedToController = TextEditingController();
  final selectedCaseType = ''.obs;
  final hoursController = TextEditingController();
  final odometerController = TextEditingController();
  final selectedFuel = ''.obs;
  final selectedTransmission = ''.obs;
  final selectedAccidentalStatus = ''.obs;

  // ── step 3: mechanical inspection ─────────────────────────────────
  final engineCondition = ''.obs;
  final engineRemarksController = TextEditingController();
  final transmissionCondition = ''.obs;
  final transmissionRemarksController = TextEditingController();
  final suspensionCondition = ''.obs;
  final suspensionRemarksController = TextEditingController();
  final frontAxleTyresPercent = 0.obs;
  final rearAxleTyresPercent = 0.obs;

  // ── step 4: body & interior ───────────────────────────────────────
  final bodyCondition = ''.obs;
  final bodyRemarksController = TextEditingController();
  final cabinInteriorCondition = ''.obs;
  final cabinInteriorRemarksController = TextEditingController();
  final electricalCondition = ''.obs;
  final electricalRemarksController = TextEditingController();
  final chasisCondition = ''.obs;
  final chasisRemarksController = TextEditingController();
  final odometerRemarksController = TextEditingController();

  // ── step 5: photo uploads ─────────────────────────────────────────
  final engineImages = <PlatformFile>[].obs;
  final transmissionImages = <PlatformFile>[].obs;
  final suspensionImages = <PlatformFile>[].obs;
  final tyreImages = <PlatformFile>[].obs;
  final bodyFrontImages = <PlatformFile>[].obs;
  final bodyBackImages = <PlatformFile>[].obs;
  final bodyLeftImages = <PlatformFile>[].obs;
  final bodyRightImages = <PlatformFile>[].obs;
  final cabinInteriorImages = <PlatformFile>[].obs;
  final electricalImages = <PlatformFile>[].obs;
  final chasisImages = <PlatformFile>[].obs;
  final odometerImages = <PlatformFile>[].obs;

  // ── step 6: valuation ─────────────────────────────────────────────
  final assetMarketValueController = TextEditingController();
  final otherRemarksController = TextEditingController();
  final webUrlController = TextEditingController();

  // ── max files per category ───────────────────────────────────────
  static const int maxFilesPerCategory = 5;

  // ── computed: access parent controller's dropdown options ──────────
  InspectionValuationController get _parent =>
      Get.find<InspectionValuationController>();

  // ── lifecycle ─────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _service = InspectionService();
  }

  @override
  void onClose() {
    _disposeAllControllers();
    super.onClose();
  }

  void _disposeAllControllers() {
    ownerNameController.dispose();
    vehicleRegNoController.dispose();
    chasisNumberController.dispose();
    manufacturingYearController.dispose();
    engineNumberController.dispose();
    rtoLocationController.dispose();
    ownerNumberController.dispose();
    vehicleConditionTextController.dispose();
    taxPendingController.dispose();
    hypothecatedToController.dispose();
    hoursController.dispose();
    odometerController.dispose();
    engineRemarksController.dispose();
    transmissionRemarksController.dispose();
    suspensionRemarksController.dispose();
    bodyRemarksController.dispose();
    cabinInteriorRemarksController.dispose();
    electricalRemarksController.dispose();
    chasisRemarksController.dispose();
    odometerRemarksController.dispose();
    assetMarketValueController.dispose();
    otherRemarksController.dispose();
    webUrlController.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  //  STEP NAVIGATION
  // ══════════════════════════════════════════════════════════════════

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      if (validateCurrentStep()) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  VALIDATION
  // ══════════════════════════════════════════════════════════════════

  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      case 3:
        return _validateStep4();
      case 4:
        return _validateStep5();
      case 5:
        return _validateStep6();
      default:
        return true;
    }
  }

  bool _validateStep1() {
    if (vehicleRegNoController.text.trim().length < 5) {
      _showValidationError('Please enter valid vehicle registration number');
      return false;
    }
    if (selectedVehicleType.value.isEmpty) {
      _showValidationError('Please select vehicle type');
      return false;
    }
    if (selectedVehicleBrand.value.isEmpty) {
      _showValidationError('Please select vehicle brand');
      return false;
    }
    if (selectedState.value == null) {
      _showValidationError('Please select state');
      return false;
    }
    if (selectedCity.value == null) {
      _showValidationError('Please select city');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    // All fields in step 2 are optional per documentation
    return true;
  }

  bool _validateStep3() {
    // Validate tyre percentages range
    if (frontAxleTyresPercent.value < 0 || frontAxleTyresPercent.value > 100) {
      _showValidationError('Front axle tyre percentage must be 0-100');
      return false;
    }
    if (rearAxleTyresPercent.value < 0 || rearAxleTyresPercent.value > 100) {
      _showValidationError('Rear axle tyre percentage must be 0-100');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    // All fields in step 4 are optional
    return true;
  }

  bool _validateStep5() {
    // Images are optional, but validate max count per category
    final allImageLists = [
      engineImages,
      transmissionImages,
      suspensionImages,
      tyreImages,
      bodyFrontImages,
      bodyBackImages,
      bodyLeftImages,
      bodyRightImages,
      cabinInteriorImages,
      electricalImages,
      chasisImages,
      odometerImages,
    ];
    for (final list in allImageLists) {
      if (list.length > maxFilesPerCategory) {
        _showValidationError(
          'Maximum $maxFilesPerCategory images per category allowed',
        );
        return false;
      }
    }
    return true;
  }

  bool _validateStep6() {
    // Market value is optional, but if entered must be valid number
    final value = assetMarketValueController.text.trim();
    if (value.isNotEmpty) {
      final parsed = double.tryParse(value);
      if (parsed == null || parsed < 0) {
        _showValidationError('Please enter a valid market value');
        return false;
      }
    }
    return true;
  }

  /// Validate all steps before final submission.
  bool validateAllSteps() {
    for (int i = 0; i < totalSteps; i++) {
      currentStep.value = i;
      if (!validateCurrentStep()) {
        return false;
      }
    }
    return true;
  }

  // ══════════════════════════════════════════════════════════════════
  //  IMAGE MANAGEMENT
  // ══════════════════════════════════════════════════════════════════

  /// Opens file picker and adds picked files to [targetList].
  Future<void> pickFiles(RxList<PlatformFile> targetList) async {
    if (targetList.length >= maxFilesPerCategory) {
      _showValidationError(
        'Maximum $maxFilesPerCategory files per category',
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final remaining = maxFilesPerCategory - targetList.length;
        final filesToAdd = result.files.take(remaining).toList();
        targetList.addAll(filesToAdd);
        if (result.files.length > remaining) {
          _showValidationError(
            'Only $remaining more file(s) allowed. ${result.files.length - remaining} file(s) skipped.',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ AgentInspection: pickFiles error – $e');
      _showValidationError('Failed to pick file. Please try again.');
    }
  }

  /// Removes a file at [index] from [targetList].
  void removeFile(RxList<PlatformFile> targetList, int index) {
    if (index >= 0 && index < targetList.length) {
      targetList.removeAt(index);
    }
  }
  // ══════════════════════════════════════════════════════════════════
  //  STATE-CITY FILTERING
  // ══════════════════════════════════════════════════════════════════

  void onStateChanged(LocationOption? state) {
    selectedState.value = state;
    selectedCity.value = null;
    // The parent controller handles filteredCities
    _parent.onStateChanged(state);
  }

  List<LocationOption> get filteredCities => _parent.filteredCities;

  // ══════════════════════════════════════════════════════════════════
  //  SUBMISSION
  // ══════════════════════════════════════════════════════════════════

  Future<void> submitAgentForm() async {
    // Validate all steps before submission
    final savedStep = currentStep.value;
    if (!validateAllSteps()) {
      _showValidationError('Please fix errors before submitting');
      return;
    }
    currentStep.value = savedStep;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      final request = _buildRequest();
      final response = await _service.submitAgentValuationForm(
        request: request,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        _showSuccessDialog(
          title: 'Inspection Submitted',
          submissionId: data['data']?['submission_id']?.toString() ??
              data['data']?['inspection_id']?.toString() ??
              '',
          message: 'Your inspection report has been submitted successfully.',
        );
        resetForm();
      } else {
        _showValidationError(_extractErrorMessage(response.data));
      }
    } catch (e) {
      debugPrint('⚠️ AgentInspection: submit error – $e');
      _showValidationError('Failed to submit inspection report.');
    } finally {
      isSubmitting.value = false;
    }
  }

  AgentInspectionRequest _buildRequest() {
    return AgentInspectionRequest(
      ownerName: _textOrNull(ownerNameController),
      vehicleRegistrationNumber: vehicleRegNoController.text.trim(),
      vehicleType: selectedVehicleType.value,
      vehicleBrand: selectedVehicleBrand.value,
      vehicleState: selectedState.value?.name ?? '',
      vehicleCity: selectedCity.value?.name ?? '',
      chasisNumber: _textOrNull(chasisNumberController),
      manufacturingYear: _textOrNull(manufacturingYearController),
      engineNumber: _textOrNull(engineNumberController),
      rtoLocation: _textOrNull(rtoLocationController),
      ownerNumber: _textOrNull(ownerNumberController),
      vehicleConditionText: _textOrNull(vehicleConditionTextController),
      vehicleConditionDropdown: _optOrNull(selectedCondition),
      insuranceValidTill: _optOrNull(insuranceValidTill),
      fitnessValidTill: _optOrNull(fitnessValidTill),
      taxPending: _textOrNull(taxPendingController),
      hypothecation: _optOrNull(selectedHypothecation),
      hypothecatedTo: _textOrNull(hypothecatedToController),
      caseType: _optOrNull(selectedCaseType),
      hours: _textOrNull(hoursController),
      odometer: _textOrNull(odometerController),
      fuel: _optOrNull(selectedFuel),
      transmissionType: _optOrNull(selectedTransmission),
      accidentalStatus: _optOrNull(selectedAccidentalStatus),
      engineCondition: _optOrNull(engineCondition),
      engineRemarks: _textOrNull(engineRemarksController),
      transmissionCondition: _optOrNull(transmissionCondition),
      transmissionRemarks: _textOrNull(transmissionRemarksController),
      suspensionCondition: _optOrNull(suspensionCondition),
      suspensionRemarks: _textOrNull(suspensionRemarksController),
      bodyCondition: _optOrNull(bodyCondition),
      bodyRemarks: _textOrNull(bodyRemarksController),
      cabinInteriorCondition: _optOrNull(cabinInteriorCondition),
      cabinInteriorRemarks: _textOrNull(cabinInteriorRemarksController),
      electricalCondition: _optOrNull(electricalCondition),
      electricalRemarks: _textOrNull(electricalRemarksController),
      chasisCondition: _optOrNull(chasisCondition),
      chasisRemarks: _textOrNull(chasisRemarksController),
      odometerRemarks: _textOrNull(odometerRemarksController),
      frontAxleTyresPercentage: frontAxleTyresPercent.value > 0
          ? frontAxleTyresPercent.value
          : null,
      rearAxleTyresPercentage: rearAxleTyresPercent.value > 0
          ? rearAxleTyresPercent.value
          : null,
      assetMarketValue: _parseDouble(assetMarketValueController),
      otherRemarks: _textOrNull(otherRemarksController),
      webUrl: _textOrNull(webUrlController),
      engineImages: engineImages.map((f) => File(f.path!)).toList(),
      transmissionImages: transmissionImages.map((f) => File(f.path!)).toList(),
      suspensionImages: suspensionImages.map((f) => File(f.path!)).toList(),
      tyreImages: tyreImages.map((f) => File(f.path!)).toList(),
      bodyFrontImage: bodyFrontImages.map((f) => File(f.path!)).toList(),
      bodyBackImage: bodyBackImages.map((f) => File(f.path!)).toList(),
      bodyLeftImage: bodyLeftImages.map((f) => File(f.path!)).toList(),
      bodyRightImage: bodyRightImages.map((f) => File(f.path!)).toList(),
      cabinInteriorImages: cabinInteriorImages.map((f) => File(f.path!)).toList(),
      electricalImages: electricalImages.map((f) => File(f.path!)).toList(),
      chasisImages: chasisImages.map((f) => File(f.path!)).toList(),
      odometerImages: odometerImages.map((f) => File(f.path!)).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  RESET
  // ══════════════════════════════════════════════════════════════════

  void resetForm() {
    currentStep.value = 0;

    // Step 1
    ownerNameController.clear();
    vehicleRegNoController.clear();
    chasisNumberController.clear();
    manufacturingYearController.clear();
    engineNumberController.clear();
    rtoLocationController.clear();
    ownerNumberController.clear();
    selectedVehicleType.value = '';
    selectedVehicleBrand.value = '';
    selectedState.value = null;
    selectedCity.value = null;

    // Step 2
    vehicleConditionTextController.clear();
    selectedCondition.value = '';
    insuranceValidTill.value = '';
    fitnessValidTill.value = '';
    taxPendingController.clear();
    selectedHypothecation.value = '';
    hypothecatedToController.clear();
    selectedCaseType.value = '';
    hoursController.clear();
    odometerController.clear();
    selectedFuel.value = '';
    selectedTransmission.value = '';
    selectedAccidentalStatus.value = '';

    // Step 3
    engineCondition.value = '';
    engineRemarksController.clear();
    transmissionCondition.value = '';
    transmissionRemarksController.clear();
    suspensionCondition.value = '';
    suspensionRemarksController.clear();
    frontAxleTyresPercent.value = 0;
    rearAxleTyresPercent.value = 0;

    // Step 4
    bodyCondition.value = '';
    bodyRemarksController.clear();
    cabinInteriorCondition.value = '';
    cabinInteriorRemarksController.clear();
    electricalCondition.value = '';
    electricalRemarksController.clear();
    chasisCondition.value = '';
    chasisRemarksController.clear();
    odometerRemarksController.clear();

    // Step 5
    engineImages.clear();
    transmissionImages.clear();
    suspensionImages.clear();
    tyreImages.clear();
    bodyFrontImages.clear();
    bodyBackImages.clear();
    bodyLeftImages.clear();
    bodyRightImages.clear();
    cabinInteriorImages.clear();
    electricalImages.clear();
    chasisImages.clear();
    odometerImages.clear();

    // Step 6
    assetMarketValueController.clear();
    otherRemarksController.clear();
    webUrlController.clear();
  }

  // ══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  String? _textOrNull(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  String? _optOrNull(RxString rx) {
    return rx.value.isEmpty ? null : rx.value;
  }

  double? _parseDouble(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Something went wrong';
    }
    return 'Something went wrong';
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  Future<bool?> _showConfirmationDialog() {
    return Get.defaultDialog<bool>(
      title: 'Submit Inspection',
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_turned_in, color: Colors.blue, size: 48),
          SizedBox(height: 16),
          Text(
            'Are you sure you want to submit this inspection report?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      textCancel: 'Review',
      textConfirm: 'Submit',
      confirmTextColor: Colors.white,
      onCancel: () => Get.back(result: false),
      onConfirm: () => Get.back(result: true),
    );
  }

  void _showSuccessDialog({
    required String title,
    String? submissionId,
    required String message,
  }) {
    Get.defaultDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          if (submissionId != null && submissionId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Reference: $submissionId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
      },
    );
  }
}
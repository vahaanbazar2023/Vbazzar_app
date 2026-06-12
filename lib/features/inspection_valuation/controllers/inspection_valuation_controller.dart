import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../data/models/customer_inspection_request.dart';
import '../data/models/inspection_vehicle_model.dart';
import '../data/models/my_inspections_response.dart';
import '../data/models/valuation_dropdown_options.dart';
import '../data/services/inspection_service.dart';

/// Main controller for the Inspection & Valuation module.
/// Handles: home view, customer form, my inspections list, dropdown options.
class InspectionValuationController extends GetxController {
  // ── dependencies ──────────────────────────────────────────────────
  late final InspectionService _service;
  late final SecureStorageService _storage;

  // ── general state ─────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // ── dropdown options ──────────────────────────────────────────────
  final vehicleCategories = <Map<String, dynamic>>[].obs;
  final vehicleTypes = <String>[].obs;
  final vehicleBrands = <Map<String, dynamic>>[].obs;
  final vehicleBrandNames = <String>[].obs;
  final states = <LocationOption>[].obs;
  final cities = <LocationOption>[].obs;
  final filteredCities = <LocationOption>[].obs;
  final conditionOptions = <String>[].obs;
  final fuelTypes = <String>[].obs;
  final transmissionTypes = <String>[].obs;
  final caseTypes = <String>[].obs;
  final hypothecationOptions = <String>[].obs;
  final accidentalStatusOptions = <String>[].obs;
  final tyreConditionOptions = <String>[].obs;
  final isLoadingDropdowns = false.obs;
  final isLoadingVehicleCategories = false.obs;
  final isLoadingVehicleBrands = false.obs;
  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;

  /// Alias for backward-compat with views that use `isDropdownLoading`.
  RxBool get isDropdownLoading => isLoadingDropdowns;

  // ── customer form state ───────────────────────────────────────────
  final customerFormKey = GlobalKey<FormState>();
  final vehicleNoController = TextEditingController();
  final chasisNoController = TextEditingController();
  final ownerNumberController = TextEditingController();
  final companyNameController = TextEditingController();
  final selectedVehicleType = ''.obs;
  final selectedVehicleBrand = ''.obs;
  final selectedState = Rx<LocationOption?>(null);
  final selectedCity = Rx<LocationOption?>(null);
  final rcFiles = <PlatformFile>[].obs;
  final insuranceFiles = <PlatformFile>[].obs;
  final companyGstFiles = <PlatformFile>[].obs;

  // Error messages for file upload fields
  final rcFileError = ''.obs;
  final insuranceFileError = ''.obs;
  final companyGstFileError = ''.obs;

  // ── selected category code (needed for brand fetch) ──────────────
  final selectedCategoryCode = ''.obs;

  // ── dropdown validation errors (for inline dropdowns) ────────────
  final vehicleTypeError = ''.obs;
  final vehicleBrandError = ''.obs;
  final stateError = ''.obs;
  final cityError = ''.obs;

  // ── my inspections state ──────────────────────────────────────────
  final inspections = <InspectionVehicleModel>[].obs;
  final inspectionsPage = 1.obs;
  final inspectionsHasMore = true.obs;
  final isInspectionsLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  final hasAttemptedLoad = false.obs;
  ScrollController inspectionsScrollController = ScrollController();

  // ── user ID helper ───────────────────────────────────────────────
  Future<String> get _userId async =>
      await _storage.read(StorageKeys.userId) ?? '';

  // ── private state ─────────────────────────────────────────────────
  bool _isApiCallInProgress = false;

  // ── lifecycle ─────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _service = InspectionService();
    _storage = SecureStorageService.to;
    loadDropdownOptions();
  }

  @override
  void onClose() {
    inspectionsScrollController.dispose();
    vehicleNoController.dispose();
    chasisNoController.dispose();
    ownerNumberController.dispose();
    companyNameController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════════
  //  DROPDOWN OPTIONS
  // ══════════════════════════════════════════════════════════════════

  Future<void> loadDropdownOptions() async {
    isLoadingDropdowns.value = true;

    // Populate static dropdown options
    conditionOptions.assignAll([
      'Excellent',
      'Good',
      'Average',
      'Below Average',
      'Poor',
    ]);
    fuelTypes.assignAll([
      'Diesel',
      'Petrol',
      'CNG',
      'Electric',
      'Hybrid',
      'LPG',
    ]);
    transmissionTypes.assignAll([
      'Manual',
      'Automatic',
      'Semi-Automatic',
    ]);
    caseTypes.assignAll([
      'Normal',
      'Accident',
      'Bank Seizure',
      'Theft Recovery',
      'Flood Damaged',
      'Fire Damaged',
    ]);
    hypothecationOptions.assignAll([
      'No',
      'Yes',
    ]);
    accidentalStatusOptions.assignAll([
      'No Accident',
      'Minor Accident',
      'Major Accident',
    ]);
    tyreConditionOptions.assignAll([
      'New',
      'Good',
      'Average',
      'Worn Out',
      'Needs Replacement',
    ]);

    isLoadingDropdowns.value = false;

    // Load customer form data from separate APIs
    loadVehicleCategories();
    loadStates();
  }

  /// Fetch vehicle categories from the buy-sell API.
  Future<void> loadVehicleCategories() async {
    isLoadingVehicleCategories.value = true;
    try {
      final uid = await _userId;
      final response = await _service.getVehicleCategories(userId: uid);
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> categoriesList = [];
        if (raw is Map<String, dynamic>) {
          final data = raw['data'];
          if (data is List<dynamic>) {
            categoriesList = data;
          } else if (data is Map<String, dynamic>) {
            categoriesList =
                (data['categories'] ?? data['vehicle_categories'] ?? [])
                    as List<dynamic>;
          }
          // Fallback: try top-level keys
          if (categoriesList.isEmpty) {
            categoriesList =
                (raw['categories'] ?? raw['vehicle_categories'] ?? [])
                    as List<dynamic>;
          }
        } else if (raw is List<dynamic>) {
          categoriesList = raw;
        }
        vehicleCategories.assignAll(
          categoriesList
              .where((e) => e is Map)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
        vehicleTypes.assignAll(
          vehicleCategories
              .map(
                (c) => (c['name'] ?? c['title'] ?? c['category_name'] ?? '')
                    .toString(),
              )
              .where((name) => name.isNotEmpty)
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: loadVehicleCategories error – $e');
    } finally {
      isLoadingVehicleCategories.value = false;
    }
  }

  /// Fetch vehicle brands from the buy-sell API (POST with category_code).
  /// Call after user selects a vehicle category.
  Future<void> loadVehicleBrands(String categoryCode) async {
    selectedCategoryCode.value = categoryCode;
    isLoadingVehicleBrands.value = true;
    vehicleBrands.clear();
    vehicleBrandNames.clear();
    selectedVehicleBrand.value = '';
    try {
      final uid = await _userId;
      final response = await _service.getVehicleBrands(
        categoryCode: categoryCode,
        userId: uid,
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> brandsList = [];
        if (raw is Map<String, dynamic>) {
          brandsList = (raw['brands'] ?? raw['data'] ?? []) as List<dynamic>;
        } else if (raw is List<dynamic>) {
          brandsList = raw;
        }
        vehicleBrands.assignAll(
          brandsList.map((e) => e as Map<String, dynamic>).toList(),
        );
        vehicleBrandNames.assignAll(
          vehicleBrands
              .map(
                (b) => (b['brand_name'] ?? b['name'] ?? b['title'] ?? '')
                    .toString(),
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: loadVehicleBrands error – $e');
    } finally {
      isLoadingVehicleBrands.value = false;
    }
  }

  /// Fetch states from the location API.
  Future<void> loadStates() async {
    isLoadingStates.value = true;
    try {
      final response = await _service.getStates();
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> statesList = [];
        if (raw is Map<String, dynamic>) {
          final data = raw['data'];
          if (data is List<dynamic>) {
            statesList = data;
          } else if (data is Map<String, dynamic>) {
            statesList = (data['states'] ?? []) as List<dynamic>;
          }
        } else if (raw is List<dynamic>) {
          statesList = raw;
        }
        states.assignAll(
          statesList
              .map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: loadStates error – $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  /// Fetch cities from the location API filtered by state_id.
  /// Call after user selects a state.
  Future<void> loadCities(String stateId) async {
    selectedState.value = states.firstWhereOrNull((s) => s.id == stateId);
    selectedCity.value = null;
    stateError.value = '';
    cities.clear();
    filteredCities.clear();
    isLoadingCities.value = true;
    try {
      final response = await _service.getCities(stateId: stateId);
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> citiesList = [];
        if (raw is Map<String, dynamic>) {
          final data = raw['data'];
          if (data is List<dynamic>) {
            citiesList = data;
          } else if (data is Map<String, dynamic>) {
            citiesList = (data['cities'] ?? []) as List<dynamic>;
          }
        } else if (raw is List<dynamic>) {
          citiesList = raw;
        }
        cities.assignAll(
          citiesList
              .map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
        filteredCities.assignAll(cities);
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: loadCities error – $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// Callback when user selects a state from the dropdown.
  void onStateChanged(LocationOption? state) {
    if (state != null) {
      loadCities(state.id);
    } else {
      selectedState.value = null;
      selectedCity.value = null;
      cities.clear();
      filteredCities.clear();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  FILE PICKING
  // ══════════════════════════════════════════════════════════════════

  /// Open file picker and assign selected files to the target list.
  /// [allowedExtensions] filters by file type (e.g. ['pdf', 'jpg', 'jpeg', 'png']).
  Future<void> pickFiles(
    RxList<PlatformFile> target, {
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        withData: false,
        withReadStream: false,
      );
      if (result != null && result.files.isNotEmpty) {
        if (allowMultiple) {
          target.addAll(result.files);
        } else {
          target.assignAll(result.files);
        }
        debugPrint('📎 InspectionValuation: picked ${result.files.length} file(s), total=${target.length}');
      } else {
        debugPrint('📎 InspectionValuation: no files picked');
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: pickFiles error – $e');
      _showErrorSnackBar('Failed to pick file. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  CUSTOMER FORM SUBMISSION
  // ══════════════════════════════════════════════════════════════════

  Future<void> submitCustomerForm() async {
    if (customerFormKey.currentState == null ||
        !customerFormKey.currentState!.validate()) {
      return;
    }

    // Validate dropdowns
    bool hasError = false;
    if (selectedVehicleType.value.isEmpty) {
      vehicleTypeError.value = 'Please select vehicle type';
      hasError = true;
    }
    if (selectedVehicleBrand.value.isEmpty) {
      vehicleBrandError.value = 'Please select vehicle brand';
      hasError = true;
    }
    if (selectedState.value == null) {
      stateError.value = 'Please select state';
      hasError = true;
    }
    if (selectedCity.value == null) {
      cityError.value = 'Please select city';
      hasError = true;
    }
    if (hasError) return;

    // Validate file uploads
    if (rcFiles.isEmpty) {
      rcFileError.value = 'Please upload RC document';
      hasError = true;
    }
    if (hasError) return;

    isSubmitting.value = true;
    try {
      final request = CustomerInspectionRequest(
        vehicleNo: vehicleNoController.text.trim(),
        chasisNo: chasisNoController.text.trim(),
        vehicleType: selectedVehicleType.value,
        vehicleBrand: selectedVehicleBrand.value,
        vehicleState: selectedState.value?.name ?? '',
        vehicleCity: selectedCity.value?.name ?? '',
        vehicleOwnerNumber: ownerNumberController.text.trim(),
        companyName: companyNameController.text.trim().isNotEmpty
            ? companyNameController.text.trim()
            : null,
        rcFiles: rcFiles.toList(),
        insuranceFiles: insuranceFiles.toList(),
        companyGstFiles: companyGstFiles.toList(),
      );

      final response = await _service.submitCustomerInspectionForm(
        request: request,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        _showSuccessDialog(
          title: 'Request Submitted',
          submissionId: data['data']?['submission_id']?.toString() ?? '',
          message: 'Your inspection request has been submitted successfully.',
        );
        resetCustomerForm();
      } else {
        _showErrorSnackBar(_extractErrorMessage(response.data));
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: submitCustomerForm error – $e');
      _showErrorSnackBar('Failed to submit inspection request.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetCustomerForm() {
    vehicleNoController.clear();
    chasisNoController.clear();
    ownerNumberController.clear();
    companyNameController.clear();
    selectedVehicleType.value = '';
    selectedVehicleBrand.value = '';
    selectedCategoryCode.value = '';
    selectedState.value = null;
    selectedCity.value = null;
    vehicleBrands.clear();
    vehicleBrandNames.clear();
    cities.clear();
    filteredCities.clear();
    rcFiles.clear();
    insuranceFiles.clear();
    companyGstFiles.clear();
    rcFileError.value = '';
    insuranceFileError.value = '';
    companyGstFileError.value = '';
    vehicleTypeError.value = '';
    vehicleBrandError.value = '';
    stateError.value = '';
    cityError.value = '';
  }

  // ══════════════════════════════════════════════════════════════════
  //  MY INSPECTIONS
  // ══════════════════════════════════════════════════════════════════

  Future<void> fetchMyInspections({bool refresh = false}) async {
    if (_isApiCallInProgress) return;
    _isApiCallInProgress = true;

    try {
      if (refresh) {
        inspectionsPage.value = 1;
        inspectionsHasMore.value = true;
        inspections.clear();
        hasAttemptedLoad.value = false;
      }

      final userId = await _storage.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        _showErrorSnackBar('Please log in to view inspections.');
        _isApiCallInProgress = false;
        return;
      }

      if (inspectionsPage.value > 1) {
        isLoadMoreLoading.value = true;
      } else {
        isInspectionsLoading.value = true;
      }

      final response = await _service.getMyInspections(
        userId: userId,
        page: inspectionsPage.value,
      );

      if (response.statusCode == 200) {
        final rawData = response.data as Map<String, dynamic>;
        debugPrint('══════════════════════════════════════════');
        debugPrint('📥 PARSED MY INSPECTIONS');
        debugPrint('Raw keys: ${rawData.keys.toList()}');
        final innerData = rawData['data'];
        if (innerData is Map<String, dynamic>) {
          debugPrint('Data keys: ${innerData.keys.toList()}');
          debugPrint('Data[data] count: ${(innerData['data'] as List?)?.length ?? 0}');
          debugPrint('Pagination: ${innerData['pagination']}');
          debugPrint('First item: ${(innerData['data'] as List?)?.firstOrNull}');
        }
        debugPrint('══════════════════════════════════════════');

        final parsed = MyInspectionsResponse.fromJson(rawData);

        debugPrint('✅ Parsed ${parsed.inspections.length} inspections');
        for (var i = 0; i < parsed.inspections.length; i++) {
          final ins = parsed.inspections[i];
          debugPrint('  [$i] vehicleNo=${ins.vehicleNo}, brand=${ins.vehicleBrand}, type=${ins.vehicleType}, status=${ins.status}');
        }

        if (refresh) {
          inspections.assignAll(parsed.inspections);
        } else {
          inspections.addAll(parsed.inspections);
        }

        inspectionsHasMore.value = parsed.pagination.hasNext;
        hasAttemptedLoad.value = true;

        if (parsed.pagination.hasNext) {
          inspectionsPage.value++;
        }
      } else {
        _showErrorSnackBar(_extractErrorMessage(response.data));
      }
    } catch (e) {
      debugPrint('⚠️ InspectionValuation: fetchMyInspections error – $e');
      _showErrorSnackBar('Failed to load inspections.');
    } finally {
      isInspectionsLoading.value = false;
      isLoadMoreLoading.value = false;
      _isApiCallInProgress = false;
    }
  }

  Future<void> loadMoreInspections() async {
    if (isLoadMoreLoading.value || !inspectionsHasMore.value) return;
    await fetchMyInspections();
  }

  void setupInspectionsScrollListener() {
    inspectionsScrollController.addListener(() {
      if (inspectionsScrollController.position.pixels >=
          inspectionsScrollController.position.maxScrollExtent * 0.8) {
        loadMoreInspections();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'Something went wrong';
    }
    return 'Something went wrong';
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../profile/repositories/profile_repository.dart';
import '../domain/entities/sell_vehicle_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';
import '../domain/repositories/buy_sell_repository.dart';
import '../widgets/admin_approval_dialog.dart';

/// Controller managing the Sell tab: sell vehicle listing, form submission,
/// dynamic forms, vehicle editing, and mark-as-sold.
class SellVehicleController extends GetxController {
  final BuySellRepository repository;

  SellVehicleController({required this.repository});

  // ─── User ID ─────────────────────────────────────────────────

  Future<String> get _userId async =>
      await SecureStorageService.to.read(StorageKeys.userId) ?? '';

  // ─── Sell Vehicle List ───────────────────────────────────────

  final sellVehicles = <SellVehicleEntity>[].obs;
  final isLoadingSellVehicles = false.obs;
  final isLoadingMoreSellVehicles = false.obs;
  final hasErrorSellVehicles = false.obs;
  final errorMessageSellVehicles = ''.obs;
  final sellPage = 1.obs;
  final sellTotalPages = 1.obs;
  final hasMoreSellVehicles = true.obs;

  // ─── Sell Form State ─────────────────────────────────────────

  final selectedCategoryCode = ''.obs;
  final dynamicFormFields = <FormFieldConfigEntity>[].obs;
  final formValues = <String, dynamic>{}.obs;
  final formErrors = <String, String?>{}.obs;
  final vehicleImages = <File>[].obs;
  final rcDocuments = <File>[].obs; // multiple RC docs, 12MB each
  final insuranceDocuments = <File>[].obs; // multiple insurance docs, 12MB each

  // ─── Loading States ──────────────────────────────────────────

  final isLoadingFormFields = false.obs;
  final isSubmittingForm = false.obs;

  // ─── Category List ───────────────────────────────────────────

  final categories = <VehicleCategoryEntity>[].obs;
  final isLoadingCategories = false.obs;

  // ─── Edit State ──────────────────────────────────────────────

  final isEditMode = false.obs;
  final editingVehicleId = ''.obs;
  final isLoadingEditData = false.obs;

  // ─── Sold Status ─────────────────────────────────────────────

  final isUpdatingSoldStatus = false.obs;

  // ─── Location State ──────────────────────────────────────────

  final states = <Map<String, String>>[].obs; // [{state_id, state_name}]
  final cities = <Map<String, String>>[].obs; // [{city_id, city_name}]
  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;
  final selectedStateId = ''.obs;
  final selectedCityId = ''.obs;

  // ─── Brand State ─────────────────────────────────────────────

  final brands = <Map<String, String>>[].obs; // [{brand_code, brand_name}]
  final isLoadingBrands = false.obs;

  // ─── Constants ───────────────────────────────────────────────

  static const int _limit = 10;

  // ─── Lifecycle ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchStates();
    // fetchSellVehiclesList() is called lazily — only when My Vehicles screen opens
  }

  // ─── Sell Vehicle List ───────────────────────────────────────

  Future<void> fetchSellVehiclesList({bool isRefresh = false}) async {
    if (isLoadingSellVehicles.value || isLoadingMoreSellVehicles.value) return;

    if (isRefresh) {
      sellPage.value = 1;
      hasMoreSellVehicles.value = true;
      sellVehicles.clear();
    }

    if (!hasMoreSellVehicles.value && !isRefresh) return;

    final isFirstPage = sellPage.value == 1;

    if (isFirstPage) {
      isLoadingSellVehicles.value = true;
      hasErrorSellVehicles.value = false;
      errorMessageSellVehicles.value = '';
    } else {
      isLoadingMoreSellVehicles.value = true;
    }

    try {
      final uid = await _userId;
      final result = await repository.listSellVehicles(
        userId: uid,
        limit: _limit,
        page: sellPage.value,
      );

      if (isFirstPage) {
        sellVehicles.assignAll(result.vehicles);
      } else {
        sellVehicles.addAll(result.vehicles);
      }

      sellTotalPages.value = result.totalPages;
      hasMoreSellVehicles.value = sellPage.value < result.totalPages;
      sellPage.value += 1;
    } catch (e) {
      hasErrorSellVehicles.value = true;
      errorMessageSellVehicles.value = appL10n.spareFailedToLoadYourVehicles;
      debugPrint('🔴 [SELL VEHICLES ERROR] $e');
    } finally {
      isLoadingSellVehicles.value = false;
      isLoadingMoreSellVehicles.value = false;
    }
  }

  Future<void> loadMoreSellVehicles() async {
    await fetchSellVehiclesList();
  }

  Future<void> refreshSellVehiclesList() async {
    await fetchSellVehiclesList(isRefresh: true);
  }

  // ─── Categories ──────────────────────────────────────────────

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final result = await repository.getVehicleCategories();
      categories.assignAll(result);
    } catch (e) {
      debugPrint('🔴 [CATEGORIES ERROR] $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ─── Dynamic Form Fields ─────────────────────────────────────

  Future<void> loadFormFields(String categoryCode) async {
    selectedCategoryCode.value = categoryCode;
    isLoadingFormFields.value = true;
    formErrors.clear();
    brands.clear();
    try {
      final fields = await repository.getFormFieldsByCategory(
        categoryCode: categoryCode,
      );
      // Creating a listing only asks for what the API marks mandatory; the
      // edit form still shows every field so existing details stay editable.
      final shown = isEditMode.value
          ? fields
          : fields.where((f) => f.required).toList();
      dynamicFormFields.assignAll(shown);
      for (final field in shown) {
        if (!formValues.containsKey(field.fieldName)) {
          formValues[field.fieldName] = field.defaultValue;
        }
      }
      // Load brands for this category in parallel (only if the form asks for one)
      if (shown.any((f) => f.fieldName == 'Brand')) fetchBrands(categoryCode);
      // Owner mobile / state / city come from the user's profile
      if (!isEditMode.value) await _prefillFromProfile();
    } catch (e) {
      debugPrint('🔴 [FORM FIELDS ERROR] $e');
    } finally {
      isLoadingFormFields.value = false;
    }
  }

  void updateFormValue(String fieldName, dynamic value) {
    formValues[fieldName] = value;
    formErrors.remove(fieldName);
    _scheduleLeadSave();
  }

  // ─── Prefill from profile ────────────────────────────────────

  /// Fills Owner Mobile Number, State and City from the logged-in user's
  /// profile. Never overwrites something the user already entered, and never
  /// blocks the form if the profile can't be loaded.
  Future<void> _prefillFromProfile() async {
    try {
      final res = await ProfileRepository().fetchProfile().timeout(
        const Duration(seconds: 8),
      );
      final p = res.data;
      if (!res.isSuccess || p == null) return;

      final digits = p.phoneNumber.replaceAll(RegExp(r'\D'), '');
      final mobile = digits.length > 10
          ? digits.substring(digits.length - 10)
          : digits;
      if (mobile.isNotEmpty &&
          (formValues['Owner Mobile Number'] ?? '').toString().isEmpty) {
        formValues['Owner Mobile Number'] = mobile;
      }

      // Wait (briefly) for the state list that onInit started loading.
      for (var i = 0; i < 30 && isLoadingStates.value; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (states.isEmpty) await fetchStates();

      bool same(String? a, String b) =>
          a != null &&
          a.trim().isNotEmpty &&
          a.trim().toLowerCase() == b.trim().toLowerCase();

      final state = states.firstWhereOrNull(
        (s) =>
            same(p.state, s['state_name'] ?? '') ||
            same(p.state, s['state_id'] ?? ''),
      );
      if (state == null || selectedStateId.value.isNotEmpty) return;
      await fetchCities(state['state_id']!);

      final city = cities.firstWhereOrNull(
        (c) =>
            same(p.city, c['city_name'] ?? '') ||
            same(p.city, c['city_id'] ?? ''),
      );
      if (city != null) selectCity(city['city_id']!);
    } catch (e) {
      debugPrint('🟡 [Sell prefill] skipped: $e');
    }
  }

  // ─── Sell lead (autosave of the partially filled form) ───────

  Timer? _leadTimer;

  /// Values the app fills in by itself — they alone don't make a lead.
  static const Set<String> _prefilledKeys = {
    'Owner Mobile Number',
    'state_code',
    'city_code',
    'state_name',
    'city_name',
    'Category',
    'category',
  };

  void _scheduleLeadSave() {
    if (isEditMode.value || selectedCategoryCode.value.isEmpty) return;
    _leadTimer?.cancel();
    _leadTimer = Timer(const Duration(milliseconds: 1500), _saveLead);
  }

  /// Saves any pending lead now (call when the user leaves the form).
  Future<void> flushLeadSave() async {
    if (_leadTimer?.isActive ?? false) {
      _leadTimer!.cancel();
      await _saveLead();
    }
  }

  Map<String, dynamic> _leadPayload() {
    final data = <String, dynamic>{};
    formValues.forEach((key, value) {
      if (value is String) {
        if (value.trim().isNotEmpty) data[key] = value.trim();
      } else if (value is num || value is bool) {
        data[key] = value;
      }
    });
    return data;
  }

  Future<void> _saveLead() async {
    if (isEditMode.value || selectedCategoryCode.value.isEmpty) return;
    final data = _leadPayload();
    final hasUserInput = data.entries.any(
      (e) => !_prefilledKeys.contains(e.key) && e.value != false,
    );
    if (!hasUserInput) return;
    try {
      final uid = await _userId;
      if (uid.isEmpty) return;
      await NetworkService.to.post(
        ApiEndpoints.sellLead,
        data: {
          'user_id': uid,
          'category_code': selectedCategoryCode.value,
          'form_data': data,
        },
      );
    } catch (e) {
      debugPrint('🟡 [Sell lead] not saved: $e'); // never bother the user
    }
  }

  // ─── Validation ──────────────────────────────────────────────

  bool validateForm() {
    formErrors.clear();
    bool isValid = true;

    // Fields whose values live under separate dedicated keys rather than
    // the label-keyed formValues map — skip them in dynamic validation.
    const _skipLabels = {
      'State',
      'City',
      'Brand',
      'Category',
      'Vehicle Images',
      'Upload Vehicle RC',
      'Insurance Upload',
    };

    // Validate required dynamic fields
    for (final field in dynamicFormFields) {
      if (!field.required) continue;
      if (_skipLabels.contains(field.fieldName)) continue;
      // Switches always hold an answer (off = No), so never "missing".
      if (field.fieldType == 'yes_no' ||
          const {
            'Fitness',
            'Original Invoice',
            'GST Applicability',
          }.contains(field.fieldName)) {
        continue;
      }

      final value = formValues[field.fieldName];
      if (value == null || (value is String && value.trim().isEmpty)) {
        formErrors[field.fieldName] = appL10n.spareFieldNameIsRequired(
          field.fieldName,
        );
        isValid = false;
      }
    }

    // Validate State & City via dedicated keys
    if ((formValues['state_code'] ?? '').toString().isEmpty) {
      formErrors['State'] = appL10n.stateRequired;
      isValid = false;
    }
    if ((formValues['city_code'] ?? '').toString().isEmpty) {
      formErrors['City'] = appL10n.cityRequired;
      isValid = false;
    }

    bool apiRequires(String label) =>
        dynamicFormFields.any((f) => f.fieldName == label && f.required);

    // Validate Brand via dedicated key — only when the API marks it mandatory
    if (apiRequires('Brand') &&
        (formValues['brand_code'] ?? '').toString().isEmpty) {
      formErrors['Brand'] = appL10n.brandValidation;
      isValid = false;
    }

    // Validate Category via controller field
    if (selectedCategoryCode.value.isEmpty) {
      formErrors['Category'] = appL10n.spareCategoryIsRequired;
      isValid = false;
    }

    // Validate required images
    if (apiRequires('Vehicle Images') &&
        vehicleImages.isEmpty &&
        !isEditMode.value) {
      isValid = false;
      Get.snackbar(
        appL10n.validation_error,
        appL10n.sparePleaseAddAtLeastOneVehicleImage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    // Validate RC document
    if (apiRequires('Upload Vehicle RC') &&
        rcDocuments.isEmpty &&
        !isEditMode.value) {
      isValid = false;
      Get.snackbar(
        appL10n.validation_error,
        appL10n.sparePleaseUploadAtLeastOneRcDocument,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    debugPrint('🚗 [validateForm] isValid=$isValid formErrors=$formErrors');
    if (!isValid && formErrors.isNotEmpty) {
      CustomSnackbar.show(
        message: appL10n.please_fix_all_validation_errors,
        type: SnackbarType.warning,
      );
    }
    return isValid;
  }

  // ─── Image Management ────────────────────────────────────────

  /// Adds an image file to the vehicle images list.
  /// Called from the image upload widget after picking via platform channel.
  void addImage(File file) {
    if (vehicleImages.length >= 10) {
      Get.snackbar(
        appL10n.spareLimitReached,
        appL10n.spareMaxTenImagesAllowed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    vehicleImages.add(file);
  }

  /// Adds multiple image files to the vehicle images list.
  void addImages(List<File> files) {
    final remaining = 10 - vehicleImages.length;
    if (remaining <= 0) {
      Get.snackbar(
        appL10n.spareLimitReached,
        appL10n.spareMaxTenImagesAllowed,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    vehicleImages.addAll(files.take(remaining));
  }

  void removeImage(int index) {
    if (index >= 0 && index < vehicleImages.length) {
      vehicleImages.removeAt(index);
    }
  }

  // ─── Document Management ─────────────────────────────────────

  static const int _maxDocSizeBytes = 12 * 1024 * 1024; // 12 MB

  bool _checkSize(File file) {
    if (file.lengthSync() > _maxDocSizeBytes) {
      Get.snackbar(
        appL10n.fileTooLarge,
        appL10n.spareEachDocumentUnder12Mb,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void addRcDocument(File file) {
    if (_checkSize(file)) rcDocuments.add(file);
  }

  void addRcDocuments(List<File> files) {
    for (final f in files) {
      if (_checkSize(f)) rcDocuments.add(f);
    }
  }

  void removeRcDocument(int index) {
    if (index >= 0 && index < rcDocuments.length) rcDocuments.removeAt(index);
  }

  void addInsuranceDocument(File file) {
    if (_checkSize(file)) insuranceDocuments.add(file);
  }

  void addInsuranceDocuments(List<File> files) {
    for (final f in files) {
      if (_checkSize(f)) insuranceDocuments.add(f);
    }
  }

  void removeInsuranceDocument(int index) {
    if (index >= 0 && index < insuranceDocuments.length)
      insuranceDocuments.removeAt(index);
  }

  // ─── Submit Sell Form ────────────────────────────────────────

  Future<bool> submitSellForm() async {
    debugPrint('🚗 [submitSellForm] START');
    debugPrint(
      '🚗 [submitSellForm] categoryCode=${selectedCategoryCode.value}',
    );
    debugPrint('🚗 [submitSellForm] formValues=$formValues');
    debugPrint(
      '🚗 [submitSellForm] vehicleImages.length=${vehicleImages.length}',
    );
    debugPrint('🚗 [submitSellForm] vehicleImages paths:');
    for (var i = 0; i < vehicleImages.length; i++) {
      final img = vehicleImages[i];
      debugPrint(
        '  [$i] ${img.path} - exists: ${img.existsSync()} - size: ${img.lengthSync()} bytes',
      );
    }
    debugPrint('🚗 [submitSellForm] rcDocuments=${rcDocuments.length}');
    for (var i = 0; i < rcDocuments.length; i++) {
      final doc = rcDocuments[i];
      debugPrint(
        '  RC[$i] ${doc.path} - exists: ${doc.existsSync()} - size: ${doc.lengthSync()} bytes',
      );
    }
    debugPrint(
      '🚗 [submitSellForm] insuranceDocuments=${insuranceDocuments.length}',
    );
    for (var i = 0; i < insuranceDocuments.length; i++) {
      final doc = insuranceDocuments[i];
      debugPrint(
        '  INS[$i] ${doc.path} - exists: ${doc.existsSync()} - size: ${doc.lengthSync()} bytes',
      );
    }

    if (!validateForm()) {
      debugPrint(
        '🚗 [submitSellForm] validateForm FAILED, formErrors=$formErrors',
      );
      return false;
    }
    debugPrint('🚗 [submitSellForm] validateForm PASSED, calling API...');

    isSubmittingForm.value = true;
    try {
      final uid = await _userId;
      debugPrint('🚗 [submitSellForm] userId=$uid');
      debugPrint(
        '🚗 [submitSellForm] Calling repository.createSellVehicle with:',
      );
      debugPrint('  - categoryCode: ${selectedCategoryCode.value}');
      debugPrint(
        '  - brandCode: ${(formValues['brand_code'] ?? formValues['Brand'] ?? '').toString()}',
      );
      debugPrint('  - vehicleImages: ${vehicleImages.length} files');
      debugPrint('  - rcDocument: ${rcDocuments.isNotEmpty ? 'YES' : 'NO'}');
      debugPrint(
        '  - insuranceDocument: ${insuranceDocuments.isNotEmpty ? 'YES' : 'NO'}',
      );

      await repository.createSellVehicle(
        userId: uid,
        categoryCode: selectedCategoryCode.value,
        brandCode: (formValues['brand_code'] ?? formValues['Brand'] ?? '')
            .toString(),
        assetDescOrModel:
            (formValues['Asset Description'] ??
                    formValues['asset_desc_or_model'] ??
                    formValues['model'] ??
                    '')
                .toString(),
        registrationNumber:
            (formValues['Registration Number'] ??
                    formValues['registration_number'] ??
                    '')
                .toString(),
        manufacturingYear:
            int.tryParse(
              '${formValues['Year of Manufacturing'] ?? formValues['manufacturing_year'] ?? 0}',
            ) ??
            0,
        chassisNumber:
            (formValues['Chassis Number'] ?? formValues['chassis_number'] ?? '')
                .toString(),
        price:
            double.tryParse(
              '${formValues['Price'] ?? formValues['price'] ?? 0}',
            ) ??
            0,
        ownerMobile:
            (formValues['Owner Mobile Number'] ??
                    formValues['owner_mobile'] ??
                    '')
                .toString(),
        stateCode: (formValues['state_code'] ?? '').toString(),
        cityCode: (formValues['city_code'] ?? '').toString(),
        vehicleImages: vehicleImages.toList(),
        rcDocument: rcDocuments.isNotEmpty ? rcDocuments.first : null,
        insuranceDocument: insuranceDocuments.isNotEmpty
            ? insuranceDocuments.first
            : null,
        odometer: (formValues['Odometer'] ?? formValues['odometer'])
            ?.toString(),
        noOfTyres: (formValues['No Of Tyres'] ?? formValues['no_of_tyres'])
            ?.toString(),
        fitness: formValues['Fitness'] == true || formValues['fitness'] == true,
        insurance:
            formValues['Vehicle Insurance'] != null ||
            formValues['insurance'] == true,
        originalInvoice:
            formValues['Original Invoice'] == true ||
            formValues['original_invoice'] == true,
        gstApplicability:
            formValues['GST Applicability'] == true ||
            formValues['gst_applicability'] == true,
        tonnage: (formValues['Tonnage'] ?? formValues['tonnage'])?.toString(),
        hours: (formValues['Hours'] ?? formValues['hours'])?.toString(),
        bodyType: (formValues['Body Type'] ?? formValues['body_type'])
            ?.toString(),
        bodyLength: (formValues['Body Length'] ?? formValues['body_length'])
            ?.toString(),
        fuelType: (formValues['Fuel Type'] ?? formValues['fuel_type'])
            ?.toString(),
        insuranceDates:
            (formValues['Vehicle Insurance'] ?? formValues['insurance_dates'])
                ?.toString(),
        kv: (formValues['KV'] ?? formValues['kv'])?.toString(),
        otherBrand: formValues['other_brand']?.toString(),
        otherTipper: formValues['other_tipper']?.toString(),
        otherBodyType: formValues['other_body_type']?.toString(),
        otherTyre: formValues['other_tyre']?.toString(),
      );

      debugPrint('✅ [submitSellForm] API call successful');

      // Navigate back first, THEN reset form and refresh list
      // This prevents blank screen issue
      if (Get.currentRoute == AppRoutes.sellVehicle) {
        Get.back();
      }

      // Now reset form and refresh
      resetForm();
      await refreshSellVehiclesList();

      // Admin approval notice after navigation
      AdminApprovalDialog.show();

      return true;
    } catch (e) {
      debugPrint('❌ [submitSellForm] ERROR: $e');
      Get.snackbar(
        appL10n.spareError,
        appL10n.spareFailedToSubmitVehicle(e.toString()),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmittingForm.value = false;
    }
  }

  // ─── Update Vehicle ──────────────────────────────────────────

  /// Form label → API key for `update-sell-vehicles`.
  static const _apiKeys = <String, String>{
    'Asset Description': 'asset_desc_or_model',
    'Model': 'asset_desc_or_model',
    'Registration Number': 'registration_number',
    'Year of Manufacturing': 'manufacturing_year',
    'Chassis Number': 'chassis_number',
    'Price': 'price',
    'Owner Mobile Number': 'owner_mobile',
    'Odometer': 'odometer',
    'No Of Tyres': 'no_of_tyres',
    'Tonnage': 'tonnage',
    'Hours': 'hours',
    'Body Type': 'body_type',
    'Body Length': 'body_length',
    'Fuel Type': 'fuel_type',
    'KV': 'kv',
    'Fitness': 'fitness',
    'Original Invoice': 'original_invoice',
    'GST Applicability': 'gst_applicability',
    'Vehicle Insurance': 'insurance_dates',
  };

  static const _nonApiLabels = {
    'State',
    'City',
    'Brand',
    'Category',
    'Vehicle Images',
    'Upload Vehicle RC',
    'Insurance Upload',
  };

  String _apiKeyFor(String label) =>
      _apiKeys[label] ??
      label.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

  /// Saves the edit form using two APIs: every form field goes to
  /// `update-sell-vehicles` (JSON) and any newly added files go to
  /// `update-sell-vehicles-files` (multipart).
  Future<bool> updateVehicle() async {
    if (!isEditMode.value || editingVehicleId.value.isEmpty) return false;
    if (!validateForm()) return false;

    isSubmittingForm.value = true;
    try {
      final uid = await _userId;
      final fields = <String, dynamic>{};

      for (final f in dynamicFormFields) {
        final label = f.fieldName;
        if (_nonApiLabels.contains(label)) continue;
        final v = formValues[label];
        final isToggle =
            f.fieldType == 'yes_no' ||
            const {
              'Fitness',
              'Original Invoice',
              'GST Applicability',
            }.contains(label);
        if (isToggle && v == null) {
          fields[_apiKeyFor(label)] = false;
          continue;
        }
        if (v == null || (v is String && v.trim().isEmpty)) continue;
        final key = _apiKeyFor(label);
        if (v is bool) {
          fields[key] = v;
        } else if (key == 'price') {
          fields[key] = num.tryParse(v.toString()) ?? v;
        } else if (key == 'manufacturing_year') {
          fields[key] = int.tryParse(v.toString()) ?? v;
        } else {
          fields[key] = v.toString().trim();
        }
      }
      for (final k in const ['brand_code', 'state_code', 'city_code']) {
        final v = formValues[k]?.toString() ?? '';
        if (v.isNotEmpty) fields[k] = v;
      }

      if (fields.isNotEmpty) {
        await repository.updateSellVehicleDetails(
          sbVehicleId: editingVehicleId.value,
          userId: uid,
          fields: fields,
        );
      }
      if (vehicleImages.isNotEmpty ||
          rcDocuments.isNotEmpty ||
          insuranceDocuments.isNotEmpty) {
        await repository.uploadSellVehicleFiles(
          sbVehicleId: editingVehicleId.value,
          userId: uid,
          images: vehicleImages.toList(),
          rcDocuments: rcDocuments.toList(),
          insuranceDocs: insuranceDocuments.toList(),
        );
      }

      // Return to the Buy & Sell home (or the app root if it isn't in the stack)
      Get.until(
        (route) =>
            route.isFirst || route.settings.name == AppRoutes.buySellHome,
      );
      resetForm();
      await refreshSellVehiclesList();
      AdminApprovalDialog.show();
      return true;
    } catch (e) {
      CustomSnackbar.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
      return false;
    } finally {
      isSubmittingForm.value = false;
    }
  }

  // ─── Edit Mode ───────────────────────────────────────────────

  /// Opens the sell form in edit mode: loads the category's form fields and
  /// pre-fills them from the vehicle's full details.
  Future<void> enterEditMode(SellVehicleEntity vehicle) async {
    resetForm();
    isEditMode.value = true;
    editingVehicleId.value = vehicle.id;
    isLoadingEditData.value = true;
    try {
      final code = vehicle.categoryCode ?? '';
      if (code.isNotEmpty) await loadFormFields(code);
      final json = await _fetchVehicleJson(vehicle.id);
      _prefillFromJson(json, vehicle);
    } catch (e) {
      debugPrint('🔴 [enterEditMode] $e');
      _prefillFromJson(const {}, vehicle);
    } finally {
      isLoadingEditData.value = false;
    }
  }

  Future<Map<String, dynamic>> _fetchVehicleJson(String id) async {
    final res = await NetworkService.to.get(
      ApiEndpoints.sellBuyVehicleById(id),
    );
    dynamic d = res.data;
    if (d is Map && d['data'] != null) d = d['data'];
    if (d is Map && d['vehicle'] is Map) d = d['vehicle'];
    if (d is Map &&
        d['vehicles'] is List &&
        (d['vehicles'] as List).isNotEmpty) {
      d = (d['vehicles'] as List).first;
    }
    return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
  }

  void _prefillFromJson(Map<String, dynamic> j, SellVehicleEntity v) {
    bool? asBool(dynamic x) {
      if (x == null) return null;
      if (x is bool) return x;
      final s = x.toString().toLowerCase();
      return s == 'true' || s == 'yes' || s == '1';
    }

    for (final f in dynamicFormFields) {
      final label = f.fieldName;
      if (_nonApiLabels.contains(label)) continue;
      final raw = j[_apiKeyFor(label)];
      if (raw == null) continue;
      if (f.fieldType == 'yes_no' ||
          const {
            'Fitness',
            'Original Invoice',
            'GST Applicability',
          }.contains(label)) {
        final b = asBool(raw);
        if (b != null) formValues[label] = b;
      } else {
        formValues[label] = raw.toString();
      }
    }
    // Fallbacks from the list entity when the detail call lacks a field
    formValues.putIfAbsent('Registration Number', () => v.registrationNumber);
    final p = v.price ?? v.askingPrice;
    if (p != null && p > 0)
      formValues.putIfAbsent('Price', () => p.toInt().toString());

    // Brand / location use dedicated keys
    formValues['brand_code'] = (j['brand_code'] ?? v.brandCode ?? '')
        .toString();
    formValues['brand_name'] = (j['brand_name'] ?? v.brandName ?? '')
        .toString();
    final st = (j['state_code'] ?? j['state_id'] ?? '').toString();
    final ct = (j['city_code'] ?? j['city_id'] ?? '').toString();
    if (st.isNotEmpty) {
      formValues['state_code'] = st;
      selectedStateId.value = st;
      fetchCities(st).then((_) {
        if (ct.isNotEmpty) selectCity(ct);
      });
    }
    if (ct.isNotEmpty) formValues['city_code'] = ct;
    formValues.refresh();
  }

  // ─── Location ────────────────────────────────────────────────

  Future<void> fetchStates() async {
    isLoadingStates.value = true;
    try {
      final response = await NetworkService.to.get(ApiEndpoints.states);
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = (raw is Map)
            ? ((raw['data']?['states'] ?? raw['data'] ?? []) as List)
            : (raw is List ? raw : []);
        states.assignAll(
          list
              .map(
                (e) => {
                  'state_id': e['state_id']?.toString() ?? '',
                  'state_name': e['state_name']?.toString() ?? '',
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('🔴 [STATES ERROR] $e');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchCities(String stateId) async {
    selectedStateId.value = stateId;
    selectedCityId.value = '';
    updateFormValue('state_code', stateId);
    updateFormValue('city_code', '');
    cities.clear();
    isLoadingCities.value = true;
    try {
      final response = await NetworkService.to.get(
        ApiEndpoints.cities,
        queryParameters: {'state_id': stateId},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = (raw is Map)
            ? ((raw['data']?['cities'] ?? raw['data'] ?? []) as List)
            : (raw is List ? raw : []);
        cities.assignAll(
          list
              .map(
                (e) => {
                  'city_id': e['city_id']?.toString() ?? '',
                  'city_name': e['city_name']?.toString() ?? '',
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('🔴 [CITIES ERROR] $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void selectCity(String cityId) {
    selectedCityId.value = cityId;
    updateFormValue('city_code', cityId);
  }

  Future<void> fetchBrands(String categoryCode) async {
    isLoadingBrands.value = true;
    brands.clear();
    try {
      final uid = await _userId;
      final response = await NetworkService.to.post(
        ApiEndpoints.vehicleBrands,
        data: {'category_code': categoryCode, 'user_id': uid},
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> list = [];
        if (raw is Map) {
          list = (raw['brands'] ?? raw['data'] ?? []) as List<dynamic>;
        } else if (raw is List) {
          list = raw;
        }
        brands.assignAll(
          list
              .map(
                (e) => {
                  'brand_code': e['brand_code']?.toString() ?? '',
                  'brand_name': e['brand_name']?.toString() ?? '',
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('🔴 [BRANDS ERROR] $e');
    } finally {
      isLoadingBrands.value = false;
    }
  }

  void resetForm() {
    _leadTimer?.cancel();
    isEditMode.value = false;
    editingVehicleId.value = '';
    selectedCategoryCode.value = '';
    dynamicFormFields.clear();
    formValues.clear();
    formErrors.clear();
    vehicleImages.clear();
    rcDocuments.clear();
    insuranceDocuments.clear();
    selectedStateId.value = '';
    selectedCityId.value = '';
    cities.clear();
    brands.clear();
  }

  // ─── Mark as Sold ────────────────────────────────────────────

  Future<void> markAsSold(String vehicleId) async {
    isUpdatingSoldStatus.value = true;
    try {
      final uid = await _userId;
      await repository.updateVehicleSoldStatus(
        sbVehicleId: vehicleId,
        isSold: 'yes',
        userId: uid,
      );
      Get.snackbar(
        appL10n.spareSuccess,
        appL10n.spareVehicleMarkedAsSold,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshSellVehiclesList();
    } catch (e) {
      Get.snackbar(
        appL10n.spareError,
        appL10n.spareFailedToMarkAsSold,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingSoldStatus.value = false;
    }
  }

  Future<void> markAsUnsold(String vehicleId) async {
    isUpdatingSoldStatus.value = true;
    try {
      final uid = await _userId;
      await repository.updateVehicleSoldStatus(
        sbVehicleId: vehicleId,
        isSold: 'no',
        userId: uid,
      );
      Get.snackbar(
        appL10n.spareSuccess,
        appL10n.spareVehicleMarkedAsAvailable,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshSellVehiclesList();
    } catch (e) {
      Get.snackbar(
        appL10n.spareError,
        appL10n.spareFailedToUpdateStatus,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingSoldStatus.value = false;
    }
  }

  // ─── Convenience Getters ─────────────────────────────────────

  List<SellVehicleEntity> get pendingVehicles =>
      sellVehicles.where((v) => v.status == 'pending').toList();

  List<SellVehicleEntity> get approvedVehicles =>
      sellVehicles.where((v) => v.approved == 'yes').toList();

  List<SellVehicleEntity> get rejectedVehicles =>
      sellVehicles.where((v) => v.status == 'rejected').toList();

  List<SellVehicleEntity> get soldVehicles =>
      sellVehicles.where((v) => v.isSold == 'yes').toList();

  List<SellVehicleEntity> get activeVehicles =>
      sellVehicles.where((v) => v.isSold != 'yes').toList();
}

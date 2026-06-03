import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/entities/sell_vehicle_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';
import '../domain/repositories/buy_sell_repository.dart';

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
      errorMessageSellVehicles.value = 'Failed to load your vehicles';
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
      dynamicFormFields.assignAll(fields);
      for (final field in fields) {
        if (!formValues.containsKey(field.fieldName)) {
          formValues[field.fieldName] = field.defaultValue;
        }
      }
      // Load brands for this category in parallel
      fetchBrands(categoryCode);
    } catch (e) {
      debugPrint('🔴 [FORM FIELDS ERROR] $e');
    } finally {
      isLoadingFormFields.value = false;
    }
  }

  void updateFormValue(String fieldName, dynamic value) {
    formValues[fieldName] = value;
    formErrors.remove(fieldName);
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

      final value = formValues[field.fieldName];
      if (value == null || (value is String && value.trim().isEmpty)) {
        formErrors[field.fieldName] = '${field.fieldName} is required';
        isValid = false;
      }
    }

    // Validate State & City via dedicated keys
    if ((formValues['state_code'] ?? '').toString().isEmpty) {
      formErrors['State'] = 'State is required';
      isValid = false;
    }
    if ((formValues['city_code'] ?? '').toString().isEmpty) {
      formErrors['City'] = 'City is required';
      isValid = false;
    }

    // Validate Brand via dedicated key
    if ((formValues['brand_code'] ?? '').toString().isEmpty) {
      formErrors['Brand'] = 'Brand is required';
      isValid = false;
    }

    // Validate Category via controller field
    if (selectedCategoryCode.value.isEmpty) {
      formErrors['Category'] = 'Category is required';
      isValid = false;
    }

    // Validate required images
    if (vehicleImages.isEmpty) {
      isValid = false;
      Get.snackbar(
        'Validation Error',
        'Please add at least 1 vehicle image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    // Validate RC document
    if (rcDocuments.isEmpty && !isEditMode.value) {
      isValid = false;
      Get.snackbar(
        'Validation Error',
        'Please upload at least one RC document',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    debugPrint('🚗 [validateForm] isValid=$isValid formErrors=$formErrors');
    return isValid;
  }

  // ─── Image Management ────────────────────────────────────────

  /// Adds an image file to the vehicle images list.
  /// Called from the image upload widget after picking via platform channel.
  void addImage(File file) {
    if (vehicleImages.length >= 10) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 10 images allowed',
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
        'Limit Reached',
        'Maximum 10 images allowed',
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
        'File Too Large',
        'Each document must be under 12 MB',
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
    debugPrint('🚗 [submitSellForm] vehicleImages=${vehicleImages.length}');
    debugPrint('🚗 [submitSellForm] rcDocuments=${rcDocuments.length}');
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
        insurance: formValues['Vehicle Insurance'] ?? formValues['insurance'],
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
        fuelType: (formValues['Fuel Type'] ?? formValues['fuel_type'])
            ?.toString(),
        kv: (formValues['KV'] ?? formValues['kv'])?.toString(),
        otherBrand: formValues['other_brand']?.toString(),
        otherTipper: formValues['other_tipper']?.toString(),
        otherBodyType: formValues['other_body_type']?.toString(),
        otherTyre: formValues['other_tyre']?.toString(),
      );

      CustomSnackbar.show(
        message: 'Vehicle submitted for approval.',
        type: SnackbarType.success,
      );

      resetForm();
      await refreshSellVehiclesList();
      return true;
    } catch (e) {
      debugPrint('❌ [submitSellForm] ERROR: $e');
      Get.snackbar(
        'Error',
        'Failed to submit vehicle: ${e.toString()}',
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

  Future<bool> updateVehicle() async {
    if (!isEditMode.value || editingVehicleId.value.isEmpty) return false;
    if (!validateForm()) return false;

    isSubmittingForm.value = true;
    try {
      final uid = await _userId;
      await repository.updateSellVehicle(
        sbVehicleId: editingVehicleId.value,
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
        vehicleImages: vehicleImages.isNotEmpty ? vehicleImages.toList() : null,
        rcDocument: rcDocuments.isNotEmpty ? rcDocuments.first : null,
        insuranceDocument: insuranceDocuments.isNotEmpty
            ? insuranceDocuments.first
            : null,
        odometer: (formValues['Odometer'] ?? formValues['odometer'])
            ?.toString(),
        noOfTyres: (formValues['No Of Tyres'] ?? formValues['no_of_tyres'])
            ?.toString(),
        fitness: formValues['Fitness'] == true || formValues['fitness'] == true,
        insurance: formValues['Vehicle Insurance'] ?? formValues['insurance'],
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
        fuelType: (formValues['Fuel Type'] ?? formValues['fuel_type'])
            ?.toString(),
        kv: (formValues['KV'] ?? formValues['kv'])?.toString(),
        otherBrand: formValues['other_brand']?.toString(),
        otherTipper: formValues['other_tipper']?.toString(),
        otherBodyType: formValues['other_body_type']?.toString(),
        otherTyre: formValues['other_tyre']?.toString(),
      );

      CustomSnackbar.show(
        message: 'Vehicle updated. Changes pending admin approval.',
        type: SnackbarType.success,
      );

      resetForm();
      await refreshSellVehiclesList();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update vehicle: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmittingForm.value = false;
    }
  }

  // ─── Edit Mode ───────────────────────────────────────────────

  void enterEditMode(SellVehicleEntity vehicle) {
    isEditMode.value = true;
    editingVehicleId.value = vehicle.id;
    selectedCategoryCode.value = vehicle.categoryCode ?? '';
    formValues['brand_code'] = vehicle.brandName ?? '';
    formValues['model'] = vehicle.model ?? '';
    formValues['registration_number'] = vehicle.registrationNumber ?? '';
    formValues['price'] = (vehicle.price ?? vehicle.askingPrice ?? 0)
        .toString();
    if (selectedCategoryCode.value.isNotEmpty) {
      loadFormFields(selectedCategoryCode.value);
    }
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
        'Success',
        'Vehicle marked as sold',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshSellVehiclesList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark as sold',
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
        'Success',
        'Vehicle marked as available',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshSellVehiclesList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
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

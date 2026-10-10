import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';
import '../domain/repositories/approved_vehicle_repository.dart';
import '../../../core/extensions/context_extensions.dart';

class ApprovedVehicleController extends GetxController {
  final ApprovedVehicleRepository _repository;

  ApprovedVehicleController({required ApprovedVehicleRepository repository})
    : _repository = repository;

  // ═══════════════════════════════════════════════════════════════
  // Categories
  // ═══════════════════════════════════════════════════════════════
  final categories = <ApprovedVehicleCategoryEntity>[].obs;
  final isLoadingCategories = false.obs;
  final categoriesError = ''.obs;
  final categoriesTotalCount = 0.obs;

  // ═══════════════════════════════════════════════════════════════
  // Listings
  // ═══════════════════════════════════════════════════════════════
  final listings = <ApprovedVehicleListingEntity>[].obs;
  final apprVehicleFeedAds = <ListingAd>[].obs;
  final isLoadingListings = false.obs;
  final isLoadingMoreListings = false.obs;
  final listingsError = ''.obs;
  final listingsTotalCount = 0.obs;
  final listingsPage = 1.obs;
  final hasMoreListings = true.obs;
  String _currentCategoryType = '';

  // ═══════════════════════════════════════════════════════════════
  // My Bookings / Inspections
  // ═══════════════════════════════════════════════════════════════
  final myBookings = <ApprovedVehicleListingEntity>[].obs;
  final isLoadingMyBookings = false.obs;
  final myBookingsPage = 1.obs;
  final hasMoreMyBookings = true.obs;

  final myInspections = <ApprovedVehicleListingEntity>[].obs;
  final isLoadingMyInspections = false.obs;
  final myInspectionsPage = 1.obs;
  final hasMoreMyInspections = true.obs;

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Text Controllers
  // ═══════════════════════════════════════════════════════════════
  final sellCategoryNameC = TextEditingController();
  final sellCategoryCodeC = TextEditingController();
  final sellRegNumberC = TextEditingController();
  final sellChassisC = TextEditingController();
  final sellBrandC = TextEditingController();
  final sellAssetDescC = TextEditingController();
  final sellOwnerMobileC = TextEditingController();
  final sellPriceC = TextEditingController();

  // ── Sell Form — Observable Selections ─────────────────────────
  final sellFitness = ''.obs;
  final sellOriginalInvoice = ''.obs;
  final sellMfgYear = ''.obs;
  final sellInsurance = ''.obs;
  final sellInsuranceDate = Rxn<DateTime>();
  final sellGSTApplicability = ''.obs;
  final sellOfferEndDate = Rxn<DateTime>();
  final sellOfferEndTime = Rxn<TimeOfDay>();

  // ── Sell Form — State/City (text-based) ───────────────────────
  final sellStateC = TextEditingController();
  final sellCityC = TextEditingController();

  // ── Sell Form — State/City dropdown data ──────────────────────
  final sellStates = <Map<String, String>>[].obs; // [{state_id, state_name}]
  final sellCities = <Map<String, String>>[].obs; // [{city_id, city_name}]
  final isLoadingSellStates = false.obs;
  final isLoadingSellCities = false.obs;
  final selectedSellStateId = ''.obs;
  final selectedSellCityId = ''.obs;

  // ── Sell Form — Brand dropdown data ────────────────────────────
  final sellBrands = <Map<String, String>>[].obs; // [{brand_code, brand_name}]
  final isLoadingSellBrands = false.obs;

  // ── Sell Form — File Paths ────────────────────────────────────
  final sellVehicleImages = <String>[].obs;
  final sellRCFiles = <String>[].obs;
  final sellInsuranceFiles = <String>[].obs;

  // ── Sell Form — Loading ───────────────────────────────────────
  final isSubmittingSellForm = false.obs;

  // ── Sell Form — Validation Errors ─────────────────────────────
  final sellRegNumberError = ''.obs;
  final sellStateError = ''.obs;
  final sellCityError = ''.obs;
  final sellFitnessError = ''.obs;
  final sellBrandError = ''.obs;
  final sellOriginalInvoiceError = ''.obs;
  final sellAssetDescError = ''.obs;
  final sellOwnerMobileError = ''.obs;
  final sellPriceError = ''.obs;
  final sellMfgYearError = ''.obs;
  final sellInsuranceError = ''.obs;
  final sellGSTApplicabilityError = ''.obs;
  final sellVehicleImagesError = ''.obs;
  final sellOfferEndDateError = ''.obs;
  final sellOfferEndTimeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchSellStates();
  }

  @override
  void onClose() {
    // Dispose text controllers
    sellCategoryNameC.dispose();
    sellCategoryCodeC.dispose();
    sellRegNumberC.dispose();
    sellChassisC.dispose();
    sellBrandC.dispose();
    sellAssetDescC.dispose();
    sellOwnerMobileC.dispose();
    sellPriceC.dispose();
    sellStateC.dispose();
    sellCityC.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════
  // Categories
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchCategories({bool isRefresh = false}) async {
    if (isLoadingCategories.value) return;
    isLoadingCategories.value = true;
    categoriesError.value = '';

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getCategories(userId: userId);
      categories.assignAll(result.categories);
      categoriesTotalCount.value = result.totalCount;
    } catch (e) {
      categoriesError.value = appL10n.apprFailedLoadCategories;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Listings
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchListings({
    required String categoryType,
    bool isRefresh = false,
  }) async {
    if (isLoadingListings.value) return;

    if (isRefresh || _currentCategoryType != categoryType) {
      listingsPage.value = 1;
      hasMoreListings.value = true;
      listings.clear();
    }

    _currentCategoryType = categoryType;
    isLoadingListings.value = true;
    listingsError.value = '';

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getListings(
        userId: userId,
        categoryType: categoryType,
        page: listingsPage.value,
      );
      if (isRefresh || listingsPage.value == 1) {
        listings.assignAll(result.listings);
        apprVehicleFeedAds.assignAll(result.ads);
      } else {
        listings.addAll(result.listings);
      }
      listingsTotalCount.value = result.totalCount;
      hasMoreListings.value = listings.length < result.totalCount;
    } catch (e) {
      listingsError.value = appL10n.apprFailedLoadVehicles;
    } finally {
      isLoadingListings.value = false;
    }
  }

  Future<void> loadMoreListings() async {
    if (!hasMoreListings.value || isLoadingMoreListings.value) return;
    isLoadingMoreListings.value = true;
    try {
      listingsPage.value++;
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getListings(
        userId: userId,
        categoryType: _currentCategoryType,
        page: listingsPage.value,
      );
      listings.addAll(result.listings);
      if (result.ads.isNotEmpty) apprVehicleFeedAds.assignAll(result.ads);
      hasMoreListings.value = listings.length < result.totalCount;
    } catch (_) {
      listingsPage.value--;
    } finally {
      isLoadingMoreListings.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // User Interest (Book / Inspection)
  // ═══════════════════════════════════════════════════════════════

  Future<bool> bookVehicle(String approvedVehicleId) async {
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      await _repository.updateUserInterest(
        userId: userId,
        approvedVehicleId: approvedVehicleId,
        isInterested: 'Yes',
        isBooked: 'Yes',
      );
      if (_currentCategoryType.isNotEmpty) {
        fetchListings(categoryType: _currentCategoryType, isRefresh: true);
      }
      return true;
    } catch (e) {
      Get.snackbar(
        appL10n.apprError,
        appL10n.apprFailedBookVehicle,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }
  }

  Future<bool> requestInspection(String approvedVehicleId) async {
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      await _repository.updateUserInterest(
        userId: userId,
        approvedVehicleId: approvedVehicleId,
        isInterested: 'Yes',
        isBooked: 'No',
      );
      if (_currentCategoryType.isNotEmpty) {
        fetchListings(categoryType: _currentCategoryType, isRefresh: true);
      }
      return true;
    } catch (e) {
      Get.snackbar(
        appL10n.apprError,
        appL10n.apprFailedRequestInspection,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // My Bookings
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchMyBookings({bool isRefresh = false}) async {
    if (isLoadingMyBookings.value) return;
    if (isRefresh) {
      myBookingsPage.value = 1;
      hasMoreMyBookings.value = true;
      myBookings.clear();
    }
    isLoadingMyBookings.value = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getUserBookedVehicles(
        userId: userId,
        bookedVehicles: 'yes',
        page: myBookingsPage.value,
      );
      if (isRefresh || myBookingsPage.value == 1) {
        myBookings.assignAll(result.listings);
      } else {
        myBookings.addAll(result.listings);
      }
      hasMoreMyBookings.value = myBookings.length < result.totalCount;
    } catch (_) {
      // silent
    } finally {
      isLoadingMyBookings.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // My Inspections
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchMyInspections({bool isRefresh = false}) async {
    if (isLoadingMyInspections.value) return;
    if (isRefresh) {
      myInspectionsPage.value = 1;
      hasMoreMyInspections.value = true;
      myInspections.clear();
    }
    isLoadingMyInspections.value = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _repository.getUserBookedVehicles(
        userId: userId,
        inspectionRequested: 'yes',
        page: myInspectionsPage.value,
      );
      if (isRefresh || myInspectionsPage.value == 1) {
        myInspections.assignAll(result.listings);
      } else {
        myInspections.addAll(result.listings);
      }
      hasMoreMyInspections.value = myInspections.length < result.totalCount;
    } catch (_) {
      // silent
    } finally {
      isLoadingMyInspections.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Validation
  // ═══════════════════════════════════════════════════════════════

  void validateSellRegNumber() {
    sellRegNumberError.value = sellRegNumberC.text.trim().isEmpty
        ? appL10n.apprRegNoRequired
        : '';
  }

  void validateSellState() {
    sellStateError.value =
        (selectedSellStateId.value.isEmpty && sellStateC.text.trim().isEmpty)
        ? appL10n.stateRequired
        : '';
  }

  void validateSellCity() {
    sellCityError.value =
        (selectedSellCityId.value.isEmpty && sellCityC.text.trim().isEmpty)
        ? appL10n.cityRequired
        : '';
  }

  void validateSellFitness() {
    sellFitnessError.value = sellFitness.value.isEmpty
        ? appL10n.apprFitnessRequired
        : '';
  }

  void validateSellBrand() {
    sellBrandError.value = sellBrandC.text.trim().isEmpty
        ? appL10n.brandValidation
        : '';
  }

  void validateSellOriginalInvoice() {
    sellOriginalInvoiceError.value = sellOriginalInvoice.value.isEmpty
        ? appL10n.apprOriginalInvoiceRequired
        : '';
  }

  void validateSellAssetDesc() {
    sellAssetDescError.value = sellAssetDescC.text.trim().isEmpty
        ? appL10n.apprAssetDescRequired
        : '';
  }

  void validateSellOwnerMobile() {
    final mobile = sellOwnerMobileC.text.trim();
    if (mobile.isEmpty) {
      sellOwnerMobileError.value = appL10n.apprOwnerMobileRequired;
    } else if (mobile.length != 10) {
      sellOwnerMobileError.value = appL10n.apprEnterValidMobile;
    } else {
      sellOwnerMobileError.value = '';
    }
  }

  void validateSellPrice() {
    final price = sellPriceC.text.trim();
    if (price.isEmpty) {
      sellPriceError.value = appL10n.apprPriceRequired;
    } else if (double.tryParse(price) == null) {
      sellPriceError.value = appL10n.apprEnterValidPrice;
    } else {
      sellPriceError.value = '';
    }
  }

  void validateSellMfgYear() {
    sellMfgYearError.value = sellMfgYear.value.isEmpty
        ? appL10n.apprMfgYearRequired
        : '';
  }

  void validateSellInsurance() {
    sellInsuranceError.value = sellInsurance.value.isEmpty
        ? appL10n.apprInsuranceRequired
        : '';
  }

  void validateSellGSTApplicability() {
    sellGSTApplicabilityError.value = sellGSTApplicability.value.isEmpty
        ? appL10n.apprGstApplicabilityRequired
        : '';
  }

  void validateSellVehicleImages() {
    sellVehicleImagesError.value = sellVehicleImages.isEmpty
        ? appL10n.apprVehicleImagesRequired
        : '';
  }

  void validateSellOfferEndDate() {
    sellOfferEndDateError.value = sellOfferEndDate.value == null
        ? appL10n.apprOfferEndDateRequired
        : '';
  }

  void validateSellOfferEndTime() {
    sellOfferEndTimeError.value = sellOfferEndTime.value == null
        ? appL10n.apprOfferEndTimeRequired
        : '';
  }

  /// Validate all sell form fields. Returns `true` if all valid.
  bool validateSellForm() {
    validateSellRegNumber();
    validateSellState();
    validateSellCity();
    validateSellFitness();
    validateSellBrand();
    validateSellOriginalInvoice();
    validateSellAssetDesc();
    validateSellMfgYear();
    validateSellInsurance();
    validateSellGSTApplicability();
    validateSellVehicleImages();
    validateSellOfferEndDate();
    validateSellOfferEndTime();
    validateSellOwnerMobile();
    validateSellPrice();

    return sellRegNumberError.value.isEmpty &&
        sellStateError.value.isEmpty &&
        sellCityError.value.isEmpty &&
        sellFitnessError.value.isEmpty &&
        sellBrandError.value.isEmpty &&
        sellOriginalInvoiceError.value.isEmpty &&
        sellAssetDescError.value.isEmpty &&
        sellMfgYearError.value.isEmpty &&
        sellInsuranceError.value.isEmpty &&
        sellGSTApplicabilityError.value.isEmpty &&
        sellVehicleImagesError.value.isEmpty &&
        sellOfferEndDateError.value.isEmpty &&
        sellOfferEndTimeError.value.isEmpty &&
        sellOwnerMobileError.value.isEmpty &&
        sellPriceError.value.isEmpty;
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Submission
  // ═══════════════════════════════════════════════════════════════

  Future<void> submitSellFormData() async {
    if (isSubmittingSellForm.value) return;
    if (!validateSellForm()) {
      Get.snackbar(
        appL10n.validation_error,
        appL10n.apprFixErrorsBeforeSubmitting,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isSubmittingSellForm.value = true;

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';

      // Build form data map
      final formData = <String, dynamic>{
        'user_id': userId,
        'category_type': sellCategoryCodeC.text.trim(),
        'registration_number': sellRegNumberC.text.trim(),
        'state_code': selectedSellStateId.value.isNotEmpty
            ? selectedSellStateId.value
            : sellStateC.text.trim(),
        'city_code': selectedSellCityId.value.isNotEmpty
            ? selectedSellCityId.value
            : sellCityC.text.trim(),
        'fitness_available': sellFitness.value.isEmpty
            ? 'No'
            : sellFitness.value,
        'brand': sellBrandC.text.trim(),
        'original_invoice_available': sellOriginalInvoice.value.isEmpty
            ? 'No'
            : sellOriginalInvoice.value,
        'owner_mobile_number': sellOwnerMobileC.text.trim(),
        'asset_description': sellAssetDescC.text.trim(),
        'year_of_manufacturing': sellMfgYear.value,
        'price': sellPriceC.text.trim(),
        'insurance': sellInsurance.value.isEmpty ? 'No' : sellInsurance.value,
        'gst_applicable': sellGSTApplicability.value.isEmpty
            ? 'No'
            : sellGSTApplicability.value,
      };

      // Optional fields
      if (sellChassisC.text.trim().isNotEmpty) {
        formData['chassis_number'] = sellChassisC.text.trim();
      }
      if (sellInsuranceDate.value != null) {
        formData['vehicle_insurance_date'] = DateFormat(
          'yyyy-MM-dd',
        ).format(sellInsuranceDate.value!);
      }
      if (sellOfferEndDate.value != null) {
        formData['offer_end_date'] = DateFormat(
          'yyyy-MM-dd',
        ).format(sellOfferEndDate.value!);
      }
      if (sellOfferEndTime.value != null) {
        final t = sellOfferEndTime.value!;
        formData['offer_end_time'] =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
      }

      // Build dio.FormData with multipart files
      final dioFormData = dio.FormData.fromMap(formData);
      for (final path in sellVehicleImages) {
        dioFormData.files.add(
          MapEntry('vehicle_images', await dio.MultipartFile.fromFile(path)),
        );
      }
      for (final path in sellRCFiles) {
        dioFormData.files.add(
          MapEntry('rc_documents', await dio.MultipartFile.fromFile(path)),
        );
      }
      for (final path in sellInsuranceFiles) {
        dioFormData.files.add(
          MapEntry(
            'insurance_documents',
            await dio.MultipartFile.fromFile(path),
          ),
        );
      }

      final success = await _repository.submitVehicle(dioFormData);

      if (success) {
        Get.snackbar(
          appL10n.apprSuccess,
          appL10n.apprVehicleSubmittedSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        clearSellForm();
        Get.back(); // Return to buy/sell landing
      }
    } catch (e) {
      Get.snackbar(
        appL10n.apprError,
        appL10n.apprFailedSubmitVehicle,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSubmittingSellForm.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Clear
  // ═══════════════════════════════════════════════════════════════

  void clearSellForm() {
    sellRegNumberC.clear();
    sellChassisC.clear();
    sellBrandC.clear();
    sellAssetDescC.clear();
    sellOwnerMobileC.clear();
    sellPriceC.clear();
    sellStateC.clear();
    sellCityC.clear();

    sellFitness.value = '';
    sellOriginalInvoice.value = '';
    sellMfgYear.value = '';
    sellInsurance.value = '';
    sellInsuranceDate.value = null;
    sellGSTApplicability.value = '';
    sellOfferEndDate.value = null;
    sellOfferEndTime.value = null;

    sellVehicleImages.clear();
    sellRCFiles.clear();
    sellInsuranceFiles.clear();

    selectedSellStateId.value = '';
    selectedSellCityId.value = '';
    sellCities.clear();
    sellBrands.clear();

    // Clear all errors
    sellRegNumberError.value = '';
    sellStateError.value = '';
    sellCityError.value = '';
    sellFitnessError.value = '';
    sellBrandError.value = '';
    sellOriginalInvoiceError.value = '';
    sellAssetDescError.value = '';
    sellOwnerMobileError.value = '';
    sellPriceError.value = '';
    sellMfgYearError.value = '';
    sellInsuranceError.value = '';
    sellGSTApplicabilityError.value = '';
    sellVehicleImagesError.value = '';
    sellOfferEndDateError.value = '';
    sellOfferEndTimeError.value = '';
  }

  /// Initialize sell form with category from navigation args
  void initSellForm(String categoryName, String categoryCode) {
    sellCategoryNameC.text = categoryName;
    sellCategoryCodeC.text = categoryCode;
    sellBrands.clear();
    if (categoryCode.isNotEmpty) {
      fetchSellBrands(categoryCode);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Location (State / City)
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchSellStates() async {
    isLoadingSellStates.value = true;
    try {
      final response = await NetworkService.to.get(ApiEndpoints.states);
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = (raw is Map)
            ? ((raw['data']?['states'] ?? raw['data'] ?? []) as List)
            : (raw is List ? raw : []);
        sellStates.assignAll(
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
      debugPrint('🔴 [SELL STATES ERROR] $e');
    } finally {
      isLoadingSellStates.value = false;
    }
  }

  Future<void> fetchSellCities(String stateId) async {
    selectedSellStateId.value = stateId;
    selectedSellCityId.value = '';
    sellCityC.clear();
    sellCities.clear();
    isLoadingSellCities.value = true;
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
        sellCities.assignAll(
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
      debugPrint('🔴 [SELL CITIES ERROR] $e');
    } finally {
      isLoadingSellCities.value = false;
    }
  }

  void selectSellCity(String cityId) {
    selectedSellCityId.value = cityId;
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Brand
  // ═══════════════════════════════════════════════════════════════

  Future<void> fetchSellBrands(String categoryCode) async {
    isLoadingSellBrands.value = true;
    sellBrands.clear();
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    final requestBody = {
      'category_code': categoryCode,
      'user_id': userId,
      'status': 'active',
    };
    debugPrint(
      '🟡 [SELL BRANDS REQUEST] POST ${ApiEndpoints.vehicleBrands} body=$requestBody',
    );
    try {
      final response = await NetworkService.to.post(
        ApiEndpoints.vehicleBrands,
        data: requestBody,
      );
      debugPrint(
        '🟢 [SELL BRANDS] categoryCode=$categoryCode response=${response.data}',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        // API returns: { "brands": [...] } or wrapped:
        // { "status": "success", "data": { "brands": [...] } } or { "data": [...] }
        List<dynamic> list = [];
        if (raw is Map) {
          if (raw['brands'] is List) {
            list = raw['brands'] as List<dynamic>;
          } else if (raw['data'] is Map &&
              (raw['data'] as Map)['brands'] is List) {
            list = (raw['data'] as Map)['brands'] as List<dynamic>;
          } else if (raw['data'] is List) {
            list = raw['data'] as List<dynamic>;
          }
        } else if (raw is List) {
          list = raw;
        }
        sellBrands.assignAll(
          list
              .whereType<Map>()
              .map(
                (e) => {
                  'brand_code': e['brand_code']?.toString() ?? '',
                  'brand_name': e['brand_name']?.toString() ?? '',
                },
              )
              .toList(),
        );
      }
      debugPrint('🟢 [SELL BRANDS] parsed count=${sellBrands.length}');
    } on dio.DioException catch (e) {
      debugPrint(
        '🔴 [SELL BRANDS ERROR] status=${e.response?.statusCode} '
        'requestBody=${e.requestOptions.data} '
        'responseBody=${e.response?.data} '
        'message=${e.message}',
      );
    } catch (e) {
      debugPrint('🔴 [SELL BRANDS ERROR] $e');
    } finally {
      isLoadingSellBrands.value = false;
    }
  }
}

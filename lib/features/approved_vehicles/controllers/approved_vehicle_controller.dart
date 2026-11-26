import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';
import '../domain/entities/auction_vehicle_match.dart';
import '../domain/repositories/approved_vehicle_repository.dart';
import '../utils/sell_form_inputs.dart';
import '../services/approved_access_gate.dart';
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
  final sellYardNameC = TextEditingController();
  final sellYardLocationC = TextEditingController();

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
    sellYardNameC.dispose();
    sellYardLocationC.dispose();
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
      // The server refuses users without a Gold plan (403).
      final text = e.toString();
      listingsError.value =
          text.contains(approvedPlanRequiredCode) || text.contains('valid plan')
          ? approvedLockedMessage
          : appL10n.apprFailedLoadVehicles;
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
    } else if (!SellFormInputs.isValidPrice(price)) {
      sellPriceError.value = appL10n.apprEnterValidPrice;
    } else {
      sellPriceError.value = '';
    }
  }

  void validateSellMfgYear() {
    final year = sellMfgYear.value.trim();
    if (year.isEmpty) {
      sellMfgYearError.value = appL10n.apprMfgYearRequired;
    } else if (!SellFormInputs.isValidYear(year)) {
      sellMfgYearError.value = appL10n.apprMfgYearRange(
        SellFormInputs.minYear,
        SellFormInputs.maxYear(),
      );
    } else {
      sellMfgYearError.value = '';
    }
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
  /// Validates what the sell form asks for (registration, brand, year,
  /// price, description, state, city, at least one photo). Returns `true`
  /// when all are valid; [sellFormErrors] then lists nothing.
  bool validateSellForm() {
    validateSellRegNumber();
    validateSellBrand();
    validateSellMfgYear();
    validateSellPrice();
    validateSellAssetDesc();
    validateSellState();
    validateSellCity();
    validateSellVehicleImages();
    return sellFormErrors.isEmpty;
  }

  /// The current validation messages, in form order (empty when valid).
  List<String> get sellFormErrors => [
    sellRegNumberError.value,
    sellBrandError.value,
    sellMfgYearError.value,
    sellPriceError.value,
    sellAssetDescError.value,
    sellStateError.value,
    sellCityError.value,
    sellVehicleImagesError.value,
  ].where((e) => e.isNotEmpty).toList();

  void _showSellError(String message) {
    Get.snackbar(
      appL10n.validation_error,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 5),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Sell Form — Submission
  // ═══════════════════════════════════════════════════════════════

  Future<void> submitSellFormData() async {
    if (isSubmittingSellForm.value) return;
    if (!validateSellForm()) {
      // Name exactly what is missing, e.g. "Price is required".
      _showSellError(sellFormErrors.join('\n'));
      return;
    }

    isSubmittingSellForm.value = true;

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';

      // Only what the form asks for (owner mobile, vehicle condition,
      // insurance and offer end were removed; the API treats them as optional).
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
        'brand': sellBrandC.text.trim(),
        'asset_description': sellAssetDescC.text.trim(),
        'year_of_manufacturing': sellMfgYear.value,
        'price': sellPriceC.text.trim(),
      };
      void optional(String key, String value) {
        if (value.trim().isNotEmpty) formData[key] = value.trim();
      }

      optional('chassis_number', sellChassisC.text);
      optional('yard_name', sellYardNameC.text);
      optional('yard_location', sellYardLocationC.text);

      // Photos go in the API's `images` field (repeat it for each file).
      final dioFormData = dio.FormData.fromMap(formData);
      for (final path in sellVehicleImages) {
        dioFormData.files.add(
          MapEntry(
            'images',
            await dio.MultipartFile.fromFile(
              path,
              filename: path.split(RegExp(r'[/\\]')).last,
            ),
          ),
        );
      }

      // Throws SubmitVehicleRejected with the server's message on failure.
      await _repository.submitVehicle(dioFormData);
      clearSellForm();
      // Leave the form first: while a snackbar is open, Get.back() only
      // closes the snackbar (the seller stayed on a filled-in form).
      Get.back(); // Return to buy/sell landing
      Get.snackbar(
        appL10n.apprSuccess,
        appL10n.apprVehicleSubmittedSuccess,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } on SubmitVehicleRejected catch (e) {
      // The server's exact reason, e.g. "images: 'a.heic' is not allowed".
      _showSellError(e.message);
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
    sellYardNameC.clear();
    sellYardLocationC.clear();
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
  // Sell Form — prefill from our auction listings
  // ═══════════════════════════════════════════════════════════════

  /// The vehicle with [registrationNumber] in our auction listings, or null
  /// when we don't have it. Throws on network errors.
  Future<AuctionVehicleMatch?> findAuctionVehicle(
    String registrationNumber,
  ) async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    return _repository.findAuctionVehicle(
      userId: userId,
      registrationNumber: registrationNumber,
    );
  }

  /// Downloads auction photos to the app's temp folder so they upload like
  /// picked files. Returns the local paths of the ones that downloaded and
  /// are really JPG/PNG/GIF (what appr-veh-submit accepts; it checks the
  /// bytes, not the name). A photo that fails or is another format (e.g. a
  /// WEBP saved as .jpg) is left out, so it can't make the submit fail.
  Future<List<String>> downloadAuctionPhotos(List<String> urls) async {
    if (urls.isEmpty) return const [];
    final dir = await getTemporaryDirectory();
    final client = dio.Dio(
      dio.BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        responseType: dio.ResponseType.bytes,
      ),
    );
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final results = await Future.wait([
      for (var i = 0; i < urls.length; i++)
        () async {
          try {
            final res = await client.get<List<int>>(_safeUrl(urls[i]));
            final bytes = res.data ?? const <int>[];
            final ext = photoExtension(bytes);
            if (ext == null) {
              debugPrint('Auction photo skipped (not JPG/PNG/GIF): ${urls[i]}');
              return null;
            }
            final path = '${dir.path}/auction_photo_${stamp}_${i + 1}.$ext';
            await File(path).writeAsBytes(bytes, flush: true);
            return path;
          } catch (e) {
            debugPrint('Auction photo download failed: ${urls[i]} ($e)');
            return null;
          }
        }(),
    ]);
    client.close();
    return results.whereType<String>().toList();
  }

  /// The file extension for photo [bytes] the server accepts, from their
  /// content: 'jpg', 'png' or 'gif'; null for anything else.
  static String? photoExtension(List<int> bytes) {
    bool starts(List<int> sig) =>
        bytes.length >= sig.length &&
        List.generate(sig.length, (i) => bytes[i] == sig[i]).every((ok) => ok);
    if (starts(const [0xFF, 0xD8, 0xFF])) return 'jpg';
    if (starts(const [0x89, 0x50, 0x4E, 0x47])) return 'png';
    if (starts(const [0x47, 0x49, 0x46, 0x38])) return 'gif';
    return null;
  }

  /// Encodes spaces and other unsafe characters in a stored photo URL
  /// without double-encoding ones that are already encoded.
  static String _safeUrl(String url) {
    final trimmed = url.trim();
    try {
      return Uri.parse(trimmed).toString() == trimmed && !trimmed.contains(' ')
          ? trimmed
          : Uri.encodeFull(Uri.decodeFull(trimmed));
    } catch (_) {
      return Uri.encodeFull(trimmed);
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

  /// Approved Vehicles categories (2W, 3W, 4W, CV, CE, FE) have no brand list
  /// of their own; brands live under the Buy & Sell categories. Each Approved
  /// category reads the brands of its matching Buy & Sell categories.
  /// 2W and 3W have their own brand-only categories with the same codes
  /// (inactive in Buy & Sell, backend migrations 20261085 + 20261086), so they
  /// are read as they are.
  static const Map<String, List<String>> sellBrandSourceCategories = {
    '4W': ['CARS'],
    'CV': ['TRUC', 'LCVH', 'ICVH', 'TIPR', 'TRLR', 'BUSS'],
    'CE': [
      'EXCV',
      'BHLD',
      'WHLD',
      'CRNS',
      'MGRD',
      'ROLL',
      'SLMX',
      'TRMX',
      'CBPL',
    ],
    'FE': ['FARM'],
  };

  /// Buy & Sell category codes to read brands from for [categoryCode].
  /// A code that is already a Buy & Sell category is used as it is.
  static List<String> brandSourcesFor(String categoryCode) {
    final code = categoryCode.trim().toUpperCase();
    if (code.isEmpty) return const [];
    return sellBrandSourceCategories[code] ?? [code];
  }

  /// `{brands: [...]}`, `{data: {brands: [...]}}` or `{data: [...]}` -> rows.
  @visibleForTesting
  static List<Map<String, String>> parseBrandRows(Object? raw) {
    List<dynamic> list = [];
    if (raw is Map) {
      if (raw['brands'] is List) {
        list = raw['brands'] as List<dynamic>;
      } else if (raw['data'] is Map && (raw['data'] as Map)['brands'] is List) {
        list = (raw['data'] as Map)['brands'] as List<dynamic>;
      } else if (raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      }
    } else if (raw is List) {
      list = raw;
    }
    return list
        .whereType<Map>()
        .map(
          (e) => {
            'brand_code': e['brand_code']?.toString() ?? '',
            'brand_name': e['brand_name']?.toString().trim() ?? '',
          },
        )
        .where((b) => b['brand_name']!.isNotEmpty)
        .toList();
  }

  /// Merges brand lists: one entry per name (ignoring case), A to Z.
  @visibleForTesting
  static List<Map<String, String>> mergeBrands(
    Iterable<List<Map<String, String>>> lists,
  ) {
    final byName = <String, Map<String, String>>{};
    for (final list in lists) {
      for (final b in list) {
        byName.putIfAbsent(b['brand_name']!.toLowerCase(), () => b);
      }
    }
    final merged = byName.values.toList()
      ..sort(
        (a, b) => a['brand_name']!.toLowerCase().compareTo(
          b['brand_name']!.toLowerCase(),
        ),
      );
    return merged;
  }

  Future<void> fetchSellBrands(String categoryCode) async {
    isLoadingSellBrands.value = true;
    sellBrands.clear();
    try {
      final sources = brandSourcesFor(categoryCode);
      if (sources.isEmpty) return;
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final lists = await Future.wait(
        sources.map((code) => _fetchBrandsOf(code, userId)),
      );
      sellBrands.assignAll(mergeBrands(lists));
      debugPrint(
        '🟢 [SELL BRANDS] $categoryCode <- ${sources.join(',')}: '
        '${sellBrands.length} brands',
      );
    } finally {
      isLoadingSellBrands.value = false;
    }
  }

  /// Brands of one Buy & Sell category; an error gives an empty list so one
  /// missing category does not hide the others.
  Future<List<Map<String, String>>> _fetchBrandsOf(
    String sbCategoryCode,
    String userId,
  ) async {
    try {
      final response = await NetworkService.to.post(
        ApiEndpoints.vehicleBrands,
        data: {
          'category_code': sbCategoryCode,
          'user_id': userId,
          'status': 'active',
        },
      );
      if (response.statusCode == 200) return parseBrandRows(response.data);
    } on dio.DioException catch (e) {
      debugPrint(
        '🔴 [SELL BRANDS ERROR] $sbCategoryCode '
        'status=${e.response?.statusCode} body=${e.response?.data}',
      );
    } catch (e) {
      debugPrint('🔴 [SELL BRANDS ERROR] $sbCategoryCode $e');
    }
    return const [];
  }
}

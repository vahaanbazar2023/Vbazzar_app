import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../models/VehicleListResponseByVehicleID.dart';
import '../models/list_buy_subscribed_vechile_req.dart';

import '../models/vehicle_category_model.dart';
import '../models/vehicle_brand_model.dart';
import '../models/vehicle_details_by_id_request.dart';
import '../models/vehicle_sold_request.dart';
import '../models/vehicle_tire_model.dart';
import '../models/sell_vehicle_request.dart';
import '../models/list_sell_vehicles_request.dart';
import '../models/list_sell_vehicles_response.dart';
import '../models/list_buy_vehicles_request.dart';
import '../models/list_buy_vehicles_response.dart' hide VehicleFile;
import '../models/user_interest_request.dart';
import '../models/update_vehicle_request.dart';
import '../models/form_field_model.dart' as form_models;
import '../views/buy_vehicles_list_view.dart';
import '../../../core/api/api_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../location/models/states_model.dart';
import '../../location/models/cities_model.dart';
import 'dart:io';

class BuySellController extends GetxController
    with GetTickerProviderStateMixin {
  // Expose RxList for Obx reactivity
  RxList<VehicleCategory> get categories => _categories;
  // API Repository and Storage Service
  final ApiRepository _apiRepository = Get.find<ApiRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Auth Controller for state management (initialize immediately)
  final AuthController _authController = Get.find<AuthController>();

  // Vehicle Categories
  final RxList<VehicleCategory> _categories = <VehicleCategory>[].obs;
  final RxBool _isCategoryLoading = false.obs;
  final RxString _categoryError = ''.obs;

  // Vehicle Brands
  final RxList<VehicleBrand> _brands = <VehicleBrand>[].obs;
  final RxBool _isBrandLoading = false.obs;
  final RxString _brandError = ''.obs;
  final Rx<VehicleBrand?> _selectedBrand = Rx<VehicleBrand?>(null);

  // Vehicle Tires
  final RxList<VehicleTire> _tires = <VehicleTire>[].obs;
  final RxBool _isTireLoading = false.obs;
  final RxString _tireError = ''.obs;
  final Rx<VehicleTire?> _selectedTire = Rx<VehicleTire?>(null);

  // Dynamic Form Fields
  final Rx<form_models.FormFieldResponse?> _currentFormFields =
      Rx<form_models.FormFieldResponse?>(null);
  final RxBool _isFormFieldsLoading = false.obs;
  final RxString _formFieldsError = ''.obs;
  final RxMap<String, dynamic> _dynamicFormValues = <String, dynamic>{}.obs;
  final RxMap<String, String> _dynamicFormErrors = <String, String>{}.obs;

  // Existing documents storage for edit mode
  final RxMap<String, List<VehicleFile>> _existingDocuments =
      <String, List<VehicleFile>>{}.obs;
  final RxMap<String, List<PlatformFile>> _newDocuments =
      <String, List<PlatformFile>>{}.obs;

  // Tab controller for buy and sell categories
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;
  RxList<PlatformFile> vehicleSelectedFiles = <PlatformFile>[].obs;
  RxList<PlatformFile> vehicleInsuranceFiles = <PlatformFile>[].obs;
  RxList<PlatformFile> vehicleRCFiles = <PlatformFile>[].obs;
  RxBool isUploadingVehicleFile = false.obs;

  // Icon mapping for different titles
  static const Map<String, String> _titleIconMapping = {
    'BHL': AppImages.bhl,
    'Excavator': AppImages.excavator,
    'Tipper': AppImages.tipper,
    'Truck': AppImages.truckIcon,
    'ICV': AppImages.icv,
    'LCV': AppImages.lcv,
    'Car': AppImages.car,
    'Bus': AppImages.bus,
    'Trailer': AppImages.trailer,
    'Farm Equipment': AppImages.tractor, // Using tractor for farm equipment
    'Self Loading Mixer': AppImages.selfLoadingConcreteMixer,
    'Crushing Batching Plant': AppImages.crushing,
    'Wheel Loader': AppImages.wheelLoader,
    'Rollers': AppImages.rollers,
    'Motor Grader': AppImages.motorGrader,
    'Gen Set': AppImages.generator,
    'Cranes': AppImages.crane,
    'Scrap': AppImages.scrap,
    'Transit Mixture': AppImages.transitMixture,
    'Other Machines': AppImages.otherMachines,
  };

  // Loading states
  final RxBool isLoadingBuy = true.obs;
  final RxBool isLoadingSell = false.obs;

  // Load more functionality
  final RxBool isLoadingMoreBuy = false.obs;
  final RxBool isLoadingMoreSell = false.obs;

  // Pagination
  final RxInt buyPage = 1.obs;
  final RxInt sellPage = 1.obs;
  final int pageSize = 10;

  var isLoading = false.obs;
  var errorMessage = "".obs;

  // Buy and Sell data lists (using generic Map for now)
  final RxList<Map<String, dynamic>> buyItems = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sellItems = <Map<String, dynamic>>[].obs;

  // Sell Vehicles List Management
  final RxList<SellVehicleItem> sellVehiclesList = <SellVehicleItem>[].obs;
  final RxBool isLoadingSellVehiclesList = false.obs;
  final RxInt sellVehiclesPage = 1.obs;
  final RxInt sellVehiclesTotalPages = 0.obs;
  final RxInt sellVehiclesTotalCount = 0.obs;
  final RxBool hasMoreSellVehicles = true.obs;

  // Buy Vehicles List Management
  final RxList<BuyVehicle> buyVehiclesList = <BuyVehicle>[].obs;
  final RxBool isLoadingBuyVehiclesList = false.obs;
  final RxInt buyVehiclesPage = 1.obs;
  final RxInt buyVehiclesTotalPages = 0.obs;
  final RxInt buyVehiclesTotalCount = 0.obs;
  final RxBool hasMoreBuyVehicles = true.obs;

  // Buy Vechile Details By ID

  final RxList<VehicleByVehicleID> vechicleDetailsByID =
      <VehicleByVehicleID>[].obs;

  // Vehicle Category Getters
  // Remove non-reactive List getter to avoid confusion
  bool get isCategoryLoading => _isCategoryLoading.value;
  String get categoryError => _categoryError.value;
  bool get hasCategoryError => _categoryError.value.isNotEmpty;

  // Vehicle Brand Getters
  List<VehicleBrand> get brands => _brands;
  bool get isBrandLoading => _isBrandLoading.value;
  String get brandError => _brandError.value;
  bool get hasBrandError => _brandError.value.isNotEmpty;
  VehicleBrand? get selectedBrand => _selectedBrand.value;

  // Vehicle Tire Getters
  List<VehicleTire> get tires => _tires;
  bool get isTireLoading => _isTireLoading.value;
  String get tireError => _tireError.value;
  bool get hasTireError => _tireError.value.isNotEmpty;
  VehicleTire? get selectedTire => _selectedTire.value;

  // Form Field Getters
  form_models.FormFieldResponse? get currentFormFields =>
      _currentFormFields.value;
  bool get isFormFieldsLoading => _isFormFieldsLoading.value;
  RxBool get isFormFieldsLoadingRx => _isFormFieldsLoading;
  String get formFieldsError => _formFieldsError.value;
  bool get hasFormFieldsError => _formFieldsError.value.isNotEmpty;

  /// Set form fields loading state (for controlling loading during prefill)
  void setFormFieldsLoading(bool loading) {
    _isFormFieldsLoading.value = loading;
  }

  Map<String, dynamic> get dynamicFormValues => _dynamicFormValues;
  Map<String, String> get dynamicFormErrors => _dynamicFormErrors;

  // Existing documents getters
  Map<String, List<VehicleFile>> get existingDocuments => _existingDocuments;
  Map<String, List<PlatformFile>> get newDocuments => _newDocuments;

  /// Normalize a field name to a base document key (rc/insurance/gst/image/other)
  String _getDocumentBaseKey(String fieldName) {
    final name = fieldName.toLowerCase();
    if (name.contains('insurance')) return 'insurance';
    if (name.contains('gst') || name.contains('tax')) return 'gst';
    if (name.contains('rc') || name.contains('registration')) return 'rc';
    if (name.contains('image') || name.contains('photo')) return 'image';
    return fieldName;
  }

  /// Set existing documents for read-only display in edit mode
  void setExistingDocuments(String fieldName, List<VehicleFile> documents) {
    _existingDocuments[fieldName] = documents;
    final baseKey = _getDocumentBaseKey(fieldName);
    if (baseKey != fieldName) {
      _existingDocuments[baseKey] = documents;
    }
    print(
      '📋 Set ${documents.length} existing documents for field: $fieldName (base: $baseKey)',
    );
  }

  /// Get existing documents for a specific field (with base-key fallback)
  List<VehicleFile> getExistingDocumentsForField(String fieldName) {
    final baseKey = _getDocumentBaseKey(fieldName);
    if (_existingDocuments.containsKey(fieldName)) {
      return _existingDocuments[fieldName] ?? [];
    }
    return _existingDocuments[baseKey] ?? [];
  }

  /// Check if field has existing documents
  bool hasExistingDocumentsForField(String fieldName) {
    return getExistingDocumentsForField(fieldName).isNotEmpty;
  }

  /// Set new documents that user is adding
  void setNewDocuments(String fieldName, List<PlatformFile> documents) {
    _newDocuments[fieldName] = documents;
    final baseKey = _getDocumentBaseKey(fieldName);
    if (baseKey != fieldName) {
      _newDocuments[baseKey] = documents;
    }
    print(
      '📋 Set ${documents.length} new documents for field: $fieldName (base: $baseKey)',
    );
  }

  /// Get new documents for a specific field (with base-key fallback)
  List<PlatformFile> getNewDocumentsForField(String fieldName) {
    final baseKey = _getDocumentBaseKey(fieldName);
    if (_newDocuments.containsKey(fieldName)) {
      return _newDocuments[fieldName] ?? [];
    }
    return _newDocuments[baseKey] ?? [];
  }

  /// Clear all existing and new documents (used when resetting form)
  void clearAllDocuments() {
    _existingDocuments.clear();
    _newDocuments.clear();
    print('🧹 Cleared all existing and new documents');
  }

  /// Get widget key for forcing rebuilds
  String get widgetResetKey => widgetKey.value;

  // Filter controllers
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceRangeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController brandFilterController = TextEditingController();
  final TextEditingController tyreFilterController = TextEditingController();
  final TextEditingController yearFilterController = TextEditingController();
  final TextEditingController stateFilterController = TextEditingController();

  // Dynamic Category Filters
  final RxList<String> categoryFilterOptions = <String>[].obs;
  final RxMap<String, dynamic> categoryFilterConfigurations =
      <String, dynamic>{}.obs;
  final RxBool isLoadingCategoryFilters = false.obs;
  final RxString categoryFiltersError = ''.obs;
  final RxMap<String, TextEditingController> dynamicFilterControllers =
      <String, TextEditingController>{}.obs;

  // Map to store label-to-value mappings for dynamic filters
  final RxMap<String, Map<String, String>> dynamicFilterValueMappings =
      <String, Map<String, String>>{}.obs;

  // Simple storage for selected filter codes/IDs
  final RxString selectedBrandCode = ''.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedTyreCode = ''.obs;
  final RxString selectedFuelType = ''.obs;
  final RxString selectedBodyType = ''.obs;
  final RxString selectedKV = ''.obs;
  final RxString selectedTonnage = ''.obs;

  // Sell form controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController numberOfTyresController = TextEditingController();

  // Other field controllers for when user selects "Other" option
  final TextEditingController otherBrandController = TextEditingController();
  final TextEditingController otherTipperController = TextEditingController();
  final TextEditingController otherBodyTypeController = TextEditingController();
  final TextEditingController otherTyreController = TextEditingController();

  // Observable variables to track when "Other" is selected
  final RxBool isOtherBrandSelected = false.obs;
  final RxBool isOtherTipperSelected = false.obs;
  final RxBool isOtherBodyTypeSelected = false.obs;
  final RxBool isOtherTyreSelected = false.obs;
  final TextEditingController chasisNumberController = TextEditingController();
  final TextEditingController locationFormController = TextEditingController();
  final TextEditingController ownerMobileNumberController =
      TextEditingController();
  final TextEditingController assetsDescriptionController =
      TextEditingController();
  final TextEditingController yearOfManufactureController =
      TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // Additional form field controllers for new fields
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController tonnageController = TextEditingController();
  final TextEditingController tyreController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();
  final TextEditingController bodyLengthController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();
  final TextEditingController fitnessController = TextEditingController();
  final TextEditingController originalInvoiceController =
      TextEditingController();
  final TextEditingController vehicleInsuranceController =
      TextEditingController();
  final TextEditingController gstApplicabilityController =
      TextEditingController();
  final TextEditingController kvController =
      TextEditingController(); // For Gen-Set KV rating
  final TextEditingController stateController =
      TextEditingController(); // For state selection

  // Standard controllers for all categories
  final TextEditingController standardPriceController = TextEditingController();
  final Rx<bool?> hasInsurance = Rx<bool?>(null);

  // Dynamic form field controllers
  final Map<String, TextEditingController> _dynamicFormControllers = {};

  // Sell Form Validation Error Variables
  final RxString categoryErrorKey = ''.obs;
  final RxString registrationNumberErrorKey = ''.obs;
  final RxString stateErrorKey = ''.obs;
  final RxString brandErrorKey = ''.obs;
  final RxString numberOfTyresErrorKey = ''.obs;
  final RxString chassisNumberErrorKey = ''.obs;
  final RxString locationErrorKey = ''.obs;
  final RxString ownerMobileErrorKey = ''.obs;
  final RxString assetsDescriptionErrorKey = ''.obs;
  final RxString yearOfManufactureErrorKey = ''.obs;
  final RxString odometerErrorKey = ''.obs;
  final RxString cityErrorKey = ''.obs;
  final RxString vehicleImagesErrorKey = ''.obs;

  // Additional error parameters for localized messages
  final RxMap<String, dynamic> categoryErrorParams = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> registrationNumberErrorParams =
      <String, dynamic>{}.obs;
  final RxMap<String, dynamic> stateErrorParams = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> brandErrorParams = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> numberOfTyresErrorParams =
      <String, dynamic>{}.obs;
  final RxMap<String, dynamic> chassisNumberErrorParams =
      <String, dynamic>{}.obs;
  final RxMap<String, dynamic> locationErrorParams = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> ownerMobileErrorParams = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> assetsDescriptionErrorParams =
      <String, dynamic>{}.obs;
  final RxMap<String, dynamic> yearOfManufactureErrorParams =
      <String, dynamic>{}.obs;
  final RxMap<String, dynamic> odometerErrorParams = <String, dynamic>{}.obs;

  // Selected category
  final RxString selectedCategoryName = ''.obs;
  final RxBool isCategoryLocked = false.obs;

  // Form validation state
  final RxBool isSellFormValid = false.obs;

  // Sell vehicle submission state
  final RxBool isSubmittingSellForm = false.obs;
  final RxString sellFormError = ''.obs;
  final RxString sellVehicleId = ''.obs;

  // Checkbox states for sell form
  final RxBool isFitnessSelected = false.obs;
  final RxBool isInsuranceSelected = false.obs;
  final RxBool isOriginalInvoiceSelected = false.obs;
  final RxBool isGstApplicabilitySelected = false.obs;

  // Year picker state
  final RxString selectedYear = ''.obs;

  // Widget key for forcing rebuilds after reset
  final RxInt formResetKey = 0.obs;

  // Widget rebuild timestamp
  final RxString widgetKey = DateTime.now().millisecondsSinceEpoch
      .toString()
      .obs; // State dropdown
  // Selected state from AuthController
  StateItem? get selectedState {
    try {
      return _authController.selectedState.value;
    } catch (e) {
      return null;
    }
  }

  // List of states from AuthController
  List<StateItem> get states {
    try {
      return _authController.states;
    } catch (e) {
      return <StateItem>[];
    }
  }

  @override
  void onInit() {
    super.onInit();

    initializeTabController();

    // Setup validation listeners
    _setupValidationListeners();

    // Load categories first, then load initial data
    _initializeData();

    // Load states for dropdown
    _loadStates();
  }

  /// Setup listeners for reactive variables to trigger form validation
  void _setupValidationListeners() {
    // Listen for changes in vehicle images
    vehicleSelectedFiles.listen((_) {
      validateVehicleImages();
    });

    // Add text controller listeners
    brandController.addListener(() => validateBrand());
    numberOfTyresController.addListener(() => validateNumberOfTyres());

    // Add price controller listener to sync with dynamic form values
    priceController.addListener(() {
      if (!isUpdatingController && !_isValidatingForm) {
        final priceText = priceController.text.trim();
        setDynamicFormValue('Price', priceText);
        if (_currentFormFields.value != null) {
          final priceField = _currentFormFields.value!.formFields['Price'];
          if (priceField != null) {
            validateDynamicField('Price', priceField);
          }
        }
      }
    });
  }

  /// Initialize data by loading categories and buy items in parallel
  Future<void> _initializeData() async {
    try {
      // Start loading categories in background (don't await)
      final categoriesFuture = fetchCategories();

      // Start loading initial data immediately (don't wait for categories)
      loadInitialData();

      // Await categories to complete in background
      await categoriesFuture;
    } catch (e) {
      // Still load initial data even if categories fail
      loadInitialData();
    }
  }

  void initializeTabController() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      // Load data when switching tabs
      if (tabController.index == 0 && buyItems.isEmpty) {
        loadBuyItems();
      } else if (tabController.index == 1 && sellItems.isEmpty) {
        loadSellItems();
      }
    });
  }

  void loadInitialData() {
    // Load buy items by default (first tab)
    loadBuyItems();
  }

  Future<void> loadBuyItems({bool isLoadMore = false}) async {
    try {
      debugPrint('🔄 [loadBuyItems] Starting - isLoadMore: $isLoadMore');
      debugPrint(
        '🔄 [loadBuyItems] Current buyItems count: ${buyItems.length}',
      );

      if (isLoadMore) {
        isLoadingMoreBuy.value = true;
        buyPage.value++;
      } else {
        debugPrint('🔄 [loadBuyItems] Setting isLoadingBuy = true');
        isLoadingBuy.value = true;
        buyPage.value = 1;
        buyItems.clear();
        debugPrint(
          '🔄 [loadBuyItems] Cleared buyItems, count now: ${buyItems.length}',
        );

        // Refresh categories from API
        await fetchCategories();
      }

      // Add a small delay to show the refresh indicator
      debugPrint('🔄 [loadBuyItems] Starting delay for refresh indicator...');
      await Future.delayed(const Duration(milliseconds: 800));
      debugPrint('🔄 [loadBuyItems] Delay completed');

      // Build category items from loaded categories
      List<Map<String, dynamic>> categoryItems = [];

      if (_categories.isNotEmpty) {
        debugPrint(
          '✅ [loadBuyItems] Building items from ${_categories.length} categories',
        );

        for (int i = 0; i < _categories.length; i++) {
          final category = _categories[i];

          categoryItems.add({
            'id': '${i + 1}',
            'title': category.categoryName,
            'category': category.categoryName,
            'categoryCode': category.categoryCode,
            'categoryObject': category,
            'image': getIconForTitle(category.categoryName),
          });
        }
      } else {
        debugPrint(
          '⚠️ [loadBuyItems] No categories loaded, using fallback data',
        );

        // Fallback categories if API fails
        final fallbackCategories = [
          'Excavator',
          'BHL',
          'Tipper',
          'Truck',
          'Car',
          'Bus',
          'Trailer',
          'Crane',
        ];

        for (int i = 0; i < fallbackCategories.length; i++) {
          final categoryName = fallbackCategories[i];

          categoryItems.add({
            'id': '${i + 1}',
            'title': categoryName,
            'category': categoryName,
            'categoryCode': categoryName.toLowerCase(),
            'categoryObject': null,
            'image': getIconForTitle(categoryName),
          });
        }
      }

      if (isLoadMore) {
        buyItems.addAll(categoryItems);
      } else {
        buyItems.assignAll(categoryItems);
      }

      debugPrint(
        '✅ [loadBuyItems] Successfully loaded ${categoryItems.length} buy items',
      );
      debugPrint(
        '✅ [loadBuyItems] Total buyItems count now: ${buyItems.length}',
      );
    } catch (e) {
      debugPrint('❌ [loadBuyItems] Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      debugPrint('🔄 [loadBuyItems] Setting isLoadingBuy = false');
      isLoadingBuy.value = false;
      isLoadingMoreBuy.value = false;
      debugPrint('🔄 [loadBuyItems] Completed');
    }
  }

  Future<void> loadSellItems({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        isLoadingMoreSell.value = true;
        sellPage.value++;
      } else {
        isLoadingSell.value = true;
        sellPage.value = 1;
        sellItems.clear();
      }

      // TODO: Implement API call for sell items
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for now
      List<Map<String, dynamic>> mockSellItems = [
        {
          'id': '1',
          'title': 'MacBook Air',
          'price': 75000,
          'location': 'Bangalore',
          'category': 'Electronics',
        },
        {
          'id': '2',
          'title': 'Maruti Swift',
          'price': 600000,
          'location': 'Chennai',
          'category': 'Vehicles',
        },
      ];

      if (isLoadMore) {
        sellItems.addAll(mockSellItems);
      } else {
        sellItems.assignAll(mockSellItems);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load sell items: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingSell.value = false;
      isLoadingMoreSell.value = false;
    }
  }

  void onTabChanged(int index) {
    tabController.animateTo(index);
    currentTabIndex.value = index;
  }

  void refreshCurrentTab() {
    if (currentTabIndex.value == 0) {
      loadBuyItems();
    } else {
      loadSellItems();
    }
  }

  void loadMoreCurrentTab() {
    if (currentTabIndex.value == 0 && !isLoadingMoreBuy.value) {
      loadBuyItems(isLoadMore: true);
    } else if (currentTabIndex.value == 1 && !isLoadingMoreSell.value) {
      loadSellItems(isLoadMore: true);
    }
  }

  void applyFilters() {
    // TODO: Implement filter logic
    refreshCurrentTab();
  }

  void clearFilters() {
    categoryController.clear();
    locationController.clear();
    priceRangeController.clear();
    searchController.clear();
    brandFilterController.clear();
    tyreFilterController.clear();
    yearFilterController.clear();
    stateFilterController.clear();
    // Clear dynamic filters
    clearDynamicFilters();
    dynamicFilterValueMappings.clear();
    // Clear stored filter codes
    selectedBrandCode.value = '';
    selectedStateId.value = '';
    selectedTyreCode.value = '';
    selectedFuelType.value = '';
    selectedBodyType.value = '';
    selectedKV.value = '';
    selectedTonnage.value = '';
    refreshCurrentTab();
  }

  // Helper method to get icon for a title
  String getIconForTitle(String title) {
    // First try exact match
    if (_titleIconMapping.containsKey(title)) {
      return _titleIconMapping[title]!;
    }

    // Then try partial matches (case insensitive)
    final lowerTitle = title.toLowerCase();

    for (String key in _titleIconMapping.keys) {
      if (lowerTitle.contains(key.toLowerCase()) ||
          key.toLowerCase().contains(lowerTitle)) {
        return _titleIconMapping[key]!;
      }
    }

    // Check for common vehicle type keywords
    if (lowerTitle.contains('excavator')) return AppImages.excavator;
    if (lowerTitle.contains('bhl') || lowerTitle.contains('backhoe'))
      return AppImages.bhl;
    if (lowerTitle.contains('tipper')) return AppImages.tipper;
    if (lowerTitle.contains('truck')) return AppImages.truckIcon;
    if (lowerTitle.contains('car')) return AppImages.car;
    if (lowerTitle.contains('bus')) return AppImages.bus;
    if (lowerTitle.contains('trailer')) return AppImages.trailer;
    if (lowerTitle.contains('crane')) return AppImages.crane;
    if (lowerTitle.contains('mixer')) return AppImages.selfLoadingConcreteMixer;
    if (lowerTitle.contains('crusher') || lowerTitle.contains('crushing'))
      return AppImages.crushing;
    if (lowerTitle.contains('loader')) return AppImages.wheelLoader;
    if (lowerTitle.contains('roller')) return AppImages.rollers;
    if (lowerTitle.contains('grader')) return AppImages.motorGrader;
    if (lowerTitle.contains('generator') || lowerTitle.contains('gen'))
      return AppImages.generator;
    if (lowerTitle.contains('scrap')) return AppImages.scrap;
    if (lowerTitle.contains('tractor') || lowerTitle.contains('farm'))
      return AppImages.tractor;
    if (lowerTitle.contains('transit')) return AppImages.transitMixture;
    if (lowerTitle.contains('lcv')) return AppImages.lcv;
    if (lowerTitle.contains('icv')) return AppImages.icv;

    // Default icon if no match found
    return AppImages.otherMachines;
  }

  /// Handle buy item card tap - fetch buy vehicles for selected category
  Future<void> onBuyItemTap(Map<String, dynamic> item) async {
    try {
      // Debug: Print current state
      debugCategoriesState();
      clearFilters();

      // Get category name from item
      final categoryName = item['title'] as String?;

      if (categoryName == null || categoryName.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid category selected',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Try to get category object directly from item first
      VehicleCategory? category = item['categoryObject'] as VehicleCategory?;

      // If not found, try to get category code from item
      if (category == null) {
        final categoryCode = item['categoryCode'] as String?;
        if (categoryCode != null) {
          category = getCategoryByCode(categoryCode);
        }
      }

      // If still not found, try to find by name
      if (category == null) {
        category = getCategoryByName(categoryName);
      }

      if (category != null) {
        final selectedCategory = category; // Create a non-null local variable

        // Only clear filters if switching to a different category
        // This ensures applied filters are maintained when refreshing the same category
        if (buyVehiclesList.isNotEmpty) {
          // Check if we're switching to a different category by looking at current data
          // If we have existing data, we should clear filters for a fresh start
          clearFilters();
          debugPrint(
            '🧹 Cleared filters - switching to new category: ${selectedCategory.categoryName}',
          );
        }

        // Set loading state to true immediately to show shimmer
        isLoadingBuyVehiclesList.value = true;

        // Clear previous data
        buyVehiclesList.clear();

        // Navigate to buy vehicles listing page immediately (shimmer will show)
        Get.to(
          () => BuyVehiclesListView(
            categoryName: selectedCategory.categoryName,
            categoryCode: selectedCategory.categoryCode,
          ),
        );

        // Call fetchBuyVehiclesByCategory API with the category code
        await fetchBuyVehiclesByCategory(
          categoryCode: selectedCategory.categoryCode,
        );
      } else {
        // Handle case where category is not found
        Get.snackbar(
          'Error',
          'Category not found for $categoryName. Please refresh and try again.',
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Handle any errors during the API call
      isLoadingBuyVehiclesList.value = false; // Stop loading on error
      Get.snackbar(
        'Error',
        'Failed to load vehicles: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Debug method to print current categories state
  void debugCategoriesState() {}

  // ========== STATE MANAGEMENT METHODS ==========

  /// Load states using AuthController
  Future<void> _loadStates() async {
    try {
      await _authController.loadStates();
    } catch (e) {}
  }

  /// Load states if needed for sell form
  Future<void> loadStatesIfNeeded() async {
    try {
      if (states.isEmpty) {
        await _authController.loadStates();
      }
    } catch (e) {}
  }

  /// Select a state for sell form
  void selectState(StateItem? state) {
    try {
      if (state != null) {
        _authController.selectState(state);
      }
    } catch (e) {}
  }

  /// Check if states are loading
  bool get isLoadingStates {
    try {
      return _authController.isLoadingStates.value;
    } catch (e) {
      return false;
    }
  }

  /// Get cities from auth controller
  List<CityItem> get cities {
    try {
      return _authController.cities;
    } catch (e) {
      return [];
    }
  }

  /// Check if cities are loading
  bool get isLoadingCities {
    try {
      return _authController.isLoadingCities.value;
    } catch (e) {
      return false;
    }
  }

  /// Select city for sell form
  void selectCityForSell(CityItem city) {
    try {
      _authController.selectCity(city);
      _updateFormValidation(); // Update form validation when city changes
    } catch (e) {}
  }

  /// Select state for sell form
  void selectStateForSell(StateItem state) {
    try {
      _authController.selectState(state);
      _updateFormValidation(); // Update form validation when state changes
    } catch (e) {}
  }

  /// Load cities for sell form
  Future<void> loadCitiesForSell(String stateId) async {
    try {
      await _authController.loadCities(stateId);
    } catch (e) {}
  }

  /// Clear state selection for sell form
  void clearStateForSell() {
    try {
      _authController.selectedState.value = null;
      locationFormController.clear();
      // Clear city as well when state is cleared
      clearCityForSell();
      _updateFormValidation();
    } catch (e) {}
  }

  /// Clear city selection for sell form
  void clearCityForSell() {
    try {
      _authController.selectedCity.value = null;
      cityController.clear();
      _updateFormValidation();
    } catch (e) {}
  }

  /// Clear brand selection for sell form
  void clearBrandForSell() {
    try {
      _selectedBrand.value = null;
      brandController.clear();
      _updateFormValidation();
    } catch (e) {}
  }

  /// Clear number of tyres selection for sell form
  void clearTyresForSell() {
    try {
      _selectedTire.value = null;
      numberOfTyresController.clear();
      _updateFormValidation();
    } catch (e) {}
  }

  // ========== VEHICLE CATEGORY METHODS ==========

  /// Fetch vehicle categories from API
  Future<void> fetchCategories({String status = 'active'}) async {
    try {
      print('DEBUG: Entered fetchCategories');
      _isCategoryLoading.value = true;
      _categoryError.value = '';

      final startTime = DateTime.now();

      // Get user ID from storage
      final userId = await _storageService.getUserId() ?? '';

      // Create request
      final request = VehicleCategoryRequest(status: status, userId: userId);

      final response = await _apiRepository.getVehicleCategories(request);
      print(
        'API response received for vehicle categories. ${response.toJson()}',
      );
      print('Fetched ${response.categories.length} categories from API.');

      _categories.value = response.categories;
      print(
        'Vehicle categories updated in controller state. ${_categories.length} categories available.',
      );
      final endTime = DateTime.now();
      print(
        '🕒 Categories loaded in ${endTime.difference(startTime).inMilliseconds}ms',
      );
    } catch (e, stackTrace) {
      print('❌ ERROR in fetchCategories: $e');
      print('❌ STACKTRACE: $stackTrace');
      _categoryError.value =
          'Failed to fetch vehicle categories: ${e.toString()}';

      // Log the full error for debugging
      debugPrint('Full error details: $e\nStacktrace: $stackTrace');

      // Show user-friendly error message
      // Get.snackbar(
      //   'Error',
      //   'Failed to load vehicle categories. Please try again.',

      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      // );
    } finally {
      _isCategoryLoading.value = false;
    }
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  /// Fetch dynamic filter options for a specific category
  Future<void> fetchCategoryFilters({required String categoryCode}) async {
    try {
      isLoadingCategoryFilters.value = true;
      categoryFiltersError.value = '';

      debugPrint('🔍 Fetching category filters for: $categoryCode');

      // Call the API endpoint
      final response = await _apiRepository.getCategoryFilters(categoryCode);

      debugPrint('🔍 API: Category filters response data: $response');
      debugPrint('🔍 API: Response type: ${response.runtimeType}');
      debugPrint('🔍 API: Response keys: ${response?.keys}');

      if (response != null) {
        // The response is already the filter_options Map<String, dynamic>
        // where each key is a filter name and value is the filter configuration
        final filterOptionsMap = response;

        debugPrint(
          '🔍 Processing filter options map with ${filterOptionsMap.length} filters',
        );

        // Store the complete filter configurations
        categoryFilterConfigurations.value = filterOptionsMap;

        // Convert the map keys to a list of filter names
        final filterNames = filterOptionsMap.keys.toList();
        categoryFilterOptions.value = filterNames;

        debugPrint('🔍 Extracted filter options: $filterNames');

        if (filterNames.isNotEmpty) {
          // Initialize controllers for each filter option
          _initializeDynamicFilterControllers();

          // Populate label-to-value mappings for filters with options
          _populateDynamicFilterMappings();

          debugPrint(
            '✅ Category filters loaded: ${categoryFilterOptions.length} options',
          );
          categoryFilterOptions.forEach((option) => debugPrint('   - $option'));

          // Load required data for specific filters
          _loadFilterData(categoryCode);
        } else {
          categoryFilterOptions.clear();
          categoryFilterConfigurations.clear();
          debugPrint('⚠️ No filter options found in response map');
        }
      } else {
        categoryFilterOptions.clear();
        categoryFilterConfigurations.clear();
        debugPrint('⚠️ Null response received for category filters');
      }
    } catch (e) {
      debugPrint('❌ Error fetching category filters: $e');
      categoryFiltersError.value = 'Failed to load filter options';
      categoryFilterOptions.clear();
      categoryFilterConfigurations.clear();

      Get.snackbar(
        'Error',
        'Failed to load filter options. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCategoryFilters.value = false;
    }
  }

  /// Get filter configuration for a specific filter name
  Map<String, dynamic>? getFilterConfiguration(String filterName) {
    return categoryFilterConfigurations[filterName] as Map<String, dynamic>?;
  }

  /// Get options for a specific filter (for dropdowns with static options)
  List<Map<String, dynamic>>? getFilterOptions(String filterName) {
    final config = getFilterConfiguration(filterName);
    if (config != null && config.containsKey('options')) {
      return List<Map<String, dynamic>>.from(config['options'] as List);
    }
    return null;
  }

  /// Load required data for specific filters
  void _loadFilterData(String categoryCode) {
    if (categoryCode.isEmpty) return;

    final filterOptionsList = categoryFilterOptions
        .map((option) => option.toLowerCase())
        .toList();

    // Load brands if Brand filter is available
    if (filterOptionsList.contains('brand')) {
      debugPrint(
        '🔍 Loading brands for Brand filter (category: $categoryCode)...',
      );
      fetchBrands(categoryCode: categoryCode);
    }

    // Load states if State filter is available
    if (filterOptionsList.contains('state')) {
      debugPrint('🔍 Loading states for State filter...');
      loadStatesIfNeeded();
    }

    // Load tires if Tyres filter is available
    if (filterOptionsList.contains('tyres')) {
      debugPrint(
        '🔍 Loading tires for Tyres filter (category: $categoryCode)...',
      );
      fetchTires(tyreCategory: categoryCode);
    }

    // Load machine categories if Machine Category filter is available
    if (filterOptionsList.contains('machine category')) {
      debugPrint('🔍 Machine Category filter detected');
      // Note: Machine categories might need a specific API call if available
    }

    // Load tonnage options if Tonnage filter is available
    if (filterOptionsList.contains('tonnage')) {
      debugPrint('🔍 Tonnage filter detected');
      // Note: Tonnage options might need a specific API call if available
    }
  }

  /// Initialize text controllers for dynamic filter options
  void _initializeDynamicFilterControllers() {
    // Clear existing controllers
    for (var controller in dynamicFilterControllers.values) {
      controller.dispose();
    }
    dynamicFilterControllers.clear();

    // Create new controllers for each filter option
    for (String filterOption in categoryFilterOptions) {
      dynamicFilterControllers[filterOption] = TextEditingController();
    }
  }

  /// Populate label-to-value mappings for dynamic filters with options
  void _populateDynamicFilterMappings() {
    dynamicFilterValueMappings.clear();

    for (String filterOption in categoryFilterOptions) {
      final config = getFilterConfiguration(filterOption);
      if (config != null && config.containsKey('options')) {
        final options = List<Map<String, dynamic>>.from(
          config['options'] as List,
        );
        final Map<String, String> labelToValueMap = {};

        for (var option in options) {
          final label = option['label'] as String;
          final value = option['value'] as String;
          labelToValueMap[label] = value;
        }

        if (labelToValueMap.isNotEmpty) {
          setDynamicFilterMapping(filterOption, labelToValueMap);
          debugPrint('🗺️ Created mapping for $filterOption: $labelToValueMap');
        }
      }
    }
  }

  /// Get controller for a dynamic filter option
  TextEditingController? getDynamicFilterController(String filterOption) {
    return dynamicFilterControllers[filterOption];
  }

  /// Get the API value for a displayed label in dynamic filters
  String? getDynamicFilterValue(String filterOption, String displayLabel) {
    final mappings = dynamicFilterValueMappings[filterOption];
    return mappings?[displayLabel];
  }

  /// Set label-to-value mapping for a dynamic filter
  void setDynamicFilterMapping(
    String filterOption,
    Map<String, String> labelToValueMap,
  ) {
    dynamicFilterValueMappings[filterOption] = labelToValueMap;
  }

  /// Get the API value for what's currently displayed in the filter controller
  String? getCurrentFilterApiValue(String filterOption) {
    final controller = getDynamicFilterController(filterOption);
    if (controller == null || controller.text.trim().isEmpty) return null;

    final displayedText = controller.text.trim();
    return getDynamicFilterValue(filterOption, displayedText) ?? displayedText;
  }

  /// Clear all dynamic filters
  void clearDynamicFilters() {
    for (var controller in dynamicFilterControllers.values) {
      controller.clear();
    }
  }

  /// Simple setter methods for selected filter codes
  void setSelectedBrandCode(String code) {
    selectedBrandCode.value = code;
  }

  void setSelectedStateId(String id) {
    selectedStateId.value = id;
  }

  void setSelectedTyreCode(String code) {
    selectedTyreCode.value = code;
  }

  void setSelectedFuelType(String fuelType) {
    selectedFuelType.value = fuelType;
  }

  void setSelectedBodyType(String bodyType) {
    selectedBodyType.value = bodyType;
  }

  void setSelectedKV(String kv) {
    selectedKV.value = kv;
  }

  void setSelectedTonnage(String tonnage) {
    selectedTonnage.value = tonnage;
  }

  /// Fetch form fields for a specific category
  Future<void> fetchFormFields({required String categoryCode}) async {
    try {
      print(
        '🔄 [fetchFormFields] Starting FRESH API call for category: $categoryCode',
      );
      print(
        '🧹 [fetchFormFields] This will clear existing form data and load new fields',
      );

      // Check if user is authenticated
      if (!_storageService.isLoggedIn) {
        print(
          '⚠️ [fetchFormFields] User not authenticated, skipping form fields fetch',
        );
        _formFieldsError.value = 'Please log in to access form fields';
        return;
      }

      _isFormFieldsLoading.value = true;
      _formFieldsError.value = '';

      // Get user ID from storage
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      print(
        '📡 [fetchFormFields] Making API call with userId: $userId, categoryCode: $categoryCode',
      );
      final request = form_models.FormFieldRequest(
        categoryCode: categoryCode,
        userId: userId,
      );
      final response = await _apiRepository.getVehicleCategoryFormFields(
        request,
      );

      _currentFormFields.value = response;
      print(
        '📋 [fetchFormFields] Received ${response.formFields.length} fresh form fields from API',
      );

      // Store category before clearing, then restore it
      final categoryValue = _dynamicFormValues['Category'];
      _clearDynamicFormData(); // Clear previous form data

      // Restore category if it existed
      if (categoryValue != null) {
        _dynamicFormValues['Category'] = categoryValue;
        print(
          '🔄 Restored category value after form fields load: $categoryValue',
        );
      }

      _initializeFileFields(); // Initialize file fields with empty lists

      // Initialize Price field if it exists in the form fields
      if (_currentFormFields.value!.formFields.containsKey('Price')) {
        // Initialize Price field with empty string if not already set
        if (!_dynamicFormValues.containsKey('Price') ||
            _dynamicFormValues['Price'] == null) {
          _dynamicFormValues['Price'] = '';
          print('💰 Initialized Price field with empty value for validation');
        }
      }

      // Load tires for this category to ensure they're available for form submission
      print('🔄 [fetchFormFields] Loading tires for category: $categoryCode');
      fetchTires(tyreCategory: categoryCode);

      // Trigger validation after everything is set up
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFormValidation();
        print('🔄 Triggered validation after form fields loaded');
      });

      print(
        '✅ [fetchFormFields] Successfully loaded ${response.formFields.length} form fields',
      );
    } catch (e, stackTrace) {
      print('❌ ERROR in fetchFormFields: $e');
      print('❌ STACKTRACE: $stackTrace');

      // Handle different types of errors
      if (e.toString().contains('401') ||
          e.toString().contains('Authentication')) {
        _formFieldsError.value = 'Please log in to access this feature';

        // Show user-friendly error message
        Get.snackbar(
          'Authentication Required',
          'Please log in to access vehicle form fields',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        _formFieldsError.value = 'Failed to fetch form fields: ${e.toString()}';

        // Show user-friendly error message
        Get.snackbar(
          'Error',
          'Failed to load form fields. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      _isFormFieldsLoading.value = false;
    }
  }

  /// Clear dynamic form data
  void _clearDynamicFormData() {
    _dynamicFormValues.clear();
    _dynamicFormErrors.clear();
  }

  /// Clear all sell form data (public method)
  void clearSellFormData() {
    print('🧹 Clearing all sell form data...');

    // Reset initialization flag to allow fresh clearing
    _hasInitializedSellForm = false;

    // Clear dynamic form data
    _clearDynamicFormData();

    // Clear static controllers
    productNameController.clear();
    descriptionController.clear();
    registrationNumberController.clear();
    brandController.clear();
    tyreController.clear();
    chasisNumberController.clear();
    locationFormController.clear();
    ownerMobileNumberController.clear();
    assetsDescriptionController.clear();
    yearOfManufactureController.clear();
    odometerController.clear();
    cityController.clear();
    categoryController.clear();
    stateController.clear();
    hoursController.clear();
    tonnageController.clear();
    bodyTypeController.clear();
    bodyLengthController.clear();
    fuelTypeController.clear();
    fitnessController.clear();
    originalInvoiceController.clear();
    vehicleInsuranceController.clear();
    gstApplicabilityController.clear();
    kvController.clear();

    // Clear "Other" field controllers
    otherBrandController.clear();
    otherTipperController.clear();
    otherBodyTypeController.clear();
    otherTyreController.clear();

    // Reset "Other" selection flags
    isOtherBrandSelected.value = false;
    isOtherTipperSelected.value = false;
    isOtherBodyTypeSelected.value = false;
    isOtherTyreSelected.value = false;

    // Clear dynamic controllers
    _dynamicFormControllers.values.forEach((controller) => controller.clear());
    _dynamicFormControllers.clear();

    // Clear selected files
    vehicleSelectedFiles.clear();
    vehicleInsuranceFiles.clear();
    vehicleRCFiles.clear();

    // Clear error states
    categoryErrorKey.value = '';
    registrationNumberErrorKey.value = '';
    stateErrorKey.value = '';
    brandErrorKey.value = '';
    numberOfTyresErrorKey.value = '';
    chassisNumberErrorKey.value = '';
    locationErrorKey.value = '';
    ownerMobileErrorKey.value = '';
    assetsDescriptionErrorKey.value = '';
    yearOfManufactureErrorKey.value = '';
    odometerErrorKey.value = '';
    cityErrorKey.value = '';
    vehicleImagesErrorKey.value = '';

    // Clear selected values
    selectedCategoryName.value = '';
    _selectedBrand.value = null;
    _authController.selectedState.value = null;

    // Clear auth controller city selection
    _authController.selectedCity.value = null;

    // Reset form validation state
    isSellFormValid.value = false;

    print('✅ All sell form data cleared successfully');
  }

  /// Clear sell form data if needed (intelligent clearing)
  void clearSellFormDataIfNeeded() {
    // Only clear if this is the first time or if explicitly requested
    if (_hasInitializedSellForm) {
      print('⏭️ Sell form already initialized, skipping clear');
      return;
    }

    // Only clear form data, keep category prefilled if it exists
    print('🧹 Clearing sell form data while preserving category...');
    print('🧹 Current form values count: ${_dynamicFormValues.length}');

    // Store the current category before clearing
    final currentCategory = selectedCategoryName.value;
    final currentCategoryInDynamic = _dynamicFormValues['Category'];
    final isCategoryCurrentlyLocked = isCategoryLocked.value;

    // Clear all form data except category
    _clearFormDataExceptCategory();

    // If no category was selected before, ensure category field is unlocked and empty
    if (currentCategory.isEmpty) {
      selectedCategoryName.value = '';
      isCategoryLocked.value = false;
      categoryController.clear();
      _dynamicFormValues.remove('Category');
      categoryErrorKey.value = '';
    } else {
      // Restore category state
      selectedCategoryName.value = currentCategory;
      isCategoryLocked.value = isCategoryCurrentlyLocked;
      categoryController.text = currentCategory;
      if (currentCategoryInDynamic != null) {
        _dynamicFormValues['Category'] = currentCategoryInDynamic;
      }
    }

    // Mark as initialized to prevent future clearing
    _hasInitializedSellForm = true;
    print('✅ Form cleared with category preserved: "$currentCategory"');
  }

  /// Force clear the sell form (for navigation or explicit reset)
  void forceClearSellForm() {
    print('🧹 Force clearing sell form...');
    _hasInitializedSellForm = false;
    clearSellFormDataIfNeeded();
  }

  /// Get the prefilled category name for the sell form
  String getPrefilledCategory() {
    return selectedCategoryName.value;
  }

  /// Reset form completely (including category) - for complete fresh start
  void resetSellFormCompletely() {
    print('🔄 Completely resetting sell form including category...');
    clearSellFormData(); // This clears everything including category

    // Ensure category is unlocked for fresh selection
    isCategoryLocked.value = false;
    selectedCategoryName.value = '';
    categoryController.clear();
    _dynamicFormValues.remove('Category');
    categoryErrorKey.value = '';

    print('✅ Sell form completely reset - ready for fresh start');
  }

  // Helper methods for converting dynamic form values to API request format

  /// Get dynamic form value as string
  String _getDynamicFormValueAsString(String fieldName) {
    final value = _dynamicFormValues[fieldName];
    if (value == null) return '';
    return value.toString().trim();
  }

  /// Get dynamic form value as int
  int? _getDynamicFormValueAsInt(String fieldName) {
    final value = _getDynamicFormValueAsString(fieldName);
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Get dynamic form value as bool
  bool _getDynamicFormValueAsBool(String fieldName) {
    final value = _dynamicFormValues[fieldName];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value.toLowerCase() == 'yes';
    }
    return false;
  }

  /// Get dynamic form value as list of PlatformFile
  List<PlatformFile> _getDynamicFormValueAsFileList(String fieldName) {
    final value = _dynamicFormValues[fieldName];
    if (value is List<PlatformFile>) return value;
    if (value is List) {
      try {
        return value.cast<PlatformFile>();
      } catch (e) {
        print('⚠️ Error casting file list for $fieldName: $e');
        return [];
      }
    }
    return [];
  }

  /// Get brand code from dynamic form
  String _getBrandCodeFromDynamicForm() {
    final brandName = _getDynamicFormValueAsString('Brand');
    if (brandName.isEmpty) return '';

    debugPrint('🏷️ Looking for brand code for: "$brandName"');

    // Find the brand code from loaded brands (including for "Other" or "Others")
    final brand = _brands.firstWhereOrNull((b) => b.brandName == brandName);
    final brandCode = brand?.brandCode ?? '';

    debugPrint('🏷️ Brand "$brandName" -> Code "$brandCode"');
    if (brandName.toLowerCase() == 'others' ||
        brandName.toLowerCase() == 'other') {
      debugPrint(
        '🏷️ Others option selected - using API code: $brandCode, custom text will be in other_brand field',
      );
    }

    return brandCode;
  }

  /// Get state code from dynamic form
  String _getStateCodeFromDynamicForm() {
    final stateName = _getDynamicFormValueAsString('State');
    if (stateName.isEmpty) return '';

    // Try to find state code from loaded states
    final state = states.firstWhereOrNull((s) => s.stateName == stateName);
    return state?.stateId ?? '';
  }

  /// Get city code from dynamic form
  String _getCityCodeFromDynamicForm() {
    final cityName = _getDynamicFormValueAsString('City');
    if (cityName.isEmpty) return '';

    // Try to find city code from loaded cities
    final city = cities.firstWhereOrNull((c) => c.cityName == cityName);
    return city?.cityId ?? '';
  }

  /// Get tyre code from dynamic form
  String _getTyreCodeFromDynamicForm() {
    final tyreDisplayName = _getDynamicFormValueAsString('Tyre');
    if (tyreDisplayName.isEmpty) return '';

    debugPrint('🔍 Looking for tyre code for display name: "$tyreDisplayName"');
    debugPrint('🔍 Available tires count: ${_tires.length}');

    // Debug: Print all available tires
    for (int i = 0; i < _tires.length; i++) {
      debugPrint(
        '  Loaded tire $i: code="${_tires[i].tyreCode}", display="${_tires[i].tyreDisplayName}"',
      );
    }

    // Find the tyre code from loaded tires (including for "Other" or "Others")
    final tire = _tires.firstWhereOrNull(
      (t) => t.tyreDisplayName == tyreDisplayName,
    );
    if (tire != null) {
      debugPrint('✅ Found matching tire: ${tire.tyreCode}');
      debugPrint('🚛 Final tyre code being sent to API: "${tire.tyreCode}"');
      return tire.tyreCode;
    }

    debugPrint('⚠️ No matching tire found for: $tyreDisplayName');
    // Return empty string if no match found
    return '';
  }

  /// Get body type from dynamic form, handling "Other" selection
  String _getBodyTypeFromDynamicForm() {
    final bodyType = _getDynamicFormValueAsString('Body Type');
    if (bodyType.isEmpty) return '';

    // Return the selected body type as-is (including "Others" if selected from dropdown)
    return bodyType;
  }

  /// Get price value from dynamic form fields
  double _getPriceValue() {
    // Get price from dynamic form values (from API)
    final dynamicPrice = _getDynamicFormValueAsString('Price');
    if (dynamicPrice.isNotEmpty) {
      final price = double.tryParse(dynamicPrice);
      if (price != null && price > 0) {
        debugPrint('💰 Using dynamic price from API: $price');
        return price;
      }
    }

    debugPrint('⚠️ No valid price found, defaulting to 0.0');
    return 0.0;
  }

  /// Get insurance status from standard boolean controller
  bool _getInsuranceStatus() {
    debugPrint(
      '🔧 Insurance status: ${hasInsurance.value} (from standard controller)',
    );
    return hasInsurance.value ?? false; // Default to false if not selected
  }

  /// Clear form data except category (when category changes)
  void _clearFormDataExceptCategory() {
    // Don't clear if we're processing files
    if (isProcessingFiles) {
      print('🚫 Skipping form clear - file processing in progress');
      return;
    }

    print('🧹 Clearing form data except category...');
    print('🧹 Current form values: ${_dynamicFormValues.keys.toList()}');

    // Store the current category values
    final currentCategory = selectedCategoryName.value;
    final currentCategoryInDynamic = _dynamicFormValues['Category'];
    final isCategoryCurrentlyLocked = isCategoryLocked.value;
    final currentCategoryError = categoryErrorKey.value;

    // Clear all dynamic form data
    _dynamicFormValues.clear();
    _dynamicFormErrors.clear();

    // Clear standard controllers
    hasInsurance.value = null;

    // Clear static controllers (except category)
    productNameController.clear();
    descriptionController.clear();
    registrationNumberController.clear();
    brandController.clear();
    tyreController.clear();
    chasisNumberController.clear();
    locationFormController.clear();
    ownerMobileNumberController.clear();
    assetsDescriptionController.clear();
    yearOfManufactureController.clear();
    selectedYear.value = ''; // Clear selected year for consistency
    odometerController.clear();
    cityController.clear();
    stateController.clear();
    hoursController.clear();
    tonnageController.clear();
    bodyTypeController.clear();
    bodyLengthController.clear();
    fuelTypeController.clear();
    fitnessController.clear();
    originalInvoiceController.clear();
    vehicleInsuranceController.clear();
    gstApplicabilityController.clear();
    kvController.clear();

    // Clear "Other" field controllers
    otherBrandController.clear();
    otherTipperController.clear();
    otherBodyTypeController.clear();
    otherTyreController.clear();

    // Reset "Other" selection flags
    isOtherBrandSelected.value = false;
    isOtherTipperSelected.value = false;
    isOtherBodyTypeSelected.value = false;
    isOtherTyreSelected.value = false;

    // Clear dynamic controllers (but keep category controller text)
    _dynamicFormControllers.forEach((fieldName, controller) {
      if (fieldName.toLowerCase() != 'category') {
        controller.clear();
      }
    });
    // Remove all dynamic controllers except category
    _dynamicFormControllers.removeWhere(
      (fieldName, controller) => fieldName.toLowerCase() != 'category',
    );

    // Clear selected files
    vehicleSelectedFiles.clear();
    vehicleInsuranceFiles.clear();
    vehicleRCFiles.clear();

    // Clear error states (except category)
    registrationNumberErrorKey.value = '';
    stateErrorKey.value = '';
    brandErrorKey.value = '';
    numberOfTyresErrorKey.value = '';
    chassisNumberErrorKey.value = '';
    locationErrorKey.value = '';
    ownerMobileErrorKey.value = '';
    assetsDescriptionErrorKey.value = '';
    yearOfManufactureErrorKey.value = '';
    odometerErrorKey.value = '';
    cityErrorKey.value = '';
    vehicleImagesErrorKey.value = '';

    // Clear selected values (except category)
    _selectedBrand.value = null;
    _authController.selectedState.value = null;
    _authController.selectedCity.value = null;

    // Reset form validation state
    isSellFormValid.value = false;

    // Restore category values only if they were set
    if (currentCategory.isNotEmpty) {
      selectedCategoryName.value = currentCategory;
      categoryController.text = currentCategory;
      isCategoryLocked.value = isCategoryCurrentlyLocked;
      categoryErrorKey.value = currentCategoryError;
      if (currentCategoryInDynamic != null) {
        _dynamicFormValues['Category'] = currentCategoryInDynamic;
      }
    }

    print('✅ Form data cleared except category: "$currentCategory"');
  }

  /// Initialize file fields with empty lists
  void _initializeFileFields() {
    final formFields = _currentFormFields.value?.formFields;
    if (formFields != null) {
      for (final entry in formFields.entries) {
        final fieldName = entry.key;
        final formField = entry.value;

        // Initialize file fields with empty lists
        if (formField.type == 'file') {
          _dynamicFormValues[fieldName] = <PlatformFile>[];
          print('📁 Initialized file field: $fieldName');
        }
      }

      // Update form validation after initializing fields
      _updateFormValidation();
    }
  }

  /// Set value for a dynamic form field
  void setDynamicFormValue(String fieldName, dynamic value) {
    print(
      '📝 Setting dynamic form value: $fieldName = $value (${value.runtimeType})',
    );

    // Special debugging for year fields
    if (fieldName.toLowerCase().contains('year') ||
        fieldName.toLowerCase().contains('manufacture')) {
      print('📅 YEAR FIELD DEBUG: Setting $fieldName to $value');
      print(
        '📅 Current dynamic form values before update: ${_dynamicFormValues.length} fields',
      );
      _dynamicFormValues.forEach((key, val) {
        if (key.toLowerCase().contains('price') ||
            key.toLowerCase().contains('registration') ||
            key.toLowerCase().contains('year')) {
          print('📅   Important field: $key = $val');
        }
      });
    }

    // Skip if we're in the middle of updating controllers to prevent clearing
    if (isUpdatingController) {
      print('⏳ Updating controller in progress, setting value directly');
      _dynamicFormValues[fieldName] = value;
      _dynamicFormErrors.remove(fieldName);
      return;
    }

    _dynamicFormValues[fieldName] = value;
    // Clear error when user starts typing/selecting
    _dynamicFormErrors.remove(fieldName);

    // Update controller text if controller exists
    _updateControllerText(fieldName, value);

    // Handle state selection - load cities when state is selected
    bool shouldUpdateValidation = true;
    if (fieldName.toLowerCase() == 'state' &&
        value != null &&
        value.toString().isNotEmpty) {
      print('🏛️ State selected: $value, loading cities...');
      // Find the state ID from the selected state name
      try {
        final selectedStateItem = states
            .where((state) => state.stateName == value.toString())
            .firstOrNull;
        if (selectedStateItem != null) {
          print(
            '🏙️ Loading cities for state ID: ${selectedStateItem.stateId}',
          );
          loadCitiesForSell(selectedStateItem.stateId.toString());
          // Only clear city if it's different from current selection
          final currentCity = _dynamicFormValues['City'];
          if (currentCity != null) {
            print('🏙️ Clearing city value due to state change');
            _dynamicFormValues['City'] = null;
            _dynamicFormErrors.remove('City');
          }
          // Mark that we'll update validation after all state changes
          shouldUpdateValidation = true;
        }
      } catch (e) {
        print('❌ Error finding state: $e');
      }
    }

    // Update form validation state only once
    if (shouldUpdateValidation) {
      _updateFormValidation();
    }

    print(
      '✅ Dynamic form value set: $fieldName = ${_dynamicFormValues[fieldName]}',
    );
  }

  /// Get or create a TextEditingController for a dynamic form field
  TextEditingController getDynamicFormController(String fieldName) {
    // For dynamic forms, always use dedicated controllers to avoid disposal conflicts
    // This prevents "TextEditingController was used after being disposed" errors

    if (!_dynamicFormControllers.containsKey(fieldName)) {
      _dynamicFormControllers[fieldName] = TextEditingController();

      // Initialize with existing value if any
      final existingValue = getDynamicFormValue(fieldName);
      if (existingValue != null) {
        _dynamicFormControllers[fieldName]!.text = existingValue.toString();
      }

      // Add listener to sync with dynamic form values (with debouncing)
      _dynamicFormControllers[fieldName]!.addListener(() {
        // Prevent circular updates
        if (isUpdatingController || _isValidatingForm) {
          return;
        }

        final currentText = _dynamicFormControllers[fieldName]!.text;
        final currentValue = getDynamicFormValue(fieldName);

        // Only update if values are actually different
        if (currentValue != currentText) {
          print(
            '🔄 Dynamic controller listener triggered for $fieldName: "$currentText"',
          );
          setDynamicFormValue(
            fieldName,
            currentText.isEmpty ? null : currentText,
          );
        }
      });
    }

    return _dynamicFormControllers[fieldName]!;
  }

  // Flags to prevent circular updates and unwanted clearing
  bool _isValidatingForm = false;
  bool isUpdatingController = false; // Made public for widget access
  bool isProcessingFiles = false;
  bool _hasInitializedSellForm =
      false; // Track if sell form has been initialized

  /// Update controller text when form value changes externally
  void _updateControllerText(String fieldName, dynamic value) {
    // Skip file fields as they don't use TextEditingController
    final isFile = _isFileField(fieldName);
    if (value is List<PlatformFile> || isFile) {
      if (isFile) {
        print('📎 Skipping controller update for file field: $fieldName');
      }
      return;
    }

    // Prevent circular updates
    if (isUpdatingController) {
      return;
    }

    final controller = getDynamicFormController(fieldName);
    final newText = value?.toString() ?? '';

    // Only update if the text is actually different to prevent loops
    if (controller.text != newText) {
      print(
        '🔄 Updating controller text for $fieldName: "${controller.text}" -> "$newText"',
      );

      isUpdatingController = true;
      try {
        controller.text = newText;
        // Move cursor to end
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        print('✅ Controller text updated for $fieldName');
      } finally {
        isUpdatingController = false;
      }
    } else {
      print('ℹ️ Controller text already matches for $fieldName: "$newText"');
    }
  }

  /// Check if a field is a file type field
  bool _isFileField(String fieldName) {
    final lowerFieldName = fieldName.toLowerCase();

    // Check actual form field type first if available
    if (_currentFormFields.value != null) {
      final fieldConfig = _currentFormFields.value!.formFields[fieldName];
      if (fieldConfig != null && fieldConfig.type == 'file') {
        print('📎 $fieldName detected as file field (type=file from API)');
        return true;
      }
    }

    // Fallback to name-based detection, but be more specific
    // Use exact matches or "upload/file" combinations to avoid false positives
    final isFileByName =
        lowerFieldName == 'vehicle images' ||
        lowerFieldName == 'upload vehicle rc' ||
        lowerFieldName == 'insurance upload' ||
        lowerFieldName == 'gst certificate' ||
        (lowerFieldName.contains('upload') &&
            lowerFieldName.contains('file')) ||
        (lowerFieldName.contains('upload') &&
            lowerFieldName.contains('document')) ||
        (lowerFieldName.contains('upload') && lowerFieldName.contains('image'));

    if (isFileByName) {
      print('📎 $fieldName detected as file field (by name matching)');
    }

    return isFileByName;
  }

  /// Get value for a dynamic form field
  dynamic getDynamicFormValue(String fieldName) {
    return _dynamicFormValues[fieldName];
  }

  /// Set error for a dynamic form field
  void setDynamicFormError(String fieldName, String error) {
    _dynamicFormErrors[fieldName] = error;
    // Don't call _updateFormValidation here to avoid infinite loops
  }

  /// Get error for a dynamic form field
  String? getDynamicFormError(String fieldName) {
    return _dynamicFormErrors[fieldName];
  }

  /// Validate a dynamic form field
  bool validateDynamicField(
    String fieldName,
    form_models.FormField formField, {
    bool forSubmission = false,
  }) {
    final value = _dynamicFormValues[fieldName];

    print(
      '🔍 Validating field: $fieldName = $value (${value.runtimeType}) - mandatory: ${formField.mandatory}',
    );

    // Skip mandatory validation for document/upload fields
    if (_isFileField(fieldName)) {
      print('📄 Skipping validation for document field: $fieldName');
      return true;
    }

    // Check if mandatory field is empty
    if (formField.mandatory) {
      // Special handling for yes/no fields (boolean values)
      if (formField.type == 'yes_no') {
        if (value == null) {
          // Only show validation errors for yes/no fields during form submission
          // This prevents the red validation from showing by default on form load
          if (forSubmission) {
            setDynamicFormError(
              fieldName,
              'Please select Yes or No for $fieldName',
            );
            print(
              '❌ Field $fieldName failed validation - no yes/no selection made',
            );
          }
          return false;
        }
      } else if (value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty)) {
        setDynamicFormError(fieldName, '$fieldName is required');
        print('❌ Field $fieldName failed validation - empty mandatory field');
        return false;
      }
    }

    // Additional validations based on field type
    if (value != null && value is String && value.isNotEmpty) {
      switch (formField.type) {
        case 'number':
          if (double.tryParse(value) == null) {
            setDynamicFormError(fieldName, 'Please enter a valid number');
            print('❌ Field $fieldName failed validation - invalid number');
            return false;
          }
          break;
        case 'text':
          // Special validation for Price field
          if (fieldName.toLowerCase() == 'price') {
            if (double.tryParse(value) == null) {
              setDynamicFormError(fieldName, 'Please enter a valid price');
              print(
                '❌ Field $fieldName failed validation - invalid price format',
              );
              return false;
            }
            final priceValue = double.parse(value);
            if (priceValue <= 0) {
              setDynamicFormError(fieldName, 'Price must be greater than 0');
              print(
                '❌ Field $fieldName failed validation - price must be positive',
              );
              return false;
            }
          }
          // Mobile number validation
          else if (fieldName.toLowerCase().contains('mobile') &&
              value.length != 10) {
            setDynamicFormError(fieldName, 'Mobile number must be 10 digits');
            print(
              '❌ Field $fieldName failed validation - invalid mobile length',
            );
            return false;
          }
          break;
      }
    }

    // Clear error if validation passes
    _dynamicFormErrors.remove(fieldName);
    print('✅ Field $fieldName passed validation');
    return true;
  }

  /// Validate all dynamic form fields
  bool validateAllDynamicFields() {
    if (_currentFormFields.value == null) {
      print('⚠️ [validateAllDynamicFields] No form fields loaded');
      return true;
    }

    print('🔍 [validateAllDynamicFields] Starting validation...');
    bool isValid = true;

    _currentFormFields.value!.formFields.forEach((fieldName, formField) {
      print('🔍 Validating field: $fieldName');
      final currentValue = _dynamicFormValues[fieldName];
      print('   Current value: "$currentValue" (${currentValue.runtimeType})');

      if (!validateDynamicField(fieldName, formField, forSubmission: true)) {
        isValid = false;
        final error = _dynamicFormErrors[fieldName];
        print('   ❌ Validation failed: $error');
      } else {
        print('   ✅ Validation passed');
      }
    });

    print('🔍 [validateAllDynamicFields] Final result: $isValid');
    print('📋 Current errors: $_dynamicFormErrors');
    return isValid;
  }

  /// Validate all mandatory fields and show error messages
  bool validateAllMandatoryFields() {
    if (_currentFormFields.value == null) return true;

    bool allValid = true;

    // Validate all dynamic form fields
    _currentFormFields.value!.formFields.forEach((fieldName, formField) {
      if (!validateDynamicField(fieldName, formField, forSubmission: true)) {
        allValid = false;
      }
    });

    // Note: Insurance is now handled as a dynamic form field, no separate validation needed

    // Update form validation state
    _updateFormValidation();

    return allValid;
  }

  /// Manually trigger form validation (for debugging)
  void triggerFormValidation() {
    print('🔄 Manually triggering form validation...');
    _updateFormValidation();
  }

  /// Debug method to check form status
  void debugFormStatus() {
    print('🔍 === FORM DEBUG STATUS ===');
    print('🔍 isSellFormValid: ${isSellFormValid.value}');
    print('🔍 Form fields loaded: ${_currentFormFields.value != null}');
    if (_currentFormFields.value != null) {
      print(
        '🔍 Total form fields: ${_currentFormFields.value!.formFields.length}',
      );
      _currentFormFields.value!.formFields.forEach((name, field) {
        print(
          '🔍   - $name (mandatory: ${field.mandatory}, type: ${field.type})',
        );
      });
    }
    print('🔍 Dynamic form values (${_dynamicFormValues.length}):');
    _dynamicFormValues.forEach((key, value) {
      print('🔍   - $key: $value (${value.runtimeType})');
    });
    print('🔍 Dynamic form errors (${_dynamicFormErrors.length}):');
    _dynamicFormErrors.forEach((key, error) {
      print('🔍   - $key: $error');
    });
    print('🔍 === END DEBUG STATUS ===');
  }

  /// Get categories for autocomplete (returns list of strings)
  List<String> getCategoryNames() {
    return _categories.map((category) => category.categoryName).toList();
  }

  /// Get category by name
  VehicleCategory? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.categoryName == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get category by code
  VehicleCategory? getCategoryByCode(String code) {
    try {
      return _categories.firstWhere(
        (category) => category.categoryCode == code,
      );
    } catch (e) {
      return null;
    }
  }

  /// Filter categories by search term
  List<VehicleCategory> filterCategories(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _categories;
    }

    return _categories
        .where(
          (category) =>
              category.categoryName.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ||
              category.categoryCode.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ),
        )
        .toList();
  }

  /// Filter category names by search term (for autocomplete)
  List<String> filterCategoryNames(String searchTerm) {
    return filterCategories(
      searchTerm,
    ).map((category) => category.categoryName).toList();
  }

  /// Clear category error
  void clearCategoryError() {
    _categoryError.value = '';
  }

  // ========== VEHICLE BRAND METHODS ==========

  /// Fetch vehicle brands from API based on category
  Future<void> fetchBrands({
    required String categoryCode,
    String status = 'active',
  }) async {
    try {
      _isBrandLoading.value = true;
      _brandError.value = '';

      // Get user ID from storage
      final userId = await _storageService.getUserId() ?? '';

      // Create request
      final request = VehicleBrandRequest(
        categoryCode: categoryCode,
        status: status,
        userId: userId,
      );

      final response = await _apiRepository.getVehicleBrands(request);
      _brands.value = response.brands;
    } catch (e) {
      _brandError.value = e.toString();
    } finally {
      _isBrandLoading.value = false;
    }
  }

  /// Select a brand
  void selectBrand(VehicleBrand? brand) {
    _selectedBrand.value = brand;
    if (brand != null) {
      brandController.text = brand.brandName;
    }
    validateBrand(); // Validate brand when selection changes
  }

  /// Get brand names for autocomplete
  List<String> getBrandNames() {
    return _brands.map((brand) => brand.brandName).toList();
  }

  /// Get brand by name
  VehicleBrand? getBrandByName(String name) {
    try {
      return _brands.firstWhere((brand) => brand.brandName == name);
    } catch (e) {
      return null;
    }
  }

  /// Get state by name to resolve state ID
  StateItem? getStateByName(String name) {
    try {
      return states.firstWhere((state) => state.stateName == name);
    } catch (e) {
      return null;
    }
  }

  /// Filter brands by search term
  List<VehicleBrand> filterBrands(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _brands;
    }

    return _brands
        .where(
          (brand) =>
              brand.brandName.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ||
              brand.brandCode.toLowerCase().contains(searchTerm.toLowerCase()),
        )
        .toList();
  }

  /// Filter brand names by search term (for autocomplete)
  List<String> filterBrandNames(String searchTerm) {
    return filterBrands(searchTerm).map((brand) => brand.brandName).toList();
  }

  /// Clear brand error
  void clearBrandError() {
    _brandError.value = '';
  }

  // ========== VEHICLE TIRE METHODS ==========

  /// Fetch vehicle tires from API based on tire category
  Future<void> fetchTires({
    required String tyreCategory,
    String status = 'active',
  }) async {
    try {
      debugPrint(
        '🔄 [fetchTires] Starting tire fetch for category: $tyreCategory',
      );
      _isTireLoading.value = true;
      _tireError.value = '';

      // Get user ID from storage
      final userId = await _storageService.getUserId() ?? '';
      debugPrint('🔄 [fetchTires] User ID: $userId');

      // Create request
      final request = VehicleTireRequest(
        status: status,
        // tyreCategory: tyreCategory,
        tyreCategory: 'tipper',
        userId: userId,
      );

      debugPrint('🔄 [fetchTires] Making API request: ${request.toJson()}');

      final response = await _apiRepository.getVehicleTires(request);

      _tires.value = response.tyres;
      debugPrint(
        '✅ [fetchTires] Successfully loaded ${response.tyres.length} tires for category $tyreCategory',
      );

      // Debug: Print all loaded tires
      for (int i = 0; i < response.tyres.length; i++) {
        debugPrint(
          '  Loaded tire $i: code="${response.tyres[i].tyreCode}", display="${response.tyres[i].tyreDisplayName}"',
        );
      }

      // Clear any previous errors
      _tireError.value = '';
    } catch (e, stackTrace) {
      debugPrint('❌ [fetchTires] Error loading tires: $e');
      debugPrint('❌ [fetchTires] Stack trace: $stackTrace');
      debugPrint('❌ [fetchTires] Error type: ${e.runtimeType}');

      // Check if it's a network/API error vs parsing error
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('TimeoutException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (errorMessage.contains('FormatException') ||
          errorMessage.contains('type') &&
              errorMessage.contains('not a subtype')) {
        errorMessage = 'Data format error. Please try again.';
      }

      _tireError.value = errorMessage;

      // Show user-friendly error
      Get.snackbar(
        'Tire Loading Error',
        'Failed to load tire options for $tyreCategory: $errorMessage',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isTireLoading.value = false;
      debugPrint(
        '🔄 [fetchTires] Tire loading completed. Final tire count: ${_tires.length}',
      );
    }
  }

  /// Select a tire
  void selectTire(VehicleTire? tire) {
    _selectedTire.value = tire;
    if (tire != null) {
      numberOfTyresController.text = tire.tyreDisplayName;
    }
    validateNumberOfTyres(); // Validate tyres when selection changes
  }

  /// Get tire display names for autocomplete
  List<String> getTireNames() {
    return _tires.map((tire) => tire.tyreDisplayName).toList();
  }

  /// Get tire by display name
  VehicleTire? getTireByDisplayName(String displayName) {
    try {
      return _tires.firstWhere((tire) => tire.tyreDisplayName == displayName);
    } catch (e) {
      return null;
    }
  }

  /// Filter tires by search term
  List<VehicleTire> filterTires(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _tires;
    }

    return _tires
        .where(
          (tire) =>
              tire.tyreDisplayName.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ||
              tire.tyreCode.toLowerCase().contains(searchTerm.toLowerCase()),
        )
        .toList();
  }

  /// Filter tire display names by search term (for autocomplete)
  List<String> filterTireNames(String searchTerm) {
    return filterTires(searchTerm).map((tire) => tire.tyreDisplayName).toList();
  }

  /// Clear tire error
  void clearTireError() {
    _tireError.value = '';
  }

  // Sell Form Validation Methods

  /// Validate category selection
  void validateCategory() {
    if (selectedCategoryName.value.isEmpty) {
      categoryErrorKey.value = 'categoryCannotBeEmpty';
      categoryErrorParams.clear();
    } else {
      categoryErrorKey.value = '';
      categoryErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate registration number
  void validateRegistrationNumber() {
    final regNumber = registrationNumberController.text.trim();
    if (regNumber.isEmpty) {
      registrationNumberErrorKey.value = 'registrationNumberCannotBeEmpty';
      registrationNumberErrorParams.clear();
    } else if (regNumber.length < 6) {
      registrationNumberErrorKey.value = 'registrationNumberMinLength';
      registrationNumberErrorParams.clear();
    } else {
      registrationNumberErrorKey.value = '';
      registrationNumberErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate state selection
  void validateState() {
    if (selectedState == null) {
      stateErrorKey.value = 'stateCannotBeEmpty';
      stateErrorParams.clear();
    } else {
      stateErrorKey.value = '';
      stateErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate brand field
  void validateBrand() {
    final brand = brandController.text.trim();
    if (brand.isEmpty) {
      brandErrorKey.value = 'brandCannotBeEmpty';
      brandErrorParams.clear();
    } else if (brand.length < 2) {
      brandErrorKey.value = 'brandMinLength';
      brandErrorParams.clear();
    } else {
      brandErrorKey.value = '';
      brandErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate number of tyres
  void validateNumberOfTyres() {
    final tyres = numberOfTyresController.text.trim();
    if (tyres.isEmpty) {
      numberOfTyresErrorKey.value = 'numberOfTyresCannotBeEmpty';
      numberOfTyresErrorParams.clear();
    } else {
      // Check if it's a special case like "others" from dropdown
      if (tyres.toLowerCase() == 'others' || tyres.toLowerCase() == 'other') {
        // "Others" is a valid selection from dropdown
        numberOfTyresErrorKey.value = '';
        numberOfTyresErrorParams.clear();
      } else {
        // Try to parse as number for numeric values
        int? tyresNum = int.tryParse(tyres);
        if (tyresNum == null || tyresNum < 2 || tyresNum > 20) {
          numberOfTyresErrorKey.value = 'invalidNumberOfTyres';
          numberOfTyresErrorParams.clear();
        } else {
          numberOfTyresErrorKey.value = '';
          numberOfTyresErrorParams.clear();
        }
      }
    }
    _updateFormValidation();
  }

  /// Validate chassis number
  void validateChassisNumber() {
    final chassis = chasisNumberController.text.trim();
    if (chassis.isEmpty) {
      chassisNumberErrorKey.value = 'chassisNumberCannotBeEmpty';
      chassisNumberErrorParams.clear();
    } else {
      chassisNumberErrorKey.value = '';
      chassisNumberErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate location field
  void validateLocation() {
    final location = locationFormController.text.trim();
    if (location.isEmpty) {
      locationErrorKey.value = 'locationCannotBeEmpty';
      locationErrorParams.clear();
    } else if (location.length < 3) {
      locationErrorKey.value = 'locationMinLength';
      locationErrorParams.clear();
    } else {
      locationErrorKey.value = '';
      locationErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate owner mobile number
  void validateOwnerMobile() {
    final mobile = ownerMobileNumberController.text.trim();
    if (mobile.isEmpty) {
      ownerMobileErrorKey.value = 'ownerMobileCannotBeEmpty';
      ownerMobileErrorParams.clear();
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      ownerMobileErrorKey.value = 'invalidMobileNumber';
      ownerMobileErrorParams.clear();
    } else {
      ownerMobileErrorKey.value = '';
      ownerMobileErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate assets description
  void validateAssetsDescription() {
    final description = assetsDescriptionController.text.trim();
    if (description.isEmpty) {
      assetsDescriptionErrorKey.value = 'assetsDescriptionCannotBeEmpty';
      assetsDescriptionErrorParams.clear();
    } else {
      assetsDescriptionErrorKey.value = '';
      assetsDescriptionErrorParams.clear();
    }
    _updateFormValidation();
  }

  /// Validate year of manufacture
  void validateYearOfManufacture() {
    final year = yearOfManufactureController.text.trim();
    if (year.isEmpty) {
      yearOfManufactureErrorKey.value = 'yearOfManufactureCannotBeEmpty';
      yearOfManufactureErrorParams.clear();
    } else {
      int? yearNum = int.tryParse(year);
      int currentYear = DateTime.now().year;
      if (yearNum == null || yearNum < 1950 || yearNum > currentYear) {
        yearOfManufactureErrorKey.value = 'invalidYearOfManufacture';
        yearOfManufactureErrorParams.value = {'currentYear': currentYear};
      } else {
        yearOfManufactureErrorKey.value = '';
        yearOfManufactureErrorParams.clear();
      }
    }
    _updateFormValidation();
  }

  /// Select year from year picker
  void selectYear(String year) {
    print('📅 Selecting year: $year');

    // Prevent other fields from being cleared during year update
    isUpdatingController = true;
    try {
      selectedYear.value = year;

      // Update the controller text
      yearOfManufactureController.text = year;

      // Set the dynamic form value for Year of Manufacturing field
      setDynamicFormValue('Year of Manufacturing', year);

      // Sync with any other year field names
      final yearFieldNames = [
        'Year of Manufacturing',
        'Manufacturing Year',
        'Year',
      ];
      for (final fieldName in yearFieldNames) {
        if (_dynamicFormValues.containsKey(fieldName) ||
            _currentFormFields.value?.formFields.containsKey(fieldName) ==
                true) {
          _dynamicFormValues[fieldName] = year;
        }
      }

      // Validate the field
      validateYearOfManufacture();

      print('📅 Year selection completed and synced: $year');
    } finally {
      isUpdatingController = false;
    }
  }

  /// Validate odometer reading
  void validateOdometer() {
    final odometer = odometerController.text.trim();
    if (odometer.isEmpty) {
      odometerErrorKey.value = 'odometerCannotBeEmpty';
      odometerErrorParams.clear();
    } else {
      int? reading = int.tryParse(odometer);
      if (reading == null || reading < 0) {
        odometerErrorKey.value = 'invalidOdometerReading';
        odometerErrorParams.clear();
      } else {
        odometerErrorKey.value = '';
        odometerErrorParams.clear();
      }
    }
    _updateFormValidation();
  }

  /// Validate city selection
  void validateCity() {
    if (_authController.selectedCity.value == null) {
      cityErrorKey.value = 'cityCannotBeEmpty';
    } else {
      cityErrorKey.value = '';
    }
    _updateFormValidation();
  }

  /// Validate vehicle images
  void validateVehicleImages() {
    if (vehicleSelectedFiles.isEmpty) {
      vehicleImagesErrorKey.value = 'vehicleImagesCannotBeEmpty';
    } else {
      vehicleImagesErrorKey.value = '';
    }
    _updateFormValidation();
  }

  /// Public method to trigger form validation update
  void updateFormValidation() {
    _updateFormValidation();
  }

  /// Update overall form validation state
  void _updateFormValidation() {
    // Prevent recursive validation calls
    if (_isValidatingForm) {
      print('⚠️ Skipping recursive form validation call');
      return;
    }

    _isValidatingForm = true;
    try {
      // For dynamic form fields, use the dynamic validation
      if (_currentFormFields.value != null &&
          _currentFormFields.value!.formFields.isNotEmpty) {
        // Dynamic form validation
        bool allDynamicFieldsValid = true;
        bool allMandatoryFieldsFilled = true;

        List<String> missingMandatoryFields = [];
        List<String> fieldsWithErrors = [];

        _currentFormFields.value!.formFields.forEach((fieldName, formField) {
          // Check if field is valid (no errors)
          if (_dynamicFormErrors.containsKey(fieldName) &&
              _dynamicFormErrors[fieldName]!.isNotEmpty) {
            allDynamicFieldsValid = false;
            fieldsWithErrors.add(fieldName);
          }

          // Check if mandatory fields are filled (skip document fields)
          if (formField.mandatory && !_isFileField(fieldName)) {
            final value = _dynamicFormValues[fieldName];
            if (value == null ||
                (value is String && value.trim().isEmpty) ||
                (value is List && value.isEmpty)) {
              allMandatoryFieldsFilled = false;
              missingMandatoryFields.add(fieldName);
            }
          }
        });

        // Add validation for insurance selection (always required)
        if (hasInsurance.value == null) {
          allMandatoryFieldsFilled = false;
          missingMandatoryFields.add('Insurance');
        }

        isSellFormValid.value =
            allDynamicFieldsValid && allMandatoryFieldsFilled;

        // Debug logging
        print('📋 Form validation debug:');
        print(
          '   📝 Total form fields: ${_currentFormFields.value!.formFields.length}',
        );
        print('   📝 Dynamic form values count: ${_dynamicFormValues.length}');
        print('   📝 Dynamic form errors count: ${_dynamicFormErrors.length}');

        if (missingMandatoryFields.isNotEmpty || fieldsWithErrors.isNotEmpty) {
          if (missingMandatoryFields.isNotEmpty) {
            print(
              '   ❌ Missing mandatory fields: ${missingMandatoryFields.join(", ")}',
            );
            // Show current values for missing fields
            for (String field in missingMandatoryFields) {
              final value = _dynamicFormValues[field];
              print('      📝 $field = $value (${value.runtimeType})');
            }
          }
          if (fieldsWithErrors.isNotEmpty) {
            print('   ❌ Fields with errors: ${fieldsWithErrors.join(", ")}');
            // Show actual errors
            for (String field in fieldsWithErrors) {
              final error = _dynamicFormErrors[field];
              print('      ⚠️ $field error: $error');
            }
          }
        } else {
          print('   ✅ All mandatory fields filled and no errors');
          // Show all current values for debugging
          _dynamicFormValues.forEach((field, value) {
            print('      📝 $field = $value (${value.runtimeType})');
          });
          // Show standard controller values
          print('      📝 Insurance (Standard) = ${hasInsurance.value}');
        }

        print(
          '🔍 Form validation result: allValid=$allDynamicFieldsValid, allFilled=$allMandatoryFieldsFilled, FINAL=${isSellFormValid.value}',
        );
      } else {
        // Legacy validation for static fields (fallback)
        isSellFormValid.value =
            // Error checks - no field should have errors
            categoryErrorKey.value.isEmpty &&
            registrationNumberErrorKey.value.isEmpty &&
            stateErrorKey.value.isEmpty &&
            brandErrorKey.value.isEmpty &&
            numberOfTyresErrorKey.value.isEmpty &&
            chassisNumberErrorKey.value.isEmpty &&
            locationErrorKey.value.isEmpty &&
            ownerMobileErrorKey.value.isEmpty &&
            assetsDescriptionErrorKey.value.isEmpty &&
            yearOfManufactureErrorKey.value.isEmpty &&
            odometerErrorKey.value.isEmpty &&
            cityErrorKey.value.isEmpty &&
            vehicleImagesErrorKey.value.isEmpty &&
            // Content checks - all required fields must have values
            selectedCategoryName.value.isNotEmpty &&
            registrationNumberController.text.trim().isNotEmpty &&
            selectedState != null &&
            _authController.selectedCity.value !=
                null && // FIXED: Added city validation
            brandController.text.trim().isNotEmpty &&
            numberOfTyresController.text.trim().isNotEmpty &&
            chasisNumberController.text.trim().isNotEmpty &&
            locationFormController.text.trim().isNotEmpty &&
            ownerMobileNumberController.text.trim().isNotEmpty &&
            assetsDescriptionController.text.trim().isNotEmpty &&
            yearOfManufactureController.text.trim().isNotEmpty &&
            odometerController.text.trim().isNotEmpty &&
            vehicleSelectedFiles
                .isNotEmpty; // FIXED: Added vehicle images validation
      }
    } finally {
      _isValidatingForm = false;
    }
  }

  /// Method to get localized error message using the AuthController's method
  String getLocalizedErrorMessage(
    String errorKey,
    Map<String, dynamic> params,
    dynamic l10n,
  ) {
    if (errorKey.isEmpty) return '';

    // Handle sell form specific error keys
    switch (errorKey) {
      case 'categoryCannotBeEmpty':
        return l10n.categoryCannotBeEmpty;
      case 'registrationNumberCannotBeEmpty':
        return l10n.registrationNumberCannotBeEmpty;
      case 'registrationNumberMinLength':
        return l10n.registrationNumberMinLength;
      case 'stateCannotBeEmpty':
        return l10n.stateCannotBeEmpty;
      case 'brandCannotBeEmpty':
        return l10n.brandCannotBeEmpty;
      case 'brandMinLength':
        return l10n.brandMinLength;
      case 'numberOfTyresCannotBeEmpty':
        return l10n.numberOfTyresCannotBeEmpty;
      case 'invalidNumberOfTyres':
        return l10n.invalidNumberOfTyres;
      case 'chassisNumberCannotBeEmpty':
        return l10n.chassisNumberCannotBeEmpty;
      case 'chassisNumberMinLength':
        return l10n.chassisNumberMinLength;
      case 'locationCannotBeEmpty':
        return l10n.locationCannotBeEmpty;
      case 'locationMinLength':
        return l10n.locationMinLength;
      case 'ownerMobileCannotBeEmpty':
        return l10n.ownerMobileCannotBeEmpty;
      case 'invalidMobileNumber':
        return l10n.invalidMobileNumber;
      case 'assetsDescriptionCannotBeEmpty':
        return l10n.assetsDescriptionCannotBeEmpty;
      case 'assetsDescriptionMinLength':
        return l10n.assetsDescriptionMinLength;
      case 'yearOfManufactureCannotBeEmpty':
        return l10n.yearOfManufactureCannotBeEmpty;
      case 'invalidYearOfManufacture':
        return l10n.invalidYearOfManufacture(
          params['currentYear'] as int? ?? DateTime.now().year,
        );
      case 'odometerCannotBeEmpty':
        return l10n.odometerCannotBeEmpty;
      case 'invalidOdometerReading':
        return l10n.invalidOdometerReading;
      case 'cityCannotBeEmpty':
        return l10n.cityCannotBeEmpty;
      case 'vehicleImagesCannotBeEmpty':
        return l10n.vehicleImagesCannotBeEmpty;
      default:
        // Fallback to AuthController's method for common validation errors
        return _authController.getLocalizedErrorMessage(errorKey, params, l10n);
    }
  }

  /// Select category method
  void selectCategory(String categoryName) {
    print(
      '🎯 Category selected: $categoryName (Previous: ${selectedCategoryName.value})',
    );

    // Always clear form data when selecting a category to ensure fresh start
    if (selectedCategoryName.value.isNotEmpty) {
      if (selectedCategoryName.value != categoryName) {
        print(
          '🔄 Category changed from ${selectedCategoryName.value} to $categoryName - clearing form data',
        );
        _clearFormDataExceptCategory();
      } else {
        print(
          '🔄 Same category reselected: $categoryName - clearing and reloading form data for fresh start',
        );
        _clearFormDataExceptCategory();
      }
    }

    selectedCategoryName.value = categoryName;
    // Update the category controller text to show the selected category
    categoryController.text = categoryName;
    // Set the category value in dynamic form values as well
    setDynamicFormValue('Category', categoryName);
    // Lock the category field once selected to prevent further editing
    isCategoryLocked.value = true;
    validateCategory();

    // Load states when category is selected
    print('🌍 Loading states for sell form');
    loadStatesIfNeeded();

    // ALWAYS fetch fresh form fields for the selected category
    final category = getCategoryByName(categoryName);
    if (category != null) {
      print(
        '🔄 Fetching fresh data for category: ${category.categoryName} (${category.categoryCode})',
      );

      // CRITICAL: Always call API to get fresh form fields
      fetchFormFields(categoryCode: category.categoryCode);

      // Fetch brands for this category
      print('📱 Fetching brands for category: ${category.categoryCode}');
      fetchBrands(categoryCode: category.categoryCode);

      // Fetch tires for this category (using categoryCode as tyreCategory)
      print('🚗 Fetching tires for category: ${category.categoryCode}');
      fetchTires(tyreCategory: category.categoryCode);
    }
  }

  /// Unlock category (for testing or admin purposes)
  void unlockCategory() {
    isCategoryLocked.value = false;
  }

  /// Submit sell vehicle form with multipart file uploads
  Future<void> submitSellVehicle() async {
    try {
      // Validate all dynamic fields based on API form configuration
      if (!validateAllDynamicFields()) {
        // Force UI update to show validation errors
        update();

        // Show specific error message
        sellFormError.value = 'Please fill all required fields correctly';

        // Show snackbar with list of validation errors
        List<String> errorFields = [];
        _dynamicFormErrors.forEach((field, error) {
          if (error.isNotEmpty) {
            errorFields.add(field);
          }
        });

        if (errorFields.isNotEmpty) {
          Get.snackbar(
            'Validation Error',
            'Please check: ${errorFields.join(', ')}',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            snackPosition: SnackPosition.TOP,
          );
        }

        return;
      }

      // Ensure required data is loaded before submission
      final categoryName = selectedCategoryName.value;
      if (categoryName.isNotEmpty) {
        final category = getCategoryByName(categoryName);
        if (category != null && _tires.isEmpty) {
          debugPrint(
            '⚠️ [submitSellVehicle] Tires not loaded yet, loading now...',
          );
          await fetchTires(tyreCategory: category.categoryCode);
          // Wait a bit for the data to be properly set
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      isSubmittingSellForm.value = true;
      sellFormError.value = '';

      // Get user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        sellFormError.value = 'User not authenticated';
        isSubmittingSellForm.value = false;
        return;
      }

      // Get selected category from the category name
      final category = getCategoryByName(selectedCategoryName.value);
      if (category == null) {
        sellFormError.value = 'Please select a valid category';
        isSubmittingSellForm.value = false;
        return;
      }

      // Create request object with all mandatory and optional fields from dynamic form
      debugPrint('🚀 Creating SellVehicleRequest with the following values:');

      // Log mandatory fields
      debugPrint('📋 MANDATORY FIELDS:');
      debugPrint('   userId: $userId');
      debugPrint('   categoryCode: ${category.categoryCode}');
      debugPrint('   brandCode: ${_getBrandCodeFromDynamicForm()}');
      debugPrint(
        '   assetDescOrModel: "${_getDynamicFormValueAsString('Asset Description')}"',
      );
      debugPrint('   price: ${_getPriceValue()}');
      debugPrint(
        '   registrationNumber: "${_getDynamicFormValueAsString('Registration Number')}"',
      );
      debugPrint('   stateCode: "${_getStateCodeFromDynamicForm()}"');
      debugPrint('   cityCode: "${_getCityCodeFromDynamicForm()}"');
      debugPrint(
        '   ownerMobile: "${_getDynamicFormValueAsString('Owner Mobile Number')}"',
      );
      debugPrint(
        '   manufacturingYear: ${_getDynamicFormValueAsInt('Year of Manufacturing') ?? DateTime.now().year}',
      );
      debugPrint('   insurance: ${_getInsuranceStatus()}');
      debugPrint('   fitness: ${_getDynamicFormValueAsBool('Fitness')}');
      debugPrint(
        '   originalInvoice: ${_getDynamicFormValueAsBool('Original Invoice')}',
      );
      debugPrint(
        '   gstApplicability: ${_getDynamicFormValueAsBool('GST Applicability')}',
      );

      // Log Other fields
      debugPrint('📋 OTHER FIELDS:');
      debugPrint('   otherBrand: "${otherBrandController.text.trim()}"');
      debugPrint('   otherTipper: "${otherTipperController.text.trim()}"');
      debugPrint('   otherBodyType: "${otherBodyTypeController.text.trim()}"');
      debugPrint('   otherTyre: "${otherTyreController.text.trim()}"');

      final request = SellVehicleRequest(
        // Mandatory fields from dynamic form values
        userId: userId,
        categoryCode: category.categoryCode,
        brandCode: _getBrandCodeFromDynamicForm(),
        assetDescOrModel: _getDynamicFormValueAsString('Asset Description'),
        price: _getPriceValue(),
        registrationNumber: _getDynamicFormValueAsString('Registration Number'),
        stateCode: _getStateCodeFromDynamicForm(),
        cityCode: _getCityCodeFromDynamicForm(),
        ownerMobile: _getDynamicFormValueAsString('Owner Mobile Number'),
        manufacturingYear:
            _getDynamicFormValueAsInt('Year of Manufacturing') ??
            DateTime.now().year,
        insurance: _getInsuranceStatus(),
        fitness: _getDynamicFormValueAsBool('Fitness'),
        originalInvoice: _getDynamicFormValueAsBool('Original Invoice'),
        gstApplicability: _getDynamicFormValueAsBool('GST Applicability'),
        // Optional fields from dynamic form values (always include, even if empty)
        chassisNumber: _getDynamicFormValueAsString('Chassis Number'),
        noOfTyres: _getTyreCodeFromDynamicForm(),
        odometer: _getDynamicFormValueAsString('Odometer'),
        tonnage: _getDynamicFormValueAsString('Tonnage'),
        hours: _getDynamicFormValueAsString('Hours'),
        bodyType: _getBodyTypeFromDynamicForm(),
        bodyLength: _getDynamicFormValueAsString('Body Length'),
        fuelType: _getDynamicFormValueAsString('Fuel Type'),
        insuranceDates: _getDynamicFormValueAsString('Vehicle Insurance'),
        kv: _getDynamicFormValueAsString('KV'),
        // Other fields
        otherBrand: otherBrandController.text.trim().isNotEmpty
            ? otherBrandController.text.trim()
            : null,
        otherTipper: otherTipperController.text.trim().isNotEmpty
            ? otherTipperController.text.trim()
            : null,
        otherBodyType: otherBodyTypeController.text.trim().isNotEmpty
            ? otherBodyTypeController.text.trim()
            : null,
        otherTyre: otherTyreController.text.trim().isNotEmpty
            ? otherTyreController.text.trim()
            : null,
        // Set sold status as null (will be determined by backend)
        isSold: 'NOT_SOLD',
      );

      // Log optional fields for debugging
      debugPrint('📋 OPTIONAL FIELDS:');
      debugPrint(
        '   chassisNumber: "${_getDynamicFormValueAsString('Chassis Number')}"',
      );
      debugPrint(
        '   noOfTyres: "${_getTyreCodeFromDynamicForm()}" (from display: "${_getDynamicFormValueAsString('Tyre')}")',
      );
      debugPrint('   odometer: "${_getDynamicFormValueAsString('Odometer')}"');
      debugPrint('   tonnage: "${_getDynamicFormValueAsString('Tonnage')}"');
      debugPrint('   hours: "${_getDynamicFormValueAsString('Hours')}"');
      debugPrint('   bodyType: "${_getBodyTypeFromDynamicForm()}"');
      debugPrint(
        '   bodyLength: "${_getDynamicFormValueAsString('Body Length')}"',
      );
      debugPrint('   fuelType: "${_getDynamicFormValueAsString('Fuel Type')}"');
      debugPrint(
        '   insuranceDates: "${_getDynamicFormValueAsString('Vehicle Insurance')}"',
      );
      debugPrint('   kv: "${_getDynamicFormValueAsString('KV')}"');
      debugPrint('   otherBrand: "${otherBrandController.text.trim()}"');
      debugPrint('   otherTipper: "${otherTipperController.text.trim()}"');
      debugPrint('   otherBodyType: "${otherBodyTypeController.text.trim()}"');
      debugPrint('   otherTyre: "${otherTyreController.text.trim()}"');

      // Convert PlatformFile to File for API call from dynamic form values
      List<File>? imageFiles;
      List<File>? rcFiles;
      List<File>? insuranceFilesList;

      // Get files from dynamic form values
      final vehicleImages = _getDynamicFormValueAsFileList('Vehicle Images');
      final rcDocuments = _getDynamicFormValueAsFileList('Upload Vehicle RC');
      final insuranceDocuments = _getDynamicFormValueAsFileList(
        'Insurance Upload',
      );

      // Log file attachments
      debugPrint('📎 FILE ATTACHMENTS:');
      debugPrint('   Vehicle Images: ${vehicleImages.length} files');
      debugPrint('   RC Documents: ${rcDocuments.length} files');
      debugPrint('   Insurance Documents: ${insuranceDocuments.length} files');

      if (vehicleImages.isNotEmpty) {
        imageFiles = vehicleImages
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        debugPrint('   ✅ Image files prepared: ${imageFiles.length}');
      }

      if (rcDocuments.isNotEmpty) {
        rcFiles = rcDocuments
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        debugPrint('   ✅ RC files prepared: ${rcFiles.length}');
      }

      if (insuranceDocuments.isNotEmpty) {
        insuranceFilesList = insuranceDocuments
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        debugPrint(
          '   ✅ Insurance files prepared: ${insuranceFilesList.length}',
        );
      }

      debugPrint('🚀 Making API call to sell vehicle...');

      // Make API call
      final response = await _apiRepository.sellVehicle(
        request,
        imageFiles,
        rcFiles,
        insuranceFilesList,
      );

      // Handle success response
      sellVehicleId.value = response.sbVehicleId;

      // Show success message
      Get.snackbar(
        'Success',
        'Vehicle listed successfully! ID: ${response.sbVehicleId}',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        snackPosition: SnackPosition.TOP,
      );

      // Reset form after successful submission
      resetSellForm();

      // Navigate to buy-sell dashboard after successful submission
      Get.offNamed(AppRoutes.buySell);
    } catch (e) {
      sellFormError.value = e.toString();

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to list vehicle: ${e.toString()}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSubmittingSellForm.value = false;
    }
  }

  /// Reset sell form to initial state
  void resetSellForm() {
    debugPrint('🔄 Starting complete form reset...');

    // Clear all text controllers
    categoryController.clear();
    productNameController.clear();
    descriptionController.clear();
    registrationNumberController.clear();
    brandController.clear();
    numberOfTyresController.clear();
    chasisNumberController.clear();
    locationFormController.clear();
    ownerMobileNumberController.clear();
    assetsDescriptionController.clear();
    yearOfManufactureController.clear();
    odometerController.clear();
    cityController.clear();

    // Clear "Other" field controllers
    otherBrandController.clear();
    otherTipperController.clear();
    otherBodyTypeController.clear();
    otherTyreController.clear();

    // Reset "Other" selection flags
    isOtherBrandSelected.value = false;
    isOtherTipperSelected.value = false;
    isOtherBodyTypeSelected.value = false;
    isOtherTyreSelected.value = false;

    // Reset all dropdown selections and clear their controllers
    selectedCategoryName.value = '';
    isCategoryLocked.value = false; // Unlock category for next use
    _selectedBrand.value = null;
    _selectedTire.value = null;
    selectedYear.value = '';

    // CRITICAL: Clear all dynamic form values completely
    debugPrint('🧹 Clearing ${_dynamicFormValues.length} dynamic form values');
    _dynamicFormValues.clear();

    // CRITICAL: Clear category filter configurations
    debugPrint(
      '🗂️ Clearing ${categoryFilterConfigurations.length} filter configs',
    );
    categoryFilterConfigurations.clear();

    // CRITICAL: Reset initialization flag to allow fresh form setup
    _hasInitializedSellForm = false;
    debugPrint('🔓 Reset form initialization flag');

    // Clear state and city selections from auth controller
    try {
      _authController.resetLocationData();
      _authController.selectedState.value = null;
      _authController.selectedCity.value = null;
    } catch (e) {}

    // Reset all checkbox values
    isFitnessSelected.value = false;
    isInsuranceSelected.value = false;
    isOriginalInvoiceSelected.value = false;
    isGstApplicabilitySelected.value = false;

    // Clear all file selections
    vehicleSelectedFiles.clear();
    vehicleRCFiles.clear();
    vehicleInsuranceFiles.clear();

    // Clear existing and new documents for edit mode
    clearAllDocuments();

    // Reset all validation error keys
    categoryErrorKey.value = '';
    registrationNumberErrorKey.value = '';
    stateErrorKey.value = '';
    brandErrorKey.value = '';
    numberOfTyresErrorKey.value = '';
    chassisNumberErrorKey.value = '';
    locationErrorKey.value = '';
    ownerMobileErrorKey.value = '';
    assetsDescriptionErrorKey.value = '';
    yearOfManufactureErrorKey.value = '';
    odometerErrorKey.value = '';

    // Clear all error parameter maps
    categoryErrorParams.clear();
    registrationNumberErrorParams.clear();
    stateErrorParams.clear();
    brandErrorParams.clear();
    numberOfTyresErrorParams.clear();
    chassisNumberErrorParams.clear();
    locationErrorParams.clear();
    ownerMobileErrorParams.clear();
    assetsDescriptionErrorParams.clear();
    yearOfManufactureErrorParams.clear();
    odometerErrorParams.clear();

    // Reset form validation state
    isSellFormValid.value = false;

    // Reset submission states
    sellFormError.value = '';
    sellVehicleId.value = '';
    isSubmittingSellForm.value = false;

    // Clear dependent data lists (will be reloaded when needed)
    brands.clear();
    tires.clear();
    cities.clear();

    // CRITICAL: Clear all dynamic form field controllers
    debugPrint(
      '🎛️ Clearing ${dynamicFilterControllers.length} dynamic field controllers',
    );
    for (var controller in dynamicFilterControllers.values) {
      controller.clear();
    }

    // CRITICAL: Clear any form-specific controller maps if they exist
    debugPrint('📝 Form reset - All controllers and values cleared');

    // Force form validation update to reflect cleared state
    _updateFormValidation();

    // Force UI refresh by updating observable values
    Future.delayed(const Duration(milliseconds: 100), () {
      // Trigger a rebuild by updating timestamp
      formResetKey.value++;
      widgetKey.value = DateTime.now().millisecondsSinceEpoch.toString();
      update();
      debugPrint('✅ Complete form reset finished - UI refreshed');
    });

    debugPrint('🔄 Form reset completed successfully');
  }

  @override
  void onClose() {
    tabController.dispose();
    categoryController.dispose();
    locationController.dispose();
    priceRangeController.dispose();
    searchController.dispose();
    brandFilterController.dispose();
    tyreFilterController.dispose();
    yearFilterController.dispose();
    stateFilterController.dispose();

    // Dispose sell form controllers
    productNameController.dispose();
    descriptionController.dispose();

    // Dispose dynamic filter controllers
    for (var controller in dynamicFilterControllers.values) {
      controller.dispose();
    }

    // Dispose user interest controllers
    vehicleDetailContactController.value.dispose();

    super.onClose();
  }

  // ==================== SUBSCRIBED VEHICLES LIST METHODS ====================

  /// Subscribed vehicles observable list
  final RxList<BuyVehicle> subscribedVehiclesList = <BuyVehicle>[].obs;

  /// Subscribed vehicles loading state
  final RxBool isLoadingSubscribedVehiclesList = false.obs;

  /// Subscribed vehicles pagination
  final RxInt subscribedVehiclesPage = 1.obs;
  final RxInt subscribedVehiclesTotalPages = 0.obs;
  final RxInt subscribedVehiclesTotalCount = 0.obs;
  final RxBool hasMoreSubscribedVehicles = true.obs;

  /// Fetch subscribed vehicles list with pagination
  Future<void> fetchSubscribedVehicles({
    int page = 1,
    int limit = 10,
    required String userId,
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh) {
        subscribedVehiclesPage.value = 1;
        subscribedVehiclesList.clear();
        hasMoreSubscribedVehicles.value = true;
      }

      if (!hasMoreSubscribedVehicles.value && !isRefresh) {
        return;
      }

      isLoadingSubscribedVehiclesList.value = true;
      errorMessage.value = "";

      final request = ListBuySubscribedVehiclesRequest(
        limit: limit,
        page: subscribedVehiclesPage.value,
        userId: userId,
      );

      final response = await _apiRepository.fetchtBuySubscribedVehicle(request);

      // Clear list if this is the first page or refresh
      if (subscribedVehiclesPage.value == 1 || isRefresh) {
        subscribedVehiclesList.clear();
      }

      // Convert SubscribedVehicle objects to BuyVehicle objects
      List<BuyVehicle> convertedVehicles = response.data.vehicles.map((
        subscribedVehicle,
      ) {
        // Create a map with the subscribed vehicle data and convert to BuyVehicle
        Map<String, dynamic> vehicleJson = {
          'id': subscribedVehicle.id ?? 0,
          'sb_vehicle_id': subscribedVehicle.sbVehicleId ?? '',
          'category_code': subscribedVehicle.categoryCode ?? '',
          'category_name': subscribedVehicle.categoryName ?? '',
          'state_code': subscribedVehicle.stateCode ?? '',
          'city_code': subscribedVehicle.cityCode ?? '',
          'brand_code': subscribedVehicle.brandCode ?? '',
          'brand_name': subscribedVehicle.brandName ?? '',
          'no_of_tyres': subscribedVehicle.noOfTyres ?? '',
          'manufacturing_year': subscribedVehicle.manufacturingYear ?? 0,
          'price': subscribedVehicle.price?.toString() ?? '0',
          'registration_number': subscribedVehicle.registrationNumber ?? '',
          'chassis_number': subscribedVehicle.chassisNumber ?? '',
          'location': subscribedVehicle.location ?? '',
          'odometer': subscribedVehicle.odometer ?? '',
          'original_invoice': subscribedVehicle.originalInvoice ?? false,
          'fitness': subscribedVehicle.fitness ?? false,
          'insurance': subscribedVehicle.insurance ?? false,
          'gst_applicability': subscribedVehicle.gstApplicability ?? false,
          'owner_mobile': subscribedVehicle.ownerMobile ?? '',
          'inspection_requested': subscribedVehicle.inspectionRequested ?? '',
          'asset_desc_or_model': subscribedVehicle.assetDescOrModel ?? '',
          'status': subscribedVehicle.status ?? '',
          'approved': subscribedVehicle.approved ?? '',
          'approved_by': subscribedVehicle.approvedBy ?? '',
          'approved_on': subscribedVehicle.approvedOn ?? '',
          'uploaded_by': subscribedVehicle.uploadedBy ?? '',
          'inserted_at': subscribedVehicle.insertedAt ?? '',
          'modified_at': subscribedVehicle.modifiedAt ?? '',
          'user_info': subscribedVehicle.userInfo != null
              ? {
                  'user_id': subscribedVehicle.userInfo!.userId,
                  'full_name': subscribedVehicle.userInfo!.fullName,
                  'email': subscribedVehicle.userInfo!.email,
                  'mobile': subscribedVehicle.userInfo!.mobile,
                }
              : {},
          'vehicle_files':
              subscribedVehicle.vehicleFiles
                  ?.map(
                    (file) => {
                      'id': file.id,
                      'file_url': file.fileUrl,
                      'file_type': file.fileType,
                      'bucket_name': file.bucketName,
                      'file_key': file.fileKey,
                      'status': file.status,
                      'uploaded_at': file.uploadedAt,
                    },
                  )
                  .toList() ??
              [],
          'files':
              subscribedVehicle.vehicleFiles
                  ?.map(
                    (file) => {
                      'id': file.id,
                      'file_url': file.fileUrl,
                      'file_type': file.fileType,
                      'bucket_name': file.bucketName,
                      'file_key': file.fileKey,
                      'status': file.status,
                      'uploaded_at': file.uploadedAt,
                    },
                  )
                  .toList() ??
              [],
        };

        return BuyVehicle.fromJson(vehicleJson);
      }).toList();

      subscribedVehiclesList.addAll(convertedVehicles);

      // Update pagination info
      subscribedVehiclesTotalPages.value = response.data.pagination.totalPages;
      subscribedVehiclesTotalCount.value = response.data.pagination.totalCount;

      // Check if there are more pages
      hasMoreSubscribedVehicles.value =
          subscribedVehiclesPage.value < response.data.pagination.totalPages;

      // Increment page for next fetch
      if (hasMoreSubscribedVehicles.value) {
        subscribedVehiclesPage.value++;
      }
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to fetch subscribed vehicles: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingSubscribedVehiclesList.value = false;
    }
  }

  /// Load more subscribed vehicles (for pagination)
  Future<void> loadMoreSubscribedVehicles() async {
    if (!hasMoreSubscribedVehicles.value ||
        isLoadingSubscribedVehiclesList.value) {
      return;
    }

    final userId = await _storageService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      await fetchSubscribedVehicles(userId: userId);
    }
  }

  /// Refresh subscribed vehicles list
  Future<void> refreshSubscribedVehiclesList() async {
    final userId = await _storageService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      await fetchSubscribedVehicles(userId: userId, isRefresh: true);
    }
  }

  /// Get subscribed vehicle by ID
  BuyVehicle? getSubscribedVehicleById(String vehicleId) {
    try {
      return subscribedVehiclesList.firstWhere(
        (vehicle) => vehicle.sbVehicleId == vehicleId,
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== SELL VEHICLES LIST METHODS ====================

  /// Fetch sell vehicles list with pagination
  Future<void> fetchSellVehiclesList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        sellVehiclesPage.value = 1;
        sellVehiclesList.clear();
        hasMoreSellVehicles.value = true;
      }

      if (!hasMoreSellVehicles.value && !isRefresh) {
        return;
      }

      isLoadingSellVehiclesList.value = true;

      // Get current user ID from auth controller
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final request = ListSellVehiclesRequest(
        limit: pageSize,
        page: sellVehiclesPage.value,
        userId: userId,
      );

      final response = await _apiRepository.listSellVehicles(request);

      if (isRefresh) {
        sellVehiclesList.clear();
      }

      sellVehiclesList.addAll(response.vehicles);
      sellVehiclesTotalPages.value = response.totalPages;
      sellVehiclesTotalCount.value = response.totalCount;

      // Check if there are more pages
      hasMoreSellVehicles.value = sellVehiclesPage.value < response.totalPages;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load sell vehicles: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingSellVehiclesList.value = false;
    }
  }

  /// Load more sell vehicles (for pagination)
  Future<void> loadMoreSellVehicles() async {
    if (!hasMoreSellVehicles.value || isLoadingSellVehiclesList.value) {
      return;
    }

    sellVehiclesPage.value++;
    await fetchSellVehiclesList();
  }

  /// Refresh sell vehicles list
  Future<void> refreshSellVehiclesList() async {
    await fetchSellVehiclesList(isRefresh: true);
  }

  /// Get sell vehicle by ID
  SellVehicleItem? getSellVehicleById(String vehicleId) {
    try {
      return sellVehiclesList.firstWhere(
        (vehicle) => vehicle.sbVehicleId == vehicleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get sell vehicles by status
  List<SellVehicleItem> getSellVehiclesByStatus(String status) {
    return sellVehiclesList
        .where((vehicle) => vehicle.status == status)
        .toList();
  }

  /// Get approved sell vehicles
  List<SellVehicleItem> getApprovedSellVehicles() {
    return sellVehiclesList
        .where((vehicle) => vehicle.approved == 'yes')
        .toList();
  }

  /// Get pending sell vehicles
  List<SellVehicleItem> getPendingSellVehicles() {
    return sellVehiclesList
        .where((vehicle) => vehicle.approved != 'yes')
        .toList();
  }

  // Buy Vehicles List Methods

  /// Fetch buy vehicles list with comprehensive filters
  Future<void> fetchBuyVehiclesWithFilters({
    String? brandCode,
    String? categoryCode,
    String? stateCode,
    String? tyreCode,
    String? year, // Changed from int? to String? to support dynamic ranges
    String? bodyType,
    String? fuelType,
    String? kv,
    String? tonnage,
    bool isRefresh = true,
  }) async {
    try {
      if (isRefresh) {
        buyVehiclesList.clear();
        buyVehiclesPage.value = 1;
        hasMoreBuyVehicles.value = true;
      }

      if (!hasMoreBuyVehicles.value && !isRefresh) {
        return;
      }

      isLoadingBuyVehiclesList.value = true;

      // Get current user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final request = ListBuyVehiclesRequest(
        limit: 10,
        page: buyVehiclesPage.value,
        userId: userId,
        brandCode: brandCode,
        categoryCode: categoryCode,
        stateCode: stateCode,
        tyreCode: tyreCode,
        year: year,
        bodyType: bodyType,
        fuelType: fuelType,
        kv: kv,
        tonnage: tonnage,
      );

      final response = await _apiRepository.listBuyVehiclesWithFilters(request);

      // Clear list if this is the first page or refresh
      if (buyVehiclesPage.value == 1 || isRefresh) {
        buyVehiclesList.clear();
      }

      buyVehiclesList.addAll(response.vehicles);

      // Update pagination info
      buyVehiclesTotalPages.value = response.totalPages;
      buyVehiclesTotalCount.value = response.totalCount;

      // Check if there are more pages
      hasMoreBuyVehicles.value = buyVehiclesPage.value < response.totalPages;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch vehicles: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBuyVehiclesList.value = false;
    }
  }

  /// Fetch buy vehicles list with pagination and category filter
  /// Now uses comprehensive filtering with all available filter options
  /// Fetch buy vehicles list with pagination and category filter
  /// Now uses the new buyListFilters API with comprehensive filtering
  Future<void> fetchBuyVehiclesByCategory({
    required String categoryCode,
    String? sbVehicleId,
    bool isRefresh = true,
  }) async {
    try {
      if (isRefresh) {
        buyVehiclesList.clear();
        buyVehiclesPage.value = 1;
        hasMoreBuyVehicles.value = true;
      }

      if (!hasMoreBuyVehicles.value && !isRefresh) {
        return;
      }

      isLoadingBuyVehiclesList.value = true;

      debugPrint(
        '🔄 [fetchBuyVehiclesByCategory] Fetching vehicles for category: $categoryCode',
      );

      // Get current user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Get current filter values - use stored codes directly
      String? currentBrandFilter = selectedBrandCode.value.isNotEmpty
          ? selectedBrandCode.value
          : null;

      String? currentStateFilter = selectedStateId.value.isNotEmpty
          ? selectedStateId.value
          : null;

      String? currentTyreFilter = selectedTyreCode.value.isNotEmpty
          ? selectedTyreCode.value
          : null;

      debugPrint('🔍 [fetchBuyVehiclesByCategory] Using stored filter codes:');
      debugPrint('   Brand Code: $currentBrandFilter');
      debugPrint('   State ID: $currentStateFilter');
      debugPrint('   Tyre Code: $currentTyreFilter');

      String? currentYearFilter =
          getDynamicFilterController('Year')?.text.trim() ?? '';

      // Get the API value for year filter if it's a dynamic filter
      String? yearApiValue;
      if (currentYearFilter.isNotEmpty) {
        // Try to get the API value from dynamic mapping first
        yearApiValue = getCurrentFilterApiValue('Year');
        if (yearApiValue == null) {
          // Fallback to the displayed value if no mapping exists
          yearApiValue = currentYearFilter;
        }
        debugPrint(
          '🔍 [fetchBuyVehiclesByCategory] Year filter: $currentYearFilter -> $yearApiValue',
        );
      }

      // Get dynamic filter values - use stored values instead of controller text
      String? currentBodyTypeFilter = selectedBodyType.value.isNotEmpty
          ? selectedBodyType.value
          : null;

      String? currentFuelTypeFilter = selectedFuelType.value.isNotEmpty
          ? selectedFuelType.value
          : null;

      String? currentKvFilter = selectedKV.value.isNotEmpty
          ? selectedKV.value
          : null;

      String? currentTonnageFilter = selectedTonnage.value.isNotEmpty
          ? selectedTonnage.value
          : null;

      debugPrint('🔍 [fetchBuyVehiclesByCategory] Current filters:');
      debugPrint('   Category: $categoryCode');
      debugPrint('   Brand: $currentBrandFilter');
      debugPrint('   State: $currentStateFilter');
      debugPrint('   Tyre: $currentTyreFilter');
      debugPrint('   Year (Display): $currentYearFilter');
      debugPrint('   Year (API): $yearApiValue');
      debugPrint('   Body Type: $currentBodyTypeFilter');
      debugPrint('   Fuel Type: $currentFuelTypeFilter');
      debugPrint('   KV: $currentKvFilter');
      debugPrint('   Tonnage: $currentTonnageFilter');

      // Debug controller status
      debugPrint('🎛️ [fetchBuyVehiclesByCategory] Filter Controller Status:');
      debugPrint(
        '   Dynamic Brand Controller: ${getDynamicFilterController('Brand')?.text ?? 'null'}',
      );
      debugPrint('   Static Brand Controller: ${brandFilterController.text}');
      debugPrint(
        '   Dynamic State Controller: ${getDynamicFilterController('State')?.text ?? 'null'}',
      );
      debugPrint('   Static State Controller: ${stateFilterController.text}');
      debugPrint(
        '   Dynamic Tyres Controller: ${getDynamicFilterController('Tyres')?.text ?? 'null'}',
      );
      debugPrint('   Static Tyre Controller: ${tyreFilterController.text}');

      // Create request object for new buyListFilters API
      final request = ListBuyVehiclesRequest(
        limit: 10,
        page: buyVehiclesPage.value,
        userId: userId,
        categoryCode: categoryCode,
        brandCode: currentBrandFilter,
        stateCode: currentStateFilter,
        tyreCode: currentTyreFilter,
        year: yearApiValue?.isNotEmpty == true ? yearApiValue : null,
        bodyType: currentBodyTypeFilter,
        fuelType: currentFuelTypeFilter,
        kv: currentKvFilter,
        tonnage: currentTonnageFilter,
        sbVehicleId: '',
        // No specific vehicle ID filter
      );

      debugPrint(
        '🚀 [fetchBuyVehiclesByCategory] Making API call with request: ${request.toJson()}',
      );

      // Call the new buyListFilters API
      final response = await _apiRepository.listBuyVehiclesWithFilters(request);

      // Clear list if this is the first page or refresh
      if (buyVehiclesPage.value == 1 || isRefresh) {
        buyVehiclesList.clear();
        debugPrint(
          '🗑️ [fetchBuyVehiclesByCategory] Cleared list for page 1 or refresh',
        );
      }

      debugPrint(
        '📝 [fetchBuyVehiclesByCategory] Current list size before adding: ${buyVehiclesList.length}',
      );
      debugPrint(
        '📝 [fetchBuyVehiclesByCategory] Adding ${response.vehicles.length} new vehicles',
      );

      // Add new vehicles to the list
      final List<BuyVehicle> newVehicles = response.vehicles;
      buyVehiclesList.addAll(newVehicles);

      debugPrint(
        '📝 [fetchBuyVehiclesByCategory] List size after adding: ${buyVehiclesList.length}',
      );

      // Force refresh the observable list to ensure UI updates
      buyVehiclesList.refresh();

      // Update pagination info
      buyVehiclesTotalPages.value = response.totalPages;
      buyVehiclesTotalCount.value = response.totalCount;

      // Check if there are more pages
      hasMoreBuyVehicles.value = buyVehiclesPage.value < response.totalPages;

      // Increment page for next fetch if not refreshing
      if (hasMoreBuyVehicles.value && !isRefresh) {
        buyVehiclesPage.value++;
        debugPrint(
          '📄 [fetchBuyVehiclesByCategory] Incremented page to: ${buyVehiclesPage.value}',
        );
      }

      debugPrint(
        '✅ [fetchBuyVehiclesByCategory] Successfully fetched ${response.vehicles.length} vehicles. Total: ${response.totalCount}, Page: ${buyVehiclesPage.value - 1}/${response.totalPages}',
      );

      // Small delay to ensure UI processes the update
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('❌ [fetchBuyVehiclesByCategory] Error: $e');
      // Show user-friendly error message
      String errorMessage = 'Failed to fetch vehicles for category';
      if (e.toString().contains('User not logged in')) {
        errorMessage = 'Please log in to view vehicles';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingBuyVehiclesList.value = false;
    }
  }

  /// Fetch buy vehicles list with pagination
  Future<void> fetchBuyVehiclesList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        buyVehiclesList.clear();
        buyVehiclesPage.value = 1;
        hasMoreBuyVehicles.value = true;
      }

      if (!hasMoreBuyVehicles.value && !isRefresh) {
        return;
      }

      isLoadingBuyVehiclesList.value = true;

      // Get current user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final request = ListBuyVehiclesRequest(
        limit: 10,
        page: buyVehiclesPage.value,
        userId: userId,
        // No categoryCode for general listing (will fetch all categories)
      );

      final response = await _apiRepository.listBuyVehiclesWithFilters(request);

      // Clear list if this is the first page
      if (buyVehiclesPage.value == 1) {
        buyVehiclesList.clear();
      }

      buyVehiclesList.addAll(response.vehicles);

      // Update pagination info
      buyVehiclesTotalPages.value = response.totalPages;
      buyVehiclesTotalCount.value = response.totalCount;

      // Check if there are more pages
      hasMoreBuyVehicles.value = buyVehiclesPage.value < response.totalPages;

      // Increment page for next fetch
      if (hasMoreBuyVehicles.value) {
        buyVehiclesPage.value++;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch buy vehicles: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBuyVehiclesList.value = false;
    }
  }

  // buy vechile Details By ID

  Future<void> fetchBuyVehicleDetailsById(
    String sbVehicleId,
    String categoryCode,
  ) async {
    try {
      print(
        '🚗 [fetchBuyVehicleDetailsById] Starting API call for vehicle: $sbVehicleId',
      );

      // Get current user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      print('🔍 [fetchBuyVehicleDetailsById] User ID: $userId');
      print('🔍 [fetchBuyVehicleDetailsById] Vehicle ID: $sbVehicleId');
      print('🔍 [fetchBuyVehicleDetailsById] Category Code: $categoryCode');

      final request = VehicleDetailsByIdRequest(
        userId: userId,
        sbVehicleId: sbVehicleId,
        categoryCode: categoryCode,
      );

      final response = await _apiRepository.getVechileDeatislByID(request);

      print('✅ [fetchBuyVehicleDetailsById] API response received');
      print(
        '📊 [fetchBuyVehicleDetailsById] Vehicles count: ${response.data.vehicles.length}',
      );

      // Update the observable list with the vehicles from API response
      vechicleDetailsByID.value = response.data.vehicles;

      print(
        '✅ [fetchBuyVehicleDetailsById] Vehicle details updated successfully',
      );
    } catch (e, stackTrace) {
      print('❌ [fetchBuyVehicleDetailsById] Error: $e');
      print('📍 [fetchBuyVehicleDetailsById] Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to fetch vehicle details: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );

      // Clear the list on error
      vechicleDetailsByID.clear();
    }
  }

  /// Load more buy vehicles
  Future<void> loadMoreBuyVehicles() async {
    if (!hasMoreBuyVehicles.value || isLoadingBuyVehiclesList.value) {
      return;
    }

    await fetchBuyVehiclesList();
  }

  /// Load more buy vehicles for a specific category
  Future<void> loadMoreBuyVehiclesByCategory(String categoryCode) async {
    if (!hasMoreBuyVehicles.value || isLoadingBuyVehiclesList.value) {
      if (kDebugMode) {
        print(
          '🛑 Cannot load more: hasMore=${hasMoreBuyVehicles.value}, isLoading=${isLoadingBuyVehiclesList.value}',
        );
      }
      return;
    }

    if (kDebugMode) {
      print(
        '🚀 loadMoreBuyVehiclesByCategory: categoryCode=$categoryCode, currentPage=${buyVehiclesPage.value}',
      );
      print('🚀 Current list size before load: ${buyVehiclesList.length}');
    }

    try {
      await fetchBuyVehiclesByCategory(
        categoryCode: categoryCode,
        isRefresh: false, // Important: don't refresh, just append
      );

      if (kDebugMode) {
        print(
          '✅ loadMoreBuyVehiclesByCategory completed. New list size: ${buyVehiclesList.length}',
        );
      }

      // Force a UI update by refreshing the observable
      update();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error in loadMoreBuyVehiclesByCategory: $error');
      }
      rethrow;
    }
  }

  /// Refresh buy vehicles list
  Future<void> refreshBuyVehiclesList() async {
    await fetchBuyVehiclesList(isRefresh: true);
  }

  /// Get buy vehicle by ID
  BuyVehicle? getBuyVehicleById(String vehicleId) {
    try {
      return buyVehiclesList.firstWhere(
        (vehicle) => vehicle.sbVehicleId == vehicleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get buy vehicles by status
  List<BuyVehicle> getBuyVehiclesByStatus(String status) {
    return buyVehiclesList
        .where((vehicle) => vehicle.status == status)
        .toList();
  }

  /// Get approved buy vehicles
  List<BuyVehicle> getApprovedBuyVehicles() {
    return buyVehiclesList
        .where((vehicle) => vehicle.approved == 'yes')
        .toList();
  }

  /// Convenience method to fetch vehicles by brand and category
  Future<void> fetchVehiclesByBrandAndCategory({
    required String brandCode,
    required String categoryCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      brandCode: brandCode,
      categoryCode: categoryCode,
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by state
  Future<void> fetchVehiclesByState({
    required String stateCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      stateCode: stateCode,
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by year range
  Future<void> fetchVehiclesByYear({
    required int year,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      year: year.toString(),
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by body type
  Future<void> fetchVehiclesByBodyType({
    required String bodyType,
    String? categoryCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      bodyType: bodyType,
      categoryCode: categoryCode,
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by fuel type
  Future<void> fetchVehiclesByFuelType({
    required String fuelType,
    String? categoryCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      fuelType: fuelType,
      categoryCode: categoryCode,
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by KV rating
  Future<void> fetchVehiclesByKV({
    required String kv,
    String? categoryCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      kv: kv,
      categoryCode: categoryCode,
      isRefresh: isRefresh,
    );
  }

  /// Convenience method to fetch vehicles by tonnage
  Future<void> fetchVehiclesByTonnage({
    required String tonnage,
    String? categoryCode,
    bool isRefresh = true,
  }) async {
    await fetchBuyVehiclesWithFilters(
      tonnage: tonnage,
      categoryCode: categoryCode,
      isRefresh: isRefresh,
    );
  }

  /// Comprehensive method to apply all current filters
  Future<void> applyAllActiveFilters({
    String? categoryCode,
    bool isRefresh = true,
  }) async {
    // Get current filter values from controllers
    String? currentBrandFilter;
    if (brandFilterController.text.trim().isNotEmpty) {
      final brandName = brandFilterController.text.trim();
      final brand = getBrandByName(brandName);
      currentBrandFilter = brand?.brandCode;
    }
    String? currentStateFilter = stateFilterController.text.trim().isNotEmpty
        ? stateFilterController.text.trim()
        : null;
    String? currentTyreFilter;
    if (tyreFilterController.text.trim().isNotEmpty) {
      final tyreDisplayName = tyreFilterController.text.trim();
      final tyre = getTireByDisplayName(tyreDisplayName);
      currentTyreFilter = tyre?.tyreCode;
    }
    // Handle year filter - could be dynamic (string) or simple year (int)
    String? yearFilterValue;
    final yearController = getDynamicFilterController('Year');
    if (yearController != null && yearController.text.trim().isNotEmpty) {
      // Try to get the API value from dynamic mapping first
      yearFilterValue = getCurrentFilterApiValue('Year');
      if (yearFilterValue == null) {
        // Fallback to the displayed value if no mapping exists
        yearFilterValue = yearController.text.trim();
      }
    }

    // Get dynamic filter values
    String? currentBodyTypeFilter =
        getDynamicFilterController('Body Type')?.text.trim().isNotEmpty == true
        ? getCurrentFilterApiValue('Body Type') ??
              getDynamicFilterController('Body Type')!.text.trim()
        : null;
    String? currentFuelTypeFilter =
        getDynamicFilterController('Fuel Type')?.text.trim().isNotEmpty == true
        ? getCurrentFilterApiValue('Fuel Type') ??
              getDynamicFilterController('Fuel Type')!.text.trim()
        : null;
    String? currentKvFilter =
        getDynamicFilterController('KV')?.text.trim().isNotEmpty == true
        ? getCurrentFilterApiValue('KV') ??
              getDynamicFilterController('KV')!.text.trim()
        : null;
    String? currentTonnageFilter =
        getDynamicFilterController('Tonnage')?.text.trim().isNotEmpty == true
        ? getCurrentFilterApiValue('Tonnage') ??
              getDynamicFilterController('Tonnage')!.text.trim()
        : null;

    await fetchBuyVehiclesWithFilters(
      categoryCode: categoryCode,
      brandCode: currentBrandFilter,
      stateCode: currentStateFilter,
      tyreCode: currentTyreFilter,
      year: yearFilterValue, // Pass the string value directly
      bodyType: currentBodyTypeFilter,
      fuelType: currentFuelTypeFilter,
      kv: currentKvFilter,
      tonnage: currentTonnageFilter,
      isRefresh: isRefresh,
    );
  }

  /// Get pending buy vehicles
  List<BuyVehicle> getPendingBuyVehicles() {
    return buyVehiclesList
        .where((vehicle) => vehicle.approved != 'yes')
        .toList();
  }

  // ======================== USER INTEREST METHODS ========================

  /// User Interest Loading States
  final RxBool _isUserInterestLoading = false.obs;
  final RxString _userInterestError = ''.obs;

  /// Vehicle Details UI State Management
  final RxBool _isInterested = false.obs;
  final RxBool _isSubmittingOffer = false.obs;
  final RxBool _isSubscriptionLoading = false.obs;

  /// User Interest UI State Management
  final RxMap<String, bool> vehicleDetailCardExpanded = <String, bool>{
    'contact': false,
    'interest': false,
    'schedule': false,
    'share': false,
  }.obs;

  final Rx<TextEditingController> vehicleDetailContactController =
      TextEditingController().obs;

  // Getters for user interest
  bool get isUserInterestLoading => _isUserInterestLoading.value;
  String get userInterestError => _userInterestError.value;
  bool get isInterested => _isInterested.value;
  bool get isSubmittingOffer => _isSubmittingOffer.value;
  bool get isSubscriptionLoading => _isSubscriptionLoading.value;

  // Setters for UI state management
  set isInterested(bool value) => _isInterested.value = value;
  set isSubmittingOffer(bool value) => _isSubmittingOffer.value = value;
  set isSubscriptionLoading(bool value) => _isSubscriptionLoading.value = value;

  /// Toggle card expansion state
  void toggleCardExpansion(String cardType) {
    vehicleDetailCardExpanded[cardType] =
        !(vehicleDetailCardExpanded[cardType] ?? false);
  }

  /// Check if a card is expanded
  bool isCardExpanded(String cardType) {
    return vehicleDetailCardExpanded[cardType] ?? false;
  }

  /// Reset all card expansion states
  void resetCardExpansionStates() {
    vehicleDetailCardExpanded.updateAll((key, value) => false);
  }

  /// Reset vehicle detail UI states for new vehicle (but preserve API-driven states)
  void resetVehicleDetailStates() {
    _isSubmittingOffer.value = false;
    _isSubscriptionLoading.value = false;
    // Only reset card expansion states - let API response set them appropriately
    resetCardExpansionStates();
    vehicleDetailContactController.value.clear();
    // Note: _isInterested will be set based on API response, not reset here
  }

  /// Make Offer for Vehicle
  Future<bool> makeOffer({
    required String vehicleId,
    required double offerAmount,
  }) async {
    try {
      _isSubmittingOffer.value = true;
      _userInterestError.value = '';

      final userId = await _storageService.getUserId();

      final request = UserInterestRequest(
        userId: userId ?? '',
        vehicleId: vehicleId,
        vehicleOffer: offerAmount.toInt(),
        ownerDetailsAccess: "",
        vehicleDetailsAccess: "",
        inspectionRequest: "",
      );

      final response = await _apiRepository.createUserInterest(request);

      if (response.isSuccess) {
        Get.snackbar(
          'Offer Made',
          'Your offer of ₹${offerAmount.toStringAsFixed(0)} has been submitted successfully!',
          backgroundColor: AppColors.green,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _userInterestError.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to make offer: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      _isSubmittingOffer.value = false;
    }
  }

  /// Show Interest in Vehicle
  Future<bool> showInterest({
    required String vehicleId,
    required bool interested,
  }) async {
    try {
      _isUserInterestLoading.value = true;
      _userInterestError.value = '';

      final userId = await _storageService.getUserId() ?? 'VB0000001';

      final request = UserInterestRequest(
        userId: userId,
        vehicleId: vehicleId,
        isInterested: interested ? 'yes' : 'no',
        ownerDetailsAccess: "",
        vehicleOffer: null,
        vehicleDetailsAccess: "",
        inspectionRequest: "",
      );

      final response = await _apiRepository.createUserInterest(request);

      if (response.isSuccess) {
        Get.snackbar(
          interested ? 'Interest Shown' : 'Interest Removed',
          interested
              ? 'Your interest has been recorded successfully!'
              : 'Your interest has been removed.',
          backgroundColor: interested ? AppColors.green : AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _userInterestError.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to update interest: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      _isUserInterestLoading.value = false;
    }
  }

  /// Request Owner Details Access
  Future<bool> requestOwnerDetailsAccess({
    required String vehicleId,
    required bool requestAccess,
  }) async {
    try {
      _isUserInterestLoading.value = true;
      _userInterestError.value = '';

      final userId = await _storageService.getUserId() ?? '';

      final request = UserInterestRequest(
        userId: userId,
        vehicleId: vehicleId,
        ownerDetailsAccess: requestAccess ? 'yes' : 'no',
      );

      final response = await _apiRepository.createUserInterest(request);

      if (response.isSuccess) {
        // Get stored category code from payment flow
        String? categoryCode = _storageService.read(
          'current_vehicle_category_code',
        );

        // If no stored category code, try to find it from current vehicle lists
        if (categoryCode == null || categoryCode.isEmpty) {
          // Try to find vehicle in buy vehicles list
          final vehicle = getBuyVehicleById(vehicleId);
          if (vehicle != null) {
            categoryCode = vehicle.categoryCode;
            debugPrint(
              '🔍 [requestOwnerDetailsAccess] Found category code from buy list: $categoryCode',
            );
          } else {
            // Try subscribed vehicles list
            final subscribedVehicle = getSubscribedVehicleById(vehicleId);
            if (subscribedVehicle != null) {
              categoryCode = subscribedVehicle.categoryCode;
              debugPrint(
                '🔍 [requestOwnerDetailsAccess] Found category code from subscribed list: $categoryCode',
              );
            }
          }
        } else {
          debugPrint(
            '🔄 [requestOwnerDetailsAccess] Using stored category code: $categoryCode',
          );
        }

        // Fallback to empty string if still not found
        categoryCode = categoryCode ?? '';

        debugPrint(
          '🚀 [requestOwnerDetailsAccess] Calling fetchBuyVehicleDetailsById with categoryCode: "$categoryCode", vehicleId: "$vehicleId"',
        );

        // Refresh vehicle details to show updated owner details access status
        await fetchBuyVehicleDetailsById(vehicleId, categoryCode);

        Get.snackbar(
          requestAccess ? 'Access Requested' : 'Request Cancelled',
          requestAccess
              ? 'Request for owner details access submitted successfully!'
              : 'Your access request has been cancelled.',
          backgroundColor: requestAccess ? AppColors.green : AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _userInterestError.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to request owner details access: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      _isUserInterestLoading.value = false;
    }
  }

  /// Request Vehicle Details Access
  Future<bool> requestVehicleDetailsAccess({
    required String vehicleId,
    required bool requestAccess,
  }) async {
    try {
      _isUserInterestLoading.value = true;
      _userInterestError.value = '';

      final userId = await _storageService.getUserId() ?? 'VB0000001';

      final request = UserInterestRequest(
        userId: userId,
        vehicleId: vehicleId,
        vehicleDetailsAccess: requestAccess ? 'yes' : 'no',
      );

      final response = await _apiRepository.createUserInterest(request);

      if (response.isSuccess) {
        Get.snackbar(
          requestAccess ? 'Access Granted' : 'Request Cancelled',
          requestAccess
              ? 'Vehicle details access granted successfully!'
              : 'Your access request has been cancelled.',
          backgroundColor: requestAccess ? AppColors.green : AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _userInterestError.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to request vehicle details access: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      _isUserInterestLoading.value = false;
    }
  }

  /// Request Vehicle Inspection
  Future<bool> requestVehicleInspection({
    required String vehicleId,
    required bool requestInspection,
  }) async {
    try {
      _isUserInterestLoading.value = true;
      _userInterestError.value = '';

      final userId = await _storageService.getUserId() ?? 'VB0000001';

      final request = UserInterestRequest(
        userId: userId,
        vehicleId: vehicleId,
        inspectionRequest: requestInspection ? 'yes' : 'no',
      );

      final response = await _apiRepository.createUserInterest(request);

      if (response.isSuccess) {
        // Get stored category code from payment flow
        String? categoryCode = _storageService.read(
          'current_vehicle_category_code',
        );

        // If no stored category code, try to find it from current vehicle lists
        if (categoryCode == null || categoryCode.isEmpty) {
          // Try to find vehicle in buy vehicles list
          final vehicle = getBuyVehicleById(vehicleId);
          if (vehicle != null) {
            categoryCode = vehicle.categoryCode;
            debugPrint(
              '🔍 [requestVehicleInspection] Found category code from buy list: $categoryCode',
            );
          } else {
            // Try subscribed vehicles list
            final subscribedVehicle = getSubscribedVehicleById(vehicleId);
            if (subscribedVehicle != null) {
              categoryCode = subscribedVehicle.categoryCode;
              debugPrint(
                '🔍 [requestVehicleInspection] Found category code from subscribed list: $categoryCode',
              );
            }
          }
        } else {
          debugPrint(
            '🔄 [requestVehicleInspection] Using stored category code: $categoryCode',
          );
        }

        // Fallback to empty string if still not found
        categoryCode = categoryCode ?? '';

        debugPrint(
          '🚀 [requestVehicleInspection] Calling fetchBuyVehicleDetailsById with categoryCode: "$categoryCode", vehicleId: "$vehicleId"',
        );

        // Refresh vehicle details to show updated inspection request status
        await fetchBuyVehicleDetailsById(vehicleId, categoryCode);

        Get.snackbar(
          requestInspection ? 'Inspection Requested' : 'Request Cancelled',
          requestInspection
              ? 'Vehicle inspection request submitted successfully!'
              : 'Your inspection request has been cancelled.',
          backgroundColor: requestInspection ? AppColors.green : AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _userInterestError.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to request vehicle inspection: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      _isUserInterestLoading.value = false;
    }
  }

  // Vehicle Update Management
  /// Update an existing vehicle with modified data
  Future<bool> updateVehicle(String vehicleId) async {
    try {
      print('🔄 [updateVehicle] Starting vehicle update for ID: $vehicleId');

      // Validate all dynamic fields
      if (!validateAllDynamicFields()) {
        print('❌ [updateVehicle] Form validation failed');
        Get.snackbar(
          'Validation Error',
          'Please fix all form errors before updating',
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      isSubmittingSellForm.value = true;

      // Get user ID from storage service
      final userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      // Create update request with only modified fields
      final request = UpdateVehicleRequest(
        userId: userId,
        sbVehicleId: vehicleId,
        // Add all dynamic form values as optional fields
        registrationNumber: _getDynamicFormValueAsString('Registration Number'),
        brandCode: _getBrandCodeFromDynamicForm(),
        assetDescOrModel: _getDynamicFormValueAsString(
          'Asset Description or Model',
        ),
        manufacturingYear: _getDynamicFormValueAsInt('Manufacturing Year'),
        chassisNumber: _getDynamicFormValueAsString('Chassis Number'),
        price: _getPriceValueAsDouble(),
        odometer: _getDynamicFormValueAsString('Odometer'),
        noOfTyres: _getDynamicFormValueAsString('Number of Tyres'),
        ownerMobile: _getDynamicFormValueAsString('Owner Mobile Number'),
        stateCode: _getStateCodeFromDynamicForm(),
        cityCode: _getCityCodeFromDynamicForm(),
        fitness: _getDynamicFormValueAsBool('Fitness'),
        insurance: _getInsuranceStatus(),
        originalInvoice: _getDynamicFormValueAsBool('Original Invoice'),
        gstApplicability: _getDynamicFormValueAsBool('GST Applicability'),
        // Optional fields
        tonnage: _getDynamicFormValueAsString('Tonnage'),
        hours: _getDynamicFormValueAsString('Hours'),
        bodyType: _getBodyTypeFromDynamicForm(),
        fuelType: _getDynamicFormValueAsString('Fuel Type'),
        kv: _getDynamicFormValueAsString('KV'),
        otherBrand: otherBrandController.text.trim().isNotEmpty
            ? otherBrandController.text.trim()
            : null,
        otherTipper: otherTipperController.text.trim().isNotEmpty
            ? otherTipperController.text.trim()
            : null,
        otherBodyType: otherBodyTypeController.text.trim().isNotEmpty
            ? otherBodyTypeController.text.trim()
            : null,
        otherTyre: otherTyreController.text.trim().isNotEmpty
            ? otherTyreController.text.trim()
            : null,
      );

      // Get files from dynamic form values (new files to add)
      List<File>? imageFiles;
      List<File>? rcFiles;
      List<File>? insuranceFilesList;

      final vehicleImages = _getDynamicFormValueAsFileList('Vehicle Images');
      final rcDocuments = _getDynamicFormValueAsFileList('Upload Vehicle RC');
      final insuranceDocuments = _getDynamicFormValueAsFileList(
        'Upload Vehicle Insurance',
      );

      if (vehicleImages.isNotEmpty) {
        imageFiles = vehicleImages
            .map((platformFile) => File(platformFile.path!))
            .toList();
      }

      if (rcDocuments.isNotEmpty) {
        rcFiles = rcDocuments
            .map((platformFile) => File(platformFile.path!))
            .toList();
      }

      if (insuranceDocuments.isNotEmpty) {
        insuranceFilesList = insuranceDocuments
            .map((platformFile) => File(platformFile.path!))
            .toList();
      }

      print('🚀 [updateVehicle] Making API call...');
      print('📊 [updateVehicle] Request: ${request.toString()}');

      // Make API call
      final response = await _apiRepository.updateVehicle(
        request,
        imageFiles,
        rcFiles,
        insuranceFilesList,
      );

      print('📥 [updateVehicle] Response status: ${response.status}');
      print('📥 [updateVehicle] Response isSuccess: ${response.isSuccess}');
      print('📥 [updateVehicle] Response message: ${response.message}');

      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Success',
          'Vehicle updated successfully! Changes are pending admin approval.',
          backgroundColor: AppColors.green,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Refresh the sell vehicles list to get updated data
        try {
          await fetchSellVehiclesList(isRefresh: true);
          print('✅ [updateVehicle] Sell vehicles list refreshed successfully');
        } catch (refreshError) {
          print('⚠️ [updateVehicle] Error refreshing list: $refreshError');
          // Don't fail the update if refresh fails
        }

        print('✅ [updateVehicle] Vehicle updated successfully');
        return true;
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to update vehicle';
        print('❌ [updateVehicle] API returned error: $errorMessage');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return false;
      }
    } catch (e) {
      print('🔴 [updateVehicle] Error: $e');

      Get.snackbar(
        'Error',
        'Failed to update vehicle: ${e.toString()}',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isSubmittingSellForm.value = false;
    }
  }

  // Helper methods for getting form values safely
  double? _getPriceValueAsDouble() {
    final priceStr = _getDynamicFormValueAsString('Price');
    if (priceStr.isEmpty) return null;
    return double.tryParse(priceStr);
  }

  // Vehicle Sold Status Management
  Future<bool> updateVehicleSoldStatus(String vehicleId, String isSold) async {
    try {
      print(
        '🚗 [updateVehicleSoldStatus] Updating vehicle: $vehicleId, sold: $isSold',
      );
      final userId = await _storageService.getUserId() ?? '';

      final request = VehicleSoldRequest(
        sbVehicleId: vehicleId,
        isSold: isSold,
        userId: userId,
      );

      final response = await _apiRepository.updateVehicleSoldStatus(request);

      if (response.isSuccess) {
        // Refresh the vehicle list to get updated data
        await fetchSellVehiclesList(isRefresh: true);

        Get.snackbar(
          'Success',
          'Vehicle status updated successfully',
          backgroundColor: AppColors.green,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update vehicle status',
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      print('🔴 [updateVehicleSoldStatus] Error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }
}

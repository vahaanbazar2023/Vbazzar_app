import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/models/location_models.dart';
import '../../../theme/app_fonts.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/entities/finance_request_entity.dart';
import '../domain/entities/insurance_request_entity.dart';
import '../domain/entities/quote_entity.dart';
import '../domain/repositories/insurance_finance_repository.dart';

/// Main controller for the Insurance & Finance module.
///
/// Manages 2 tabs (Insurance, Finance), form state, validation,
/// file uploads, and My Quotes data loading.
class InsuranceFinanceController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final InsuranceFinanceRepository _repository;
  final LocationService _locationService;

  InsuranceFinanceController({
    required InsuranceFinanceRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService;

  // ─── Tab state ──────────────────────────────────────────────

  late TabController tabController;
  final currentTabIndex = 0.obs;
  static const tabs = ['Insurance', 'Finance'];

  // ─── User ───────────────────────────────────────────────────

  String? _currentUserId;

  // ─── Loading states ─────────────────────────────────────────

  final isSubmitting = false.obs;
  final isLoadingQuotes = false.obs;
  final isDownloadingQuote = false.obs;

  // ─── Insurance form controllers ─────────────────────────────

  final vehicleNoController = TextEditingController();

  // ─── Insurance form state ───────────────────────────────────

  final selectedInsuranceType = ''.obs;
  final selectedClaim = ''.obs;
  final isTermsAccepted = false.obs;
  final rcCopyFiles = <PlatformFile>[].obs;
  final aadharFiles = <PlatformFile>[].obs;
  final panFiles = <PlatformFile>[].obs;
  final previousPolicyFiles = <PlatformFile>[].obs;

  // ─── Insurance validation errors ────────────────────────────

  final vehicleNoError = ''.obs;
  final rcFileError = ''.obs;
  final insuranceTypeError = ''.obs;
  final claimError = ''.obs;
  final termsError = ''.obs;

  // ─── Finance form controllers ───────────────────────────────

  final vehicleNoFinanceController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final vehicleLocationController = TextEditingController();
  final fleetSizeController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final mobileCoApplicantNumberController = TextEditingController();

  // ─── Finance form state ─────────────────────────────────────

  final selectedFinanceState = Rx<String?>(null);
  final selectedFinanceCity = Rx<String?>(null);
  final isCoapplicant = false.obs;
  final states = <StateModel>[].obs;
  final cities = <CityModel>[].obs;
  final isLoadingStates = true.obs;
  final isLoadingCities = false.obs;
  final clearCounter = 0.obs;

  // Finance file state
  final rcCopyFinanceFiles = <PlatformFile>[].obs;
  final insuranceCopyFiles = <PlatformFile>[].obs;
  final companyGstFiles = <PlatformFile>[].obs;
  final aadharFinanceFiles = <PlatformFile>[].obs;
  final panFinanceFiles = <PlatformFile>[].obs;
  final aadharCoApplicantFinanceFiles = <PlatformFile>[].obs;
  final panCoApplicantFinanceFiles = <PlatformFile>[].obs;

  // ─── Finance validation errors ──────────────────────────────

  final financeVehicleNoError = ''.obs;
  final stateError = ''.obs;
  final cityError = ''.obs;
  final rcFinanceFileError = ''.obs;
  final insuranceFinanceFileError = ''.obs;
  final vehicleLocationError = ''.obs;
  final applicantAadharFileError = ''.obs;
  final applicantPanFileError = ''.obs;
  final mobileNumberError = ''.obs;
  final coApplicantAadharFileError = ''.obs;
  final coApplicantPanFileError = ''.obs;
  final coApplicantMobileError = ''.obs;

  // ─── My Quotes state ────────────────────────────────────────

  final vehicleQuotes = <VehicleQuoteItemEntity>[].obs;
  final quotesErrorMessage = ''.obs;
  final expandedVehicleIds = <String>{}.obs;

  // ─── Lifecycle ──────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(_onTabChanged);
    _initializeData();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();

    // Dispose insurance text controllers
    vehicleNoController.dispose();

    // Dispose finance text controllers
    vehicleNoFinanceController.dispose();
    stateController.dispose();
    cityController.dispose();
    vehicleLocationController.dispose();
    fleetSizeController.dispose();
    mobileNumberController.dispose();
    mobileCoApplicantNumberController.dispose();

    super.onClose();
  }

  // ─── Initialization ─────────────────────────────────────────

  Future<void> _initializeData() async {
    _currentUserId =
        await SecureStorageService.instance.read(StorageKeys.userId);
    _loadStates();
  }

  // ─── Tab management ─────────────────────────────────────────

  void _onTabChanged() {
    if (!tabController.indexIsChanging) return;
    final index = tabController.index;
    currentTabIndex.value = index;

    // Clear errors when switching tabs
    if (index == 0) {
      _clearFinanceErrors();
    } else {
      _clearInsuranceErrors();
    }
  }

  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  // ─── Insurance form: validation ─────────────────────────────

  void validateVehicleNo(String value) {
    if (value.isEmpty) {
      vehicleNoError.value = 'vehicleNoRequired';
    } else if (value.length < 6) {
      vehicleNoError.value = 'vehicleNoMinLength';
    } else {
      vehicleNoError.value = '';
    }
  }

  bool _validateInsuranceForm() {
    bool isValid = true;

    // Vehicle number
    if (vehicleNoController.text.isEmpty) {
      vehicleNoError.value = 'vehicleNoRequired';
      isValid = false;
    } else if (vehicleNoController.text.length < 6) {
      vehicleNoError.value = 'vehicleNoMinLength';
      isValid = false;
    } else {
      vehicleNoError.value = '';
    }

    // RC document
    if (rcCopyFiles.isEmpty) {
      rcFileError.value = 'rcFileRequired';
      isValid = false;
    } else {
      rcFileError.value = '';
    }

    // Insurance type
    if (selectedInsuranceType.value.isEmpty) {
      insuranceTypeError.value = 'insuranceTypeRequired';
      isValid = false;
    } else {
      insuranceTypeError.value = '';
    }

    // Claim status
    if (selectedClaim.value.isEmpty) {
      claimError.value = 'claimRequired';
      isValid = false;
    } else {
      claimError.value = '';
    }

    // Terms
    if (!isTermsAccepted.value) {
      termsError.value = 'termsRequired';
      isValid = false;
    } else {
      termsError.value = '';
    }

    return isValid;
  }

  void _clearInsuranceErrors() {
    vehicleNoError.value = '';
    rcFileError.value = '';
    insuranceTypeError.value = '';
    claimError.value = '';
    termsError.value = '';
  }

  // ─── Insurance form: submission ─────────────────────────────

  Future<void> submitInsuranceRequest() async {
    if (!_validateInsuranceForm()) return;

    final userId = _currentUserId;
    if (userId == null) {
      _showErrorSnackbar('Please login to submit insurance request');
      return;
    }

    isSubmitting.value = true;
    _clearInsuranceErrors();

    try {
      final request = InsuranceRequestEntity(
        userId: userId,
        vehicleNo: vehicleNoController.text.trim(),
        insuranceType: selectedInsuranceType.value,
        claimType: selectedClaim.value,
        acceptedTerms: isTermsAccepted.value ? 'checked' : 'unchecked',
      );

      // Build file map
      final files = <String, dynamic>{};
      if (rcCopyFiles.isNotEmpty) {
        files['rc_file'] = _createMultipartFile(rcCopyFiles.first);
      }
      if (aadharFiles.isNotEmpty) {
        files['aadhar_file'] = _createMultipartFile(aadharFiles.first);
      }
      if (panFiles.isNotEmpty) {
        files['pan_file'] = _createMultipartFile(panFiles.first);
      }
      if (previousPolicyFiles.isNotEmpty) {
        files['previous_policy_file'] =
            _createMultipartFile(previousPolicyFiles.first);
      }

      final result = await _repository.submitInsuranceRequest(
        request: request,
        files: files.cast(),
      );

      // ── Debug logging ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📋 INSURANCE RESULT');
      debugPrint('Success: ${result.success}');
      debugPrint('Message: ${result.message}');
      debugPrint('Error: ${result.errorMessage}');
      debugPrint('══════════════════════════════════════════');

      if (result.success) {
        _resetInsuranceForm();
        _showSuccessDialog(
          'Insurance request submitted successfully! Our team will review and get back to you soon.',
        );
      } else {
        final errorDetail = result.errorMessage != null && result.errorMessage!.isNotEmpty
            ? '\n${result.errorMessage}'
            : '';
        _showErrorSnackbar('${result.message}$errorDetail');
      }
    } catch (e) {
      debugPrint('❌ INSURANCE EXCEPTION: $e');
      _showErrorSnackbar('An unexpected error occurred. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetInsuranceForm() {
    vehicleNoController.clear();
    selectedInsuranceType.value = '';
    selectedClaim.value = '';
    isTermsAccepted.value = false;
    rcCopyFiles.clear();
    aadharFiles.clear();
    panFiles.clear();
    previousPolicyFiles.clear();
    _clearInsuranceErrors();
  }

  // ─── Finance form: state/city management ────────────────────

  Future<void> _loadStates() async {
    try {
      isLoadingStates.value = true;
      final loadedStates = await _locationService.fetchStates();
      states.assignAll(loadedStates);
    } catch (e) {
      _showErrorSnackbar('Failed to load states');
    } finally {
      isLoadingStates.value = false;
    }
  }

  void selectStateForFinance(StateModel state) {
    selectedFinanceState.value = state.stateName;
    stateController.text = state.stateName;

    // Clear city when state changes
    selectedFinanceCity.value = null;
    cityController.clear();
    cities.clear();

    // Load cities for the selected state
    _loadCitiesForFinance(state.stateId);
  }

  void clearStateForFinance() {
    selectedFinanceState.value = null;
    stateController.clear();
    selectedFinanceCity.value = null;
    cityController.clear();
    cities.clear();
    clearCounter.value++;
  }

  Future<void> _loadCitiesForFinance(String stateId) async {
    try {
      isLoadingCities.value = true;
      final loadedCities = await _locationService.fetchCities(stateId);
      cities.assignAll(loadedCities);
    } catch (e) {
      _showErrorSnackbar('Failed to load cities');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void selectCityForFinance(CityModel city) {
    selectedFinanceCity.value = city.cityName;
    cityController.text = city.cityName;
  }

  void clearCityForFinance() {
    selectedFinanceCity.value = null;
    cityController.clear();
    clearCounter.value++;
  }

  // ─── Finance form: validation ───────────────────────────────

  bool _validateFinanceForm() {
    bool isValid = true;

    // Vehicle number
    if (vehicleNoFinanceController.text.isEmpty) {
      financeVehicleNoError.value = 'vehicleNoRequired';
      isValid = false;
    } else {
      financeVehicleNoError.value = '';
    }

    // State
    if (selectedFinanceState.value == null ||
        selectedFinanceState.value!.isEmpty) {
      stateError.value = 'stateRequired';
      isValid = false;
    } else {
      stateError.value = '';
    }

    // City
    if (selectedFinanceCity.value == null ||
        selectedFinanceCity.value!.isEmpty) {
      cityError.value = 'cityRequired';
      isValid = false;
    } else {
      cityError.value = '';
    }

    // RC copy
    if (rcCopyFinanceFiles.isEmpty) {
      rcFinanceFileError.value = 'rcFinanceFileRequired';
      isValid = false;
    } else {
      rcFinanceFileError.value = '';
    }

    // Insurance copy
    if (insuranceCopyFiles.isEmpty) {
      insuranceFinanceFileError.value = 'insuranceFinanceFileRequired';
      isValid = false;
    } else {
      insuranceFinanceFileError.value = '';
    }

    // Vehicle location
    if (vehicleLocationController.text.isEmpty) {
      vehicleLocationError.value = 'vehicleLocationRequired';
      isValid = false;
    } else {
      vehicleLocationError.value = '';
    }

    // Applicant Aadhar
    if (aadharFinanceFiles.isEmpty) {
      applicantAadharFileError.value = 'applicantAadharFileRequired';
      isValid = false;
    } else {
      applicantAadharFileError.value = '';
    }

    // Applicant PAN
    if (panFinanceFiles.isEmpty) {
      applicantPanFileError.value = 'applicantPanFileRequired';
      isValid = false;
    } else {
      applicantPanFileError.value = '';
    }

    // Mobile number
    if (mobileNumberController.text.isEmpty) {
      mobileNumberError.value = 'mobileNumberRequired';
      isValid = false;
    } else {
      mobileNumberError.value = '';
    }

    // Co-applicant fields (conditional)
    if (isCoapplicant.value) {
      if (aadharCoApplicantFinanceFiles.isEmpty) {
        coApplicantAadharFileError.value = 'coApplicantAadharFileRequired';
        isValid = false;
      } else {
        coApplicantAadharFileError.value = '';
      }

      if (panCoApplicantFinanceFiles.isEmpty) {
        coApplicantPanFileError.value = 'coApplicantPanFileRequired';
        isValid = false;
      } else {
        coApplicantPanFileError.value = '';
      }

      if (mobileCoApplicantNumberController.text.isEmpty) {
        coApplicantMobileError.value = 'coApplicantMobileRequired';
        isValid = false;
      } else {
        coApplicantMobileError.value = '';
      }
    } else {
      coApplicantAadharFileError.value = '';
      coApplicantPanFileError.value = '';
      coApplicantMobileError.value = '';
    }

    return isValid;
  }

  void _clearFinanceErrors() {
    financeVehicleNoError.value = '';
    stateError.value = '';
    cityError.value = '';
    rcFinanceFileError.value = '';
    insuranceFinanceFileError.value = '';
    vehicleLocationError.value = '';
    applicantAadharFileError.value = '';
    applicantPanFileError.value = '';
    mobileNumberError.value = '';
    coApplicantAadharFileError.value = '';
    coApplicantPanFileError.value = '';
    coApplicantMobileError.value = '';
  }

  // ─── Finance form: submission ───────────────────────────────

  Future<void> submitFinanceRequest() async {
    if (!_validateFinanceForm()) return;

    final userId = _currentUserId;
    if (userId == null) {
      _showErrorSnackbar('Please login to submit finance request');
      return;
    }

    isSubmitting.value = true;
    _clearFinanceErrors();

    try {
      final request = FinanceRequestEntity(
        userId: userId,
        vehicleNo: vehicleNoFinanceController.text.trim(),
        vehicleState: selectedFinanceState.value ?? '',
        vehicleCity: selectedFinanceCity.value ?? '',
        fleetSize: fleetSizeController.text.trim(),
        vehicleLocation: vehicleLocationController.text.trim(),
        applicantMobileNum: mobileNumberController.text.trim(),
        coApplicantDetails: isCoapplicant.value ? 'checked' : 'unchecked',
        coApplicantMobileNum:
            mobileCoApplicantNumberController.text.trim(),
      );

      // Build file map
      final files = <String, dynamic>{};
      if (rcCopyFinanceFiles.isNotEmpty) {
        files['rc_file'] = _createMultipartFile(rcCopyFinanceFiles.first);
      }
      if (insuranceCopyFiles.isNotEmpty) {
        files['insurance_file'] =
            _createMultipartFile(insuranceCopyFiles.first);
      }
      if (companyGstFiles.isNotEmpty) {
        files['company_gst_file'] =
            _createMultipartFile(companyGstFiles.first);
      }
      if (aadharFinanceFiles.isNotEmpty) {
        files['applicant_aadhar_file'] =
            _createMultipartFile(aadharFinanceFiles.first);
      }
      if (panFinanceFiles.isNotEmpty) {
        files['applicant_pan_file'] =
            _createMultipartFile(panFinanceFiles.first);
      }
      if (isCoapplicant.value) {
        if (aadharCoApplicantFinanceFiles.isNotEmpty) {
          files['co_applicant_aadhar_file'] =
              _createMultipartFile(aadharCoApplicantFinanceFiles.first);
        }
        if (panCoApplicantFinanceFiles.isNotEmpty) {
          files['co_applicant_pan_file'] =
              _createMultipartFile(panCoApplicantFinanceFiles.first);
        }
      }

      final result = await _repository.submitFinanceRequest(
        request: request,
        files: files.cast(),
      );

      // ── Debug logging ──
      debugPrint('══════════════════════════════════════════');
      debugPrint('📋 FINANCE RESULT');
      debugPrint('Success: ${result.success}');
      debugPrint('Message: ${result.message}');
      debugPrint('Error: ${result.errorMessage}');
      debugPrint('══════════════════════════════════════════');

      if (result.success) {
        _resetFinanceForm();
        _showSuccessDialog(
          'Finance request submitted successfully! Our team will review and get back to you soon.',
        );
      } else {
        final errorDetail = result.errorMessage != null && result.errorMessage!.isNotEmpty
            ? '\n${result.errorMessage}'
            : '';
        _showErrorSnackbar('${result.message}$errorDetail');
      }
    } catch (e) {
      debugPrint('❌ FINANCE EXCEPTION: $e');
      _showErrorSnackbar('An unexpected error occurred. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetFinanceForm() {
    vehicleNoFinanceController.clear();
    stateController.clear();
    cityController.clear();
    vehicleLocationController.clear();
    fleetSizeController.clear();
    mobileNumberController.clear();
    mobileCoApplicantNumberController.clear();
    selectedFinanceState.value = null;
    selectedFinanceCity.value = null;
    isCoapplicant.value = false;
    cities.clear();
    clearCounter.value++;
    rcCopyFinanceFiles.clear();
    insuranceCopyFiles.clear();
    companyGstFiles.clear();
    aadharFinanceFiles.clear();
    panFinanceFiles.clear();
    aadharCoApplicantFinanceFiles.clear();
    panCoApplicantFinanceFiles.clear();
    _clearFinanceErrors();
  }

  // ─── My Quotes ──────────────────────────────────────────────

  Future<void> loadVehicleQuotes() async {
    final userId = _currentUserId;
    if (userId == null) {
      quotesErrorMessage.value = 'Please login to view quotes';
      return;
    }

    isLoadingQuotes.value = true;
    quotesErrorMessage.value = '';

    try {
      final quotes = await _repository.getVehicleListingsQuotes(
        userId: userId,
      );
      vehicleQuotes.assignAll(quotes);
    } catch (e) {
      quotesErrorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
      vehicleQuotes.clear();
    } finally {
      isLoadingQuotes.value = false;
    }
  }

  Future<void> refreshQuotes() async {
    await loadVehicleQuotes();
  }

  void toggleVehicleExpansion(String vehicleId) {
    if (expandedVehicleIds.contains(vehicleId)) {
      expandedVehicleIds.remove(vehicleId);
    } else {
      expandedVehicleIds.add(vehicleId);
    }
  }

  // ─── File picker helpers ─────────────────────────────────

  Future<void> pickFiles(RxList<PlatformFile> targetList) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        targetList.addAll(result.files);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick file. Please try again.');
    }
  }

  void removeFile(RxList<PlatformFile> targetList, int index) {
    if (index >= 0 && index < targetList.length) {
      targetList.removeAt(index);
    }
  }

  // ─── File handling utilities ────────────────────────────────

  dynamic _createMultipartFile(PlatformFile file) {
    if (file.bytes != null) {
      return dio.MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    }
    return null;
  }

  // ─── Price formatting utility ───────────────────────────────

  String formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    final result = priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '₹$result';
  }

  // ─── My Quotes: PDF download ───────────────────────────────

  Future<void> downloadQuote(
    String pdfUrl,
    String providerName,
    String vehicleNo,
  ) async {
    if (pdfUrl.isEmpty || pdfUrl == '#') {
      _showErrorSnackbar('Download link not available');
      return;
    }

    try {
      isDownloadingQuote.value = true;

      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showErrorSnackbar(
              'Storage permission is required to download quotes');
          return;
        }
      }

      // Determine save directory
      String savePath;
      if (Platform.isAndroid) {
        final downloadsDir = await getExternalStorageDirectory();
        savePath = downloadsDir?.path ??
            (await getApplicationDocumentsDirectory()).path;
      } else {
        savePath = (await getApplicationDocumentsDirectory()).path;
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = providerName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final sanitizedVehicle = vehicleNo.replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = 'Quote_${sanitizedName}_${sanitizedVehicle}_$timestamp.pdf';
      final filePath = '$savePath/$fileName';

      // Download file
      final dioClient = dio.Dio();
      await dioClient.download(
        pdfUrl,
        filePath,
        options: dio.Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      // Open downloaded file
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        _showErrorSnackbar('Could not open the downloaded PDF');
      } else {
        Get.snackbar(
          'Downloaded',
          'Quote PDF saved successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } on dio.DioException catch (e) {
      String message;
      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          message = 'Request timeout. Please try again.';
          break;
        case dio.DioExceptionType.connectionError:
          message = 'Network error. Please check your connection.';
          break;
        default:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            message = 'Quote file not found.';
          } else if (statusCode == 403) {
            message = 'Access denied. Quote may have expired.';
          } else {
            message = 'Failed to download quote PDF.';
          }
      }
      _showErrorSnackbar(message);
    } catch (e) {
      _showErrorSnackbar('Failed to save quote PDF: ${e.toString()}');
    } finally {
      isDownloadingQuote.value = false;
    }
  }

  // ─── UI helpers ─────────────────────────────────────────────

  void _showErrorSnackbar(String message) {
    CustomSnackbar.show(
      message: message,
      type: SnackbarType.error,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contact Us Image
              Image.asset(
                'assets/images/png/contact_us.png',
                width: 120.w,
                height: 120.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),

              // Thank You Title
              Text(
                'Thank you for submitting!',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Our team will contact you soon..!',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Okay Button
              SizedBox(
                width: double.infinity,
                child: GradientButton.filled(
                  text: 'Okay',
                  onPressed: () {
                    Get.back(); // Close dialog
                    _navigateToCategories();
                  },
                  height: 48.h,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToCategories() {
    Get.offAllNamed('/home');
  }

  /// Navigate to Terms & Conditions page.
  void navigateToTerms() {
    // TODO: Add terms route when available
    // Get.toNamed(AppRoutes.termsAndConditions);
  }
}
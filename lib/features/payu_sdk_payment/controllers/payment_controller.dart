import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:vahaan_bazar/core/api/api_repository.dart';
import 'package:vahaan_bazar/modules/auction/models/auction_vehicle_bid_model.dart';
import 'package:vahaan_bazar/modules/auction/controllers/auction_controller.dart';
import 'package:vahaan_bazar/modules/buy_and_sell/controllers/buy_sell_controller.dart';
import 'package:vahaan_bazar/modules/buy_and_sell/widgets/buy_vehicle_details.dart';
import 'package:vahaan_bazar/modules/inspection_valuation/controllers/inspection_valuation_controller.dart';
import 'package:vahaan_bazar/modules/service_support/controllers/service_support_controller.dart';
import 'package:vahaan_bazar/modules/spare_and_fms/controllers/spare_and_fms_controller.dart';
import 'package:vahaan_bazar/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/finance_success_dialog.dart';
import '../models/initiate_payment_model.dart';
import '../models/payment_status_callback.dart';
import '../services/payment_api_service.dart';
import '../services/hash_service.dart';
import '../config/payu_config.dart';

class PaymentController extends GetxController
    implements PayUCheckoutProProtocol {
  // Add Rx variables for merchantKey and saltKey
  final RxString merchantKey = ''.obs;
  final RxString saltKey = ''.obs;
  late PayUCheckoutProFlutter _checkoutPro;
  final StorageService _storageService = Get.find<StorageService>();
  final ApiRepository _apiRepository = Get.find<ApiRepository>();

  final RxBool isLoading = false.obs;
  final RxBool isPaymentSuccess = false.obs;

  // Vehicle-specific payment success tracking
  final RxMap<String, bool> vehiclePaymentSuccessForInspection =
      <String, bool>{}.obs;
  final RxMap<String, bool> vehiclePaymentSuccessForSubscribe =
      <String, bool>{}.obs;

  // Vehicle-specific inspection request tracking
  final RxMap<String, String> vehicleInspectionRequestStatus =
      <String, String>{}.obs;

  // Helper methods for vehicle-specific payment success tracking
  bool isPaymentSuccessForInspection(String vehicleId) {
    return vehiclePaymentSuccessForInspection[vehicleId] ?? false;
  }

  bool isPaymentSuccessForSubscribe(String vehicleId) {
    return vehiclePaymentSuccessForSubscribe[vehicleId] ?? false;
  }

  void setPaymentSuccessForInspection(String vehicleId, bool success) {
    vehiclePaymentSuccessForInspection[vehicleId] = success;
  }

  void setPaymentSuccessForSubscribe(String vehicleId, bool success) {
    vehiclePaymentSuccessForSubscribe[vehicleId] = success;
  }

  // Helper methods for vehicle inspection request status tracking
  String getVehicleInspectionStatus(String vehicleId) {
    return vehicleInspectionRequestStatus[vehicleId] ?? 'no';
  }

  void setVehicleInspectionStatus(String vehicleId, String status) {
    vehicleInspectionRequestStatus[vehicleId] = status;
  }

  void clearVehiclePaymentStatus(String vehicleId) {
    vehiclePaymentSuccessForInspection.remove(vehicleId);
    vehiclePaymentSuccessForSubscribe.remove(vehicleId);
    vehicleInspectionRequestStatus.remove(vehicleId);
  }

  void clearAllVehiclePaymentStatus() {
    vehiclePaymentSuccessForInspection.clear();
    vehiclePaymentSuccessForSubscribe.clear();
    vehicleInspectionRequestStatus.clear();
  }

  final RxString paymentStatus = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentStep =
      'idle'.obs; // idle, initiating, launching, processing, completed

  Rxn<PaymentData> paymentDataList = Rxn<PaymentData>();

  PaymentData? _currentPaymentData;
  Completer<bool>? _paymentCompleter;

  /// Clear all subscription-related loading states across different controllers
  void _clearAllSubscriptionLoadingStates() {
    print('🔄 [URGENT] Clearing all subscription loading states...');

    try {
      // Clear PaymentController loading state
      isLoading.value = false;
      print('🔄 PaymentController.isLoading = false');

      // Clear AuctionController payment gateway loading state
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();
        final wasLoading = auctionController.isOpeningPaymentGateway.value;
        auctionController.isOpeningPaymentGateway.value = false;
        print(
          '🔄 AuctionController.isOpeningPaymentGateway = false (was: $wasLoading)',
        );

        // Force update on auction controller as well
        auctionController.update();
      } else {
        print('🔄 AuctionController not registered');
      }

      // Force UI update on this controller
      update();

      print(
        '🔄 [SUCCESS] All subscription loading states cleared and UI updated',
      );
    } catch (e) {
      print('🔄 [ERROR] Failed to clear loading states: $e');
    }

    // Note: Individual subscription plan widgets (SingleSubscriptionPlan, etc.)
    // manage their own isProcessingPayment states and should clear them in their dispose methods
  }

  @override
  void onInit() {
    super.onInit();
    _checkoutPro = PayUCheckoutProFlutter(this);
  }

  Future<bool> startPayment({required String planCode}) async {
    try {
      isLoading.value = true;
      currentStep.value = 'initiating';
      paymentStatus.value = 'initiating';
      errorMessage.value = '';

      // 🔍 DEBUG: Check storage context before starting payment
      final savedSource = await _storageService.getSubscriptionSource();
      print('🟢 START PAYMENT - Payment context:');
      print('   subscriptionSource: $savedSource');
      print('   planCode: $planCode');

      // Only read auction data if this is an auction-related payment
      if (savedSource?.contains('auction') == true ||
          planCode.contains('BID') ||
          planCode.contains('AUCTION')) {
        final savedAuctionId = await _storageService.getPendingAuctionId();
        final savedVehicleId = await _storageService.getPendingVehicleId();
        final savedBidAmount = await _storageService.getPendingBidAmount();
        print('   🏚️ AUCTION CONTEXT:');
        print('     auctionId: $savedAuctionId');
        print('     vehicleId: $savedVehicleId');
        print('     bidAmount: $savedBidAmount');
      } else {
        print('   ✅ SUBSCRIPTION-ONLY: No auction data needed');
      }

      // Get user ID from storage
      final storedUserId = await _storageService.getUserId();
      if (storedUserId == null || storedUserId.isEmpty) {
        throw Exception('User not authenticated. Please login first.');
      }

      final initiationResponse = await PaymentApiService.initiatePayment(
        InitiatePaymentReq(userId: storedUserId, planCode: planCode),
      );

      if (initiationResponse.status != 'success' ||
          initiationResponse.data == null) {
        throw Exception(initiationResponse.message);
      }

      _currentPaymentData = initiationResponse.data!;
      paymentDataList.value = initiationResponse.data!;
      // Assign merchantKey and saltKey from payment data
      merchantKey.value = _currentPaymentData?.merchantKey ?? '';
      saltKey.value = _currentPaymentData?.saltKey ?? '';
      // Assign to config and hash service for global/static access
      PayUConfig.setMerchantKey(merchantKey.value);
      PayUConfig.setSaltKey(saltKey.value);
      HashService.merchantSalt = saltKey.value;
      currentStep.value = 'launching';
      paymentStatus.value = 'launching';

      final payuParams = PayUConfig.createPayUPaymentParamsFromData(
        _currentPaymentData!,
      );
      final payuConfig = PayUConfig.createPayUConfigParams();

      _paymentCompleter = Completer<bool>();
      currentStep.value = 'processing';

      print(
        '🔄 Opening PayU Checkout Screen with params: $payuParams and config: $payuConfig',
      );

      await _checkoutPro.openCheckoutScreen(
        payUPaymentParams: payuParams,
        payUCheckoutProConfig: payuConfig,
      );

      print(
        '🔄 Opening PayU Checkout Screen with params: asdasdsadsadadadada $payuParams and config: $payuConfig',
      );

      return await _paymentCompleter!.future;
    } catch (e) {
      // Enhanced error logging for debugging
      print('❌ PAYMENT ERROR: ${e.toString()}');
      print('❌ ERROR TYPE: ${e.runtimeType}');
      if (e is Exception) {
        print('❌ EXCEPTION DETAILS: $e');
      }

      errorMessage.value = e.toString();
      paymentStatus.value = 'failed';
      currentStep.value = 'failed';

      // Clear loading states on error
      _clearAllSubscriptionLoadingStates();

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  generateHash(Map response) {
    // Backend will generate the hash which you need to pass to SDK
    // hashResponse: is the response which you get from your server

    //Keep the salt and hash calculation logic in the backend for security reasons. Don't use local hash logic.
    //Uncomment following line to test the test hash.
    Map hashResponse = HashService.generateHash(response);

    _checkoutPro.hashGenerated(hash: hashResponse);
  }

  // @override
  // generateHash(Map response) {
  //   // Backend will generate the hash which you need to pass to SDK
  //   // hashResponse: is the response which you get from your server

  //   // Use the hash from backend if available, otherwise generate locally
  //   Map hashResponse;

  //   if (_currentPaymentData?.payuFormData.hash != null &&
  //       _currentPaymentData!.payuFormData.hash.isNotEmpty) {
  //     // Use the hash provided by backend
  //     var hashName = response[PayUHashConstantsKeys.hashName];
  //     hashResponse = {hashName: _currentPaymentData!.payuFormData.hash};
  //     print('🔐 Using backend-provided hash for: $hashName');
  //   } else {
  //     // Fallback to local hash generation
  //     print('🔐 Generating hash locally as fallback');
  //     hashResponse = HashService.generateHash(response);
  //   }

  //   _checkoutPro.hashGenerated(hash: hashResponse);
  // }

  @override
  void onPaymentSuccess(dynamic response) async {
    // IMMEDIATELY clear loading states before any processing
    _clearAllSubscriptionLoadingStates();

    // Add small delay to ensure PayU SDK completes its internal processing
    await Future.delayed(const Duration(milliseconds: 300));

    paymentStatus.value = 'success';
    currentStep.value = 'completed';
    isPaymentSuccess.value = true;

    // CRITICAL: Complete the payment completer IMMEDIATELY after setting status.
    // This ensures startPayment() returns promptly even if post-processing fails.
    // Previously, this was at the very end of the method, meaning ANY unhandled
    // exception in post-processing would cause the completer to never complete,
    // making startPayment() hang forever.
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(true);
    }

    if (_currentPaymentData != null) {
      final callbackData = _createPaymentCallback(response, 'success');
      try {} catch (_) {}
      PaymentApiService.notifyPaymentSuccess(callbackData);
    }

    // Get subscription context
    String? subscriptionSource;
    try {
      subscriptionSource = await _storageService.getSubscriptionSource();
    } catch (e) {
      print('❌ Error reading subscription source: $e');
    }
    final auctionId = await _storageService.getPendingAuctionId();
    final auctionTitle = await _storageService.getPendingAuctionTitle();

    print('🎯 POST-PAYMENT: subscriptionSource=$subscriptionSource');
    print('🎯 POST-PAYMENT: auctionId=$auctionId');
    print('🎯 POST-PAYMENT: auctionTitle=$auctionTitle');

    // Handle different subscription types with appropriate navigation stack cleanup
    if (subscriptionSource == 'SUBT001') {
      // Auction access subscription - check if coming from category subscription

      // Check if user came from category subscription flow
      final fromCategorySubscription =
          Get.previousRoute == '/category-subscriptions' ||
          await _storageService.read('from_category_subscription') == true;

      print(
        '🎯 SUBT001 Navigation Context: fromCategorySubscription=$fromCategorySubscription',
      );

      // Remove subscription plan route from the navigation stack for SUBT001
      Get.until((route) => route.settings.name != AppRoutes.suscriptionPlan);

      if (Get.isRegistered<AuctionController>()) {
        final controller = Get.find<AuctionController>();

        // Comprehensive refresh of subscription data and vehicle data
        try {
          await controller.refreshAfterPayment();
        } catch (e) {
          print('Error refreshing data after SUBT001 payment: $e');
        }

        if (fromCategorySubscription) {
          // Category subscription flow - navigate to categories
          print(
            '📱 SUBT001: Category subscription flow - navigating to categories',
          );

          // Show success message for category subscription
          Get.snackbar(
            'Auction Access Activated! 🎉',
            'You can now browse auction categories',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );

          // Navigate to categories page
          Get.offAllNamed(AppRoutes.categories);

          // Clear the category subscription flag
          await _storageService.remove('from_category_subscription');
        } else {
          // Original auction flow - navigate to auctions list
          print('📱 SUBT001: Auction flow - navigating to auctions list');

          // Navigate to auctions list instead of specific vehicle list
          Get.toNamed(AppRoutes.auctionsList);

          // Show success message for auction access
          Get.snackbar(
            'Auction Access Activated! 🎉',
            'You can now view and access auctions',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }

        // Clear subscription source after successful navigation
        await _storageService.removeSubscriptionSource();
      } else {}
    } else if (subscriptionSource == 'SUBT002') {
      // Bid limit subscription - requires AuctionController
      print('🎯 SUBT002 flow started - Bid limit subscription');

      // Check if user came from category subscription flow FIRST
      final fromCategorySubscription =
          Get.previousRoute == '/category-subscriptions' ||
          await _storageService.read('from_category_subscription') == true;

      print(
        '🎯 SUBT002 Navigation Context: fromCategorySubscription=$fromCategorySubscription',
      );

      // Remove subscription plan route from the navigation stack for SUBT002
      Get.until((route) => route.settings.name != AppRoutes.suscriptionPlan);
      print('🎯 Removed subscription plan from navigation stack');

      if (fromCategorySubscription) {
        // Category subscription flow - show success and navigate to categories
        print(
          '📱 SUBT002: Category subscription flow - navigating to categories',
        );

        Get.snackbar(
          'Bid Limit Activated! 🎉',
          'You can now browse auction categories with bidding access',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Navigate to categories page
        Get.offAllNamed(AppRoutes.categories);

        // Clear the category subscription flag and subscription source
        await _storageService.remove('from_category_subscription');
        await _storageService.removeSubscriptionSource();
        return; // Exit early for category subscription flow
      }

      // Continue with auction flow for SUBT002 (existing logic)
      print('📱 SUBT002: Auction flow - continuing with bid placement');

      // 🎯 STEP 1: Get pending bid data
      final vehicleId = await _storageService.getPendingVehicleId();
      final bidAmount = await _storageService.getPendingBidAmount();
      final auctionId = await _storageService.getPendingAuctionId();
      final auctionTitle = await _storageService.getPendingAuctionTitle();

      print('🎯 Pending bid data retrieved:');
      print('   vehicleId=$vehicleId');
      print('   bidAmount=$bidAmount');
      print('   auctionId=$auctionId');
      print('   auctionTitle=$auctionTitle');

      // Validate we have all required data
      if (vehicleId == null || bidAmount == null || auctionId == null) {
        print(
          '❌ Missing pending bid data: vehicleId=$vehicleId, bidAmount=$bidAmount, auctionId=$auctionId',
        );

        // Navigate back to vehicle list if we have auction context
        if (auctionId != null && auctionId.isNotEmpty) {
          Get.toNamed(
            AppRoutes.vechileList,
            arguments: {
              'auctionId': auctionId,
              'auctionTitle': auctionTitle ?? 'Auction',
            },
          );
        } else {
          Get.back();
        }

        // Clear subscription source
        await _storageService.removeSubscriptionSource();
        return;
      }

      // Show immediate success message for faster UX
      Get.snackbar(
        'Bid Limit Activated! 🎉',
        'Your bid is being placed automatically',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
      );

      // 🎯 STEP 2: Navigate to vehicle list FIRST (before placing bid)
      if (auctionId.isNotEmpty) {
        Get.toNamed(
          AppRoutes.vechileList,
          arguments: {
            'auctionId': auctionId,
            'auctionTitle': auctionTitle ?? 'Auction',
          },
        );
        print(
          '✅ Navigated to vehicle list before bid placement: auctionId=$auctionId',
        );
      }

      // 🎯 STEP 3: Place pending bid with fresh subscription (bypass validation)
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();

        try {
          print(
            '🎯 STEP 3.1: Waiting for backend to process payment and update subscription...',
          );

          // Store OLD balance BEFORE payment to compare with new balance
          final oldBalance = auctionController.getAvailableBidLimit();
          print(
            '💰 OLD balance before payment: ${_formatCurrency(oldBalance)}',
          );
          print('💸 Pending bid amount: ${_formatCurrency(bidAmount)}');

          // CRITICAL: Backend needs time to process payment and update subscription
          // Add initial delay to allow payment processing to complete
          await Future.delayed(const Duration(seconds: 3));

          double freshBalance = oldBalance;
          int retryCount = 0;
          const maxRetries = 8; // Increased from 5 to 8 retries
          const retryDelayMs =
              2000; // Increased from 1500ms to 2000ms (2 seconds)

          // Retry mechanism: Keep refreshing until balance INCREASES from old value
          while (retryCount < maxRetries) {
            try {
              print(
                '🔄 Refresh attempt ${retryCount + 1}/$maxRetries - Fetching latest subscription...',
              );

              // Refresh subscription to get fresh balance after payment
              await auctionController.getMySuscription();

              // Get fresh balance after refresh
              freshBalance = auctionController.getAvailableBidLimit();

              print(
                '💰 Attempt ${retryCount + 1}: Available balance = ${_formatCurrency(freshBalance)}',
              );

              // Check if balance has INCREASED (new subscription added)
              if (freshBalance > oldBalance) {
                print(
                  '✅ SUCCESS! Balance increased from ${_formatCurrency(oldBalance)} to ${_formatCurrency(freshBalance)}',
                );
                print(
                  '💵 New subscription amount: ${_formatCurrency(freshBalance - oldBalance)}',
                );
                break;
              }

              // If balance hasn't increased and we haven't reached max retries, wait and retry
              if (retryCount < maxRetries - 1) {
                print(
                  '⚠️ Balance unchanged (${_formatCurrency(freshBalance)}), waiting ${retryDelayMs}ms before retry...',
                );
                await Future.delayed(Duration(milliseconds: retryDelayMs));
              }
            } catch (listError) {
              print(
                '⚠️ Subscription refresh attempt ${retryCount + 1} failed: $listError',
              );

              // Fallback: try subscription refresh with vehicle update
              try {
                await auctionController.getMySuscription();
                await auctionController.updateAvailableBalanceForAllVehicles();
                freshBalance = auctionController.getAvailableBidLimit();
                print(
                  '💰 Fallback subscription refresh: balance = ${_formatCurrency(freshBalance)}',
                );

                if (freshBalance > oldBalance) {
                  print('✅ Fallback refresh successful - balance increased!');
                  break;
                }
              } catch (subError) {
                print(
                  '⚠️ Fallback subscription refresh also failed: $subError',
                );
              }

              // Wait before retry even on error
              if (retryCount < maxRetries - 1) {
                await Future.delayed(Duration(milliseconds: retryDelayMs));
              }
            }

            retryCount++;
          }

          // Final balance check and validation
          print(
            '💰 FINAL CHECK - Available balance after payment: ${_formatCurrency(freshBalance)}',
          );
          print(
            '💰 OLD balance before payment: ${_formatCurrency(oldBalance)}',
          );
          print('💸 Pending bid amount: ${_formatCurrency(bidAmount)}');

          // Check if balance increased (new subscription was added)
          if (freshBalance > oldBalance) {
            print(
              '✅ Subscription successfully added! Balance increased by ${_formatCurrency(freshBalance - oldBalance)}',
            );
          } else if (freshBalance == oldBalance) {
            print(
              '⚠️ WARNING: Balance unchanged after $maxRetries attempts (${_formatCurrency(freshBalance)})',
            );
            print('⚠️ Backend may still be processing payment...');
            print(
              '⚠️ Proceeding with bid - backend will validate with latest data',
            );
          }

          // Validate bid amount against fresh balance
          if (freshBalance <= 0) {
            // Balance is still 0 after all retries - backend might still be processing
            print('⚠️ WARNING: Balance is still ₹0 after $maxRetries attempts');
            print(
              '⚠️ Backend may still be processing payment. Proceeding with bid placement...',
            );
            print(
              '⚠️ Backend will validate the bid with latest subscription data',
            );

            // Don't return here - let the backend validate
            // The bid API will check against the latest subscription in the database
          } else if (bidAmount > freshBalance) {
            // Balance is non-zero but bid exceeds it
            print(
              '❌ VALIDATION FAILED: Bid amount ${_formatCurrency(bidAmount)} exceeds available balance ${_formatCurrency(freshBalance)}',
            );

            // Check if balance didn't increase - payment might still be processing
            if (freshBalance == oldBalance) {
              print(
                '⚠️ NOTE: Balance unchanged from before payment - backend may still be processing',
              );
              print(
                '⚠️ Allowing bid placement - backend will validate with latest subscription',
              );
              // Continue to bid placement - backend will have the latest data
            } else {
              // Balance increased but still insufficient
              print(
                '❌ ERROR: Balance increased to ${_formatCurrency(freshBalance)} but still insufficient for bid ${_formatCurrency(bidAmount)}',
              );

              // Show error notification
              Get.snackbar(
                'Insufficient Balance',
                'Your bid amount ${_formatCurrency(bidAmount)} exceeds the available balance ${_formatCurrency(freshBalance)}.\n\nPlease purchase a higher subscription plan.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.error, color: Colors.white),
                duration: const Duration(seconds: 5),
              );

              // Clear pending data since we confirmed bid exceeds new subscription
              await _storageService.clearAllPendingBidData();
              print(
                '⚠️ Cleared pending data - bid confirmed to exceed subscription balance',
              );

              // Clear subscription source
              await _storageService.removeSubscriptionSource();
              return;
            }
          } else {
            // Balance is valid and sufficient
            print(
              '✅ VALIDATION PASSED: Bid amount ${_formatCurrency(bidAmount)} is within available balance ${_formatCurrency(freshBalance)}',
            );
          }

          // Get user ID for API call
          final storedUserId = await _storageService.getUserId();
          if (storedUserId == null) {
            throw Exception('User ID not found');
          }

          print('🎯 STEP 3.2: Placing bid via API (bypassing validation)...');

          // Create bid request
          final bidRequest = AuctionVehicleBidRequest(
            auctionId: auctionId,
            bidAmount: bidAmount,
            userId: storedUserId,
            vehicleId: vehicleId,
          );

          // Place bid directly via API (bypass validateBidAmount to avoid re-triggering subscription flow)
          final response = await _apiRepository.getAuctionVehicleBid(
            bidRequest,
          );

          // Check response
          if (response.status == 'success' && response.data != null) {
            print('✅ Pending bid placed successfully via API');

            // Extract response data
            final bidId = response.data?.bidId ?? 0;
            final remainingLimit = response.data?.remainingBidLimit ?? 0.0;

            print('🎯 STEP 3.3: Updating vehicle data with new balance...');

            // Send bid notification
            try {
              await auctionController.sendBidPlacedNotification(
                vehicleId: vehicleId,
                bidAmount: bidAmount,
                auctionId: auctionId,
                bidId: bidId,
              );
              print('✅ Bid notification sent');
            } catch (notifError) {
              print('⚠️ Bid notification failed: $notifError');
            }

            // Update vehicle data with remaining balance (updates in-memory data)
            auctionController.updateVehicleDataAfterBid(
              vehicleId,
              bidAmount,
              remainingLimit,
            );
            print(
              '✅ Vehicle data updated with remaining balance: ${_formatCurrency(remainingLimit)}',
            );

            // 🔥 CRITICAL: Refresh vehicle list in-place to update UI with fresh data from backend
            // This maintains scroll position and current page while fetching latest bid data
            print(
              '🔄 Refreshing vehicle data in-place to sync with backend...',
            );
            try {
              await auctionController.refreshVehicleDataInPlace(auctionId);
              print(
                '✅ Vehicle list refreshed in-place - UI synced with backend',
              );
            } catch (refreshError) {
              print('⚠️ Failed to refresh vehicle list: $refreshError');
              // Continue even if refresh fails - in-memory update already done
            }

            // Clear pending bid data after success
            await _storageService.clearAllPendingBidData();
            print('✅ Pending bid data cleared');

            // Show success message
            final formattedBidAmount = _formatCurrency(bidAmount);
            final formattedRemainingLimit = _formatCurrency(remainingLimit);
            final successMessage = response.message.isNotEmpty
                ? response.message
                : 'Bid placed successfully for $formattedBidAmount!';

            Get.snackbar(
              'Bid Placed Successfully! 🎉',
              '$successMessage\nRemaining limit: $formattedRemainingLimit',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              duration: const Duration(seconds: 4),
            );
          } else {
            // Bid placement failed
            print('❌ Pending bid placement failed: ${response.message}');

            // Extract error details
            String errorTitle = 'Bid Placement Failed';
            String errorMessage = response.message.isNotEmpty
                ? response.message
                : 'Failed to place bid after payment. Please try again.';

            // Customize error based on type
            if (response.message.contains('exceeds your available bid limit') ||
                response.message.contains('BID_EXCEEDS_LIMIT')) {
              errorTitle = 'Bid Limit Exceeded';
            } else if (response.message.contains('AUCTION_INACTIVE') ||
                response.message.contains('auction is not active')) {
              errorTitle = 'Auction Closed';
            }

            // Show error notification
            Get.snackbar(
              errorTitle,
              errorMessage,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              icon: const Icon(Icons.error, color: Colors.white),
              duration: const Duration(seconds: 5),
            );

            // Refresh subscription and vehicle data to show correct balance
            try {
              await auctionController.getMySuscription();
              await auctionController.updateAvailableBalanceForAllVehicles();
              print('✅ Refreshed data after bid failure');
            } catch (refreshError) {
              print('⚠️ Failed to refresh data: $refreshError');
            }

            // Don't clear pending data - user might want to retry with adjusted amount
            print('⚠️ Keeping pending data for potential retry');
          }
        } catch (e) {
          print('❌ Exception in post-payment bid placement: $e');

          // Show error notification
          Get.snackbar(
            'Bid Failed',
            'Failed to place bid after payment: ${e.toString()}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.white),
            duration: const Duration(seconds: 4),
          );

          // Refresh balance even on exception
          try {
            await auctionController.getMySuscription();
            await auctionController.updateAvailableBalanceForAllVehicles();
            print('✅ Refreshed data after exception');
          } catch (refreshError) {
            print('⚠️ Failed to refresh data: $refreshError');
          }

          // Don't clear pending data on exception
          print('⚠️ Keeping pending data for potential retry');
        }
      } else {
        print('❌ AuctionController not registered');

        // Show error
        Get.snackbar(
          'Error',
          'Unable to place bid. Please try again manually.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      // Clear subscription source after processing
      await _storageService.removeSubscriptionSource();
    } else if (subscriptionSource == 'SUBT003') {
      // Vehicle details access subscription - no AuctionController needed

      // Remove singleSubscriptionPlan route from the navigation stack for SUBT003
      Get.until(
        (route) => route.settings.name != AppRoutes.singleSubscriptionPlan,
      );

      // Call requestOwnerDetailsAccess API after successful SUBT003 payment
      try {
        final vehicleData = StorageService.to.read('current_vehicle');
        if (vehicleData != null && vehicleData is Map<String, dynamic>) {
          final vehicleId = vehicleData['sb_vehicle_id'];
          if (vehicleId != null) {
            // Set payment success for this specific vehicle
            setPaymentSuccessForSubscribe(vehicleId.toString(), true);

            // Find BuySellController if available to call the API
            if (Get.isRegistered<BuySellController>()) {
              final buySellController = Get.find<BuySellController>();
              await buySellController.requestOwnerDetailsAccess(
                vehicleId: vehicleId,
                requestAccess: true,
              );
            } else {}
          } else {}
        } else {}
      } catch (e) {}

      // Try to refresh subscription data if AuctionController is available
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();
        try {
          // Use comprehensive refresh method for complete data update
          await auctionController.refreshAfterPayment();
        } catch (e) {
          print('Error refreshing data after SUBT003 payment: $e');
        }
      }

      // Clear subscription source from storage since payment is complete
      await _storageService.removeSubscriptionSource();

      // Show success message
      Get.snackbar(
        'Vehicle Access Activated! 🎉',
        'You can now view detailed vehicle information',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Navigate back to vehicle details after successful SUBT003 purchase

      // Add a small delay to ensure PayU SDK completes its process
      await Future.delayed(Duration(milliseconds: 500));

      // Option 1: Try using stored vehicle data
      final vehicleData = StorageService.to.read('current_vehicle');

      if (vehicleData != null) {
        // Navigate to BuyVehicleDetails with stored vehicle data

        // Clean up stored data
        StorageService.to.remove('current_vehicle');

        try {
          // Use offAllNamed to clear the navigation stack and ensure clean navigation
          // Get.offAllNamed(AppRoutes.buyVehicleDetails, arguments: vehicleData);
        } catch (e) {
          // Fallback to simple back navigation
          Get.back();
        }
      } else {
        // Option 2: Use simple back navigation

        // Since the navigation stack is: VehicleDetails -> SubscriptionPlan
        // Get.back() should return to VehicleDetails
        Get.back();
      }
    } else if (subscriptionSource == 'SUBT004') {
      // Buy & Sell vehicle details access subscription
      try {
        // Remove subscription plan route from the navigation stack for SUBT004
        Get.until((route) => route.settings.name != AppRoutes.suscriptionPlan);

        // Get vehicle information from storage
        final vehicleData = StorageService.to.read('current_vehicle');
        String? vehicleId;
        String? categoryCode;

        if (vehicleData != null && vehicleData is Map<String, dynamic>) {
          vehicleId = vehicleData['sb_vehicle_id'] as String?;
          categoryCode = vehicleData['category_code'] as String?;
        }

        print('🎯 SUBT004 - Vehicle Details Access Payment Success');
        print('   vehicleId: $vehicleId');
        print('   categoryCode: $categoryCode');

        // Try to refresh subscription data if AuctionController is available
        if (Get.isRegistered<AuctionController>()) {
          final auctionController = Get.find<AuctionController>();
          try {
            await auctionController.refreshAfterPayment();
          } catch (e) {
            print('Error refreshing data after SUBT004 payment: $e');
          }
        }

        // Clear subscription source from storage since payment is complete
        await _storageService.removeSubscriptionSource();

        // Show success message
        Get.snackbar(
          'Vehicle Details Unlocked! 🎉',
          'You can now view complete vehicle information',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Navigate to vehicle details after successful payment
        if (vehicleId != null && categoryCode != null) {
          // Fetch vehicle details and navigate
          if (Get.isRegistered<BuySellController>()) {
            final buySellController = Get.find<BuySellController>();
            try {
              // First, refresh the vehicle list to get updated access permissions
              await buySellController.loadMoreBuyVehiclesByCategory(categoryCode);

              // Then fetch vehicle details
              await buySellController.fetchBuyVehicleDetailsById(
                vehicleId,
                categoryCode,
              );

              // Clean up stored vehicle data
              StorageService.to.remove('current_vehicle');

              // Navigate to vehicle details page using the EXACT same approach as direct access
              // This matches the navigation in BuyVehicleCard when vehicleDetailsAccess == "yes"
              Get.to(() => BuyVehicleDetails());
            } catch (e) {
              print('Error fetching vehicle details after SUBT004 payment: $e');
              // Clean up stored data on error
              StorageService.to.remove('current_vehicle');
              // Fallback - go back to previous screen
              Get.back();
            }
          } else {
            print('BuySellController not registered for SUBT004');
            StorageService.to.remove('current_vehicle');
            Get.back();
          }
        } else {
          print('Missing vehicle data for SUBT004 navigation');
          StorageService.to.remove('current_vehicle');
          Get.back();
        }
      } catch (e) {
        print('❌ SUBT004 post-payment processing error: $e');
        // Ensure cleanup happens even on unexpected errors
        try {
          StorageService.to.remove('current_vehicle');
          await _storageService.removeSubscriptionSource();
        } catch (_) {}
        // Fallback navigation
        try {
          Get.back();
        } catch (_) {}
      }
    } else if (subscriptionSource == 'SUBT005') {
      // Vehicle inspection subscription - similar to SUBT003

      // Remove singleSubscriptionPlan route from the navigation stack for SUBT005
      Get.until(
        (route) => route.settings.name != AppRoutes.singleSubscriptionPlan,
      );

      // Try to refresh subscription data if AuctionController is available
      if (Get.isRegistered<AuctionController>()) {
        final controller = Get.find<AuctionController>();
        try {
          controller.getMySuscription();
        } catch (e) {}
      }

      // Clear subscription source from storage since payment is complete
      await _storageService.removeSubscriptionSource();

      // Call requestVehicleInspection API after successful SUBT005 payment
      try {
        final vehicleData = StorageService.to.read('current_vehicle');
        if (vehicleData != null && vehicleData is Map<String, dynamic>) {
          final vehicleId = vehicleData['sb_vehicle_id'];
          if (vehicleId != null) {
            // Set payment success for this specific vehicle
            setPaymentSuccessForInspection(vehicleId.toString(), true);

            // Find BuySellController if available to call the API
            if (Get.isRegistered<BuySellController>()) {
              final buySellController = Get.find<BuySellController>();
              final apiSuccess = await buySellController
                  .requestVehicleInspection(
                    vehicleId: vehicleId,
                    requestInspection: true,
                  );

              if (apiSuccess) {
                // Update the inspection status to 'yes' after successful API call
                setVehicleInspectionStatus(vehicleId.toString(), 'yes');
              } else {}
            } else {}
          } else {}
        } else {}
      } catch (e) {}

      // Show success message for vehicle inspection
      Get.snackbar(
        'Vehicle Inspection Activated! 🔍',
        'You can now request vehicle inspection services',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Navigate back to vehicle details after successful SUBT005 purchase

      // Add a small delay to ensure PayU SDK completes its process
      await Future.delayed(Duration(milliseconds: 500));

      // Try using stored vehicle data
      final vehicleData = StorageService.to.read('current_vehicle');

      if (vehicleData != null) {
        // Navigate to BuyVehicleDetails with stored vehicle data

        // Clean up stored data
        StorageService.to.remove('current_vehicle');

        try {
          // Use offAllNamed to clear the navigation stack and ensure clean navigation
          // Get.offAllNamed(AppRoutes.buyVehicleDetails, arguments: vehicleData);
        } catch (e) {
          // Fallback to simple back navigation
          Get.back();
        }
      } else {
        // Fallback: use Get.back() if no stored data
        Get.back();
      }
    } else if (subscriptionSource == 'SUBT006') {
      // Mechanic contact subscription - requires ServiceSupportController

      // Remove single subscription plan route from the navigation stack for SUBT006
      Get.until(
        (route) => route.settings.name != AppRoutes.singleSubscriptionPlan,
      );

      // Call createMechanicSubscription API after successful SUBT006 payment
      try {
        final mechanicId = await _storageService.getPendingMechanicId();
        if (mechanicId != null) {
          // Find ServiceSupportController if available to call the API
          if (Get.isRegistered<ServiceSupportController>()) {
            final serviceSupportController =
                Get.find<ServiceSupportController>();
            await serviceSupportController
                .handleMechanicSubscriptionPaymentSuccess(mechanicId);
          } else {
            print(
              '🔧 ServiceSupportController not registered, cleaning up mechanic data',
            );
            await _storageService.removePendingMechanicId();
          }
        } else {
          print('🔧 No mechanic ID found in storage for SUBT006 subscription');
        }
      } catch (e) {
        print('🔧 Error handling mechanic subscription payment success: $e');
        // Clean up stored data on error
        await _storageService.removePendingMechanicId();
      }

      // Clear subscription source from storage since payment is complete
      await _storageService.removeSubscriptionSource();

      // Show success message for mechanic contact subscription
      Get.snackbar(
        'Mechanic Contact Activated! 🔧',
        'You can now access mechanic contact details',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Navigate back to service provider list after successful SUBT006 purchase
      try {
        // First try to navigate back using until
        Get.until(
          (route) => route.settings.name == AppRoutes.serviceSupportListView,
        );
      } catch (e) {
        // If until fails (route not in stack), navigate directly
        Get.offAllNamed(AppRoutes.serviceSupportListView);
      }

      // Add delay to ensure navigation completes before refresh
      await Future.delayed(const Duration(milliseconds: 800));

      // Refresh the service support data after navigation
      try {
        if (Get.isRegistered<ServiceSupportController>()) {
          final serviceController = Get.find<ServiceSupportController>();
          await serviceController.refreshAfterPaymentSuccess();
        }
      } catch (e) {
        print('Error refreshing service support after payment: $e');
      }
    } else if (subscriptionSource == 'SUBT007') {
      // Shop contact subscription - requires SpareAndFmsController

      // Remove single subscription plan route from the navigation stack for SUBT007
      Get.until(
        (route) => route.settings.name != AppRoutes.singleSubscriptionPlan,
      );

      // Call createShopSubscription API after successful SUBT007 payment
      try {
        final shopId = await _storageService.read('pending_shop_id');
        if (shopId != null) {
          // Find SpareAndFmsController if available to call the API
          if (Get.isRegistered<SpareAndFmsController>()) {
            final spareAndFmsController = Get.find<SpareAndFmsController>();
            await spareAndFmsController.handleShopSubscriptionPaymentSuccess(
              shopId,
            );
          } else {
            print(
              '🔧 SpareAndFmsController not registered, cleaning up shop data',
            );
            await _storageService.remove('pending_shop_id');
          }
        } else {
          print('🔧 No shop ID found in storage for SUBT007 subscription');
        }
      } catch (e) {
        print('🔧 Error handling shop subscription payment success: $e');
        // Clean up stored data on error
        await _storageService.remove('pending_shop_id');
      }

      // Clear subscription source from storage since payment is complete
      await _storageService.removeSubscriptionSource();

      // Show success message for shop contact subscription
      Get.snackbar(
        'Shop Contact Activated! 🛒',
        'You can now access shop contact details',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Navigate back to shop list after successful SUBT007 purchase
      try {
        // First try to navigate back using until
        Get.until((route) => route.settings.name == AppRoutes.shopList);
      } catch (e) {
        // If until fails (route not in stack), navigate directly
        Get.offAllNamed(AppRoutes.shopList);
      }

      // Add delay to ensure navigation completes before refresh
      await Future.delayed(const Duration(milliseconds: 800));

      // Refresh the shop data after navigation
      try {
        if (Get.isRegistered<SpareAndFmsController>()) {
          final spareAndFmsController = Get.find<SpareAndFmsController>();
          await spareAndFmsController.refreshAfterShopPaymentSuccess();
        }
      } catch (e) {
        print('Error refreshing shops after payment: $e');
      }
    } else if (Get.currentRoute == AppRoutes.customerSubscriptionPlan) {
      // Customer subscription plan payment success

      // Add delay to ensure PayU SDK completes its process
      await Future.delayed(const Duration(milliseconds: 800));

      // Remove customer subscription plan route from navigation stack
      Get.until(
        (route) => route.settings.name != AppRoutes.customerSubscriptionPlan,
      );

      // Clear stored inspection data after successful payment
      if (Get.isRegistered<InspectionValuationController>()) {
        final inspectionController = Get.find<InspectionValuationController>();
        inspectionController.clearStoredInspectionData();

        // Clear customer form data after successful payment
        inspectionController.customerVehicleNoC.clear();
        inspectionController.customerChasisNoC.clear();
        inspectionController.customerContactNumberC.clear();
        inspectionController.customerCompanyNameC.clear();
        inspectionController.rcCopyFiles.clear();
        inspectionController.insuranceCopyFiles.clear();
        inspectionController.gstFiles.clear();
        inspectionController.selectedVehicleType.value = null;
        inspectionController.selectedVehicleBrand.value = null;
        inspectionController.selectedState.value = null;
        inspectionController.selectedCity.value = null;
      }

      // Show finance success dialog
      SuccessDialog.show(
        onClose: () {
          // Navigate to categories page after dialog close
          Get.offAllNamed(AppRoutes.categories);
        },
      );
    } else if (Get.currentRoute == AppRoutes.buySellSubscriptionPlan) {
      // Buy and Sell subscription plan payment success (like SUBT005)

      // Add delay to ensure PayU SDK completes its process
      await Future.delayed(const Duration(milliseconds: 800));

      // Remove buy sell subscription plan route from navigation stack
      Get.until(
        (route) => route.settings.name != AppRoutes.buySellSubscriptionPlan,
      );

      // Try to refresh subscription data if AuctionController is available

      // Call requestOwnerDetailsAccess API after successful buy sell subscription payment
      try {
        final vehicleId = _storageService.read<String>('buy_sell_vehicle_id');
        if (vehicleId != null) {
          print('🎉 Processing buy sell subscription for vehicle: $vehicleId');

          // Set payment success for this specific vehicle
          setPaymentSuccessForSubscribe(vehicleId, true);

          // Find BuySellController if available to call the API
          if (Get.isRegistered<BuySellController>()) {
            final buySellController = Get.find<BuySellController>();
            final apiSuccess = await buySellController.requestVehicleInspection(
              vehicleId: vehicleId,
              requestInspection: true,
            );

            if (apiSuccess) {
              print('✅ Owner details access granted for vehicle: $vehicleId');
              setVehicleInspectionStatus(vehicleId.toString(), 'yes');
            } else {
              print(
                '⚠️ Failed to grant owner details access for vehicle: $vehicleId',
              );
            }
          } else {
            print('⚠️ BuySellController not registered, cannot call API');
          }
        } else {
          print('⚠️ No vehicle ID found in storage');
        }
      } catch (e) {
        print('❌ Error requesting owner details access: $e');
      }

      // Clear stored buy sell subscription data after successful payment
      _storageService.remove('buy_sell_vehicle_id');
      _storageService.remove('buy_sell_category_plan');
      _storageService.remove('buy_sell_subscription_amount');

      // Show success message

      // Navigate back to vehicle details after successful subscription purchase
      await Future.delayed(Duration(milliseconds: 200));

      // Safe navigation back - just go back one screen to vehicle details
      try {
        if (Get.currentRoute == AppRoutes.buySellSubscriptionPlan) {
          // If we're still on subscription plan screen, go back
          Get.back();
        }
      } catch (e) {
        print('⚠️ Navigation error: $e');
      }
    } else if (auctionId?.startsWith('approved_vehicle_') == true) {
      // Approved vehicle payment success
      print('🎯 Approved vehicle payment detected: $auctionId');

      // Add delay to ensure PayU SDK completes its process
      await Future.delayed(const Duration(milliseconds: 500));

      // Get stored approved vehicle context
      final approvedVehicleId = await _storageService.read(
        'approved_vehicle_id',
      );
      final subscriptionType = await _storageService.read(
        'approved_vehicle_subscription_type',
      );

      print('🎯 Approved vehicle ID: $approvedVehicleId');
      print('🎯 Subscription type: $subscriptionType');

      if (approvedVehicleId != null && subscriptionType != null) {
        // Update user interest via AuctionController
        // This method will:
        // 1. Call the user interest API to update is_interested/is_booked
        // 2. Refresh the approved vehicle listings automatically
        if (Get.isRegistered<AuctionController>()) {
          try {
            final auctionController = Get.find<AuctionController>();
            print(
              '🔄 STEP 1: Calling updateApprovedVehicleUserInterest: vehicleId=$approvedVehicleId, type=$subscriptionType',
            );

            // Call user interest API which also refreshes listings internally
            await auctionController.updateApprovedVehicleUserInterest(
              approvedVehicleId: approvedVehicleId,
              subscriptionType: subscriptionType,
            );
            print('✅ User interest API called successfully');

            // Additional explicit refresh to ensure listings are up-to-date
            // print('🔄 STEP 2: Explicitly refreshing approved vehicle listings...');
            // await auctionController.refreshApprovedListings();
            print('✅ Approved vehicle listings refreshed successfully');

            print('✅ All updates completed: User interest + Listings refresh');
          } catch (e) {
            print('❌ Error updating approved vehicle user interest: $e');
            // Show error but continue
            Get.snackbar(
              'Warning',
              'Payment successful but failed to update status. Please refresh.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        } else {
          print('⚠️ AuctionController not registered');
        }

        // Show success message
        Get.snackbar(
          'Success! 🎉',
          subscriptionType == 'category'
              ? 'Vehicle booking successful!'
              : 'Inspection request submitted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Navigate back to approved vehicle listings
        try {
          Get.until(
            (route) => route.settings.name == AppRoutes.approvedVehicleListings,
          );
        } catch (e) {
          print('⚠️ Navigation error, using fallback: $e');
          Get.back();
        }
      } else {
        print('⚠️ Missing approved vehicle context in storage');
        Get.back();
      }

      // Clean up stored approved vehicle data
      await _storageService.remove('approved_vehicle_id');
      await _storageService.remove('approved_vehicle_subscription_type');
      await _storageService.removePendingAuctionId();

      await _storageService.removeSubscriptionSource();
    } else {
      // Generic success message for unknown subscription types
      Get.snackbar(
        'Payment Successful',
        'Your payment has been processed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    }

    // Complete payment future if it exists and hasn't been completed yet
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(true);
    }
  }

  @override
  void onPaymentFailure(dynamic response) async {
    // IMMEDIATELY clear loading states before any processing
    _clearAllSubscriptionLoadingStates();

    // Add delay to ensure PayU SDK completes its processing
    await Future.delayed(const Duration(milliseconds: 300));

    paymentStatus.value = 'failed';
    currentStep.value = 'failed';

    if (_currentPaymentData != null) {
      final callbackData = _createPaymentCallback(response, 'failed');
      try {} catch (_) {}
      PaymentApiService.notifyPaymentFailure(callbackData);
    }

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }

    // Add navigation back to previous screen after failure
    await Future.delayed(const Duration(milliseconds: 500));

    Get.snackbar(
      'Payment Failed',
      'Payment could not be processed',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );

    // Try to go back to previous screen
    try {
      Get.back();
    } catch (e) {}
  }

  @override
  void onPaymentCancel(Map? response) async {
    // IMMEDIATELY clear loading states before any processing
    _clearAllSubscriptionLoadingStates();

    paymentStatus.value = 'cancelled';
    currentStep.value = 'cancelled';

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }

    // Add delay to ensure PayU SDK completes its processing
    await Future.delayed(const Duration(milliseconds: 300));

    // Clean up any pending data based on subscription source
    try {
      final subscriptionSource = await _storageService.getSubscriptionSource();

      if (subscriptionSource == 'SUBT006') {
        // Clean up mechanic subscription data
        await _storageService.removePendingMechanicId();
        print('🔧 Cleaned up mechanic subscription data on payment cancel');
      }

      // Clean up subscription source
      await _storageService.removeSubscriptionSource();
    } catch (e) {
      print('Error cleaning up subscription data on cancel: $e');
    }

    Get.snackbar(
      'Payment Cancelled',
      'Payment was cancelled by user',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.cancel, color: Colors.white),
      duration: const Duration(seconds: 3),
    );

    // Add small delay before navigation
    await Future.delayed(const Duration(milliseconds: 200));

    // Try to go back to previous screen
    try {
      Get.back();
    } catch (e) {
      print('Error navigating back on payment cancel: $e');
    }
  }

  @override
  void onError(Map? response) {
    // IMMEDIATELY clear loading states before any processing
    _clearAllSubscriptionLoadingStates();

    paymentStatus.value = 'error';
    currentStep.value = 'error';
    errorMessage.value = response?['error'] ?? 'Payment error occurred';

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(false);
    }

    Get.snackbar(
      'Payment Error',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  PaymentStatusCallback _createPaymentCallback(
    dynamic response,
    String status,
  ) {
    final Map<String, dynamic> responseMap = response is Map<String, dynamic>
        ? response
        : <String, dynamic>{};

    // Get chassis number for customer subscription plans
    String? chassisNumber;
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.customerSubscriptionPlan) {
      // Get chassis number from inspection valuation controller
      if (Get.isRegistered<InspectionValuationController>()) {
        final inspectionController = Get.find<InspectionValuationController>();
        chassisNumber = inspectionController.getStoredChasisNo();
      }
    }

    return PaymentStatusCallback(
      key: responseMap['key'] ?? _currentPaymentData?.merchantKey ?? '',
      txnid:
          responseMap['txnid'] ?? _currentPaymentData?.payuFormData.txnId ?? '',
      amount:
          responseMap['amount'] ??
          _currentPaymentData?.payuFormData.amount ??
          '',
      productinfo:
          responseMap['productinfo'] ??
          _currentPaymentData?.payuFormData.productInfo ??
          '',
      firstname:
          responseMap['firstname'] ??
          _currentPaymentData?.payuFormData.firstname ??
          '',
      email:
          responseMap['email'] ?? _currentPaymentData?.payuFormData.email ?? '',
      phone:
          responseMap['phone'] ?? _currentPaymentData?.payuFormData.phone ?? '',
      paymentStatus: status,
      hash: responseMap['hash'] ?? '',
      mode: responseMap['mode'],
      bankref: responseMap['bankref'],
      pgType: responseMap['PG_TYPE'],
      bankRefNum: responseMap['bank_ref_num'],
      mihpayid: responseMap['mihpayid'],
      udf1: responseMap['udf1'] ?? _currentPaymentData?.paymentId,
      udf2:
          responseMap['udf2'] ??
          chassisNumber, // Add chassis number for customer subscription
      udf3: responseMap['udf3'],
      udf4: responseMap['udf4'],
      udf5: responseMap['udf5'],
      error: responseMap['error'],
      errorMessage: responseMap['error_Message'],
      chasisNumber:
          chassisNumber, // Add chassis number for customer subscription
    );
  }

  void resetPaymentState() {
    paymentStatus.value = '';
    currentStep.value = 'idle';
    isLoading.value = false;
    errorMessage.value = '';
    _currentPaymentData = null;
    _paymentCompleter = null;
    // Clear all vehicle-specific payment status when resetting
    clearAllVehiclePaymentStatus();
  }

  // Convenience getters for debugging and UI
  String? get currentPaymentId => _currentPaymentData?.paymentId;
  String? get currentTransactionId => _currentPaymentData?.payuFormData.txnId;
  String? get currentAmount => _currentPaymentData?.payuFormData.amount;
  String? get currentMerchantKey => _currentPaymentData?.merchantKey;

  // Method to get current payment details for logging
  Map<String, dynamic>? getCurrentPaymentDetails() {
    if (_currentPaymentData == null) return null;

    return {
      'payment_id': _currentPaymentData!.paymentId,
      'transaction_id': _currentPaymentData!.payuFormData.txnId,
      'amount': _currentPaymentData!.payuFormData.amount,
      'product_info': _currentPaymentData!.payuFormData.productInfo,
      'merchant_key': _currentPaymentData!.merchantKey,
      'status': paymentStatus.value,
      'step': currentStep.value,
    };
  }

  /// Helper method to format currency
  String _formatCurrency(double amount) {
    try {
      // Try to use AuctionController's formatCurrency for consistency
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();
        return auctionController.formatCurrency(amount);
      }
    } catch (e) {}

    // Fallback formatting
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  /// Set pending bid information to be executed after successful payment

  /// Place the pending bid after successful payment
  /// This follows the same process as the regular placeBid method
  Future<void> placePendingBid() async {
    try {
      // Retrieve stored bid data
      final vehicleId = await _storageService.getPendingVehicleId();
      final bidAmount = await _storageService.getPendingBidAmount();
      final auctionId = await _storageService.getPendingAuctionId();

      // Validate we have all required data
      if (vehicleId == null || bidAmount == null || auctionId == null) {
        print(
          '❌ Missing pending bid data: vehicleId=$vehicleId, bidAmount=$bidAmount, auctionId=$auctionId',
        );
        return;
      }

      // Get user ID from storage
      final storedUserId = await _storageService.getUserId();
      if (storedUserId == null) {
        print('❌ No user ID found for pending bid');
        return;
      }

      print(
        '🎯 Placing pending bid: vehicleId=$vehicleId, amount=${_formatCurrency(bidAmount)}',
      );

      // 🎯 STEP 1: CRITICAL - Refresh subscription data FIRST to get updated limits
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();

        try {
          print(
            '🔄 Refreshing subscription data to get latest available balance...',
          );

          // Force clear any cached subscription data first
          auctionController.mySubscriptionListData.clear();

          // Now refresh from backend with retries
          int retryCount = 0;
          bool refreshSuccess = false;

          while (retryCount < 3 && !refreshSuccess) {
            try {
              await auctionController.getMySuscription();
              refreshSuccess = true;
              print(
                '✅ Subscription refresh attempt ${retryCount + 1} successful',
              );
            } catch (e) {
              retryCount++;
              print('⚠️ Subscription refresh attempt $retryCount failed: $e');
              if (retryCount < 3) {
                await Future.delayed(Duration(milliseconds: 500));
              }
            }
          }

          if (!refreshSuccess) {
            print(
              '❌ All subscription refresh attempts failed - proceeding with backend validation',
            );
          }

          // Get the fresh available balance after subscription refresh
          final updatedBalance = auctionController.getAvailableBidLimit();
          print(
            '💰 Fresh available balance: ${_formatCurrency(updatedBalance)}',
          );
          print('💸 Bid amount: ${_formatCurrency(bidAmount)}');
          print(
            '📊 Subscription list count: ${auctionController.mySubscriptionListData.length}',
          );

          // Log detailed subscription info for debugging
          for (var sub in auctionController.mySubscriptionListData) {
            print(
              '📋 Subscription: ${sub.subscriptionType} - Available: ${_formatCurrency(sub.planAvailableBidAmount.toDouble())} / Total: ${_formatCurrency(sub.planBidAmount.toDouble())}',
            );
          }

          // Only do client-side validation if we have valid subscription data
          if (auctionController.mySubscriptionListData.isNotEmpty &&
              updatedBalance > 0) {
            if (bidAmount > updatedBalance) {
              print(
                '❌ CLIENT VALIDATION: Bid amount ${_formatCurrency(bidAmount)} exceeds available balance ${_formatCurrency(updatedBalance)}',
              );

              // Show error and return without placing bid
              Get.snackbar(
                'Insufficient Balance',
                'Bid amount ${_formatCurrency(bidAmount)} exceeds available balance ${_formatCurrency(updatedBalance)}',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.error, color: Colors.white),
                duration: const Duration(seconds: 4),
              );
              return;
            } else {
              print(
                '✅ CLIENT VALIDATION PASSED: Bid amount is within available balance - proceeding with bid placement',
              );
            }
          } else {
            print(
              '⚠️ No subscription data or zero balance - letting backend validate the bid',
            );
          }

          // 🔥 CRITICAL: Force update all vehicle data with latest balance before proceeding
          print(
            '🔄 Forcing vehicle data update with latest subscription balance...',
          );
          await auctionController.updateAvailableBalanceForAllVehicles();
          print(
            '✅ Vehicle data updated with latest balance before bid placement',
          );
        } catch (e) {
          print('⚠️ Subscription refresh failed before bid: $e');
          print('⚠️ Proceeding with bid placement - let backend validate');

          // If subscription refresh fails, force vehicle data update anyway
          if (Get.isRegistered<AuctionController>()) {
            final auctionController = Get.find<AuctionController>();
            try {
              await auctionController.updateAvailableBalanceForAllVehicles();
              print(
                '✅ Forced vehicle data update completed despite subscription refresh failure',
              );
            } catch (updateError) {
              print('⚠️ Vehicle data update also failed: $updateError');
            }
          }
        }
      } else {
        print(
          '⚠️ AuctionController not registered - cannot refresh subscription data',
        );
      }

      // Create the bid request using the same structure as auction controller
      final bidRequest = AuctionVehicleBidRequest(
        auctionId: auctionId,
        bidAmount: bidAmount,
        userId: storedUserId,
        vehicleId: vehicleId,
      );

      print('🎯 STEP 2: Placing bid via API (after subscription refresh)...');
      print(
        '📊 Final Bid Request: Vehicle ID: $vehicleId, Amount: ${_formatCurrency(bidAmount)}',
      );

      // Place the bid using the auction API (now with fresh subscription data)
      final response = await _apiRepository.getAuctionVehicleBid(bidRequest);

      // Check if bid placement was successful
      if (response.status == 'success' && response.data != null) {
        print('✅ Pending bid placed successfully');

        // Extract bid ID and remaining limit from response
        final bidId = response.data?.bidId ?? 0;
        final remainingLimit = response.data?.remainingBidLimit ?? 0.0;

        // 🎯 STEP 1: Send bid placed notification (same as auction controller)
        if (Get.isRegistered<AuctionController>()) {
          final auctionController = Get.find<AuctionController>();

          try {
            await auctionController.sendBidPlacedNotification(
              vehicleId: vehicleId,
              bidAmount: bidAmount,
              auctionId: auctionId,
              bidId: bidId,
            );
            print('✅ Bid notification sent');
          } catch (e) {
            print('⚠️ Bid notification failed: $e');
            // Continue with bid processing even if notification fails
          }
        }

        // 🎯 STEP 2: Update vehicle data for ALL vehicles (subscription already refreshed before bid)
        if (Get.isRegistered<AuctionController>()) {
          final auctionController = Get.find<AuctionController>();

          try {
            // Use the same method that updates the bid vehicle AND all other vehicles with new available balance
            auctionController.updateVehicleDataAfterBid(
              vehicleId,
              bidAmount,
              remainingLimit,
            );
            print(
              '✅ All vehicles updated with new available balance: ${_formatCurrency(remainingLimit)}',
            );
          } catch (e) {
            print('⚠️ Vehicle data update failed: $e');
          }
        }

        // 🎯 STEP 3: Clear pending bid data
        await _storageService.clearAllPendingBidData();
        print('✅ Pending bid data cleared');

        // 🎯 STEP 4: Show success message with same formatting as auction controller
        final formattedBidAmount = _formatCurrency(bidAmount);
        final formattedRemainingLimit = _formatCurrency(remainingLimit);

        final successMessage = response.message.isNotEmpty
            ? response.message
            : 'Bid placed successfully for $formattedBidAmount!';

        final remainingLimitText = remainingLimit >= 0
            ? '\nRemaining limit: $formattedRemainingLimit'
            : '';

        Get.snackbar(
          'Bid Placed Successfully! 🎉',
          '$successMessage$remainingLimitText',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 4),
        );

        print('🎉 Pending bid placement completed successfully');
      } else {
        // 🎯 STEP 5: Handle bid placement failure (same error handling as auction controller)
        print('❌ Pending bid placement failed: ${response.message}');

        // Extract error details from response
        String errorTitle = 'Bid Placement Failed';
        String errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to place bid after payment. Please try again.';

        // Check for specific error codes to customize the title
        if (response.message.contains('exceeds your available bid limit') ||
            response.message.contains('BID_EXCEEDS_LIMIT')) {
          errorTitle = 'Bid Limit Exceeded';

          // 🔧 DEBUG: Log current balance vs bid amount for troubleshooting
          if (Get.isRegistered<AuctionController>()) {
            final auctionController = Get.find<AuctionController>();
            final currentBalance = auctionController.getAvailableBidLimit();
            print('🔧 DEBUG - Bid failed due to limit:');
            print('   Bid amount: ${_formatCurrency(bidAmount)}');
            print('   Available balance: ${_formatCurrency(currentBalance)}');
            print(
              '   Difference: ${_formatCurrency(currentBalance - bidAmount)}',
            );
          }
        } else if (response.message.contains('AUCTION_INACTIVE') ||
            response.message.contains('auction is not active')) {
          errorTitle = 'Auction Closed';
        } else if (response.message.contains('NO_ACTIVE_SUBSCRIPTION')) {
          errorTitle = 'Subscription Required';
        }

        // Show error notification with backend message
        Get.snackbar(
          errorTitle,
          'Bid amount must be higher than current highest bid',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 5),
        );

        // 🔥 CRITICAL FIX: When bid fails, refresh subscription and update all vehicles with correct balance
        // DO NOT update vehicles as if bid succeeded - just refresh with current balance
        if (Get.isRegistered<AuctionController>()) {
          final auctionController = Get.find<AuctionController>();

          try {
            print(
              '🔄 Bid failed - refreshing subscription data to get correct available balance...',
            );

            // Refresh subscription data to get current balance
            await auctionController.getMySuscription();

            // Update all vehicles with the CURRENT (correct) available balance
            // This will fix the "0 balance" issue when bid fails
            await auctionController.updateAvailableBalanceForAllVehicles();

            final currentBalance = auctionController.getAvailableBidLimit();
            print(
              '✅ After bid failure - vehicles updated with correct balance: ${_formatCurrency(currentBalance)}',
            );
          } catch (e) {
            print('⚠️ Failed to refresh balance after bid failure: $e');
          }
        }

        // Don't clear pending data on failure - user might want to retry or adjust bid amount
        print('❌ Keeping pending data for potential retry');
        return; // Exit early on failure
      }
    } catch (e) {
      print('❌ Exception in placePendingBid: $e');

      // Show error notification but keep pending data for retry
      Get.snackbar(
        'Bid Failed',
        'Failed to place bid after payment. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

      // 🔥 CRITICAL FIX: Even on exception, refresh balance to prevent 0 balance display
      if (Get.isRegistered<AuctionController>()) {
        final auctionController = Get.find<AuctionController>();

        try {
          print(
            '🔄 Exception occurred - refreshing subscription data to maintain correct balance...',
          );

          // Refresh subscription and vehicle data to maintain correct state
          await auctionController.getMySuscription();
          await auctionController.updateAvailableBalanceForAllVehicles();

          final currentBalance = auctionController.getAvailableBidLimit();
          print(
            '✅ After exception - vehicles updated with correct balance: ${_formatCurrency(currentBalance)}',
          );
        } catch (refreshError) {
          print('⚠️ Failed to refresh balance after exception: $refreshError');
        }
      }
    }
  }
}

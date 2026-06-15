import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../subscription/models/user_subscription.dart';
import '../../subscription/services/subscription_guard_service.dart';
import '../models/category_item.dart';

class CategoriesController extends GetxController {
  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'auction',
      title: 'Auction Zone',
      assetPath: 'assets/images/png/auction.png',
    ),
    CategoryItem(
      id: 'buy_sell',
      title: 'Buy & Sell',
      assetPath: 'assets/images/png/buy_sell.png',
    ),
    CategoryItem(
      id: 'fms',
      title: 'FMS',
      assetPath: 'assets/images/png/fms.png',
    ),
    CategoryItem(
      id: 'insurance',
      title: 'Insurance & Finance',
      assetPath: 'assets/images/png/insurance_finanace.png',
    ),
    CategoryItem(
      id: 'inspection',
      title: 'Inspection',
      assetPath: 'assets/images/png/inspection.png',
    ),
    CategoryItem(
      id: 'service_support',
      title: 'Service Support',
      assetPath: 'assets/images/png/spare_parts.png',
    ),
  ];

  Future<void> onCategoryTapped(CategoryItem item) async {
    switch (item.id) {
      case 'auction':
        await _openAuction();
        break;
      case 'buy_sell':
        _openBuySell();
        break;
      case 'fms':
      case 'spare_parts':
        _openSpareAndFms();
        break;
      case 'insurance':
        _openInsuranceAndFinance();
        break;
      case 'inspection':
        _openInspection();
        break;
      case 'service_support':
        _openServiceSupport();
        break;
      default:
        break;
    }
  }

  // ── Buy & Sell (no subscription gate) ───────────────────────────────────────

  void _openBuySell() {
    Get.toNamed(AppRoutes.buySellHome);
  }

  // ── Spare & FMS ────────────────────────────────────────────────────────────

  void _openSpareAndFms() {
    Get.toNamed(AppRoutes.spareFms);
  }

  // ── Insurance & Finance ────────────────────────────────────────────────────

  void _openInsuranceAndFinance() {
    Get.toNamed(AppRoutes.insuranceFinance);
  }

  // ── Service Support ────────────────────────────────────────────────────────

  void _openServiceSupport() {
    Get.toNamed(AppRoutes.serviceSupport);
  }

  // ── Inspection ────────────────────────────────────────────────────────────

  Future<void> _openInspection() async {
    final userType =
        await SecureStorageService.to.read(StorageKeys.userType) ?? '';
    final normalized = userType.toUpperCase().trim();

    if (normalized == 'VENDOR' || normalized == 'AGENT') {
      Get.toNamed(AppRoutes.agentValuationForm);
    } else {
      // Default to customer form for 'CUSTOMER' or unknown types
      Get.toNamed(AppRoutes.customerValuationForm);
    }
  }

  // ── Auction gate ──────────────────────────────────────────────────────────

  Future<void> _openAuction() async {
    final guard = SubscriptionGuardService.to;
    // Always do a fresh check when the user explicitly taps Auction Zone
    // so a just-purchased subscription is always reflected.
    await guard.ensureLoaded(forceRefresh: true);

    final hasAccess = guard.hasActiveSubscription(SubscriptionTypeCode.auction);
    debugPrint('🎯 _openAuction: hasActiveSubscription(SUBT001)=$hasAccess');

    if (hasAccess) {
      Get.toNamed(AppRoutes.auctionType);
      return;
    }

    // No valid subscription — go directly to the subscription screen
    Get.toNamed(
      AppRoutes.subscription,
      arguments: {
        'subscription_source': SubscriptionTypeCode.auction,
        'title': 'Choose Subscription Plan',
        'subtitle': 'Choose a subscription plan to unlock features of auction',
      },
    );
  }
}

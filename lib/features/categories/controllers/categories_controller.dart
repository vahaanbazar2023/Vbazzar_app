import 'package:get/get.dart';
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
      id: 'spare_parts',
      title: 'Spare Parts & Service Support',
      assetPath: 'assets/images/png/spare_parts.png',
    ),
  ];

  Future<void> onCategoryTapped(CategoryItem item) async {
    switch (item.id) {
      case 'auction':
        await _openAuction();
        break;
      default:
        break;
    }
  }

  // ── Auction gate ──────────────────────────────────────────────────────────

  Future<void> _openAuction() async {
    final guard = SubscriptionGuardService.to;
    await guard.ensureLoaded();

    if (guard.hasActiveSubscription(SubscriptionTypeCode.auction)) {
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

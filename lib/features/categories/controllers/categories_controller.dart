import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
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

  void onCategoryTapped(CategoryItem item) {
    switch (item.id) {
      case 'auction':
        Get.toNamed(AppRoutes.auctionType);
        break;
      default:
        break;
    }
  }
}

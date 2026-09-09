import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class GlobalSearchItem {
  final String id;
  final String title;
  final String subtitle;
  final String matchedField;
  final String navigationRoute;
  final Map<String, dynamic> navigationParams;

  const GlobalSearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.matchedField,
    required this.navigationRoute,
    required this.navigationParams,
  });

  factory GlobalSearchItem.fromJson(Map<String, dynamic> j) {
    return GlobalSearchItem(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      subtitle: j['subtitle']?.toString() ?? '',
      matchedField: j['matched_field']?.toString() ?? '',
      navigationRoute: j['navigation_route']?.toString() ?? '',
      navigationParams:
          (j['navigation_params'] as Map<String, dynamic>?) ?? {},
    );
  }

  IconData get icon {
    switch (navigationRoute) {
      case 'AppRoutes.auctionVehicleDetail':
        return Icons.gavel_rounded;
      case 'AppRoutes.buyVehicleDetail':
        return Icons.directions_car_rounded;
      case 'AppRoutes.approvedVehicleDetail':
        return Icons.verified_rounded;
      case 'AppRoutes.spareDetail':
        return Icons.build_rounded;
      case 'AppRoutes.serviceSupport':
        return Icons.handyman_rounded;
      default:
        return Icons.search_rounded;
    }
  }
}

class GlobalSearchSection {
  final String module;
  final String label;
  final int totalCount;
  final List<GlobalSearchItem> items;

  const GlobalSearchSection({
    required this.module,
    required this.label,
    required this.totalCount,
    required this.items,
  });

  factory GlobalSearchSection.fromJson(Map<String, dynamic> j) {
    return GlobalSearchSection(
      module: j['module']?.toString() ?? '',
      label: j['label']?.toString() ?? '',
      totalCount: (j['total_count'] as num?)?.toInt() ?? 0,
      items: ((j['items'] as List<dynamic>?) ?? [])
          .map((e) => GlobalSearchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class SearchController extends GetxController {
  final NetworkService _network;

  SearchController({NetworkService? network})
      : _network = network ?? NetworkService.to;

  final TextEditingController textController = TextEditingController();
  final query = ''.obs;
  final sections = <GlobalSearchSection>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      final q = textController.text;
      query.value = q;
      _onQueryChanged(q);
    });
  }

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      sections.clear();
      errorMessage.value = '';
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final response = await _network.post<Map<String, dynamic>>(
        ApiEndpoints.globalSearch,
        data: {'user_id': userId, 'query': q},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        sections.clear();
        return;
      }

      final raw = (data['sections'] as List<dynamic>?) ?? [];
      sections.assignAll(
        raw
            .map((e) =>
                GlobalSearchSection.fromJson(e as Map<String, dynamic>))
            .where((s) => s.items.isNotEmpty)
            .toList(),
      );
    } catch (e) {
      errorMessage.value = 'Search failed. Please try again.';
      debugPrint('❌ [SearchController._search] $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to the correct screen based on the API navigation_route string.
  void navigate(GlobalSearchItem item) {
    switch (item.navigationRoute) {
      case 'AppRoutes.auctionVehicleDetail':
        Get.toNamed(AppRoutes.vehicleDetail, arguments: item.navigationParams);
        break;
      case 'AppRoutes.approvedVehicleDetail':
        Get.toNamed(AppRoutes.approvedVehicleDetail,
            arguments: item.navigationParams);
        break;
      case 'AppRoutes.buyVehicleDetail':
        Get.toNamed(AppRoutes.buyVehicleDetail,
            arguments: item.navigationParams);
        break;
      case 'AppRoutes.spareDetail':
        Get.toNamed(AppRoutes.spareDetail, arguments: item.navigationParams);
        break;
      case 'AppRoutes.serviceSupport':
        Get.toNamed(AppRoutes.serviceSupport, arguments: item.navigationParams);
        break;
      default:
        // Unknown route — do nothing
        debugPrint(
            '⚠️ [SearchController.navigate] Unknown route: ${item.navigationRoute}');
    }
  }
}

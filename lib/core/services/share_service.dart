import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../network/network_service.dart';
import '../network/endpoints/api_endpoints.dart';
import '../services/logger_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_keys.dart';

/// ShareService — calls the backend generate-link API and opens the
/// native share sheet with the returned share_url.
///
/// API: POST /api/v1/share/generate-link
/// Response: { data: { share_url, short_url, referral_code, ... } }
class ShareService extends GetxService {
  static ShareService get to => Get.find();

  // Smart redirect base — the API server detects the user agent and redirects:
  //   Android (no app) → Play Store
  //   iOS (no app) → App Store
  //   App installed → opened directly by App Links / Universal Links
  //   Desktop → web listing page
  static const _shareBase = 'https://api.staging.vahaanbazar.in';
  static const _fallbackBase = 'https://vahaanbazar.in';

  // ── Share buy vehicle ──────────────────────────────────────────

  Future<void> shareVehicle({
    required String sbVehicleId,
    String? vehicleName,
    String? brandName,
    String? modelName,
    String? year,
    String? categoryName,
    String? imageUrl,
  }) async {
    final displayName = _buildName(
      vehicleName: vehicleName,
      brandName: brandName,
      modelName: modelName,
      categoryName: categoryName,
    );

    String shareUrl;

    try {
      final resp = await NetworkService.to.post(
        ApiEndpoints.generateShareLink,
        data: {
          'content_type': 'buy_vehicle',
          'content_id': sbVehicleId,
          if (displayName.isNotEmpty) 'title': displayName,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        },
      );

      shareUrl = _extractUrl(resp.data);
      LoggerService.to.info('[ShareService] Vehicle link generated: $shareUrl');
    } catch (e) {
      LoggerService.to.error('[ShareService] generate-link failed: $e');
      // Fallback — build smart redirect URL via API server
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      shareUrl =
          '$_shareBase/v/$sbVehicleId'
          '${userId.isNotEmpty ? '?ref=$userId' : ''}';
    }

    final text = _buildVehicleShareText(
      name: displayName,
      year: year,
      url: shareUrl,
    );

    await Share.share(
      text,
      subject: displayName.isNotEmpty
          ? '$displayName — Vahaan Bazar'
          : 'Check out this vehicle on Vahaan Bazar',
    );
  }

  // ── Share referral link ────────────────────────────────────────

  Future<void> shareReferral({String? referralCode}) async {
    String shareUrl;

    try {
      final resp = await NetworkService.to.post(
        ApiEndpoints.referralLink,
        data: {
          'content_type': 'referral',
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );
      shareUrl = _extractUrl(resp.data);
      LoggerService.to.info('[ShareService] Referral link: $shareUrl');
    } catch (e) {
      LoggerService.to.error('[ShareService] referral-link failed: $e');
      final userId =
          referralCode ??
          await SecureStorageService.to.read(StorageKeys.userId) ??
          '';
      shareUrl =
          '$_fallbackBase/referral${userId.isNotEmpty ? '?ref=$userId' : ''}';
    }

    await Share.share(
      '🚛 Join Vahaan Bazar — India\'s trusted vehicle marketplace!\n\n'
      'Sign up using my referral link and start buying & selling vehicles:\n\n'
      '$shareUrl\n\n'
      '📱 Available on Android & iOS.',
      subject: 'Join Vahaan Bazar',
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _extractUrl(dynamic responseData) {
    try {
      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map) {
          final url =
              (data['short_url'] as String?)?.trim() ??
              (data['share_url'] as String?)?.trim() ??
              '';
          if (url.isNotEmpty) return url;
        }
      }
    } catch (_) {}
    return '';
  }

  String _buildName({
    String? vehicleName,
    String? brandName,
    String? modelName,
    String? categoryName,
  }) {
    final brand = (brandName ?? '').trim();
    final model = (modelName ?? '').trim();
    if (brand.isNotEmpty && model.isNotEmpty) return '$brand $model';
    if (brand.isNotEmpty) return brand;
    if (model.isNotEmpty) return model;
    final name = (vehicleName ?? '').trim();
    if (name.isNotEmpty) return name;
    return (categoryName ?? '').trim();
  }

  String _buildVehicleShareText({
    required String name,
    String? year,
    required String url,
  }) {
    final nameLine = name.isNotEmpty ? '🚛 *$name*' : '🚛 Vehicle';
    final yearLine = (year != null && year.isNotEmpty)
        ? '\n📅 Year: $year'
        : '';

    return '$nameLine$yearLine\n\n'
        'Found on *Vahaan Bazar* — India\'s trusted vehicle marketplace.\n\n'
        '👉 View details & contact seller:\n$url';
  }
}

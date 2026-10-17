import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../network/network_service.dart';
import '../network/endpoints/api_endpoints.dart';
import '../services/logger_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_keys.dart';
import '../extensions/context_extensions.dart';

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
  static const _shareBase = 'https://q7imfgydpj.ap-south-1.awsapprunner.com';
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
          ? appL10n.coreShareVehicleSubject(displayName)
          : appL10n.coreShareVehicleSubjectFallback,
    );
  }

  // ── Share approved vehicle / auction / auction vehicle ─────────

  /// Public site path per content type (mirrors the backend link builder).
  static const _sitePaths = <String, String>{
    'approved_vehicle': 'approved-vehicle',
    'live_auction': 'auction',
    'upcoming_auction': 'auction',
    'closed_auction': 'auction',
    'auction_vehicle': 'auction-vehicle',
  };
  static const _siteBase = 'https://www.vahaanbazar.com';

  /// Asks the backend for a link carrying the sharer's referral code. If the
  /// API is unreachable, builds the same URL locally so sharing still works.
  Future<String> _linkFor(String contentType, String contentId) async {
    try {
      final resp = await NetworkService.to.post(
        ApiEndpoints.generateShareLink,
        data: {'content_type': contentType, 'content_id': contentId},
      );
      final url = _extractUrl(resp.data);
      if (url.isNotEmpty) return url;
    } catch (e) {
      LoggerService.to.error('[ShareService] generate-link($contentType) failed: $e');
    }
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    final path = _sitePaths[contentType] ?? 'vehicle';
    return '$_siteBase/$path/$contentId${userId.isNotEmpty ? '?ref=$userId' : ''}';
  }

  Future<void> shareApprovedVehicle({
    required String approvedVehicleId,
    String? name,
    int? year,
    double? price,
  }) async {
    final url = await _linkFor('approved_vehicle', approvedVehicleId);
    final title = (name ?? '').trim().isNotEmpty ? name!.trim() : 'Approved vehicle';
    final lines = <String>[
      '🚛 *$title*',
      if (year != null && year > 0) '📅 Year: $year',
      if (price != null && price > 0) '💰 Price: ₹${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}',
      '',
      'Check out this approved vehicle on Vahaan Bazar:\n$url',
    ];
    await Share.share(lines.join('\n'), subject: title);
  }

  /// [auctionType]: live_auction | upcoming_auction | closed_auction
  Future<void> shareAuction({
    required String auctionId,
    String auctionType = 'live_auction',
    String? title,
  }) async {
    final url = await _linkFor(auctionType, auctionId);
    final name = (title ?? '').trim().isNotEmpty ? title!.trim() : 'Auction $auctionId';
    await Share.share(
      '🔨 *$name*\n\nJoin this auction on Vahaan Bazar:\n$url',
      subject: name,
    );
  }

  Future<void> shareAuctionVehicle({
    required String vehicleId,
    String? name,
    String? auctionId,
  }) async {
    final url = await _linkFor('auction_vehicle', vehicleId);
    final title = (name ?? '').trim().isNotEmpty ? name!.trim() : 'Auction vehicle';
    await Share.share(
      '🚛 *$title*'
      '${(auctionId ?? '').isNotEmpty ? '\n🔨 Auction: $auctionId' : ''}'
      '\n\nSee this vehicle on Vahaan Bazar:\n$url',
      subject: title,
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
      appL10n.coreShareReferralText(shareUrl),
      subject: appL10n.coreShareReferralSubject,
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
    final nameLine = name.isNotEmpty
        ? '🚛 *$name*'
        : '🚛 ${appL10n.coreShareVehicleLabel}';
    final yearLine = (year != null && year.isNotEmpty)
        ? '\n📅 ${appL10n.coreShareYearLine(year)}'
        : '';

    return '$nameLine$yearLine\n\n${appL10n.coreShareVehicleBody(url)}';
  }
}

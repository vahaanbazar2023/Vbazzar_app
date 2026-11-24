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
/// API: POST /api/v1/share/generate-link (platform: app)
/// Response: { data: { share_url, short_url, referral_code, ... } }
///
/// Links shared from the app are `https://www.vahaanbazar.com/open/{type}/{id}?ref=…`.
/// Only /open/* is claimed by the app (App Links / Universal Links), so they open
/// the app; without the app the website sends Android to the Play Store, iOS to the
/// App Store and desktop to the web page. Links shared from the website have no
/// /open prefix and stay in the browser.
class ShareService extends GetxService {
  static ShareService get to => Get.find();

  static const _appLinkBase = 'https://www.vahaanbazar.com/open';

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
          'platform': 'app',
          if (displayName.isNotEmpty) 'title': displayName,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        },
      );

      shareUrl = _extractUrl(resp.data);
      LoggerService.to.info('[ShareService] Vehicle link generated: $shareUrl');
    } catch (e) {
      LoggerService.to.error('[ShareService] generate-link failed: $e');
      // Fallback — build the same app link locally
      shareUrl = await _localLink('vehicle', sbVehicleId);
    }
    if (shareUrl.isEmpty) shareUrl = await _localLink('vehicle', sbVehicleId);

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

  /// Site path per content type (mirrors the backend link builder).
  static const _sitePaths = <String, String>{
    'approved_vehicle': 'approved-vehicle',
    'live_auction': 'auction',
    'upcoming_auction': 'auction',
    'closed_auction': 'auction',
    'auction_vehicle': 'auction-vehicle',
  };

  /// Asks the backend for a link carrying the sharer's referral code. If the
  /// API is unreachable, builds the same URL locally so sharing still works.
  Future<String> _linkFor(String contentType, String contentId) async {
    try {
      final resp = await NetworkService.to.post(
        ApiEndpoints.generateShareLink,
        data: {
          'content_type': contentType,
          'content_id': contentId,
          'platform': 'app',
        },
      );
      final url = _extractUrl(resp.data);
      if (url.isNotEmpty) return url;
    } catch (e) {
      LoggerService.to.error('[ShareService] generate-link($contentType) failed: $e');
    }
    return _localLink(_sitePaths[contentType] ?? 'vehicle', contentId);
  }

  /// App link built on the device when the API can't be reached.
  Future<String> _localLink(String path, String? contentId, {String? ref}) async {
    final userId =
        ref ?? await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    final id = (contentId ?? '').isNotEmpty ? '/$contentId' : '';
    return '$_appLinkBase/$path$id${userId.isNotEmpty ? '?ref=$userId' : ''}';
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
          'platform': 'app',
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );
      shareUrl = _extractUrl(resp.data);
      LoggerService.to.info('[ShareService] Referral link: $shareUrl');
    } catch (e) {
      LoggerService.to.error('[ShareService] referral-link failed: $e');
      shareUrl = await _localLink('referral', null, ref: referralCode);
    }
    if (shareUrl.isEmpty) {
      shareUrl = await _localLink('referral', null, ref: referralCode);
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

import 'package:flutter/widgets.dart';

import '../../core/network/endpoints/api_endpoints.dart';
import '../../core/network/network_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/storage/storage_keys.dart';

/// Embed session minted by the backend (secret key never reaches the app).
class RevvotSession {
  final String sessionId;
  final String embedToken;
  final String platformKey;

  const RevvotSession({
    required this.sessionId,
    required this.embedToken,
    required this.platformKey,
  });
}

/// Server-verified outcome of a Revvot session.
class RevvotConfirmation {
  /// approved | underReview | notEligible | pending
  final String outcome;
  final num? eligibleAmount;
  final num? interestRate;
  final int? tenureMonths;

  const RevvotConfirmation({
    required this.outcome,
    this.eligibleAmount,
    this.interestRate,
    this.tenureMonths,
  });

  bool get isApproved => outcome == 'approved';
}

class RevvotService {
  RevvotService._();

  /// POST /api/v1/revvot/sessions — call when the user taps, not at app start.
  static Future<RevvotSession> createSession({String? externalRef}) async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    final res = await NetworkService.to.post(
      ApiEndpoints.revvotSessions,
      data: {
        if (externalRef != null && externalRef.isNotEmpty)
          'external_ref': externalRef,
        'user_id': userId,
      },
    );
    final data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return RevvotSession(
      sessionId: data['session_id'] as String,
      embedToken: data['embed_token'] as String,
      platformKey: data['platform_key'] as String,
    );
  }

  /// GET /api/v1/revvot/sessions/{id} — decide from this, not the SDK result.
  static Future<RevvotConfirmation> confirmSession(String sessionId) async {
    final res = await NetworkService.to.get(
      ApiEndpoints.revvotSession(sessionId),
    );
    final data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return RevvotConfirmation(
      outcome: (data['outcome'] as String?) ?? 'pending',
      eligibleAmount: data['eligible_amount'] as num?,
      interestRate: data['interest_rate'] as num?,
      tenureMonths: (data['tenure_months'] as num?)?.toInt(),
    );
  }

  /// Flip to true once the Revvot SDK (or its embed URL + JS bridge spec) is
  /// wired into [openSheet]. While false, the vehicle screen hides the button.
  static const bool sdkAvailable = false;

  /// Opens the Revvot sheet; returns true if the user finished the flow.
  /// TODO: replace with `RevvotBuyingPower.open(context, publicKey:
  /// session.platformKey, embedToken: session.embedToken)` once the package
  /// is available (it is not on pub.dev and its GitHub repo has no source).
  static Future<bool> openSheet(
    BuildContext context,
    RevvotSession session,
  ) async {
    throw UnimplementedError('Revvot SDK not integrated');
  }
}

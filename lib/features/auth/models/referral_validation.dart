/// Result of GET /api/v1/share/validate-referral-code (API key only, callable before login).
///
/// `data`: { valid, reason (EMPTY_CODE | INVALID_CODE | REFER_EARN_DISABLED), referral_code,
/// referrer_first_name (only when valid) }.
class ReferralValidation {
  final bool valid;
  final String? reason;
  final String? referrerFirstName;

  const ReferralValidation({
    required this.valid,
    this.reason,
    this.referrerFirstName,
  });

  /// Refer & Earn is switched off: a code cannot be applied, but that is not the user's mistake.
  bool get isDisabled => reason == 'REFER_EARN_DISABLED';

  factory ReferralValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return ReferralValidation(
      valid: data['valid'] == true,
      reason: data['reason'] as String?,
      referrerFirstName: data['referrer_first_name'] as String?,
    );
  }
}

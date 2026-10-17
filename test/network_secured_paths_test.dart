import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/network/endpoints/api_endpoints.dart';
import 'package:vahaan_mobile_2_0/core/network/network_service.dart';

/// NetworkService only attaches the Bearer token to paths on its allow-list; a route missing
/// from it is sent without a token and the backend answers 401 "Authentication token is
/// required". This guards the routes added for partner onboarding, vendor portal and cash-out.
void main() {
  final net = NetworkService();
  bool secured(String p) => net.requiresAuthenticationForTest(p);

  test('partner with us routes send the Bearer token', () {
    expect(secured(ApiEndpoints.partnerRequest), isTrue);
    expect(secured(ApiEndpoints.partnerMyRequest), isTrue);
  });

  test(
    'vendor portal and vendor self-service routes send the Bearer token',
    () {
      for (final p in [
        ApiEndpoints.vendorPortalSummary,
        ApiEndpoints.vendorPortalInventory,
        ApiEndpoints.vendorPortalInventoryUpdate,
        ApiEndpoints.vendorPortalSpareUpdate,
        ApiEndpoints.vendorPortalMyOrders,
        ApiEndpoints.vendorPortalOrderStatus,
        '${ApiEndpoints.spareFmsVendorPrefix}/shop-enroll',
        '${ApiEndpoints.spareFmsVendorPrefix}/spare-create',
        '${ApiEndpoints.spareFmsVendorPrefix}/my-listings',
        '${ApiEndpoints.spareFmsVendorPrefix}/upload-images',
      ]) {
        expect(secured(p), isTrue, reason: p);
      }
    },
  );

  test('cash-out routes (incl. history) send the Bearer token', () {
    expect(secured(ApiEndpoints.walletCashOut), isTrue);
    expect(secured(ApiEndpoints.walletCashOutHistory), isTrue);
    expect(secured('${ApiEndpoints.walletCashOut}/eligibility'), isTrue);
  });

  test(
    'referral-link is authenticated, validate-referral-code is API-key only',
    () {
      expect(secured(ApiEndpoints.referralLink), isTrue);
      // Called on the signup screen before login, so it must not require a session.
      expect(secured(ApiEndpoints.validateReferralCode), isFalse);
    },
  );
}

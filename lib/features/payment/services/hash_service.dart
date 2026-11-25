import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

import 'payment_service.dart';

/// Answers PayU Checkout Pro's `generateHash` callback.
///
/// Hashes that need the merchant salt are signed by the backend
/// (`POST /api/v1/payments/payu-hash`). The salt must never be on the device:
/// anyone holding it can forge PayU hashes.
class HashService {
  static const merchantSecretKey = ""; // Add Merchant Secret Key - Optional

  static Future<Map> generateHash(Map response, PaymentService service) async {
    final hashName = response[PayUHashConstantsKeys.hashName]?.toString() ?? '';
    final hashString =
        response[PayUHashConstantsKeys.hashString]?.toString() ?? '';
    final hashType = response[PayUHashConstantsKeys.hashType]?.toString();
    final postSalt = response[PayUHashConstantsKeys.postSalt]?.toString();

    // MCP lookup is keyed with the merchant secret key, not the salt.
    if (hashName == PayUHashConstantsKeys.mcpLookup) {
      return {hashName: getHmacSHA1Hash(hashString, merchantSecretKey)};
    }

    final hash = await service.signPayuHash(
      hashName: hashName,
      hashString: hashString,
      hashType: hashType,
      postSalt: postSalt,
    );
    // An empty hash makes PayU fail that step instead of hanging the checkout.
    return {hashName: hash ?? ''};
  }

  static String getHmacSHA1Hash(String hashData, String key) {
    final hmacSha1 = Hmac(sha1, utf8.encode(key));
    return hmacSha1.convert(utf8.encode(hashData)).toString();
  }
}

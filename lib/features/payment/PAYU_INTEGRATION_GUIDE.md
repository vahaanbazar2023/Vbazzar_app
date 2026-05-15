# PayU SDK Payment Integration — Complete Documentation

> **Project:** Vahaan Bazar (Flutter)  
> **SDK:** `payu_checkoutpro_flutter` (PayU Checkout Pro)  
> **State Management:** GetX  
> **HTTP Client:** Dio  
> **Last Updated:** April 2026

---

## 📦 1. Overview

### How PayU Is Integrated

Vahaan Bazar uses the **PayU Checkout Pro SDK** (`payu_checkoutpro_flutter`) to process payments natively within the Flutter app. The integration follows a **client-server hybrid model**:

1. The **Flutter app** requests payment credentials (merchant key, salt, form data) from the **backend API**.
2. The **backend** creates a payment record, generates the PayU form data (including hash), and returns it to the app.
3. The **Flutter app** opens the PayU Checkout Pro SDK with the received credentials.
4. The **SDK** handles the entire payment UI (card entry, UPI, netbanking, wallets, OTP, etc.).
5. On completion, the **SDK callback** returns the result to the app, which then **reports success/failure back to the backend**.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                              │
│                                                                 │
│  SubscriptionConfirmController                                  │
│       │                                                         │
│       ▼                                                         │
│  PaymentController.initiatePayment()                            │
│       │                                                         │
│       ▼                                                         │
│  PaymentService.initiatePayment()  ──── POST /api/v1/payments/initiate
│       │                                                         │
│       ▼                                                         │
│  PayUConfig.setMerchantKey() / setSaltKey()                     │
│  HashService.merchantSalt = saltKey                             │
│       │                                                         │
│       ▼                                                         │
│  PayUCheckoutProFlutter.openCheckoutScreen()                    │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────────────────────────────┐                        │
│  │     PayU Checkout Pro SDK UI        │                        │
│  │  (Card / UPI / NetBanking / Wallet) │                        │
│  └─────────────────────────────────────┘                        │
│       │                                                         │
│       ├──► onPaymentSuccess ──► PaymentService.reportSuccess()  │
│       ├──► onPaymentFailure ──► PaymentService.reportFailure()  │
│       ├──► onPaymentCancel  ──► (local state update only)       │
│       └──► onError          ──► (local state update only)       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
App ──► Backend API (/payments/initiate) ──► Returns PaymentData
                                                  │
                                                  ▼
                                    PayUConfig (merchantKey, saltKey)
                                    HashService (merchantSalt)
                                                  │
                                                  ▼
                                    PayU SDK opens checkout screen
                                                  │
                                    ┌─────────────┼─────────────┐
                                    ▼             ▼             ▼
                                 Success       Failure       Cancel
                                    │             │             │
                                    ▼             ▼             ▼
                              Report to      Report to     Update local
                              Backend API    Backend API     state only
```

---

## 🗂️ 2. Module Breakdown

### Directory Structure

```
lib/features/payment/
├── config/
│   └── payu_config.dart               # PayU configuration & parameter builders
├── controllers/
│   └── payment_controller.dart        # Main payment orchestration (GetX controller)
├── models/
│   └── payment_models.dart            # Request/response data models
├── services/
│   ├── hash_service.dart              # SHA-512 / HMAC hash generation
│   └── payment_service.dart           # API communication (Dio-based)
├── views/
│   └── payment_view.dart              # Payment UI (optional standalone view)
└── PAYU_INTEGRATION_GUIDE.md          # This documentation
```

### File-by-File Breakdown

#### `config/payu_config.dart` — PayU Configuration

| Responsibility | Details |
|---|---|
| **Dynamic credential storage** | Static `merchantKey` and `saltKey` fields, set at runtime from API response |
| **Environment flag** | `isProduction = true` (always production) |
| **Payment params builder** | `createPayUPaymentParamsFromData(PaymentData)` — builds the map required by `openCheckoutScreen()` |
| **Checkout config builder** | `createPayUConfigParams()` — builds UI config (colors, payment modes order, cart details, custom notes) |
| **Transaction ID generator** | `generateTransactionId()` — creates unique `VB_{timestamp}_{suffix}` IDs |

**Key design decision:** The merchant key and salt are **never hardcoded** in the app. They are fetched from the backend API on every payment initiation. This means credentials can be rotated server-side without app updates.

#### `controllers/payment_controller.dart` — Payment Orchestrator

| Responsibility | Details |
|---|---|
| **Implements `PayUCheckoutProProtocol`** | Required interface for PayU SDK callbacks |
| **`initiatePayment()`** | Public API — calls backend, configures SDK, opens checkout |
| **`generateHash()`** | SDK callback — delegates to `HashService` |
| **`onPaymentSuccess()`** | SDK callback — extracts response, reports to backend, completes future |
| **`onPaymentFailure()`** | SDK callback — extracts error, reports to backend, completes future |
| **`onPaymentCancel()`** | SDK callback — updates state, completes future with false |
| **`onError()`** | SDK callback — logs error, notifies failure callback |
| **State management** | GetX observables: `status`, `errorMessage`, `paymentData` |
| **Completer pattern** | Uses `Completer<bool>` so callers can `await` the payment result |

#### `models/payment_models.dart` — Data Models

| Model | Purpose |
|---|---|
| `InitiatePaymentReq` | Request body for `POST /payments/initiate` |
| `InitiatePaymentRes` | Response wrapper with `status`, `code`, `message`, `data` |
| `PaymentData` | Contains `paymentId`, `txnId`, `payuFormData`, `merchantKey`, `saltKey` |
| `PayuFormData` | All PayU form fields: `key`, `txnid`, `amount`, `productinfo`, `firstname`, `email`, `phone`, `surl`, `furl`, `udf1`–`udf5`, `hash` |
| `PaymentStatusCallback` | Callback data sent to backend after payment completes |

**Safety features:** All models use `_safeString()`, `_safeInt()`, `_safeMap()` helpers to handle type mismatches from the API (e.g., `num` vs `String`, `null` values, `Map<dynamic, dynamic>` from Dio).

#### `services/hash_service.dart` — Hash Generation

| Method | Algorithm | Usage |
|---|---|---|
| `generateHash(Map response)` | Dispatcher | Called by SDK via controller's `generateHash()` callback |
| `getSHA512Hash(String data)` | SHA-512 | Default hash for most PayU operations |
| `getHmacSHA256Hash(String data, String salt)` | HMAC-SHA256 | Used for V2 hash type |
| `getHmacSHA1Hash(String data, String salt)` | HMAC-SHA1 | Used for MCP lookup |

**Critical:** The `merchantSalt` is set dynamically from the controller after the API response. It is **not** hardcoded.

#### `services/payment_service.dart` — API Communication

| Method | Endpoint | Purpose |
|---|---|---|
| `initiatePayment(req)` | `POST /api/v1/payments/initiate` | Start payment, get PayU form data |
| `reportPaymentSuccess(callback)` | `POST /api/v1/payments/success` | Notify backend of successful payment |
| `reportPaymentFailure(callback)` | `POST /api/v1/payments/failure` | Notify backend of failed payment |

**Architecture:** Uses a **dedicated Dio instance** (not the shared `NetworkService`) configured with:
- **Base URL:** `https://api.prod.vahaanbazar.in` (always production, regardless of app environment)
- **API Key:** `7B0F2K4R1MSS3P0D` (production API key via `X-API-Key` header)
- **Auth Token:** Injected via interceptor from `SecureStorageService` (reads `auth_token`)
- **Timeouts:** 30 seconds for connect/receive/send

This design ensures payment APIs always hit the production server even when the rest of the app is configured for staging. Uses `_safeMap()` for robust response parsing.

---

## ⚙️ 3. Setup & Installation

### Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  payu_checkoutpro_flutter: ^1.3.0   # PayU Checkout Pro SDK
  get: ^4.6.6                         # State management
  dio: ^5.4.0                         # HTTP client
  crypto: ^3.0.3                      # Hash generation (SHA-512, HMAC)
```

Run:
```bash
flutter pub get
```

### Android Setup

#### 1. `android/app/build.gradle.kts`

```kotlin
android {
    compileSdk = 34
    defaultConfig {
        minSdk = 21  // PayU requires minimum SDK 21
    }
}
```

#### 2. `android/app/src/main/AndroidManifest.xml`

Add internet permission (if not present):
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### 3. ProGuard Rules

Create `android/app/payu-sdk-proguard-rules.pro`:
```proguard
-keep class com.payu.** { *; }
-dontwarn com.payu.**
-keep class com.payu.checkoutpro.** { *; }
-keep class com.payu.custombrowser.** { *; }
```

Reference in `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro",
            "payu-sdk-proguard-rules.pro"
        )
    }
}
```

### iOS Setup

#### 1. `ios/Podfile`

```ruby
platform :ios, '12.0'  # Minimum iOS version
```

#### 2. `ios/Runner/Info.plist`

Add URL schemes for PayU callbacks:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>payu</string>
    <string>phonepe</string>
    <string>tez</string>
    <string>upi</string>
</array>
```

Run:
```bash
cd ios && pod install
```

### Environment Variables

The app does **not** use `.env` files. Credentials are fetched from the backend API at runtime. However, the following are configured in code:

| Variable | Location | Value |
|---|---|---|
| `PayUConfig.isProduction` | `payu_config.dart` | `true` (always production) |
| `PayUConfig.baseUrl` | `payu_config.dart` | `https://api.prod.vahaanbazar.in` |
| `PayUConfig.apiKey` | `payu_config.dart` | `7B0F2K4R1MSS3P0D` |
| Merchant Key | Set dynamically from API | Via `PayUConfig.setMerchantKey()` |
| Salt Key | Set dynamically from API | Via `PayUConfig.setSaltKey()` |
| Success URL (`surl`) | Returned by backend in `PayuFormData` | Backend-configured |
| Failure URL (`furl`) | Returned by backend in `PayuFormData` | Backend-configured |

---

## 🔐 4. Configuration & Security

### How Configuration Is Handled

1. **Static defaults** are in `PayUConfig` (colors, merchant name, UI options).
2. **Dynamic credentials** (merchant key, salt) are set at runtime from the backend API response.
3. **Hash generation** uses the dynamically-set salt — never a hardcoded value.

### API Endpoints

**Base URL:** `https://api.prod.vahaanbazar.in`

All payment API calls use this production base URL. The full endpoints are:

| Endpoint | Full URL | Method | Purpose |
|---|---|---|---|
| `/api/v1/payments/initiate` | `https://api.prod.vahaanbazar.in/api/v1/payments/initiate` | POST | Create payment record, get PayU form data |
| `/api/v1/payments/success` | `https://api.prod.vahaanbazar.in/api/v1/payments/success` | POST | Report successful payment to backend |
| `/api/v1/payments/failure` | `https://api.prod.vahaanbazar.in/api/v1/payments/failure` | POST | Report failed payment to backend |

### Request Structure

#### Initiate Payment Request

```json
{
  "user_id": "user_12345",
  "plan_code": "VB_MONTHLY_PREMIUM",
  "from_wallet": 100.0,
  "for_payment": 499.0,
  "referral_code": "REF123"
}
```

#### Initiate Payment Response

```json
{
  "status": "success",
  "code": 200,
  "message": "Payment initiated successfully",
  "data": {
    "payment_id": "pay_abc123",
    "txn_id": "VB_1714012345678_1234",
    "merchant_key": "iZKr5a",
    "salt_key": "your_dynamic_salt_here",
    "payment_url": "https://secure.payu.in/_payment",
    "payu_form_data": {
      "key": "iZKr5a",
      "txnid": "VB_1714012345678_1234",
      "amount": "499.00",
      "productinfo": "Vahaan Bazar Premium Plan",
      "firstname": "John",
      "email": "john@example.com",
      "phone": "9876543210",
      "surl": "https://api.prod.vahaanbazar.in/api/v1/payments/success",
      "furl": "https://api.prod.vahaanbazar.in/api/v1/payments/failure",
      "service_provider": "payu_paisa",
      "udf1": "",
      "udf2": "",
      "udf3": "",
      "udf4": "",
      "udf5": "",
      "hash": "backend_generated_hash"
    }
  }
}
```

### Hash Generation Logic

Hash generation is handled by `HashService` and is called by the PayU SDK via the `generateHash()` callback.

#### How It Works

1. The PayU SDK calls `generateHash(Map response)` with a map containing:
   - `hashName` — the name/key for the hash (e.g., `payment_hash`)
   - `hashString` — the string to hash (without salt)
   - `hashType` — determines which algorithm to use
   - `postSalt` — optional string to append after salt

2. `HashService` selects the algorithm based on `hashType`:

```
┌──────────────────────────────────────────────────────────────┐
│                    Hash Generation Flow                       │
│                                                              │
│  SDK calls generateHash(response)                            │
│       │                                                      │
│       ▼                                                      │
│  Extract: hashName, hashString, hashType, postSalt           │
│       │                                                      │
│       ├── hashType == "V2"                                   │
│       │       └──► HMAC-SHA256(hashString, salt) → Base64    │
│       │                                                      │
│       ├── hashName == "mcp_lookup"                           │
│       │       └──► HMAC-SHA1(hashString, secretKey)          │
│       │                                                      │
│       └── default                                            │
│               └──► SHA-512(hashString + salt + postSalt)     │
│                                                              │
│  Return { hashName: computedHash }                           │
└──────────────────────────────────────────────────────────────┘
```

#### Code Reference

```dart
// hash_service.dart
static Map generateHash(Map response) {
  var hashName = response[PayUHashConstantsKeys.hashName];
  var hashStringWithoutSalt = response[PayUHashConstantsKeys.hashString];
  var hashType = response[PayUHashConstantsKeys.hashType];
  var postSalt = response[PayUHashConstantsKeys.postSalt];

  var hash = "";

  if (hashType == PayUHashConstantsKeys.hashVersionV2) {
    hash = getHmacSHA256Hash(hashStringWithoutSalt, merchantSalt);
  } else if (hashName == PayUHashConstantsKeys.mcpLookup) {
    hash = getHmacSHA1Hash(hashStringWithoutSalt, merchantSecretKey);
  } else {
    var hashDataWithSalt = hashStringWithoutSalt + merchantSalt;
    if (postSalt != null) {
      hashDataWithSalt = hashDataWithSalt + postSalt;
    }
    hash = getSHA512Hash(hashDataWithSalt);
  }

  return {hashName: hash};
}
```

#### SHA-512 Implementation

```dart
static String getSHA512Hash(String hashData) {
  var bytes = utf8.encode(hashData);
  var hash = sha512.convert(bytes);
  return hash.toString();
}
```

#### HMAC-SHA256 Implementation

```dart
static String getHmacSHA256Hash(String hashData, String salt) {
  var key = utf8.encode(salt);
  var bytes = utf8.encode(hashData);
  final hmacSha256 = Hmac(sha256, key).convert(bytes).bytes;
  final hmacBase64 = base64Encode(hmacSha256);
  return hmacBase64;
}
```

### Security Considerations

| Concern | How It's Handled |
|---|---|
| **Merchant key exposure** | Fetched from backend API at runtime, not hardcoded |
| **Salt exposure** | Fetched from backend API at runtime, set dynamically |
| **Hash generation** | Done client-side via SDK callback (PayU requirement) |
| **Transaction integrity** | Backend validates hash on success/failure callbacks |
| **Credential rotation** | Backend can rotate keys without app update |
| **HTTPS** | All API calls use HTTPS (`https://api.prod.vahaanbazar.in`) |
| **Sensitive data logging** | Debug prints only in development; should be removed in production |

---

## 💳 5. Payment Flow (Step-by-Step)

### Complete Flow Diagram

```
User taps "Subscribe" on SubscriptionConfirmScreen
    │
    ▼
SubscriptionConfirmController calls PaymentController.initiatePayment()
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 1: Payment Request Creation                         │
│                                                          │
│ PaymentController creates InitiatePaymentReq with:       │
│   - userId, planCode, fromWallet, forPayment, referralCode│
│                                                          │
│ Calls PaymentService.initiatePayment(req)                │
│   → POST /api/v1/payments/initiate                       │
│                                                          │
│ Backend returns: PaymentData with merchantKey, saltKey,  │
│   payuFormData (key, txnid, amount, productinfo, etc.)   │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 2: SDK Configuration                                │
│                                                          │
│ PayUConfig.setMerchantKey(data.merchantKey)              │
│ PayUConfig.setSaltKey(data.saltKey)                      │
│ HashService.merchantSalt = data.saltKey                  │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 3: Build PayU Parameters                            │
│                                                          │
│ _buildPayUParams(data) creates:                          │
│   {                                                      │
│     key, amount, productInfo, firstName, email, phone,   │
│     surl, furl, environment("0"), userCredential(null),  │
│     transactionId, additionalParam(udf1-udf5),           │
│     enableNativeOTP: true                                │
│   }                                                      │
│                                                          │
│ _buildPayUConfig() creates:                              │
│   {                                                      │
│     primaryColor, secondaryColor, merchantName,          │
│     paymentModesOrder, cartDetails, customNotes,         │
│     autoSelectOtp, autoApprove, merchantSMSPermission    │
│   }                                                      │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 4: SDK Invocation                                   │
│                                                          │
│ _checkoutPro.openCheckoutScreen(                         │
│   payUPaymentParams: payuParams,                         │
│   payUCheckoutProConfig: payuConfig,                     │
│ )                                                        │
│                                                          │
│ PayU SDK opens native checkout UI with:                  │
│   - Credit/Debit Card                                    │
│   - UPI (PhonePe, Google Pay, etc.)                      │
│   - Net Banking                                          │
│   - Wallets                                              │
│   - EMI                                                  │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 5: Hash Generation (during SDK flow)                │
│                                                          │
│ SDK calls controller.generateHash(response)              │
│   → HashService.generateHash(response)                   │
│     → Selects algorithm (SHA-512 / HMAC-SHA256 / HMAC-SHA1)│
│     → Computes hash using dynamic salt                   │
│   → _checkoutPro.hashGenerated(hash: result)             │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 6: Response Handling                                │
│                                                          │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│ │ Success  │  │ Failure  │  │ Cancel   │  │  Error   │ │
│ │          │  │          │  │          │  │          │ │
│ │ Extract  │  │ Extract  │  │ Set      │  │ Set      │ │
│ │ response │  │ response │  │ status   │  │ status   │ │
│ │ data     │  │ data     │  │ cancelled│  │ failed   │ │
│ │          │  │          │  │          │  │          │ │
│ │ Build    │  │ Build    │  │ Call     │  │ Call     │ │
│ │ callback │  │ callback │  │ onCancel │  │ onFail   │ │
│ │          │  │          │  │          │  │          │ │
│ │ Report   │  │ Report   │  │ Complete │  │ Complete │ │
│ │ to API   │  │ to API   │  │ future   │  │ future   │ │
│ │ /success │  │ /failure │  │ (false)  │  │ (false)  │ │
│ │          │  │          │  │          │  │          │ │
│ │ Complete │  │ Complete │  │          │  │          │ │
│ │ future   │  │ future   │  │          │  │          │ │
│ │ (true)   │  │ (false)  │  │          │  │          │ │
│ └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ Step 7: Transaction Verification                         │
│                                                          │
│ Backend receives callback at /payments/success or        │
│ /payments/failure and:                                   │
│   1. Validates the hash                                  │
│   2. Verifies transaction with PayU server-to-server     │
│   3. Updates subscription/plan in database               │
│   4. Returns confirmation to app                         │
└─────────────────────────────────────────────────────────┘
```

### Success Response Data

When `onPaymentSuccess` fires, the SDK returns a map (or URL-encoded string) containing:

| Field | Example | Description |
|---|---|---|
| `key` | `iZKr5a` | Merchant key |
| `txnid` | `VB_1714012345678_1234` | Transaction ID |
| `amount` | `499.00` | Payment amount |
| `productinfo` | `Vahaan Bazar Premium Plan` | Product description |
| `firstname` | `John` | Customer name |
| `email` | `john@example.com` | Customer email |
| `phone` | `9876543210` | Customer phone |
| `hash` | `a1b2c3...` | Response hash |
| `mihpayid` | `123456789` | PayU transaction ID |
| `mode` | `CC` | Payment mode (CC/DC/UPI/NB) |
| `bank_ref_num` | `SBI123456` | Bank reference number |
| `PG_TYPE` | `CC-PG` | Payment gateway type |
| `udf1`–`udf5` | Various | User-defined fields |

---

## 🧩 6. Code-Level Explanation

### Key Classes

#### `PaymentController` (GetX Controller)

```dart
class PaymentController extends GetxController
    implements PayUCheckoutProProtocol {

  // Observable state
  final status = PaymentStatus.idle.obs;
  final errorMessage = ''.obs;
  final paymentData = Rxn<PaymentData>();

  // Callbacks (set by caller)
  void Function(PaymentData data, PaymentStatusCallback callback)? onSuccess;
  void Function(String message, PaymentStatusCallback? callback)? onFailure;
  void Function()? onCancelled;

  // Main entry point
  Future<bool> initiatePayment({
    required String userId,
    required String planCode,
    double? fromWallet,
    double? forPayment,
    String? referralCode,
  }) async { ... }
}
```

**Usage from another controller:**

```dart
final paymentCtrl = Get.put(PaymentController());

paymentCtrl.onSuccess = (data, callback) {
  // Handle success — e.g., refresh subscription list
  debugPrint('Payment successful: ${callback.txnId}');
};

paymentCtrl.onFailure = (message, callback) {
  // Handle failure — show error dialog
  Get.snackbar('Payment Failed', message);
};

paymentCtrl.onCancelled = () {
  // Handle cancellation
  Get.snackbar('Cancelled', 'Payment was cancelled');
};

final success = await paymentCtrl.initiatePayment(
  userId: currentUser.id,
  planCode: 'VB_MONTHLY_PREMIUM',
  forPayment: 499.0,
);

if (success) {
  // Navigate to success screen
}
```

#### `HashService` (Static Utility)

```dart
class HashService {
  static String merchantSalt = '';  // Set dynamically from controller

  static Map generateHash(Map response) {
    // Dispatches to correct hash algorithm based on hashType
    // Returns { hashName: computedHash }
  }

  static String getSHA512Hash(String hashData) { ... }
  static String getHmacSHA256Hash(String hashData, String salt) { ... }
  static String getHmacSHA1Hash(String hashData, String salt) { ... }
}
```

#### `PaymentService` (API Layer)

```dart
class PaymentService {
  // Dedicated Dio instance — always hits production
  static const String _paymentBaseUrl = 'https://api.prod.vahaanbazar.in';
  static const String _paymentApiKey = '7B0F2K4R1MSS3P0D';
  late final Dio _paymentDio;

  PaymentService() {
    _paymentDio = _createPaymentDio(); // Production base URL + API key + auth interceptor
  }

  Future<InitiatePaymentRes> initiatePayment(InitiatePaymentReq req) async { ... }
  Future<InitiatePaymentRes> reportPaymentSuccess(PaymentStatusCallback callback) async { ... }
  Future<InitiatePaymentRes> reportPaymentFailure(PaymentStatusCallback callback) async { ... }
}
```

**Key difference from other services:** Uses its own Dio instance with production base URL (`https://api.prod.vahaanbazar.in`) and production API key (`7B0F2K4R1MSS3P0D`), independent of the app's shared `NetworkService` which may point to staging.

#### `PayUConfig` (Configuration)

```dart
class PayUConfig {
  static String merchantKey = '';   // Set from API
  static String saltKey = '';       // Set from API
  static const bool isProduction = true;

  static void setMerchantKey(String key) { ... }
  static void setSaltKey(String salt) { ... }
  static Map<String, dynamic> createPayUPaymentParamsFromData(PaymentData data) { ... }
  static Map<String, dynamic> createPayUConfigParams() { ... }
  static String generateTransactionId({String? prefix}) { ... }
}
```

### Request/Response Models

#### `InitiatePaymentReq`

```dart
class InitiatePaymentReq {
  final String userId;       // Required
  final String planCode;     // Required
  final double? fromWallet;  // Optional — wallet deduction amount
  final double? forPayment;  // Optional — total payment amount
  final String? referralCode;// Optional — referral code

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'plan_code': planCode,
    if (fromWallet != null && fromWallet! > 0) 'from_wallet': fromWallet,
    if (forPayment != null) 'for_payment': forPayment,
    if (referralCode != null && referralCode!.isNotEmpty) 'referral_code': referralCode,
  };
}
```

#### `PaymentStatusCallback`

```dart
class PaymentStatusCallback {
  final String key;
  final String txnId;
  final String amount;
  final String productInfo;
  final String firstname;
  final String email;
  final String phone;
  final String paymentStatus;  // 'success' or 'failure'
  final String hash;
  final String? mode;
  final String? bankRef;
  final String? pgType;
  final String? bankRefNum;
  final String? mihpayid;
  final String? udf1, udf2, udf3, udf4, udf5;
  final String? error;
  final String? errorMessage;

  Map<String, dynamic> toJson() => { ... };
}
```

### Error Handling

| Error Type | Where Handled | Behavior |
|---|---|---|
| **API failure** (initiate) | `PaymentController.initiatePayment()` | Sets `status = failed`, calls `onFailure` callback, returns `false` |
| **API returns error status** | `PaymentController.initiatePayment()` | Same as above — checks `res.isSuccess` |
| **PayU SDK error** | `onError(Map? response)` | Sets `status = failed`, extracts error message, calls `onFailure` |
| **Payment failure** | `onPaymentFailure(dynamic response)` | Sets `status = failed`, reports to backend, calls `onFailure` |
| **User cancellation** | `onPaymentCancel(Map? response)` | Sets `status = cancelled`, calls `onCancelled` |
| **Network timeout** | Dio exception in `PaymentService` | Returns `InitiatePaymentRes` with error status |
| **Type mismatch** (API response) | `_safeString()`, `_safeInt()`, `_safeMap()` | Graceful fallback to defaults |
| **Unexpected exception** | `catch (e)` in `initiatePayment()` | Sets `status = failed`, calls `onFailure` |

---

## 🔄 7. Reusable Integration Guide (From Scratch)

### Step 1: Project Setup

```bash
# Create Flutter project
flutter create my_payu_app
cd my_payu_app

# Add dependencies
flutter pub add payu_checkoutpro_flutter
flutter pub add get
flutter pub add dio
flutter pub add crypto
```

### Step 2: Create Module Structure

```
lib/
├── features/
│   └── payment/
│       ├── config/
│       │   └── payu_config.dart
│       ├── controllers/
│       │   └── payment_controller.dart
│       ├── models/
│       │   └── payment_models.dart
│       └── services/
│           ├── hash_service.dart
│           └── payment_service.dart
├── core/
│   └── network/
│       ├── network_service.dart
│       └── endpoints/
│           └── api_endpoints.dart
└── main.dart
```

### Step 3: Implement Models

Create `payment_models.dart` with:
- `InitiatePaymentReq` — request body
- `InitiatePaymentRes` — response wrapper
- `PaymentData` — payment details from API
- `PayuFormData` — PayU form fields
- `PaymentStatusCallback` — callback data

Use `_safeString()`, `_safeInt()`, `_safeMap()` helpers for robust JSON parsing.

### Step 4: Implement Hash Service

Create `hash_service.dart`:
- Static `merchantSalt` field (set dynamically)
- `generateHash(Map response)` — dispatches to correct algorithm
- `getSHA512Hash()` — for default hash
- `getHmacSHA256Hash()` — for V2 hash
- `getHmacSHA1Hash()` — for MCP lookup

### Step 5: Implement Payment Service

Create `payment_service.dart`:
- `initiatePayment(req)` — POST to backend
- `reportPaymentSuccess(callback)` — POST success callback
- `reportPaymentFailure(callback)` — POST failure callback

### Step 6: Implement PayU Config

Create `payu_config.dart`:
- Static `merchantKey` and `saltKey` (set from API)
- `isProduction = true`
- `createPayUPaymentParamsFromData(data)` — builds SDK params
- `createPayUConfigParams()` — builds checkout config

### Step 7: Implement Payment Controller

Create `payment_controller.dart`:
- Extend `GetxController` and implement `PayUCheckoutProProtocol`
- `initiatePayment()` — main entry point
- `generateHash()` — SDK callback → HashService
- `onPaymentSuccess()` — extract data, report to backend
- `onPaymentFailure()` — extract error, report to backend
- `onPaymentCancel()` — update state
- `onError()` — log and notify

### Step 8: Android/iOS Configuration

**Android:**
1. Set `minSdk = 21` in `build.gradle.kts`
2. Add ProGuard rules for PayU
3. Ensure internet permission

**iOS:**
1. Set `platform :ios, '12.0'` in Podfile
2. Add URL schemes in Info.plist
3. Run `pod install`

### Step 9: Backend API Requirements

Your backend must implement:

| Endpoint | Method | Request | Response |
|---|---|---|---|
| `/api/v1/payments/initiate` | POST | `{ user_id, plan_code, from_wallet?, for_payment?, referral_code? }` | `{ status, code, message, data: { payment_id, txn_id, merchant_key, salt_key, payu_form_data: { key, txnid, amount, productinfo, firstname, email, phone, surl, furl, udf1-5, hash } } }` |
| `/api/v1/payments/success` | POST | PayU callback data | `{ status, code, message }` |
| `/api/v1/payments/failure` | POST | PayU callback data | `{ status, code, message }` |

### Step 10: Testing

```dart
// In your UI controller
final paymentCtrl = Get.put(PaymentController());

paymentCtrl.onSuccess = (data, callback) {
  Get.snackbar('Success', 'Payment ${callback.txnId} completed');
};

final success = await paymentCtrl.initiatePayment(
  userId: 'test_user_001',
  planCode: 'TEST_PLAN',
  forPayment: 1.0,  // Use small amount for testing
);
```

---

## 🚀 8. Improvements / Advanced Version

### 1. Backend-Based Hash Generation (Recommended)

**Current:** Hash is generated client-side in `HashService`.

**Improved:** Move hash generation entirely to backend:

```dart
// Instead of client-side hash generation:
@override
void generateHash(Map response) {
  // Call backend API to get hash
  _service.getHash(response).then((hashResponse) {
    _checkoutPro.hashGenerated(hash: hashResponse);
  });
}
```

**Benefits:**
- Salt never exposed to client
- Hash algorithm can be updated server-side
- Better security posture

### 2. Improved Error Handling

```dart
// Add retry logic for network failures
Future<InitiatePaymentRes> initiatePaymentWithRetry(
  InitiatePaymentReq req, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    final res = await initiatePayment(req);
    if (res.isSuccess || i == maxRetries - 1) return res;
    await Future.delayed(Duration(seconds: pow(2, i).toInt()));
  }
  throw Exception('Max retries exceeded');
}

// Add specific error types
enum PaymentError {
  networkError,
  authenticationError,
  invalidAmount,
  serverError,
  sdkError,
  userCancelled,
}
```

### 3. Logging and Monitoring

```dart
// Add structured logging
class PaymentLogger {
  static void logInitiation(String txnId, String amount) {
    debugPrint('[PAYMENT] Initiating: txnId=$txnId, amount=$amount');
    // Send to analytics: Firebase Analytics, Mixpanel, etc.
  }

  static void logSuccess(String txnId, String mihpayid) {
    debugPrint('[PAYMENT] Success: txnId=$txnId, mihpayid=$mihpayid');
  }

  static void logFailure(String txnId, String error) {
    debugPrint('[PAYMENT] Failed: txnId=$txnId, error=$error');
    // Send to crash reporting: Sentry, Crashlytics, etc.
  }
}
```

### 4. Webhooks (Backend-Side)

Implement server-to-server webhooks for payment verification:

```
PayU Server ──► Your Backend Webhook ──► Verify & Update DB
```

This ensures payment status is updated even if the app crashes or loses connectivity after payment.

### 5. Modular and Reusable Architecture

```dart
// Abstract payment interface for multiple providers
abstract class PaymentProvider {
  Future<bool> initiatePayment(PaymentRequest request);
  void setCallbacks({
    required void Function(PaymentResult) onSuccess,
    required void Function(String) onFailure,
    required void Function() onCancel,
  });
}

// PayU implementation
class PayUProvider implements PaymentProvider { ... }

// Razorpay implementation (future)
class RazorpayProvider implements PaymentProvider { ... }

// Factory
class PaymentProviderFactory {
  static PaymentProvider create(PaymentProviderType type) {
    switch (type) {
      case PaymentProviderType.payu:
        return PayUProvider();
      // Add more providers as needed
    }
  }
}
```

### 6. Wallet Integration Enhancement

```dart
// Add wallet balance check before payment
Future<void> initiatePaymentWithWalletCheck({
  required String userId,
  required String planCode,
  required double totalAmount,
}) async {
  final walletBalance = await _walletService.getBalance(userId);

  if (walletBalance >= totalAmount) {
    // Full wallet payment — no PayU needed
    await _walletService.deduct(userId, totalAmount);
  } else {
    // Partial wallet + PayU
    final remaining = totalAmount - walletBalance;
    await initiatePayment(
      userId: userId,
      planCode: planCode,
      fromWallet: walletBalance,
      forPayment: remaining,
    );
  }
}
```

---

## 🧪 9. Testing Guide

### Sandbox Setup

1. **Get test credentials** from PayU Dashboard:
   - Test Merchant Key
   - Test Salt

2. **Set test environment** in `payu_config.dart`:
   ```dart
   static const bool isProduction = false; // Switch to test
   ```

3. **Use test card numbers:**

   | Card Type | Number | CVV | Expiry |
   |---|---|---|---|
   | Visa Success | `4012001037141112` | `123` | `12/25` |
   | Visa Failure | `4012001037167778` | `123` | `12/25` |
   | Mastercard Success | `5123456789012346` | `123` | `12/25` |

4. **Test UPI:** Use `success@payu` for success, `failure@payu` for failure

### Test Credentials

| Environment | Merchant Key | Salt |
|---|---|---|
| Test | `gtKFFx` | `eCwWELlh` |
| Production | Contact PayU | Contact PayU |

### Common Errors and Solutions

| Error | Cause | Solution |
|---|---|---|
| `Hash mismatch` | Salt is incorrect or not set | Verify `HashService.merchantSalt` is set from API response |
| `Invalid merchant key` | Wrong key for environment | Check `PayUConfig.merchantKey` matches the environment |
| `Transaction already processed` | Duplicate `txnid` | Generate unique transaction ID using `PayUConfig.generateTransactionId()` |
| `Network error` | No internet or API down | Check connectivity, implement retry logic |
| `SDK initialization failed` | Missing Android/iOS config | Verify ProGuard rules, Podfile, Info.plist |
| `Payment cancelled by user` | User pressed back | Handle gracefully in `onPaymentCancel` |
| `Amount must be greater than 0` | Invalid amount | Validate amount before calling `initiatePayment()` |
| `Hash generation timeout` | Backend hash API slow | Implement timeout and fallback |
| `SSL error` on Android | Missing network security config | Add `network_security_config.xml` for API domain |

### Testing Checklist

- [ ] Payment initiation with valid credentials
- [ ] Payment success flow (test card)
- [ ] Payment failure flow (failure card)
- [ ] Payment cancellation (user presses back)
- [ ] Network error during initiation
- [ ] Network error during callback reporting
- [ ] Hash generation with correct salt
- [ ] Wallet + PayU partial payment
- [ ] Referral code application
- [ ] Multiple rapid payment attempts
- [ ] Payment on slow network
- [ ] App backgrounding during payment

---

## ⚠️ 10. Best Practices

### Security Guidelines

| ✅ Do | ❌ Don't |
|---|---|
| Fetch merchant key and salt from backend API | Hardcode credentials in the app |
| Use HTTPS for all API calls | Use HTTP for any payment-related endpoint |
| Validate payment on backend (server-to-server) | Trust client-side payment confirmation alone |
| Use dynamic salt from API response | Use static/hardcoded salt |
| Log payment events for audit trail | Log sensitive data (card numbers, CVV, salt) |
| Implement proper error handling | Swallow errors silently |
| Use ProGuard rules for PayU SDK | Ship debug builds to production |
| Set `isProduction = true` for release | Leave test mode enabled in production |
| Generate unique transaction IDs | Reuse transaction IDs |
| Implement timeout for hash generation | Let hash generation hang indefinitely |

### Production Readiness Checklist

- [ ] `PayUConfig.isProduction = true`
- [ ] Production merchant key and salt from backend
- [ ] Backend validates all payment callbacks
- [ ] Server-to-server webhook verification implemented
- [ ] ProGuard rules configured for release builds
- [ ] Debug logging removed or disabled in release
- [ ] Error messages are user-friendly (no stack traces)
- [ ] Network retry logic implemented
- [ ] Payment timeout handling implemented
- [ ] Analytics tracking for payment events
- [ ] Crash reporting for payment errors
- [ ] Wallet balance checked before payment
- [ ] Duplicate payment prevention (idempotency)
- [ ] SSL pinning for API calls (optional but recommended)
- [ ] Rate limiting on payment initiation API
- [ ] Subscription status verified after payment

### Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  SubscriptionConfirmScreen → SubscriptionConfirmController  │
│  PaymentView (optional standalone)                          │
├─────────────────────────────────────────────────────────────┤
│                    Controller Layer                          │
│  PaymentController (GetX, PayUCheckoutProProtocol)          │
│  - State: status, errorMessage, paymentData                 │
│  - Callbacks: onSuccess, onFailure, onCancelled             │
├─────────────────────────────────────────────────────────────┤
│                    Service Layer                             │
│  PaymentService (Dio HTTP)     HashService (Crypto)         │
│  - initiatePayment()           - generateHash()             │
│  - reportPaymentSuccess()      - getSHA512Hash()            │
│  - reportPaymentFailure()      - getHmacSHA256Hash()        │
│                                - getHmacSHA1Hash()          │
├─────────────────────────────────────────────────────────────┤
│                    Configuration Layer                       │
│  PayUConfig                                                │
│  - Dynamic credentials (merchantKey, saltKey)               │
│  - Environment (always production)                          │
│  - Parameter builders                                       │
├─────────────────────────────────────────────────────────────┤
│                    Model Layer                               │
│  InitiatePaymentReq, InitiatePaymentRes, PaymentData        │
│  PayuFormData, PaymentStatusCallback                        │
├─────────────────────────────────────────────────────────────┤
│                    External Dependencies                     │
│  payu_checkoutpro_flutter (SDK)                             │
│  get (State Management)                                     │
│  dio (HTTP Client)                                          │
│  crypto (Hash Generation)                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Quick Reference

### Key Files

| File | Purpose |
|---|---|
| `config/payu_config.dart` | Configuration, parameter builders |
| `controllers/payment_controller.dart` | Payment orchestration, SDK callbacks |
| `models/payment_models.dart` | Data models for API communication |
| `services/hash_service.dart` | Hash generation (SHA-512, HMAC) |
| `services/payment_service.dart` | Backend API communication |

### Key Methods

| Method | Location | Purpose |
|---|---|---|
| `initiatePayment()` | PaymentController | Start payment flow |
| `generateHash()` | PaymentController → HashService | Compute PayU hash |
| `onPaymentSuccess()` | PaymentController | Handle success |
| `onPaymentFailure()` | PaymentController | Handle failure |
| `setMerchantKey()` | PayUConfig | Set dynamic merchant key |
| `setSaltKey()` | PayUConfig | Set dynamic salt |
| `createPayUPaymentParamsFromData()` | PayUConfig | Build SDK params |
| `createPayUConfigParams()` | PayUConfig | Build checkout config |

### API Endpoints

**Base URL:** `https://api.prod.vahaanbazar.in`

| Endpoint | Full URL | Method | Purpose |
|---|---|---|---|
| `/api/v1/payments/initiate` | `https://api.prod.vahaanbazar.in/api/v1/payments/initiate` | POST | Create payment |
| `/api/v1/payments/success` | `https://api.prod.vahaanbazar.in/api/v1/payments/success` | POST | Report success |
| `/api/v1/payments/failure` | `https://api.prod.vahaanbazar.in/api/v1/payments/failure` | POST | Report failure |

### Dependencies

| Package | Version | Purpose |
|---|---|---|
| `payu_checkoutpro_flutter` | ^1.3.0 | PayU SDK |
| `get` | ^4.6.6 | State management |
| `dio` | ^5.4.0 | HTTP client |
| `crypto` | ^3.0.3 | Hash generation |
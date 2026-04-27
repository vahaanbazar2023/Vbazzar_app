# PayU Payment Integration — Complete Documentation

> **Project:** Vahaan Bazar (Flutter Mobile App)  
> **Module:** `lib/modules/payu_sdk_payment/`  
> **SDK:** `payu_checkoutpro_flutter: 1.3.2`  
> **State Management:** GetX  
> **HTTP Client:** Dio  
> **Last Updated:** April 2026

---

## Table of Contents

1. [📦 Overview](#-overview)
2. [🗂️ Module Breakdown](#️-module-breakdown)
3. [⚙️ Setup & Installation](#️-setup--installation)
4. [🔐 Configuration & Security](#-configuration--security)
5. [💳 Payment Flow (Step-by-Step)](#-payment-flow-step-by-step)
6. [🧩 Code-Level Explanation](#-code-level-explanation)
7. [🔄 Reusable Integration Guide (From Scratch)](#-reusable-integration-guide-from-scratch)
8. [🚀 Improvements / Advanced Version](#-improvements--advanced-version)
9. [🧪 Testing Guide](#-testing-guide)
10. [⚠️ Best Practices](#-best-practices)

---

## 📦 Overview

### How PayU is Integrated

This project uses the **PayU Checkout Pro SDK** (`payu_checkoutpro_flutter`) to process payments within a Flutter mobile application. The integration follows a **hybrid approach** where:

1. **Payment initiation** is handled via a backend API call that returns PayU form data (including merchant key, salt, transaction details, and a pre-generated hash).
2. **Hash generation** is performed locally on the client using SHA-512 with a dynamic salt received from the backend.
3. **PayU SDK** is invoked with the payment parameters to open the native PayU checkout screen.
4. **Payment callbacks** (success, failure, cancellation, error) are handled by the controller and forwarded to the backend for verification and record-keeping.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                              │
│                                                                 │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│  │ PaymentView  │───▶│PaymentController │───▶│ PayU SDK     │  │
│  │   (UI)       │    │ (Orchestration)  │    │ (CheckoutPro)│  │
│  └──────────────┘    └────────┬─────────┘    └──────┬───────┘  │
│                               │                      │          │
│                    ┌──────────▼──────────┐           │          │
│                    │   HashService       │◀──────────┘          │
│                    │ (SHA-512 Hash Gen)  │  (generateHash)      │
│                    └─────────────────────┘                      │
│                               │                                 │
│                    ┌──────────▼──────────┐                      │
│                    │ PaymentApiService   │                      │
│                    │ (Dio HTTP Client)   │                      │
│                    └──────────┬──────────┘                      │
└───────────────────────────────┼─────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │    BACKEND SERVER     │
                    │                       │
                    │ POST /payments/initiate│──▶ Returns PaymentData
                    │ POST /payments/success │──▶ Callback notification
                    │ POST /payments/failure │──▶ Callback notification
                    └───────────────────────┘
```

### Data Flow Summary

```
1. User taps "Pay" → PaymentController.startPayment(planCode)
2. App calls backend → POST /api/v1/payments/initiate {user_id, plan_code}
3. Backend returns → PaymentData (merchant_key, salt_key, payu_form_data with hash)
4. App configures PayU SDK → PayUConfig.createPayUPaymentParamsFromData()
5. App opens PayU checkout → _checkoutPro.openCheckoutScreen()
6. PayU SDK requests hash → generateHash() callback → HashService.generateHash()
7. User completes payment → onPaymentSuccess / onPaymentFailure / onPaymentCancel
8. App notifies backend → POST /api/v1/payments/success or /failure
9. App handles navigation based on subscription type (SUBT001-SUBT007)
```

---

## 🗂️ Module Breakdown

### Directory Structure

```
lib/modules/payu_sdk_payment/
├── payu_sdk_payment.dart              # Barrel export file
├── config/
│   └── payu_config.dart               # PayU SDK configuration & parameter builder
├── controllers/
│   └── payment_controller.dart        # Main payment orchestration (2000 lines)
├── models/
│   ├── initiate_payment_model.dart    # Payment initiation request/response models
│   └── payment_status_callback.dart   # Payment callback request/response models
├── services/
│   ├── payment_api_service.dart       # Backend API communication
│   └── hash_service.dart              # SHA-512 hash generation
└── views/
    └── payment_view.dart              # Payment UI (test/debug view)
```

### File-by-File Analysis

#### `payu_sdk_payment.dart` — Barrel Export

The module's entry point. Exports all public classes so consumers can import a single file:

```dart
export 'controllers/payment_controller.dart';
export 'models/initiate_payment_model.dart';
export 'models/payment_status_callback.dart';
export 'services/payment_api_service.dart';
export 'services/hash_service.dart';
export 'views/payment_view.dart';
export 'config/payu_config.dart';
```

**Usage:**
```dart
import 'package:vahaan_mobile_flutter/modules/payu_sdk_payment/payu_sdk_payment.dart';
```

---

#### `config/payu_config.dart` — PayU Configuration

**Purpose:** Centralizes all PayU SDK configuration, environment switching, and parameter construction.

**Key Responsibilities:**
- Stores merchant key and salt (dynamically updated from backend response)
- Manages test vs. production environment switching
- Constructs `payUPaymentParams` map for the PayU SDK
- Constructs `payUCheckoutProConfig` map for SDK behavior configuration
- Provides `createPayUPaymentParamsFromData()` to convert backend `PaymentData` into SDK-compatible parameters

**Key Methods:**
| Method | Description |
|--------|-------------|
| `setMerchantKey(String key)` | Sets the merchant key dynamically |
| `setSaltKey(String salt)` | Sets the salt key dynamically |
| `createPayUPaymentParamsFromData(PaymentData)` | Converts backend payment data to PayU SDK params |
| `createPayUConfigParams()` | Returns SDK configuration (merchant display name, etc.) |

**Environment Configuration:**
```dart
static const bool isProduction = false; // Toggle for test/production
static const String merchantKey = "iZKr5a"; // Test merchant key
static const String salt = ""; // Dynamic salt from API
```

---

#### `controllers/payment_controller.dart` — Payment Orchestration

**Purpose:** The core controller that manages the entire payment lifecycle. Implements `PayUCheckoutProProtocol` to receive SDK callbacks.

**Class:** `PaymentController extends GetxController implements PayUCheckoutProProtocol`

**Key State Variables:**
| Variable | Type | Description |
|----------|------|-------------|
| `merchantKey` | `RxString` | Current merchant key (from backend) |
| `saltKey` | `RxString` | Current salt key (from backend) |
| `isLoading` | `RxBool` | Loading state during payment |
| `isPaymentSuccess` | `RxBool` | Whether last payment succeeded |
| `paymentStatus` | `RxString` | Current payment status text |
| `errorMessage` | `RxString` | Error message if any |
| `currentStep` | `RxString` | Current step: idle → initiating → launching → processing → completed |
| `paymentDataList` | `Rxn<PaymentData>` | Current payment data from backend |
| `vehiclePaymentSuccessForInspection` | `RxMap<String, bool>` | Per-vehicle inspection payment tracking |
| `vehiclePaymentSuccessForSubscribe` | `RxMap<String, bool>` | Per-vehicle subscription payment tracking |
| `vehicleInspectionRequestStatus` | `RxMap<String, String>` | Per-vehicle inspection request status |

**Key Methods:**
| Method | Description |
|--------|-------------|
| `startPayment({planCode})` | Initiates the full payment flow |
| `generateHash(Map response)` | PayU SDK callback — generates hash via HashService |
| `onPaymentSuccess(dynamic response)` | Handles successful payment + post-payment logic |
| `onPaymentFailure(dynamic response)` | Handles failed payment |
| `onPaymentCancel(Map? response)` | Handles user cancellation |
| `onError(Map? response)` | Handles SDK errors |
| `resetPaymentState()` | Resets all payment state to initial |
| `placePendingBid()` | Places a pending bid after successful payment (auction flow) |

**Subscription Type Handling (onPaymentSuccess):**

The controller handles **7 different subscription types** after payment success:

| Code | Type | Post-Payment Action |
|------|------|---------------------|
| `SUBT001` | Auction Access | Refreshes auction data, navigates to auctions/categories |
| `SUBT002` | Bid Limit | Places pending bid automatically, refreshes balance with retry logic |
| `SUBT003` | Vehicle Details Access | Calls `requestOwnerDetailsAccess` API |
| `SUBT004` | Buy & Sell Vehicle Access | Fetches vehicle details, navigates to details page |
| `SUBT005` | Vehicle Inspection | Calls `requestVehicleInspection` API |
| `SUBT006` | Mechanic Contact | Calls `handleMechanicSubscriptionPaymentSuccess` |
| `SUBT007` | Shop Contact | Calls `handleShopSubscriptionPaymentSuccess` |

---

#### `models/initiate_payment_model.dart` — Payment Initiation Models

**Classes:**

**`InitiatePaymentReq`** — Request to initiate payment
```dart
{
  "user_id": "string",
  "plan_code": "string"  // e.g., "VB_MONTHLY_PREMIUM", "SUBT001", etc.
}
```

**`InitiatePaymentRes`** — Response from initiation API
```dart
{
  "status": "success",
  "code": 200,
  "message": "Payment initiated",
  "timestamp": "2026-04-27T...",
  "data": {
    "payment_id": "pay_xxx",
    "txn_id": "txn_xxx",
    "payu_form_data": { ... },  // PayuFormData object
    "payment_url": "https://...",
    "merchant_key": "iZKr5a",
    "salt_key": "dynamic_salt_from_backend"
  }
}
```

**`PaymentData`** — Core payment data from backend
| Field | Type | Description |
|-------|------|-------------|
| `paymentId` | `String` | Internal payment ID |
| `txnId` | `String` | Transaction ID for PayU |
| `payuFormData` | `PayuFormData` | Complete PayU form parameters |
| `paymentUrl` | `String` | PayU payment URL |
| `merchantKey` | `String` | Merchant key (dynamic from backend) |
| `saltKey` | `String` | Salt key (dynamic from backend) |

**`PayuFormData`** — PayU form parameters
| Field | JSON Key | Description |
|-------|----------|-------------|
| `key` | `key` | PayU merchant key |
| `txnId` | `txnid` | Unique transaction ID |
| `amount` | `amount` | Payment amount |
| `productInfo` | `productinfo` | Product description |
| `firstname` | `firstname` | Customer first name |
| `email` | `email` | Customer email |
| `phone` | `phone` | Customer phone |
| `surl` | `surl` | Success URL |
| `furl` | `furl` | Failure URL |
| `serviceProvider` | `service_provider` | Always "payu_paisa" |
| `udf1`-`udf5` | `udf1`-`udf5` | User-defined fields |
| `hash` | `hash` | Pre-generated hash from backend |

---

#### `models/payment_status_callback.dart` — Callback Models

**`PaymentStatusCallback`** — Sent to backend after payment completion
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | `String` | Yes | Merchant key |
| `txnid` | `String` | Yes | Transaction ID |
| `amount` | `String` | Yes | Payment amount |
| `productinfo` | `String` | Yes | Product info |
| `firstname` | `String` | Yes | Customer name |
| `email` | `String` | Yes | Customer email |
| `phone` | `String` | Yes | Customer phone |
| `paymentStatus` | `String` | Yes | "success" / "failed" |
| `hash` | `String` | Yes | Payment hash |
| `mode` | `String?` | No | Payment mode (CC/DC/NB/UPI) |
| `bankref` | `String?` | No | Bank reference number |
| `pgType` | `String?` | No | Payment gateway type |
| `bankRefNum` | `String?` | No | Bank reference number |
| `mihpayid` | `String?` | No | PayU payment ID |
| `udf1`-`udf5` | `String?` | No | User-defined fields |
| `error` | `String?` | No | Error code |
| `errorMessage` | `String?` | No | Error message |
| `chasisNumber` | `String?` | No | Chassis number (for inspection plans) |

**`PaymentStatusCallbackRes`** — Backend response to callback
```dart
{
  "success": true,
  "message": "Payment recorded",
  "payment_id": "pay_xxx",
  "transaction_status": "completed"
}
```

---

#### `services/payment_api_service.dart` — API Communication

**Purpose:** Handles all HTTP communication with the backend for payment operations.

**Class:** `PaymentApiService` (static methods)

**Methods:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| `initiatePayment(InitiatePaymentReq)` | `POST /api/v1/payments/initiate` | Creates payment, returns PayU params |
| `notifyPaymentSuccess(PaymentStatusCallback)` | `POST /api/v1/payments/success` | Notifies backend of success |
| `notifyPaymentFailure(PaymentStatusCallback)` | `POST /api/v1/payments/failure` | Notifies backend of failure |

**Dependencies:**
- Uses `NetworkService` (GetX-injected Dio wrapper) for HTTP calls
- Automatically includes auth token via `NetworkService` interceptor
- Includes `X-API-Key` header for API authentication

---

#### `services/hash_service.dart` — Hash Generation

**Purpose:** Generates SHA-512 hashes required by PayU for payment verification.

**Hash Formula (PayU Standard):**
```
SHA512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||salt)
```

**Key Points:**
- Uses the `crypto` package for SHA-512 hashing
- Salt is dynamically set from the backend response (`HashService.merchantSalt`)
- The hash is generated on-demand when PayU SDK requests it via the `generateHash` callback
- Empty UDF fields are represented as empty strings between pipe delimiters

**Static Property:**
```dart
static String merchantSalt = ''; // Set dynamically from PaymentData.saltKey
```

---

#### `views/payment_view.dart` — Payment UI

**Purpose:** A debug/test view for testing the payment flow independently.

**Features:**
- Plan code input field (default: `VB_MONTHLY_PREMIUM`)
- "Start Payment" button with loading state
- "Load Test Data" button for quick testing
- "Reset Payment State" button
- Status card showing current step, status, and errors
- Transaction details card (shows payment ID, transaction ID, amount)

---

### Related Shared Modules

#### `lib/core/api/api_constant.dart` — API Endpoints

Payment-related endpoints:
```dart
static const String paymentPrefix = '/api/v1/payments';
static const String paymentInitiateEndpoint = '/api/v1/payments/initiate';
static const String paymentSuccessEndpoint = '/api/v1/payments/success';
static const String paymentFailureEndpoint = '/api/v1/payments/failure';
```

Also includes V2 payment endpoints for future use:
```dart
static const String paymentPrefix_v2 = '/api/v2/payments';
static const String paymentInitiateEndpoint_v2 = '/api/v2/payments/initiate';
// ... additional V2 endpoints
```

#### `lib/core/services/network_service.dart` — HTTP Client

- Dio-based HTTP client with interceptors
- Automatically attaches `Authorization: Bearer <token>` for secured paths
- Attaches `X-API-Key` header for API authentication
- Handles 401 responses with session expiry logic
- Payment endpoints are in the secured paths list (require authentication)

---

## ⚙️ Setup & Installation

### Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  payu_checkoutpro_flutter: 1.3.2    # PayU Checkout Pro SDK
  get: ^4.6.6                        # State management
  dio: ^5.4.0                        # HTTP client
  crypto: ^3.0.3                     # SHA-512 hash generation (included with Flutter)
```

### Installation Steps

#### 1. Install Flutter Dependencies

```bash
flutter pub get
```

#### 2. Android Configuration

**`android/app/build.gradle.kts`:**

```kotlin
android {
    defaultConfig {
        minSdk = 21                    // Minimum SDK for PayU
        multiDexEnabled = true         // Required for PayU SDK
    }
    
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro",
                "payu-sdk-proguard-rules.pro",    // PayU ProGuard rules
                "../../../payu_proguard_rules.pro" // WebView ProGuard rules
            )
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

**ProGuard Rules (`payu_proguard_rules.pro`):**

```proguard
# Keep WebView and JavaScript interface classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface

# Keep JavaScript Bridge classes
-keep class * extends android.webkit.WebViewClient { public *; }
-keep class * extends android.webkit.WebChromeClient { public *; }

# Keep PayU specific classes
-keep class com.payu.** { *; }
-keep class com.payumoney.** { *; }

# Keep SSL/TLS classes (required for secure transactions)
-keep class javax.net.ssl.** { *; }

# Keep cryptography-related classes
-keep class java.security.** { *; }
-keep class javax.crypto.** { *; }
```

**PayU SDK ProGuard Rules (`android/app/payu-sdk-proguard-rules.pro`):**

```proguard
-keep class com.payu.** { *; }
-keep class com.payumoney.** { *; }
-dontwarn com.payu.**
-dontwarn com.payumoney.**
```

#### 3. iOS Configuration

Ensure the following in `ios/Podfile`:

```ruby
platform :ios, '12.0'  # Minimum iOS version

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

Then run:
```bash
cd ios && pod install && cd ..
```

### Environment Variables

| Variable | Location | Test Value | Production Value |
|----------|----------|------------|------------------|
| `merchantKey` | `PayUConfig` / Backend API | `iZKr5a` | From backend |
| `salt` | Backend API (dynamic) | From backend | From backend |
| `baseUrl` | `ApiConstants.baseUrl` | `https://api.test.vahaanbazar.in` | `https://api.prod.vahaanbazar.in` |
| `apiKey` | `ApiConstants.apiKey` | `7B9F2K4R1M6Q3P8D` | `7B0F2K4R1MSS3P0D` |
| `surl` | Backend (in PayuFormData) | Success redirect URL | Success redirect URL |
| `furl` | Backend (in PayuFormData) | Failure redirect URL | Failure redirect URL |

---

## 🔐 Configuration & Security

### Configuration Architecture

```
┌─────────────────────────────────────────────────┐
│              PayUConfig (Static)                 │
│                                                  │
│  merchantKey ──── Set dynamically from backend   │
│  salt ─────────── Set dynamically from backend   │
│  isProduction ─── Toggle test/production         │
│                                                  │
│  createPayUPaymentParamsFromData() ──▶ SDK Params│
│  createPayUConfigParams() ──────────▶ SDK Config │
└─────────────────────────────────────────────────┘
```

### API Endpoints Used

| Endpoint | Method | Auth Required | Description |
|----------|--------|---------------|-------------|
| `/api/v1/payments/initiate` | POST | Yes (Bearer + API Key) | Initiate payment |
| `/api/v1/payments/success` | POST | Yes (Bearer + API Key) | Success callback |
| `/api/v1/payments/failure` | POST | Yes (Bearer + API Key) | Failure callback |

### Request Headers

All payment API requests include:

```http
Content-Type: application/json
Accept: application/json
X-API-Key: 7B0F2K4R1MSS3P0D
Authorization: Bearer <user_jwt_token>
```

### Hash Generation Logic

The hash generation follows PayU's standard SHA-512 formula:

```
hashString = "key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||salt"
hash = SHA512(hashString)
```

**Example:**
```
Input:  "iZKr5a|txn_123|100.00|Subscription|John|john@example.com||||||||||dynamic_salt"
Output: SHA512 hash (128 hex characters)
```

**Implementation in `HashService`:**
```dart
static Map generateHash(Map response) {
  String hashName = response[PayUHashConstantsKeys.hashName];
  String hashString = response[PayUHashConstantsKeys.hashString];
  
  // Append the dynamic salt
  hashString += merchantSalt;
  
  // Generate SHA-512 hash
  var bytes = utf8.encode(hashString);
  var hash = sha512.convert(bytes);
  
  return {hashName: hash.toString()};
}
```

### Security Considerations

1. **Dynamic Salt:** Salt is fetched from the backend per transaction, not hardcoded
2. **Backend-Generated Hash:** The initial hash in `PayuFormData` is generated by the backend
3. **Client-Side Hash Fallback:** `HashService` generates hashes locally when PayU SDK requests them during the checkout flow
4. **API Key Authentication:** All API calls require a valid `X-API-Key` header
5. **JWT Authentication:** Payment endpoints require a valid user JWT token
6. **ProGuard Obfuscation:** PayU classes are kept intact while app code is obfuscated

> ⚠️ **Note:** The current implementation generates hashes locally on the client. For production, it is **strongly recommended** to generate all hashes server-side (see [Improvements](#-improvements--advanced-version)).

---

## 💳 Payment Flow (Step-by-Step)

### Complete Flow Diagram

```
User Action                App (Flutter)              Backend API              PayU SDK
    │                          │                          │                       │
    │  1. Tap "Pay"            │                          │                       │
    │─────────────────────────▶│                          │                       │
    │                          │  2. POST /payments/initiate                      │
    │                          │─────────────────────────▶│                       │
    │                          │                          │                       │
    │                          │  3. Response: PaymentData                        │
    │                          │  (merchant_key, salt_key,                        │
    │                          │   payu_form_data, hash)                          │
    │                          │◀─────────────────────────│                       │
    │                          │                          │                       │
    │                          │  4. Configure PayU SDK   │                       │
    │                          │  (Set merchantKey, salt) │                       │
    │                          │                          │                       │
    │                          │  5. openCheckoutScreen() │                       │
    │                          │──────────────────────────────────────────────────▶│
    │                          │                          │                       │
    │                          │  6. generateHash() callback                      │
    │                          │◀─────────────────────────────────────────────────│
    │                          │                          │                       │
    │                          │  7. HashService.generateHash()                   │
    │                          │  (SHA-512 with dynamic salt)                     │
    │                          │                          │                       │
    │                          │  8. hashGenerated(hash)  │                       │
    │                          │──────────────────────────────────────────────────▶│
    │                          │                          │                       │
    │  9. PayU Checkout UI     │                          │                       │
    │◀───────────────────────────────────────────────────────────────────────────│
    │                          │                          │                       │
    │  10. Complete Payment    │                          │                       │
    │────────────────────────────────────────────────────────────────────────────▶│
    │                          │                          │                       │
    │                          │  11. onPaymentSuccess()  │                       │
    │                          │◀─────────────────────────────────────────────────│
    │                          │                          │                       │
    │                          │  12. POST /payments/success                      │
    │                          │─────────────────────────▶│                       │
    │                          │                          │                       │
    │                          │  13. Handle post-payment │                       │
    │                          │  (Navigate, refresh data,│                       │
    │                          │   place pending bids)    │                       │
    │  14. Show success UI     │                          │                       │
    │◀─────────────────────────│                          │                       │
```

### Step 1: Payment Request Creation

```dart
// User triggers payment with a plan code
final success = await paymentController.startPayment(
  planCode: 'VB_MONTHLY_PREMIUM',
);
```

Inside `startPayment()`:
1. Sets loading state and current step to `'initiating'`
2. Retrieves user ID from `StorageService`
3. Calls `PaymentApiService.initiatePayment()` with `InitiatePaymentReq`
4. Validates response status is `'success'` and data is not null
5. Stores `PaymentData` for later use

### Step 2: Hash Generation

When the PayU SDK needs a hash during checkout, it calls the `generateHash()` callback:

```dart
@override
generateHash(Map response) {
  Map hashResponse = HashService.generateHash(response);
  _checkoutPro.hashGenerated(hash: hashResponse);
}
```

`HashService.generateHash()`:
1. Extracts `hashName` and `hashString` from the PayU SDK request
2. Appends the dynamic `merchantSalt` to the hash string
3. Computes SHA-512 hash
4. Returns `{hashName: hashValue}` to the SDK

### Step 3: SDK Invocation

```dart
// Configure parameters
final payuParams = PayUConfig.createPayUPaymentParamsFromData(paymentData);
final payuConfig = PayUConfig.createPayUConfigParams();

// Open PayU checkout
await _checkoutPro.openCheckoutScreen(
  payUPaymentParams: payuParams,
  payUCheckoutProConfig: payuConfig,
);
```

### Step 4: Success Response Handling

```dart
@override
void onPaymentSuccess(dynamic response) async {
  // 1. Clear loading states
  _clearAllSubscriptionLoadingStates();
  
  // 2. Update status
  paymentStatus.value = 'success';
  currentStep.value = 'completed';
  isPaymentSuccess.value = true;
  
  // 3. Notify backend
  final callbackData = _createPaymentCallback(response, 'success');
  PaymentApiService.notifyPaymentSuccess(callbackData);
  
  // 4. Handle subscription-specific logic (SUBT001-SUBT007)
  // 5. Navigate to appropriate screen
  // 6. Complete the payment future
  _paymentCompleter!.complete(true);
}
```

### Step 5: Failure Handling

```dart
@override
void onPaymentFailure(dynamic response) async {
  _clearAllSubscriptionLoadingStates();
  paymentStatus.value = 'failed';
  currentStep.value = 'failed';
  
  // Notify backend
  PaymentApiService.notifyPaymentFailure(callbackData);
  
  // Complete future with false
  _paymentCompleter!.complete(false);
  
  // Show error snackbar
  Get.snackbar('Payment Failed', 'Payment could not be processed', ...);
}
```

### Step 6: Transaction Verification

Transaction verification is handled by the backend:
1. The app sends payment callback data to `/api/v1/payments/success` or `/api/v1/payments/failure`
2. The backend verifies the transaction with PayU's server-to-server API
3. The backend updates the subscription/payment status in the database
4. The app refreshes data after payment to get the updated state

---

## 🧩 Code-Level Explanation

### Key Classes and Their Relationships

```
PaymentController (implements PayUCheckoutProProtocol)
    ├── uses PayUCheckoutProFlutter (SDK)
    ├── uses PaymentApiService (API calls)
    ├── uses HashService (hash generation)
    ├── uses PayUConfig (SDK configuration)
    ├── uses StorageService (local storage)
    ├── uses ApiRepository (other API calls)
    └── references other controllers:
        ├── AuctionController
        ├── BuySellController
        ├── InspectionValuationController
        ├── ServiceSupportController
        └── SpareAndFmsController
```

### Request/Response Flow

**Initiation Request:**
```dart
// InitiatePaymentReq
{
  "user_id": "usr_abc123",
  "plan_code": "SUBT002"
}
```

**Initiation Response:**
```dart
// InitiatePaymentRes
{
  "status": "success",
  "code": 200,
  "message": "Payment initiated successfully",
  "timestamp": "2026-04-27T17:30:00Z",
  "data": {
    "payment_id": "pay_789xyz",
    "txn_id": "VB_1682601000_abc",
    "payu_form_data": {
      "key": "iZKr5a",
      "txnid": "VB_1682601000_abc",
      "amount": "499.00",
      "productinfo": "Vahaan Bazar Premium Subscription",
      "firstname": "John",
      "email": "john@example.com",
      "phone": "9876543210",
      "surl": "https://api.prod.vahaanbazar.in/api/v1/payments/success",
      "furl": "https://api.prod.vahaanbazar.in/api/v1/payments/failure",
      "service_provider": "payu_paisa",
      "udf1": "pay_789xyz",
      "udf2": "",
      "udf3": "",
      "udf4": "",
      "udf5": "",
      "hash": "a1b2c3d4e5f6..."
    },
    "payment_url": "https://secure.payu.in/_payment",
    "merchant_key": "iZKr5a",
    "salt_key": "dynamic_salt_value"
  }
}
```

**Callback Request (Success):**
```dart
// PaymentStatusCallback
{
  "key": "iZKr5a",
  "txnid": "VB_1682601000_abc",
  "amount": "499.00",
  "productinfo": "Vahaan Bazar Premium Subscription",
  "firstname": "John",
  "email": "john@example.com",
  "phone": "9876543210",
  "payment_status": "success",
  "hash": "a1b2c3d4e5f6...",
  "mode": "CC",
  "bankref": "1234567890",
  "PG_TYPE": "CC",
  "bank_ref_num": "1234567890",
  "mihpayid": "123456789",
  "udf1": "pay_789xyz",
  "udf2": "",
  "udf3": "",
  "udf4": "",
  "udf5": "",
  "error": "",
  "error_Message": "",
  "chasis_number": ""
}
```

### Error Handling

The module handles errors at multiple levels:

**1. Network Errors (PaymentApiService):**
```dart
try {
  final response = await _networkService.post(...);
  return InitiatePaymentRes.fromJson(response.data);
} catch (e) {
  throw Exception('Payment initiation failed: $e');
}
```

**2. Payment Initiation Errors (PaymentController):**
```dart
if (initiationResponse.status != 'success' || initiationResponse.data == null) {
  throw Exception(initiationResponse.message);
}
```

**3. SDK Errors (PaymentController callbacks):**
- `onPaymentFailure` — Payment was processed but failed
- `onPaymentCancel` — User cancelled the payment
- `onError` — SDK-level error occurred

**4. Post-Payment Errors:**
- Bid placement failures with retry logic (up to 8 retries for SUBT002)
- Subscription refresh failures with fallback mechanisms
- Navigation errors with fallback to `Get.back()`

**5. Loading State Management:**
```dart
void _clearAllSubscriptionLoadingStates() {
  isLoading.value = false;
  // Also clears AuctionController.isOpeningPaymentGateway
  // Forces UI update via update()
}
```

### Reusable Code Snippets

**Starting a Payment:**
```dart
final paymentController = Get.find<PaymentController>();
final success = await paymentController.startPayment(
  planCode: 'YOUR_PLAN_CODE',
);
if (success) {
  // Payment completed successfully
}
```

**Checking Payment Status:**
```dart
final controller = Get.find<PaymentController>();
print('Status: ${controller.paymentStatus.value}');
print('Step: ${controller.currentStep.value}');
print('Error: ${controller.errorMessage.value}');
```

**Resetting Payment State:**
```dart
final controller = Get.find<PaymentController>();
controller.resetPaymentState();
```

**Tracking Vehicle-Specific Payment:**
```dart
final controller = Get.find<PaymentController>();
// Check if payment succeeded for a specific vehicle
bool paid = controller.isPaymentSuccessForInspection('vehicle_123');
// Set payment success
controller.setPaymentSuccessForInspection('vehicle_123', true);
```

---

## 🔄 Reusable Integration Guide (From Scratch)

### Step 1: Project Setup

```bash
# Create Flutter project
flutter create my_payu_app
cd my_payu_app

# Add dependencies to pubspec.yaml
```

**pubspec.yaml additions:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  payu_checkoutpro_flutter: 1.3.2
  get: ^4.6.6
  dio: ^5.4.0
```

```bash
flutter pub get
```

### Step 2: Android Configuration

**`android/app/build.gradle.kts`:**
```kotlin
android {
    defaultConfig {
        minSdk = 21
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

**Create `android/app/payu-proguard-rules.pro`:**
```proguard
-keep class com.payu.** { *; }
-keep class com.payumoney.** { *; }
-dontwarn com.payu.**
-dontwarn com.payumoney.**
-keep class javax.net.ssl.** { *; }
-keep class java.security.** { *; }
-keep class javax.crypto.** { *; }
```

### Step 3: Create Configuration

```dart
// lib/config/payu_config.dart
class PayUConfig {
  static String _merchantKey = '';
  static String _saltKey = '';
  
  static void setMerchantKey(String key) => _merchantKey = key;
  static void setSaltKey(String salt) => _saltKey = salt;
  
  static Map createPayUPaymentParams({
    required String txnId,
    required String amount,
    required String productInfo,
    required String firstName,
    required String email,
    required String phone,
    required String surl,
    required String furl,
  }) {
    return {
      PayUConstantKeys.key: _merchantKey,
      PayUConstantKeys.txnid: txnId,
      PayUConstantKeys.amount: amount,
      PayUConstantKeys.productinfo: productInfo,
      PayUConstantKeys.firstname: firstName,
      PayUConstantKeys.email: email,
      PayUConstantKeys.phone: phone,
      PayUConstantKeys.surl: surl,
      PayUConstantKeys.furl: furl,
      PayUConstantKeys.udf1: "",
      PayUConstantKeys.udf2: "",
      PayUConstantKeys.udf3: "",
      PayUConstantKeys.udf4: "",
      PayUConstantKeys.udf5: "",
      PayUConstantKeys.hash: "",
    };
  }
  
  static Map createPayUConfigParams() {
    return {
      PayUConstantKeys.merchantDisplayName: "Your App Name",
      PayUConstantKeys.autoApprove: false,
      PayUConstantKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUConstantKeys.showExitConfirmationOnPaymentScreen: true,
    };
  }
}
```

### Step 4: Create Hash Service

```dart
// lib/services/hash_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

class HashService {
  static String merchantSalt = '';
  
  static Map generateHash(Map response) {
    String hashName = response[PayUHashConstantsKeys.hashName];
    String hashString = response[PayUHashConstantsKeys.hashString];
    
    // Append salt
    hashString += merchantSalt;
    
    // Generate SHA-512
    var bytes = utf8.encode(hashString);
    var hash = sha512.convert(bytes);
    
    return {hashName: hash.toString()};
  }
}
```

### Step 5: Create Payment Controller

```dart
// lib/controllers/payment_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import '../config/payu_config.dart';
import '../services/hash_service.dart';

class PaymentController extends GetxController 
    implements PayUCheckoutProProtocol {
  
  late PayUCheckoutProFlutter _checkoutPro;
  Completer<bool>? _paymentCompleter;
  
  final RxBool isLoading = false.obs;
  final RxString paymentStatus = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkoutPro = PayUCheckoutProFlutter(this);
  }
  
  Future<bool> startPayment({
    required String txnId,
    required String amount,
    required String productInfo,
    required String firstName,
    required String email,
    required String phone,
    required String merchantKey,
    required String salt,
  }) async {
    try {
      isLoading.value = true;
      
      // Set credentials
      PayUConfig.setMerchantKey(merchantKey);
      HashService.merchantSalt = salt;
      
      // Create payment params
      final payuParams = PayUConfig.createPayUPaymentParams(
        txnId: txnId,
        amount: amount,
        productInfo: productInfo,
        firstName: firstName,
        email: email,
        phone: phone,
        surl: 'https://your-backend.com/api/payments/success',
        furl: 'https://your-backend.com/api/payments/failure',
      );
      
      final payuConfig = PayUConfig.createPayUConfigParams();
      
      _paymentCompleter = Completer<bool>();
      
      await _checkoutPro.openCheckoutScreen(
        payUPaymentParams: payuParams,
        payUCheckoutProConfig: payuConfig,
      );
      
      return await _paymentCompleter!.future;
    } catch (e) {
      paymentStatus.value = 'failed';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  generateHash(Map response) {
    Map hashResponse = HashService.generateHash(response);
    _checkoutPro.hashGenerated(hash: hashResponse);
  }
  
  @override
  void onPaymentSuccess(dynamic response) {
    paymentStatus.value = 'success';
    _paymentCompleter?.complete(true);
    // Notify your backend here
  }
  
  @override
  void onPaymentFailure(dynamic response) {
    paymentStatus.value = 'failed';
    _paymentCompleter?.complete(false);
  }
  
  @override
  void onPaymentCancel(Map? response) {
    paymentStatus.value = 'cancelled';
    _paymentCompleter?.complete(false);
  }
  
  @override
  void onError(Map? response) {
    paymentStatus.value = 'error';
    _paymentCompleter?.complete(false);
  }
}
```

### Step 6: Create Payment UI

```dart
// lib/views/payment_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  final controller = Get.put(PaymentController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : () async {
            final success = await controller.startPayment(
              txnId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
              amount: '100.00',
              productInfo: 'Test Product',
              firstName: 'Test User',
              email: 'test@example.com',
              phone: '9876543210',
              merchantKey: 'YOUR_MERCHANT_KEY',
              salt: 'YOUR_SALT',
            );
            
            if (success) {
              Get.snackbar('Success', 'Payment completed!');
            }
          },
          child: controller.isLoading.value
            ? CircularProgressIndicator()
            : Text('Pay Now'),
        )),
      ),
    );
  }
}
```

### Step 7: Initialize in Main

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/payment_view.dart';

void main() {
  runApp(GetMaterialApp(
    home: PaymentView(),
  ));
}
```

### Step 8: Testing

1. Use test merchant key and salt from PayU dashboard
2. Set `isProduction = false` in config
3. Use test card numbers (see Testing Guide below)
4. Verify callbacks are received correctly

---

## 🚀 Improvements / Advanced Version

### 1. Backend-Based Hash Generation (Recommended)

**Current Issue:** Hash is generated locally on the client, which exposes the salt.

**Improvement:** Move all hash generation to the backend.

```dart
// Instead of local hash generation:
@override
generateHash(Map response) async {
  // Call backend API to generate hash
  final hashResponse = await paymentApiService.generateHash(
    hashName: response[PayUHashConstantsKeys.hashName],
    hashString: response[PayUHashConstantsKeys.hashString],
  );
  _checkoutPro.hashGenerated(hash: hashResponse);
}
```

**Backend endpoint:**
```
POST /api/v1/payments/generate-hash
{
  "hash_name": "payment_hash",
  "hash_string": "key|txnid|amount|..."
}
Response: { "payment_hash": "sha512_hash_value" }
```

### 2. Improved Error Handling

```dart
// Create a custom exception class
class PaymentException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;
  
  PaymentException(this.code, this.message, [this.originalError]);
  
  @override
  String toString() => 'PaymentException($code): $message';
}

// Use in controller
try {
  final response = await PaymentApiService.initiatePayment(request);
} on DioException catch (e) {
  throw PaymentException('NETWORK_ERROR', 'Network request failed', e);
} catch (e) {
  throw PaymentException('UNKNOWN_ERROR', 'Unexpected error', e);
}
```

### 3. Logging and Monitoring

```dart
// Create a payment logger
class PaymentLogger {
  static void log(String step, {Map<String, dynamic>? data, String? error}) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] PAYMENT_$step: ${data ?? error}');
    
    // Send to analytics/monitoring service
    // FirebaseAnalytics.logEvent(name: 'payment_$step', parameters: data);
  }
}

// Usage
PaymentLogger.log('INITIATE', data: {'planCode': planCode, 'userId': userId});
PaymentLogger.log('SUCCESS', data: {'paymentId': paymentId, 'amount': amount});
PaymentLogger.log('ERROR', error: e.toString());
```

### 4. Webhooks (If Missing)

Ensure your backend implements PayU webhooks for reliable payment verification:

```
POST https://your-backend.com/api/v1/payments/webhook
```

**Webhook payload from PayU:**
```json
{
  "txnid": "VB_123",
  "amount": "499.00",
  "status": "success",
  "hash": "verification_hash",
  "mihpayid": "123456789"
}
```

**Backend should:**
1. Verify the webhook hash
2. Update payment status in database
3. Activate the user's subscription
4. Return 200 OK to PayU

### 5. Modular and Reusable Architecture

```dart
// Create a payment abstraction layer
abstract class PaymentGateway {
  Future<PaymentResult> initiate(PaymentRequest request);
  Future<void> generateHash(Map response);
  Stream<PaymentEvent> get paymentEvents;
}

class PayUGateway implements PaymentGateway {
  // Implementation
}

// This allows swapping PayU with other gateways (Razorpay, Stripe, etc.)
```

### 6. Retry Logic with Exponential Backoff

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(initialDuration * math.pow(2, i));
    }
  }
  throw Exception('Max retries exceeded');
}
```

### 7. Payment State Machine

```dart
enum PaymentState {
  idle,
  initiating,
  launching,
  processing,
  success,
  failed,
  cancelled,
  error,
}

class PaymentStateMachine {
  final Rx<PaymentState> state = PaymentState.idle.obs;
  
  bool canTransition(PaymentState from, PaymentState to) {
    const validTransitions = {
      PaymentState.idle: [PaymentState.initiating],
      PaymentState.initiating: [PaymentState.launching, PaymentState.failed],
      PaymentState.launching: [PaymentState.processing, PaymentState.failed],
      PaymentState.processing: [PaymentState.success, PaymentState.failed, PaymentState.cancelled, PaymentState.error],
      // Terminal states
      PaymentState.success: [PaymentState.idle],
      PaymentState.failed: [PaymentState.idle],
      PaymentState.cancelled: [PaymentState.idle],
      PaymentState.error: [PaymentState.idle],
    };
    return validTransitions[from]?.contains(to) ?? false;
  }
}
```

---

## 🧪 Testing Guide

### Sandbox Setup

1. **Get Test Credentials:**
   - Sign up at [PayU Dashboard](https://dashboard.payu.in)
   - Navigate to **Test Mode** in the dashboard
   - Copy your test merchant key and salt

2. **Configure Test Environment:**
   ```dart
   // In PayUConfig
   static const bool isProduction = false;
   static const String merchantKey = "your_test_merchant_key";
   ```

3. **Update Base URL:**
   ```dart
   // In ApiConstants
   static const String baseUrl = 'https://api.test.vahaanbazar.in';
   ```

### Test Credentials

**Test Card (Success):**
| Field | Value |
|-------|-------|
| Card Number | `5123456789012346` |
| Expiry | `12/25` |
| CVV | `123` |
| Name | `Test User` |

**Test Card (Failure):**
| Field | Value |
|-------|-------|
| Card Number | `4000000000000002` |
| Expiry | `12/25` |
| CVV | `123` |

**Test UPI:**
| Field | Value |
|-------|-------|
| UPI ID | `success@payu` |

**Test Net Banking:**
- Select any bank
- On the bank page, click "Success" to simulate successful payment

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Hash mismatch` | Salt is incorrect or hash formula is wrong | Verify salt from backend, check hash string format |
| `Invalid merchant key` | Wrong key for environment | Ensure test key for test mode, prod key for production |
| `Transaction already processed` | Duplicate txnid | Generate unique txnid for each payment |
| `Network error` | No internet or server down | Check connectivity, verify backend is running |
| `Payment cancelled by user` | User closed PayU UI | Handle gracefully in `onPaymentCancel` |
| `SDK initialization failed` | Missing dependencies or config | Verify `payu_checkoutpro_flutter` is installed, check Android config |
| `ProGuard stripped PayU classes` | Missing ProGuard rules | Add PayU ProGuard rules to build config |
| `MultiDex error` | minSdk < 21 or multidex not enabled | Set `minSdk = 21` and `multiDexEnabled = true` |
| `401 Unauthorized` | JWT token expired | Implement token refresh, check auth interceptor |

### Testing Checklist

- [ ] Payment initiation API returns valid `PaymentData`
- [ ] PayU checkout screen opens correctly
- [ ] Hash is generated and accepted by PayU SDK
- [ ] Successful payment triggers `onPaymentSuccess`
- [ ] Failed payment triggers `onPaymentFailure`
- [ ] User cancellation triggers `onPaymentCancel`
- [ ] Backend is notified of success/failure
- [ ] Post-payment navigation works for each subscription type
- [ ] Loading states are cleared after payment
- [ ] Pending bid is placed correctly (SUBT002)
- [ ] Subscription data is refreshed after payment
- [ ] Error states display appropriate messages

---

## ⚠️ Best Practices

### Security Guidelines

1. **Never hardcode production credentials** in client-side code
2. **Generate hashes server-side** — the current local hash generation is a security risk
3. **Validate all payment callbacks** on the backend before activating subscriptions
4. **Use HTTPS** for all API communications
5. **Implement webhook verification** — don't rely solely on client-side callbacks
6. **Rotate API keys** periodically
7. **Log all payment events** for audit trails
8. **Encrypt sensitive data** in local storage (use `flutter_secure_storage`)

### Do's

✅ **Do** generate hashes on the backend  
✅ **Do** validate payment status server-to-server before fulfilling orders  
✅ **Do** implement idempotency for payment callbacks  
✅ **Do** use unique transaction IDs for every payment  
✅ **Do** handle all SDK callbacks (success, failure, cancel, error)  
✅ **Do** clear loading states in `finally` blocks  
✅ **Do** test with PayU's test credentials before going live  
✅ **Do** implement proper error boundaries  
✅ **Do** log payment events for debugging  
✅ **Do** use `Completer<bool>` for async payment flow  

### Don'ts

❌ **Don't** store salt or merchant key in plain text on the client  
❌ **Don't** trust client-side payment verification alone  
❌ **Don't** reuse transaction IDs  
❌ **Don't** ignore `onPaymentCancel` or `onError` callbacks  
❌ **Don't** hardcode test credentials in production builds  
❌ **Don't** skip ProGuard rules for PayU classes  
❌ **Don't** forget to handle `MultiDex` on Android  
❌ **Don't** block the UI thread during payment processing  
❌ **Don't** navigate away from payment screen before callbacks complete  

### Production Readiness Checklist

- [ ] Merchant key and salt are fetched dynamically from backend
- [ ] Hash generation is done server-side (not client-side)
- [ ] All payment callbacks are verified server-to-server
- [ ] Webhook endpoint is implemented and verified
- [ ] ProGuard rules are configured for release builds
- [ ] MultiDex is enabled for Android
- [ ] Test credentials are removed from production code
- [ ] Error handling covers all edge cases
- [ ] Loading states are properly managed
- [ ] Payment logging is implemented
- [ ] Retry logic is in place for network failures
- [ ] Token refresh is handled for expired JWTs
- [ ] All subscription types (SUBT001-SUBT007) are tested
- [ ] Navigation stack is properly managed after payment
- [ ] App doesn't crash on payment cancellation
- [ ] Payment amount validation is done server-side
- [ ] Duplicate payment prevention is implemented
- [ ] SSL certificate pinning is configured (optional but recommended)

---

## 📋 Quick Reference

### Key Files

| File | Purpose |
|------|---------|
| `payu_sdk_payment.dart` | Module barrel export |
| `config/payu_config.dart` | SDK configuration |
| `controllers/payment_controller.dart` | Payment orchestration |
| `models/initiate_payment_model.dart` | Initiation models |
| `models/payment_status_callback.dart` | Callback models |
| `services/payment_api_service.dart` | API communication |
| `services/hash_service.dart` | Hash generation |
| `views/payment_view.dart` | Test UI |

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/payments/initiate` | POST | Start payment |
| `/api/v1/payments/success` | POST | Success callback |
| `/api/v1/payments/failure` | POST | Failure callback |

### Subscription Types

| Code | Type | Controller Used |
|------|------|-----------------|
| SUBT001 | Auction Access | AuctionController |
| SUBT002 | Bid Limit | AuctionController |
| SUBT003 | Vehicle Details | BuySellController |
| SUBT004 | Buy & Sell Access | BuySellController |
| SUBT005 | Vehicle Inspection | BuySellController |
| SUBT006 | Mechanic Contact | ServiceSupportController |
| SUBT007 | Shop Contact | SpareAndFmsController |

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `payu_checkoutpro_flutter` | 1.3.2 | PayU SDK |
| `get` | ^4.6.6 | State management |
| `dio` | ^5.4.0 | HTTP client |
| `crypto` | (bundled) | SHA-512 hashing |

---

*This documentation was generated by analyzing the complete `payu_sdk_payment` module and its dependencies in the Vahaan Bazar Flutter project.*
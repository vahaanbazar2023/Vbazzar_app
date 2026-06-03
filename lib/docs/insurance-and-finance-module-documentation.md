# Insurance & Finance Module — Complete Documentation

> **Purpose**: This document provides a comprehensive, field-level overview of the **Insurance & Finance** module from the Vahaan Bazar mobile Flutter app. It is intended to serve as a complete reference guide for recreating the module in another project with a different architecture — ensuring no feature, validation, field, or business logic is missed.

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Directory Structure](#2-directory-structure)
3. [Architecture & Design Patterns](#3-architecture--design-patterns)
4. [Dependencies & Shared Services](#4-dependencies--shared-services)
5. [API Endpoints](#5-api-endpoints)
6. [Data Models](#6-data-models)
7. [Insurance Form — Complete Field Specification](#7-insurance-form--complete-field-specification)
8. [Finance Form — Complete Field Specification](#8-finance-form--complete-field-specification)
9. [My Quotes View](#9-my-quotes-view)
10. [Controller State Variables](#10-controller-state-variables)
11. [Key Business Logic & Flows](#11-key-business-logic--flows)
12. [Validation Strategy](#12-validation-strategy)
13. [Shared Widgets Used](#13-shared-widgets-used)
14. [Navigation & Routes](#14-navigation--routes)
15. [Error Handling Patterns](#15-error-handling-patterns)
16. [Recreation Checklist](#16-recreation-checklist)

---

## 1. Module Overview

The **Insurance & Finance** module provides three main features:

| Feature | Description |
|---------|-------------|
| **Insurance** | Allows users to request vehicle insurance by submitting vehicle details, document uploads (RC, Aadhar, PAN, previous policy), selecting insurance type (Comprehensive/Third Party), and claim status. |
| **Finance** | Allows users to request vehicle financing by submitting vehicle details, location (State/City), document uploads (RC, Insurance Copy, Company GST, Applicant & Co-Applicant Aadhar/PAN), and contact information. |
| **My Quotes** | Displays all insurance/finance quotes submitted for the user's vehicles. Shows expandable cards with provider quotes, prices, and downloadable PDF links. |

The module uses a **tab-based layout** — the main view has two tabs: **Insurance** and **Finance**. My Quotes is a separate navigable page accessed from the drawer/navigation.

---

## 2. Directory Structure

```
lib/modules/insurance_finance/
├── bindings/
│   └── insurance_finance_binding.dart       # GetX dependency injection binding
├── controllers/
│   └── insurance_finance_controller.dart    # Main controller (1238 lines) — all state, validation, submission logic
├── models/
│   ├── insurance_request_model.dart         # Insurance request payload model
│   ├── insurance_response_model.dart        # Insurance API response model (InsuranceData, UploadedFile)
│   ├── finance_response_model.dart          # Finance API response model (FinanceData, UploadedFile)
│   ├── vehicle_quotes_model.dart            # Single vehicle quotes response (QuoteModel, VehicleQuotesData)
│   └── vehicle_listings_quotes_model.dart   # All vehicle listings quotes response (VehicleQuoteItem, FileUrls)
├── services/
│   └── insurance_service.dart               # API service layer — handles multipart form submissions
└── views/
    ├── insurance_finance_view.dart          # Main tab container view (TabBar: Insurance | Finance)
    ├── insurance_view.dart                  # Insurance form view
    ├── finance_view.dart                    # Finance form view
    └── my_quotes.dart                       # My Quotes listing view
```

---

## 3. Architecture & Design Patterns

### Pattern: GetX Controller-Service-Model-View

```
┌─────────────┐     ┌──────────────────────────┐     ┌─────────────────┐
│   Views      │────▶│  InsuranceFinance        │────▶│ InsuranceService│
│ (UI Screens) │     │  Controller              │     │ (API Layer)     │
└─────────────┘     │  - State management      │     └────────┬────────┘
                    │  - Validation            │              │
                    │  - Business logic        │     ┌────────▼────────┐
                    └──────────────────────────┘     │ NetworkService  │
                                                     │ (Dio HTTP)      │
                                                     └────────┬────────┘
                                                     ┌────────▼────────┐
                                                     │  Backend API    │
                                                     └─────────────────┘
```

### Key Design Decisions:
- **Single Controller** (`InsuranceFinanceController`) manages state for both Insurance and Finance tabs
- **TabController** (2 tabs) managed in the controller with `TickerProviderStateMixin`
- **Reactive State** using GetX `Rx` observables (`RxString`, `RxBool`, `RxList`, `RxInt`)
- **Service Layer** handles multipart form-data construction and API calls
- **Bindings** ensure `AuthController` is available before `InsuranceFinanceController` is created

---

## 4. Dependencies & Shared Services

### Internal Dependencies:
| Dependency | Purpose |
|------------|---------|
| `AuthController` | Provides `stateId`, `cityId` for location management; ensures user is authenticated |
| `StorageService` | Retrieves `userId` for API calls |
| `NetworkService` | HTTP client (Dio wrapper) for all API requests |
| `LocationService` | (Indirect) State/City data for Finance form autocomplete |

### External Packages:
| Package | Purpose |
|---------|---------|
| `file_picker` | File selection for document uploads (images & PDFs) |
| `dio` | HTTP client for API calls and PDF downloads |
| `permission_handler` | Storage permission for downloading quote PDFs |
| `open_filex` | Opens downloaded PDF files on device |
| `url_launcher` | Fallback: opens quote PDFs in browser |
| `path_provider` | Gets device storage directories for file downloads |
| `flutter_svg` | SVG icon rendering in My Quotes view |
| `get` | State management, dependency injection, routing, snackbars |

---

## 5. API Endpoints

### Base URL
```
Production: https://api.prod.vahaanbazar.in
Staging:    https://api.staging.vahaanbazar.in
```

### API Prefix
```
/api/v1/insurance-finance
```

### Endpoints

#### 5.1 Submit Insurance Request
```
POST /api/v1/insurance-finance/insurance-request
Content-Type: multipart/form-data
```

**Text Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Authenticated user's ID |
| `vehicle_no` | string | Vehicle registration number |
| `insurance_type` | string | `"comprehensive"` or `"third_party"` |
| `claim_type` | string | `"yes"` or `"no"` |
| `accepted_terms` | string | `"true"` or `"false"` |

**File Fields (all optional in multipart, but RC is validated mandatory on client):**
| Field | Type | Description |
|-------|------|-------------|
| `aadhar_file` | file | Aadhar card document (image/pdf) |
| `pan_file` | file | PAN card document (image/pdf) |
| `rc_file` | file | RC (Registration Certificate) document (image/pdf) |
| `previous_policy_file` | file | Previous year insurance policy (image/pdf) |

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Insurance request submitted successfully",
  "timestamp": "2026-03-06T...",
  "data": {
    "ins_vehicle_id": "...",
    "vehicle_no": "...",
    "insurance_type": "comprehensive",
    "claim_type": "no",
    "accepted_terms": "true",
    "uploaded_files": [
      {
        "field_name": "rc_file",
        "original_filename": "rc.pdf",
        "s3_url": "https://...",
        "file_size": 12345
      }
    ],
    "created_at": "2026-03-06T...",
    "status": "pending"
  },
  "error": null
}
```

---

#### 5.2 Submit Finance Request
```
POST /api/v1/insurance-finance/finance-request
Content-Type: multipart/form-data
```

**Text Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Authenticated user's ID |
| `vehicle_no` | string | Vehicle registration number |
| `vehicle_state` | string | Selected state name |
| `vehicle_city` | string | Selected city name |
| `fleet_size` | string | Fleet size (optional, can be empty string) |
| `vehicle_location` | string | Vehicle location (optional, can be empty string) |
| `applicant_mobile_num` | string | Applicant's mobile number (optional, can be empty string) |
| `co_applicant_details` | string | `"yes"` or `"no"` |
| `co_applicant_mobile_num` | string | Co-applicant's mobile number (optional, can be empty string) |

**File Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `rc_file` | file | RC document |
| `insurance_file` | file | Insurance copy |
| `company_gst_file` | file | Company GST document (optional) |
| `applicant_aadhar_file` | file | Applicant's Aadhar |
| `applicant_pan_file` | file | Applicant's PAN |
| `co_applicant_aadhar_file` | file | Co-applicant's Aadhar (conditional) |
| `co_applicant_pan_file` | file | Co-applicant's PAN (conditional) |

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Finance request submitted successfully",
  "timestamp": "2026-03-06T...",
  "data": {
    "fin_vehicle_id": "...",
    "vehicle_no": "...",
    "vehicle_state": "Maharashtra",
    "vehicle_city": "Mumbai",
    "fleet_size": "5",
    "vehicle_location": "Andheri",
    "applicant_mobile_num": "9876543210",
    "co_applicant_details": "yes",
    "co_applicant_mobile_num": "9876543211",
    "uploaded_files": [
      {
        "field_name": "rc_file",
        "original_filename": "rc.pdf",
        "s3_url": "https://...",
        "file_key": "...",
        "file_size": 12345
      }
    ],
    "created_at": "2026-03-06T...",
    "status": "pending"
  },
  "error": null
}
```

> **Note:** Finance response `UploadedFile` includes an additional `file_key` field compared to Insurance response.

---

#### 5.3 Get Vehicle Quotes (Single Vehicle)
```
POST /api/v1/insurance-finance/vehicle-quotes
Content-Type: application/json
```

**Request Body:**
```json
{
  "vehicle_id": "...",
  "user_id": "...",
  "service_type": "insurance" | "finance"
}
```

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "...",
  "timestamp": "...",
  "data": {
    "quotes": [
      {
        "provider_name": "HDFC ERGO Insurance",
        "price": 8500.0,
        "downloadable_pdf_url": "https://..."
      }
    ],
    "service_type": "insurance",
    "total_quotes": 3,
    "user_id": "...",
    "vehicle_id": "..."
  }
}
```

---

#### 5.4 Get Vehicle Listings Quotes (All Vehicles)
```
POST /api/v1/insurance-finance/vehicle-listings-quotes
Content-Type: application/json
```

**Request Body:**
```json
{
  "user_id": "..."
}
```

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "...",
  "timestamp": "...",
  "data": {
    "user_id": "...",
    "vehicles": [
      {
        "vehicle_id": "...",
        "vehicle_no": "MH01AB1234",
        "service_type": "insurance",
        "quotes": [
          {
            "provider_name": "HDFC ERGO Insurance",
            "price": 8500.0,
            "downloadable_pdf_url": "https://..."
          }
        ],
        "total_quotes": 3,
        "file_urls": {
          "aadhar_file": "https://...",
          "pan_file": "https://...",
          "rc_file": "https://...",
          "previous_policy_file": "https://..."
        }
      }
    ],
    "total_vehicles": 2,
    "total_quotes_across_all_vehicles": 6
  }
}
```

---

## 6. Data Models

### 6.1 InsuranceRequestModel

```dart
class InsuranceRequestModel {
  String userId;        // user_id
  String vehicleNo;     // vehicle_no
  String insuranceType; // insurance_type: "comprehensive" | "third_party"
  String claimType;     // claim_type: "yes" | "no"
  String acceptedTerms; // accepted_terms: "true" | "false"
}
```

### 6.2 InsuranceResponseModel

```dart
class InsuranceResponseModel {
  String status;        // "success" | "error"
  int code;             // HTTP status code
  String message;       // Response message
  String timestamp;     // ISO timestamp
  InsuranceData data;   // Response data
  String? error;        // Error details (nullable)
}

class InsuranceData {
  String insVehicleId;          // ins_vehicle_id
  String vehicleNo;             // vehicle_no
  String insuranceType;         // insurance_type
  String claimType;             // claim_type
  String acceptedTerms;         // accepted_terms
  List<UploadedFile> uploadedFiles; // uploaded_files[]
  String createdAt;             // created_at
  String status;                // "pending" etc.
}

class UploadedFile {
  String fieldName;         // field_name (e.g., "rc_file")
  String originalFilename;  // original_filename
  String s3Url;             // s3_url
  int fileSize;             // file_size (bytes)
}
```

### 6.3 FinanceResponseModel

```dart
class FinanceResponseModel {
  String status;
  int code;
  String message;
  String timestamp;
  FinanceData? data;        // Nullable
  dynamic error;            // Can be Map or String
}

class FinanceData {
  String finVehicleId;              // fin_vehicle_id
  String vehicleNo;                 // vehicle_no
  String vehicleState;              // vehicle_state
  String vehicleCity;               // vehicle_city
  String? fleetSize;                // fleet_size (nullable)
  String? vehicleLocation;          // vehicle_location (nullable)
  String? applicantMobileNum;       // applicant_mobile_num (nullable)
  String coApplicantDetails;        // co_applicant_details: "yes" | "no"
  String? coApplicantMobileNum;     // co_applicant_mobile_num (nullable)
  List<UploadedFile>? uploadedFiles; // uploaded_files[] (nullable)
  String createdAt;                 // created_at
  String status;                    // "pending" etc.
}

// Note: Finance UploadedFile has an extra field
class UploadedFile {
  String fieldName;         // field_name
  String originalFilename;  // original_filename
  String s3Url;             // s3_url
  String fileKey;           // file_key (Finance-specific, not in Insurance)
  int fileSize;             // file_size
}
```

### 6.4 VehicleQuotesResponseModel (Single Vehicle)

```dart
class VehicleQuotesResponseModel {
  String status;
  int code;
  String message;
  String timestamp;
  VehicleQuotesData? data;
  Map<String, dynamic>? error;

  bool get isSuccess => status == 'success' && code == 200;
}

class VehicleQuotesData {
  List<QuoteModel> quotes;
  String serviceType;   // "insurance" | "finance"
  int totalQuotes;
  String userId;
  String vehicleId;
}

class QuoteModel {
  String downloadablePdfUrl; // downloadable_pdf_url
  double price;              // price
  String providerName;       // provider_name
}
```

### 6.5 VehicleListingsQuotesResponseModel (All Vehicles)

```dart
class VehicleListingsQuotesResponseModel {
  String status;
  int code;
  String message;
  String timestamp;
  VehicleListingsQuotesData? data;
  Map<String, dynamic>? error;

  bool get isSuccess => status == 'success' && code == 200;
}

class VehicleListingsQuotesData {
  String userId;
  List<VehicleQuoteItem> vehicles;
  int totalVehicles;
  int totalQuotesAcrossAllVehicles;
}

class VehicleQuoteItem {
  String vehicleId;
  String vehicleNo;
  String serviceType;       // "insurance" | "finance"
  List<QuoteModel> quotes;
  int totalQuotes;
  FileUrls? fileUrls;       // Nullable — links to uploaded documents
}

class QuoteModel {
  String providerName;       // provider_name
  double price;              // price
  String downloadablePdfUrl; // downloadable_pdf_url
}

class FileUrls {
  String? aadharFile;           // aadhar_file — S3 URL
  String? panFile;              // pan_file — S3 URL
  String? rcFile;               // rc_file — S3 URL
  String? previousPolicyFile;   // previous_policy_file — S3 URL
}
```

---

## 7. Insurance Form — Complete Field Specification

### Form Fields in Order of Appearance

| # | Field Name | Label Text | Hint Text | Prefix Icon | Mandatory | Widget Type |
|---|-----------|------------|-----------|-------------|-----------|-------------|
| 1 | Vehicle Number | `Vehicle No *` | `Enter Vehicle No` | `vehiclesvg` | ✅ Yes | `CustomTextFormField` |
| 2 | RC Document | `RC Document *` | N/A (upload widget) | N/A | ✅ Yes | `CustomMultipleUploadWidget` |
| 3 | Previous Year Policy | `Previous Year Policy` | N/A (upload widget) | N/A | ❌ No | `CustomMultipleUploadWidget` |
| 4 | Insurance Type | `Select Insurance Type *` | Dropdown placeholder | `insurance-type` | ✅ Yes | `CustomDropdownField<String>` |
| 5 | Claim Status | `Select Claim *` | Dropdown placeholder | `claim` | ✅ Yes | `CustomDropdownField<String>` |
| 6 | Aadhar Document | `Aadhar Document` | N/A (upload widget) | N/A | ❌ No | `CustomMultipleUploadWidget` |
| 7 | PAN Document | `PAN Document` | N/A (upload widget) | N/A | ❌ No | `CustomMultipleUploadWidget` |
| 8 | Terms & Conditions | `I Accept the` + linked `Terms` & `Conditions` | N/A | N/A | ✅ Yes | Custom checkbox with RichText |

### Detailed Field Validations

#### Field 1: Vehicle Number
| Property | Value |
|----------|-------|
| Controller | `vehicleNoController` |
| Label | `Vehicle No *` |
| Hint | `Enter Vehicle No` |
| Icon | `AppImages.vehiclesvg` |
| Mandatory | ✅ Yes |
| Real-time Validation | `validateVehicleNo()` called on `onChanged` |
| **Rule 1** | Cannot be empty → Error key: `vehicleNoRequired` |
| **Rule 2** | Minimum 6 characters → Error key: `vehicleNoMinLength` |
| Error State Variable | `vehicleNoError` (RxString) |
| Error Messages | `vehicleNoRequired`: "Please enter vehicle registration number" / `vehicleNoMinLength`: "Vehicle number must be at least 6 characters" |
| Mapped to API field | `vehicle_no` |

#### Field 2: RC Document Upload
| Property | Value |
|----------|-------|
| State Variable | `rcCopyFiles` (RxList<PlatformFile>) |
| Title | `RC Document *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes |
| **Validation Rule** | List cannot be empty → Error key: `rcFileRequired` |
| Error State Variable | `rcFileError` (RxString) |
| Error Message | `rcFileRequired`: "Please upload RC document" |
| Mapped to API field | `rc_file` |

#### Field 3: Previous Year Policy Upload
| Property | Value |
|----------|-------|
| State Variable | `previousPolicyFiles` (RxList<PlatformFile>) |
| Title | `Previous Year Policy` (no asterisk = optional) |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ❌ No |
| Validation | None |
| Mapped to API field | `previous_policy_file` |

#### Field 4: Insurance Type Dropdown
| Property | Value |
|----------|-------|
| State Variable | `selectedInsuranceType` (RxString) |
| Hint | `Select Insurance Type *` |
| Icon | `AppImages.insuranceType` |
| Options | `['comprehensive', 'third_party']` |
| Display Labels | `comprehensive` → localized "Comprehensive", `third_party` → localized "Third Party" |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be empty string → Error key: `insuranceTypeRequired` |
| Error State Variable | `insuranceTypeError` (RxString) |
| Error Message | `insuranceTypeRequired`: "Please select insurance type" |
| Mapped to API field | `insurance_type` |

#### Field 5: Claim Status Dropdown
| Property | Value |
|----------|-------|
| State Variable | `selectedClaim` (RxString) |
| Hint | `Select Claim *` |
| Icon | `AppImages.claim` |
| Options | `['yes', 'no']` |
| Display Labels | `yes` → localized "Yes", `no` → localized "No" |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be empty string → Error key: `claimRequired` |
| Error State Variable | `claimError` (RxString) |
| Error Message | `claimRequired`: "Please select claim status" |
| Mapped to API field | `claim_type` |

#### Field 6: Aadhar Document Upload
| Property | Value |
|----------|-------|
| State Variable | `aadharFiles` (RxList<PlatformFile>) |
| Title | `Aadhar Document` (no asterisk = optional) |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ❌ No |
| Validation | None |
| Mapped to API field | `aadhar_file` |

#### Field 7: PAN Document Upload
| Property | Value |
|----------|-------|
| State Variable | `panFiles` (RxList<PlatformFile>) |
| Title | `PAN Document` (no asterisk = optional) |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ❌ No |
| Validation | None |
| Mapped to API field | `pan_file` |

#### Field 8: Terms & Conditions Checkbox
| Property | Value |
|----------|-------|
| State Variable | `isTermsAccepted` (RxBool) |
| Label | `I Accept the` + `Terms` (linked, blue) + `and` + `Conditions` (linked, blue) |
| Mandatory | ✅ Yes |
| **Validation Rule** | Must be `true` → Error key: `termsRequired` |
| Error State Variable | `termsError` (RxString) |
| Error Message | `termsRequired`: "Please accept terms and conditions" |
| Navigation | Tapping "Terms" or "Conditions" navigates to `AppRoutes.termsandService` |
| Mapped to API field | `accepted_terms` ("true"/"false") |

### Insurance Submit Button
| Property | Value |
|----------|-------|
| Text (idle) | Localized "Submit" |
| Text (submitting) | Localized "Submitting Request..." |
| Color | `AppColors.buttonPrimary` |
| Disabled when | `isSubmitting.value == true` |
| Action | `controller.submitInsuranceRequest()` |

### Insurance Form Submit Flow
1. Validate all mandatory fields (Vehicle No, RC, Insurance Type, Claim, Terms)
2. If any validation fails → set error state variables, return early
3. Set `isSubmitting = true`, clear all previous errors
4. Build multipart FormData with text fields + file bytes
5. POST to `/api/v1/insurance-finance/insurance-request`
6. On success → show success dialog with message, reset form
7. On failure → parse error message, show snackbar, reset loading state

### Insurance Success Dialog
| Property | Value |
|----------|-------|
| Title | "Insurance Request Submitted!" (localized) |
| Message | "Your insurance request has been submitted successfully. Our team will review your request and get back to you soon." |
| Button Text | "OK" (localized) |
| Action | Close dialog → reset form fields |

---

## 8. Finance Form — Complete Field Specification

### Form Fields in Order of Appearance

| # | Field Name | Label Text | Hint Text | Prefix Icon | Mandatory | Widget Type |
|---|-----------|------------|-----------|-------------|-----------|-------------|
| 1 | Vehicle Number | `Vehicle No *` | `Enter Vehicle No` | `vehiclesvg` | ✅ Yes | `CustomTextFormField` |
| 2 | State | `State *` | `Select State` | `vehicleState` | ✅ Yes | `CustomAutocomplete<StateItem>` |
| 3 | City | `City *` | `Select City` | `location` | ✅ Yes | `CustomAutocomplete<CityItem>` |
| 4 | RC Copy | `RC Copy *` | N/A (upload widget) | N/A | ✅ Yes | `CustomMultipleUploadWidget` |
| 5 | Insurance Copy | `Insurance Copy *` | N/A (upload widget) | N/A | ✅ Yes | `CustomMultipleUploadWidget` |
| 6 | Fleet Size | `Fleet Size` | `Enter Fleet Size` | `vehiclesvg` | ❌ No | `CustomTextFormField` |
| 7 | Company GST | `Company GST (if Available)` | N/A (upload widget) | N/A | ❌ No | `CustomMultipleUploadWidget` |
| 8 | Vehicle Location | `Vehicle Location *` | `Enter Vehicle Location` | `vehiclesvg` | ✅ Yes | `CustomTextFormField` |
| — | **Section Header** | `Applicant Details` | — | — | — | Text label |
| 9 | Aadhar Document | `Aadhar Document *` | N/A (upload widget) | N/A | ✅ Yes | `CustomMultipleUploadWidget` |
| 10 | PAN Document | `PAN Document *` | N/A (upload widget) | N/A | ✅ Yes | `CustomMultipleUploadWidget` |
| 11 | Mobile Number | `Mobile Number *` | `Mobile Number *` | `mobile` | ✅ Yes | `CustomTextFormField` |
| 12 | Co-Applicant Checkbox | `Add Co Applicant Details` | N/A | N/A | ❌ No | `CustomCheckbox` |
| — | **Conditional: Co-Applicant Section** (only visible when checkbox is checked) | | | | | |
| 13 | Co-Applicant Aadhar | `Aadhar Document *` | N/A (upload widget) | N/A | ✅ When visible | `CustomMultipleUploadWidget` |
| 14 | Co-Applicant PAN | `PAN Document *` | N/A (upload widget) | N/A | ✅ When visible | `CustomMultipleUploadWidget` |
| 15 | Co-Applicant Mobile | `Mobile Number *` | `Enter Mobile Number` | `mobile` | ✅ When visible | `CustomTextFormField` |

### Detailed Field Validations

#### Field 1: Vehicle Number (Finance)
| Property | Value |
|----------|-------|
| Controller | `vehicleNoFinanaceController` |
| Label | `Vehicle No *` |
| Hint | `Enter Vehicle No` |
| Icon | `AppImages.vehiclesvg` |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be empty → Error key: `vehicleNoRequired` |
| Error State Variable | `financeVehicleNoError` (RxString) |
| Error Message | `vehicleNoRequired`: "Please enter vehicle registration number" |
| Mapped to API field | `vehicle_no` |

#### Field 2: State (Autocomplete)
| Property | Value |
|----------|-------|
| Controller | `stateController` (TextEditingController) |
| State Variable | `selectedFinanceState` (RxString?) |
| Key | Dynamic: `state_autocomplete_${clearCounter}_${selectedFinanceState}` |
| Label | `State *` |
| Hint | `Select State` |
| Icon | `AppImages.vehicleState` |
| Suffix Icon | `AppImages.dropdown` |
| Data Source | `controller.states` (List<StateItem>) — loaded via `AuthController.loadStates()` |
| Filtering | Client-side: matches `stateName.toLowerCase().contains(query)` |
| Display | `option.stateName` |
| Clear Action | `clearStateForFinance()` — clears selected state, city, and reset counter |
| On Select | `selectStateForFinance(value)` — sets state, loads cities, clears city selection |
| Loading State | Shows `LoadingWidget` with message "Loading states..." when `isLoadingStates == true` |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be null/empty → Error key: `stateRequired` |
| Error State Variable | `stateError` (RxString) |
| Error Message | `stateRequired`: "Please select state" |
| Mapped to API field | `vehicle_state` (sends `stateName`, not ID) |

#### Field 3: City (Autocomplete — dependent on State)
| Property | Value |
|----------|-------|
| Controller | `cityController` (TextEditingController) |
| State Variable | `selectedFinanceCity` (RxString?) |
| Key | Dynamic: `city_autocomplete_${clearCounter}_${selectedFinanceCity}` |
| Label | `City *` |
| Hint | `Select City` |
| Icon | `AppImages.location` |
| Suffix Icon | `AppImages.dropdown` |
| Data Source | `controller.cities` (List<CityItem>) — loaded when state is selected via `loadCitiesForFinance()` |
| Filtering | Client-side: matches `cityName.toLowerCase().contains(query)` |
| Display | `option.cityName` |
| Clear Action | `clearCityForFinance()` — clears selected city and counter |
| On Select | `selectCityForFinance(value)` — sets city |
| Loading State | Shows `LoadingWidget` with message "Loading cities..." when `isLoadingCities == true` |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be null/empty → Error key: `cityRequired` |
| Error State Variable | `cityError` (RxString) |
| Error Message | `cityRequired`: "Please select city" |
| Mapped to API field | `vehicle_city` (sends `cityName`, not ID) |
| **Dependency** | Only shows cities for the selected state. Clears when state changes. |

#### Field 4: RC Copy Upload
| Property | Value |
|----------|-------|
| State Variable | `rcCopyFinanceFiles` (RxList<PlatformFile>) |
| Title | `RC Copy *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes |
| **Validation Rule** | List cannot be empty → Error key: `rcFinanceFileRequired` |
| Error State Variable | `rcFinanceFileError` (RxString) |
| Error Message | `rcFinanceFileRequired`: "Please upload RC copy" |
| Mapped to API field | `rc_file` |

#### Field 5: Insurance Copy Upload
| Property | Value |
|----------|-------|
| State Variable | `insuranceCopyFiles` (RxList<PlatformFile>) |
| Title | `Insurance Copy *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes |
| **Validation Rule** | List cannot be empty → Error key: `insuranceFinanceFileRequired` |
| Error State Variable | `insuranceFinanceFileError` (RxString) |
| Error Message | `insuranceFinanceFileRequired`: "Please upload insurance copy" |
| Mapped to API field | `insurance_file` |

#### Field 6: Fleet Size
| Property | Value |
|----------|-------|
| Controller | `fleetSizeController` |
| Label | `Fleet Size` |
| Hint | `Enter Fleet Size` |
| Icon | `AppImages.vehiclesvg` |
| Keyboard Type | `TextInputType.number` |
| Mandatory | ❌ No |
| Validation | None |
| Mapped to API field | `fleet_size` (empty string if not provided) |

#### Field 7: Company GST Upload
| Property | Value |
|----------|-------|
| State Variable | `companyGstFiles` (RxList<PlatformFile>) |
| Title | `Company GST (if Available)` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ❌ No |
| Validation | None |
| Mapped to API field | `company_gst_file` |

#### Field 8: Vehicle Location
| Property | Value |
|----------|-------|
| Controller | `vehicleLocationController` |
| Label | `Vehicle Location *` |
| Hint | `Enter Vehicle Location` |
| Icon | `AppImages.vehiclesvg` |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be empty → Error key: `vehicleLocationRequired` |
| Error State Variable | `vehicleLocationError` (RxString) |
| Error Message | `vehicleLocationRequired`: "Please enter vehicle location" |
| Mapped to API field | `vehicle_location` |

#### Field 9: Applicant Aadhar Document Upload
| Property | Value |
|----------|-------|
| State Variable | `aadharFinanceFiles` (RxList<PlatformFile>) |
| Title | `Aadhar Document *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes |
| **Validation Rule** | List cannot be empty → Error key: `applicantAadharFileRequired` |
| Error State Variable | `applicantAadharFileError` (RxString) |
| Error Message | `applicantAadharFileRequired`: "Please upload Aadhar document" |
| Mapped to API field | `applicant_aadhar_file` |

#### Field 10: Applicant PAN Document Upload
| Property | Value |
|----------|-------|
| State Variable | `panFinanceFiles` (RxList<PlatformFile>) |
| Title | `PAN Document *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes |
| **Validation Rule** | List cannot be empty → Error key: `applicantPanFileRequired` |
| Error State Variable | `applicantPanFileError` (RxString) |
| Error Message | `applicantPanFileRequired`: "Please upload PAN document" |
| Mapped to API field | `applicant_pan_file` |

#### Field 11: Mobile Number (Applicant)
| Property | Value |
|----------|-------|
| Controller | `mobileNumberController` |
| Label | `Mobile Number *` |
| Hint | `Mobile Number *` |
| Icon | `AppImages.mobile` |
| Keyboard Type | `TextInputType.phone` |
| Mandatory | ✅ Yes |
| **Validation Rule** | Cannot be empty → Error key: `mobileNumberRequired` |
| Error State Variable | `mobileNumberError` (RxString) |
| Error Message | `mobileNumberRequired`: "Please enter mobile number" |
| Mapped to API field | `applicant_mobile_num` |

#### Field 12: Co-Applicant Checkbox
| Property | Value |
|----------|-------|
| State Variable | `isCoapplicant` (RxBool, default: `false`) |
| Label | `Add Co Applicant Details` |
| Widget | `CustomCheckbox` |
| Label Font Size | `16` (responsive) |
| Label Color | `AppColors.textFieldPlaceholder` |
| Label Font Weight | `FontWeight.w400` |
| Action | Toggles `isCoapplicant.value` |
| Conditional Logic | When `true` → shows Fields 13, 14, 15 below. When `false` → hides them (`SizedBox.shrink()`) |
| Mapped to API field | `co_applicant_details` ("yes" when checked, "no" when unchecked) |

#### Field 13: Co-Applicant Aadhar Document Upload (CONDITIONAL)
| Property | Value |
|----------|-------|
| State Variable | `aadharCoApplicantFinanceFiles` (RxList<PlatformFile>) |
| Title | `Aadhar Document *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes (only when co-applicant checkbox is checked) |
| **Validation Rule** | If `isCoapplicant == true`, list cannot be empty → Error key: `coApplicantAadharFileRequired` |
| Error State Variable | `coApplicantAadharFileError` (RxString) |
| Error Message | `coApplicantAadharFileRequired`: "Please upload co-applicant Aadhar document" |
| Mapped to API field | `co_applicant_aadhar_file` |
| Visibility | Only when `isCoapplicant.value == true` |

#### Field 14: Co-Applicant PAN Document Upload (CONDITIONAL)
| Property | Value |
|----------|-------|
| State Variable | `panCoApplicantFinanceFiles` (RxList<PlatformFile>) |
| Title | `PAN Document *` |
| Max Files | `1` |
| Allowed Extensions | `['png', 'jpg', 'jpeg', 'pdf']` |
| Mandatory | ✅ Yes (only when co-applicant checkbox is checked) |
| **Validation Rule** | If `isCoapplicant == true`, list cannot be empty → Error key: `coApplicantPanFileRequired` |
| Error State Variable | `coApplicantPanFileError` (RxString) |
| Error Message | `coApplicantPanFileRequired`: "Please upload co-applicant PAN document" |
| Mapped to API field | `co_applicant_pan_file` |
| Visibility | Only when `isCoapplicant.value == true` |

#### Field 15: Co-Applicant Mobile Number (CONDITIONAL)
| Property | Value |
|----------|-------|
| Controller | `mobileCoApplicantNumberController` |
| Label | `Mobile Number *` |
| Hint | `Enter Mobile Number` |
| Icon | `AppImages.mobile` |
| Keyboard Type | `CustomKeyboardTypes.phone` |
| Input Formatters | `CustomInputFormatters.phoneFormatter` |
| Mandatory | ✅ Yes (only when co-applicant checkbox is checked) |
| **Validation Rule** | If `isCoapplicant == true`, cannot be empty → Error key: `coApplicantMobileRequired` |
| Error State Variable | `coApplicantMobileError` (RxString) |
| Error Message | `coApplicantMobileRequired`: "Please enter co-applicant mobile number" |
| Mapped to API field | `co_applicant_mobile_num` |
| Visibility | Only when `isCoapplicant.value == true` |

### Finance Submit Button
| Property | Value |
|----------|-------|
| Text (idle) | Localized "Submit" |
| Text (submitting) | Localized "Submitting Request..." |
| Color | `AppColors.buttonPrimary` |
| Disabled when | `isSubmitting.value == true` |
| Action | `controller.submitFinanceRequest()` |

### Finance Form Submit Flow
1. Validate all mandatory fields (Vehicle No, State, City, RC, Insurance Copy, Vehicle Location, Applicant Aadhar, PAN, Mobile)
2. If co-applicant is enabled → also validate co-applicant Aadhar, PAN, Mobile
3. If any validation fails → set error state variables, return early
4. Set `isSubmitting = true`, clear all previous errors
5. Build multipart FormData with text fields + file bytes
6. POST to `/api/v1/insurance-finance/finance-request`
7. On success → show success dialog with message, reset form
8. On failure → parse error message, show snackbar, reset loading state

### Finance Success Dialog
| Property | Value |
|----------|-------|
| Title | "Finance Request Submitted!" (localized) |
| Message | "Your finance request has been submitted successfully. Our team will review your request and get back to you soon." |
| Button Text | "OK" (localized) |
| Action | Close dialog → reset form fields |

---

## 9. My Quotes View

### Overview
A separate page (`MyQuotes`) that displays all insurance/finance quotes for the user's vehicles.

### Navigation
- Accessed via drawer/navigation (not part of the tab view)
- Has its own `Scaffold` with `CustomAppBar` (title: "My Quotes") and `CustomDrawer`

### Data Loading
1. On `initState` → calls `controller.loadVehicleQuotes()`
2. `loadVehicleQuotes()` checks if user is logged in → calls `InsuranceService.getVehicleListingsQuotes(userId)`
3. Response populates `vehicleQuotes` (RxList<VehicleQuoteItem>)
4. Pull-to-refresh calls `refreshQuotes()` → re-fetches data

### UI States

| State | Condition | Display |
|-------|-----------|---------|
| **Loading** | `isLoadingQuotes == true` | `CircularProgressIndicator` centered |
| **Error** | `quotesErrorMessage.isNotEmpty` | Error text + Retry button |
| **Empty** | `vehicleQuotes.isEmpty` | "No quotes available" text |
| **Data** | `vehicleQuotes.isNotEmpty` | ListView of expandable vehicle cards |

### Vehicle Card Structure
Each card shows:
- **Header (always visible):**
  - Registration number: `Reg : {vehicleNo}`
  - Service type: `Service: {serviceType}`
  - Total quotes count: `Total Quotes: {totalQuotes}`
  - Expand/Collapse arrow (SVG: `arrow_down` / `arrow-right`)
- **Expanded Section (on tap):**
  - List of quote cards from different providers

### Quote Card Design
| Property | Value |
|----------|-------|
| Width | `360` |
| Height | `80` |
| Margin | `16` horizontal |
| Border Radius | `12` |
| Background | Gradient (alternating colors per provider) |

### Gradient Color Schemes (Alternating)
| Index | Colors | Description |
|-------|--------|-------------|
| 0 | `#FF00CC` → `#C80EBE` → `#333399` | Pink to Purple to Blue |
| 1 | `#2E3393` → `#1CFAFC` | Deep Blue to Cyan |
| 2 | `#833AB4` → `#FD1D1D` → `#FCB045` | Purple to Red to Orange |
| 3 | `#EFD30D` → `#81B65A` → `#1097AD` | Yellow to Green to Teal |

### Quote Card Content
- **Left side:** Provider name + formatted price (₹ with comma separators)
- **Right side:** "Download" button (white rounded pill, `111×27`, border radius `90`)

### Download Flow
1. User taps "Download" button
2. If `pdfUrl` is empty or `"#"` → show "Download link not available" snackbar
3. Otherwise → call `downloadQuote(pdfUrl, providerName, vehicleNo)`
4. Check storage permission
5. Download PDF via Dio to device storage
6. File naming: `Quote_{providerName}_{vehicleNo}_{timestamp}.pdf`
7. Save location:
   - Android: `/storage/emulated/0/Download/` (fallback: external storage Downloads, fallback: app documents)
   - iOS: App documents directory
8. Auto-open downloaded file with `OpenFilex.open(filePath)`
9. Error handling: network, timeout, 404, 403 specific messages

### Price Formatting Utility
```dart
String formatPrice(double price) {
  // Returns: ₹8,500 (with Indian comma grouping)
  // Uses regex: (\d{1,3})(?=(\d{3})+(?!\d))
}
```

---

## 10. Controller State Variables

### Tab Management
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `tabController` | `TabController` | 2 tabs | Controls Insurance/Finance tab switching |

### Loading States
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `isSubmitting` | `RxBool` | `false` | Form submission loading state |
| `isLoadingQuotes` | `RxBool` | `false` | My Quotes data loading |
| `isDownloadingQuote` | `RxBool` | `false` | PDF download in progress |

### Insurance Form Controllers
| Variable | Type | Purpose |
|----------|------|---------|
| `vehicleNoController` | `TextEditingController` | Vehicle number input |

### Insurance Form State
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `selectedInsuranceType` | `RxString` | `''` | Selected insurance type |
| `selectedClaim` | `RxString` | `''` | Selected claim status |
| `isTermsAccepted` | `RxBool` | `false` | Terms checkbox state |
| `rcCopyFiles` | `RxList<PlatformFile>` | `[]` | RC document files |
| `aadharFiles` | `RxList<PlatformFile>` | `[]` | Aadhar files |
| `panFiles` | `RxList<PlatformFile>` | `[]` | PAN files |
| `previousPolicyFiles` | `RxList<PlatformFile>` | `[]` | Previous policy files |

### Insurance Validation Errors
| Variable | Type | Error Key |
|----------|------|-----------|
| `vehicleNoError` | `RxString` | `vehicleNoRequired`, `vehicleNoMinLength` |
| `rcFileError` | `RxString` | `rcFileRequired` |
| `insuranceTypeError` | `RxString` | `insuranceTypeRequired` |
| `claimError` | `RxString` | `claimRequired` |
| `termsError` | `RxString` | `termsRequired` |

### Finance Form Controllers
| Variable | Type | Purpose |
|----------|------|---------|
| `vehicleNoFinanaceController` | `TextEditingController` | Vehicle number input |
| `stateController` | `TextEditingController` | State autocomplete text |
| `cityController` | `TextEditingController` | City autocomplete text |
| `vehicleLocationController` | `TextEditingController` | Vehicle location input |
| `fleetSizeController` | `TextEditingController` | Fleet size input |
| `mobileNumberController` | `TextEditingController` | Applicant mobile number |
| `mobileCoApplicantNumberController` | `TextEditingController` | Co-applicant mobile number |

### Finance Form State
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `selectedFinanceState` | `RxString?` | `null` | Selected state name |
| `selectedFinanceCity` | `RxString?` | `null` | Selected city name |
| `isCoapplicant` | `RxBool` | `false` | Co-applicant toggle |
| `states` | `RxList<StateItem>` | `[]` | Available states |
| `cities` | `RxList<CityItem>` | `[]` | Available cities for selected state |
| `isLoadingStates` | `RxBool` | `true` | States loading indicator |
| `isLoadingCities` | `RxBool` | `false` | Cities loading indicator |
| `clearCounter` | `RxInt` | `0` | Counter to force autocomplete widget rebuild on clear |
| `rcCopyFinanceFiles` | `RxList<PlatformFile>` | `[]` | RC copy files |
| `insuranceCopyFiles` | `RxList<PlatformFile>` | `[]` | Insurance copy files |
| `companyGstFiles` | `RxList<PlatformFile>` | `[]` | Company GST files |
| `aadharFinanceFiles` | `RxList<PlatformFile>` | `[]` | Applicant Aadhar files |
| `panFinanceFiles` | `RxList<PlatformFile>` | `[]` | Applicant PAN files |
| `aadharCoApplicantFinanceFiles` | `RxList<PlatformFile>` | `[]` | Co-applicant Aadhar files |
| `panCoApplicantFinanceFiles` | `RxList<PlatformFile>` | `[]` | Co-applicant PAN files |

### Finance Validation Errors
| Variable | Type | Error Key |
|----------|------|-----------|
| `financeVehicleNoError` | `RxString` | `vehicleNoRequired` |
| `stateError` | `RxString` | `stateRequired` |
| `cityError` | `RxString` | `cityRequired` |
| `rcFinanceFileError` | `RxString` | `rcFinanceFileRequired` |
| `insuranceFinanceFileError` | `RxString` | `insuranceFinanceFileRequired` |
| `vehicleLocationError` | `RxString` | `vehicleLocationRequired` |
| `applicantAadharFileError` | `RxString` | `applicantAadharFileRequired` |
| `applicantPanFileError` | `RxString` | `applicantPanFileRequired` |
| `mobileNumberError` | `RxString` | `mobileNumberRequired` |
| `coApplicantAadharFileError` | `RxString` | `coApplicantAadharFileRequired` |
| `coApplicantPanFileError` | `RxString` | `coApplicantPanFileRequired` |
| `coApplicantMobileError` | `RxString` | `coApplicantMobileRequired` |

### My Quotes State
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `vehicleQuotes` | `RxList<VehicleQuoteItem>` | `[]` | All vehicle quotes data |
| `quotesErrorMessage` | `RxString` | `''` | Error message for quotes loading |
| `expandedVehicleIds` | `RxSet<String>` | `{}` | Set of expanded vehicle IDs |

---

## 11. Key Business Logic & Flows

### 11.1 State → City Dependency Chain (Finance)
```
User selects State
  → selectStateForFinance(state)
    → Sets selectedFinanceState = stateName
    → Clears selectedFinanceCity
    → Clears cityController text
    → Loads cities via AuthController.loadCities(stateId)
    → If no cities found → shows "No cities available" snackbar
    → If error → shows error snackbar
```

### 11.2 Co-Applicant Toggle Logic (Finance)
```
User checks "Add Co Applicant Details"
  → isCoapplicant = true
  → UI conditionally renders:
    - Co-Applicant Aadhar Upload (mandatory when visible)
    - Co-Applicant PAN Upload (mandatory when visible)
    - Co-Applicant Mobile Number (mandatory when visible)

User unchecks
  → isCoapplicant = false
  → Section hidden (SizedBox.shrink())
  → Validation skipped for co-applicant fields
  → API sends co_applicant_details = "no"
```

### 11.3 File Upload Architecture
```
FilePicker picks file → PlatformFile (contains bytes + name)

On form submit:
  PlatformFile.bytes → MultipartFile.fromBytes(bytes, filename: name)

FormData construction:
  formData.fields → text key-value pairs
  formData.files  → file entries with MultipartFile
```

**Key implementation detail:** Files are read into memory as bytes via `FilePicker`. On submit, `MultipartFile.fromBytes()` is used (not `fromFile()`), making it work on all platforms including web.

### 11.4 Autocomplete Clear Pattern (Finance)
When user clears a state/city autocomplete:
1. Increment `clearCounter` (forces widget rebuild via new Key)
2. Clear the TextEditingController text
3. Clear the selected value
4. For state: also clear city and reload cities

### 11.5 Error Message Localization
```dart
String getLocalizedErrorMessage(String errorKey, Map<String, String> params, AppLocalizations localizations)
```
- Maps error keys to localized strings
- Supports parameter substitution in error messages
- Falls back to raw error key if no localization found

### 11.6 Form Reset After Successful Submission
**Insurance:**
- `vehicleNoController.clear()`
- `selectedInsuranceType.value = ''`
- `selectedClaim.value = ''`
- `isTermsAccepted.value = false`
- All file lists cleared (`rcCopyFiles`, `aadharFiles`, `panFiles`, `previousPolicyFiles`)

**Finance:**
- All TextEditingControllers cleared
- `selectedFinanceState = null`, `selectedFinanceCity = null`
- `isCoapplicant = false`
- `clearCounter` incremented (forces autocomplete rebuild)
- All file lists cleared
- Cities list cleared

---

## 12. Validation Strategy

### Two-Phase Validation

#### Phase 1: Real-time (on change)
- Vehicle number: validated on every keystroke via `onChanged`
- Other fields: validated at submit time only

#### Phase 2: On Submit
- All mandatory fields validated in sequence
- Each validation failure sets the corresponding error state variable
- All errors displayed simultaneously (not just the first one)
- Form does NOT submit if any validation fails

### Error Display Pattern
```dart
Obx(() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Input widget
    CustomTextFormField(...),
    // Conditional error message
    if (controller.errorState.value.isNotEmpty)
      Padding(
        padding: EdgeInsets.only(top: 8.0, left: 24.0),
        child: Text(
          controller.getLocalizedErrorMessage(
            controller.errorState.value,
            {},
            localizations,
          ),
          style: TextStyle(
            color: Colors.red,
            fontSize: SizeConfig.responsiveFontSize(context, 12),
          ),
        ),
      ),
  ],
))
```

### Error Clearing
- All errors cleared at the start of each submit attempt: `_clearAllErrors()`
- Insurance errors cleared when switching to Finance tab
- Finance errors cleared when switching to Insurance tab

---

## 13. Shared Widgets Used

| Widget | Module | Usage |
|--------|--------|-------|
| `CustomAppBar` | `shared/widgets/` | Top app bar with title and optional filter button |
| `CustomDrawer` | `shared/widgets/` | Navigation drawer |
| `CustomTextFormField` | `shared/widgets/` | Styled text input with label, hint, prefix icon |
| `CustomDropdownField<T>` | `shared/widgets/` | Generic dropdown with prefix icon |
| `CustomAutocomplete<T>` | `shared/widgets/` | Generic autocomplete with search, clear, and suffix icon |
| `CustomMultipleUploadWidget` | `shared/widgets/` | File upload widget with title, max files, allowed extensions |
| `CustomCheckbox` | `shared/widgets/` | Styled checkbox with label |
| `CustomButton` | `shared/widgets/` | Styled button with background color and text |
| `LoadingOverlay` | `shared/widgets/` | Full-screen loading overlay with optional message |
| `LoadingWidget` | `shared/widgets/` | Inline loading indicator with message |
| `PlatformRefreshIndicator` | `shared/widgets/` | Platform-adaptive pull-to-refresh wrapper |
| `SizeConfig` | `shared/widgets/` | Responsive sizing utility |
| `AppColors` | `core/constants/` | Color constants |
| `AppImages` | `core/constants/` | Asset path constants (SVG icons) |
| `AppTextStyles` | `core/constants/` | Text style utilities |
| `AppLocalizations` | `l10n/` | Localization strings |
| `InputFormatters` | `shared/widgets/` | Phone number input formatter (`CustomInputFormatters.phoneFormatter`) |

### Key Icons Used (SVG Assets)
| Icon Key | Asset Path | Used In |
|----------|-----------|---------|
| `vehiclesvg` | `assets/icons/truck.svg` | Vehicle number field |
| `insuranceType` | `assets/icons/insurance-type.svg` | Insurance type dropdown |
| `claim` | `assets/icons/claim.svg` | Claim status dropdown |
| `vehicleState` | `assets/icons/vehicle-state.svg` | State autocomplete |
| `location` | `assets/icons/location.svg` | City autocomplete |
| `mobile` | `assets/icons/mobile.svg` | Mobile number field |
| `dropdown` | `assets/icons/dropdown.svg` | Autocomplete suffix |
| `arrowDown` | `assets/icons/downarrow.svg` | My Quotes expand arrow |
| `arrowRight` | `assets/icons/arrow-right.svg` | My Quotes collapse arrow |

---

## 14. Navigation & Routes

| Route | View | Purpose |
|-------|------|---------|
| Insurance & Finance main | `InsuranceFinanceView` | Tab container (Insurance + Finance) |
| My Quotes | `MyQuotes` | Quotes listing page |
| Terms & Conditions | `AppRoutes.termsandService` | Legal page (from Insurance terms link) |

### Binding
```dart
class InsuranceFinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AuthController exists first
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    Get.lazyPut<InsuranceFinanceController>(() => InsuranceFinanceController());
  }
}
```

---

## 15. Error Handling Patterns

### API Error Handling
```dart
try {
  final response = await _networkService.post(endpoint, data: formData);
  // Parse response
} catch (e) {
  if (e is dio.DioException) {
    statusCode = e.response?.statusCode;
    responseData = e.response?.data;

    switch (statusCode) {
      case 400: // Bad Request
        // Parse server validation errors
      case 401: // Unauthorized
        // "Session expired. Please login again."
      case 403: // Forbidden
        // "You don't have permission"
      case 404: // Not Found
        // "Service not found"
      case 422: // Validation Error
        // Parse detailed validation errors
      case 500: // Server Error
        // "Server error. Please try again later."
    }
  }
}
```

### Download Error Handling
| Error Condition | User Message |
|----------------|--------------|
| Network error | "Network error. Please check your connection." |
| Request timeout | "Request timeout. Please try again." |
| 404 response | "Quote file not found." |
| 403 response | "Access denied. Quote may have expired." |
| Storage permission denied | "Storage permission is required to download quotes" |
| Storage error | "Storage permission required to save quote PDF." |
| Generic download error | "Failed to save quote PDF: {error}" |
| Empty URL | "Download link not available" |
| Launch failure | "Could not open quote PDF: {error}" |

### Snackbar Styling
| Type | Background Color | Text Color | Position |
|------|-----------------|------------|----------|
| Success | `AppColors.green` / `Colors.green` | White | TOP |
| Error | `Colors.red` | White | TOP |
| Warning | `Colors.orange` | White | TOP |
| Info | `Colors.blue` | White | TOP |

---

## 16. Recreation Checklist

Use this checklist when recreating the module in another project:

### Setup
- [ ] Create module directory structure (bindings, controllers, models, services, views)
- [ ] Set up dependency injection (equivalent of GetX bindings)
- [ ] Configure API base URL and endpoints
- [ ] Ensure authentication/user session management is available

### Models
- [ ] Create `InsuranceRequestModel` (userId, vehicleNo, insuranceType, claimType, acceptedTerms)
- [ ] Create `InsuranceResponseModel` (status, code, message, data with InsuranceData + UploadedFile)
- [ ] Create `FinanceResponseModel` (status, code, message, data with FinanceData + UploadedFile with fileKey)
- [ ] Create `VehicleQuotesResponseModel` (status, data with quotes list)
- [ ] Create `VehicleListingsQuotesResponseModel` (status, data with vehicles list + quotes + fileUrls)

### Service Layer
- [ ] Implement `submitInsuranceRequest()` — multipart POST with text fields + 4 file fields
- [ ] Implement `submitFinanceRequest()` — multipart POST with 9 text fields + 7 file fields
- [ ] Implement `getVehicleListingsQuotes()` — JSON POST with userId

### Insurance Form
- [ ] Vehicle Number field (mandatory, min 6 chars, real-time validation)
- [ ] RC Document upload (mandatory, 1 file, png/jpg/jpeg/pdf)
- [ ] Previous Year Policy upload (optional, 1 file, png/jpg/jpeg/pdf)
- [ ] Insurance Type dropdown (mandatory, options: comprehensive/third_party)
- [ ] Claim Status dropdown (mandatory, options: yes/no)
- [ ] Aadhar Document upload (optional, 1 file, png/jpg/jpeg/pdf)
- [ ] PAN Document upload (optional, 1 file, png/jpg/jpeg/pdf)
- [ ] Terms & Conditions checkbox (mandatory, links to T&C page)
- [ ] Submit button with loading state
- [ ] Success dialog after submission
- [ ] Form reset after success

### Finance Form
- [ ] Vehicle Number field (mandatory)
- [ ] State autocomplete (mandatory, loads from API)
- [ ] City autocomplete (mandatory, dependent on State)
- [ ] RC Copy upload (mandatory, 1 file, png/jpg/jpeg/pdf)
- [ ] Insurance Copy upload (mandatory, 1 file, png/jpg/jpeg/pdf)
- [ ] Fleet Size field (optional, numeric)
- [ ] Company GST upload (optional, 1 file, png/jpg/jpeg/pdf)
- [ ] Vehicle Location field (mandatory)
- [ ] "Applicant Details" section header
- [ ] Applicant Aadhar upload (mandatory, 1 file, png/jpg/jpeg/pdf)
- [ ] Applicant PAN upload (mandatory, 1 file, png/jpg/jpeg/pdf)
- [ ] Applicant Mobile Number field (mandatory, phone keyboard)
- [ ] Co-Applicant checkbox (toggle to show/hide co-applicant section)
- [ ] Co-Applicant Aadhar upload (mandatory when visible, 1 file, png/jpg/jpeg/pdf)
- [ ] Co-Applicant PAN upload (mandatory when visible, 1 file, png/jpg/jpeg/pdf)
- [ ] Co-Applicant Mobile Number field (mandatory when visible, phone keyboard, phone formatter)
- [ ] Submit button with loading state
- [ ] Success dialog after submission
- [ ] Form reset after success
- [ ] Keyboard dismissal on tap outside

### My Quotes View
- [ ] Load quotes on page init
- [ ] Loading state with spinner
- [ ] Error state with retry button
- [ ] Empty state message
- [ ] Pull-to-refresh
- [ ] Expandable vehicle cards (registration, service type, total quotes)
- [ ] Quote cards with gradient backgrounds (4 alternating color schemes)
- [ ] Provider name + formatted price display
- [ ] Download button per quote
- [ ] PDF download to device storage (platform-specific directories)
- [ ] Auto-open downloaded PDF
- [ ] Download error handling (network, permission, 404, 403)

### Shared Components
- [ ] Tab bar with Insurance/Finance tabs
- [ ] Loading overlay for form submissions
- [ ] File upload widget (multi-file, extension filtering)
- [ ] Autocomplete widget with clear and search
- [ ] Responsive sizing utility
- [ ] Phone number input formatter
- [ ] Price formatting utility (₹ with Indian comma grouping)
- [ ] Localized error messages
- [ ] Platform-adaptive refresh indicator

### Navigation
- [ ] Main view with tab controller
- [ ] My Quotes page navigation
- [ ] Terms & Conditions page navigation
- [ ] Drawer integration

---

> **Note:** This documentation was generated from the actual source code of the Vahaan Bazar Flutter app's `insurance_finance` module. All field names, validation rules, error keys, API endpoints, and business logic described here reflect the current implementation as of the codebase snapshot analyzed.
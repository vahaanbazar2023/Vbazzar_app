# Vendor Approved Vehicles Module — Complete Documentation

> **Purpose:** This document provides a comprehensive specification of the Vendor-specific Approved Vehicles functionality from the Vahaan Bazar mobile application. It is designed to enable another developer/team to rebuild the full Vendor business logic and workflows with a completely different UI/UX design.

---

## Table of Contents

1. [Vendor Functional Overview](#1-vendor-functional-overview)
2. [Role & Permission Handling](#2-role--permission-handling)
3. [Vendor Navigation & Routing](#3-vendor-navigation--routing)
4. [API Documentation (Vendor Endpoints)](#4-api-documentation-vendor-endpoints)
5. [Data Models](#5-data-models)
6. [Vendor Screens & User Flows](#6-vendor-screens--user-flows)
7. [Sell Form — Complete Specification](#7-sell-form--complete-specification)
8. [Buy Flow — Vendor Path](#8-buy-flow--vendor-path)
9. [UI Components (Vendor-Specific)](#9-ui-components-vendor-specific)
10. [State Management](#10-state-management)
11. [Business Rules & Validation](#11-business-rules--validation)
12. [Payment Flow (Vendor)](#12-payment-flow-vendor)
13. [Dependencies Between Modules](#13-dependencies-between-modules)
14. [Edge Cases & Error Handling](#14-edge-cases--error-handling)
15. [Reusable Logic & Utilities](#15-reusable-logic--utilities)
16. [Architecture Summary](#16-architecture-summary)
17. [Suggested Improvements](#17-suggested-improvements)

---

## 1. Vendor Functional Overview

### What is the Vendor Flow?

The Vendor flow is a **specialized entry point** into the Approved Vehicles module, designed for users with the `VENDOR` role. Vendors interact with the Approved Vehicles module primarily to:

1. **SELL** — List their vehicles for sale by submitting vehicle details, documents, and images through a comprehensive sell form
2. **BUY** — Browse and purchase approved vehicles (same flow as CUSTOMER but accessed via a different entry point)

### Vendor vs Customer Flow Comparison

| Aspect | VENDOR | CUSTOMER |
|--------|--------|----------|
| **Entry Point** | Buy/Sell Landing Page (`/approved-vehicle-buy-sell`) | Category Grid (`/approved-vehicle-category`) |
| **Landing UI** | List-style cards with SELL + BUY buttons | Grid-style category cards |
| **Primary Action** | SELL vehicles | BUY vehicles |
| **Sell Form Access** | Direct from category card "SELL" button | Via "Sell Your Vehicle" menu/drawer option |
| **Buy Flow** | Same as Customer (Listings → Detail → Payment) | Category → Listings → Detail → Payment |
| **My Bookings** | ✅ Accessible | ✅ Accessible |
| **My Inspections** | ✅ Accessible | ✅ Accessible |
| **Post-Login Destination** | `/categories` (main home) | `/categories` (main home) |

### Complete Vendor Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    VENDOR USER JOURNEY                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Login/Registration (user_type = "VENDOR")                        │
│       │                                                              │
│       ▼                                                              │
│  2. Main Home (/categories)                                          │
│       │                                                              │
│       ├──► Drawer → "Approved Vehicle"                               │
│       │         │                                                    │
│       │         ▼                                                    │
│       │    3. Buy/Sell Landing Page                                  │
│       │     (/approved-vehicle-buy-sell)                             │
│       │         │                                                    │
│       │         │  Displays: List of categories                      │
│       │         │  Each card has: SELL button + BUY button            │
│       │         │                                                    │
│       │         ├──► [SELL] Button ────────────────────────┐         │
│       │         │                                           │         │
│       │         │                                           ▼         │
│       │         │    4. Sell Form (/approved-vehicle-sell-form)       │
│       │         │     - Pre-filled category (readonly)               │
│       │         │     - Vehicle registration, state, city            │
│       │         │     - Fitness, brand, chassis, invoice             │
│       │         │     - Asset description, owner mobile              │
│       │         │     - Price, manufacturing year                    │
│       │         │     - Insurance (yes/no + upload + date)           │
│       │         │     - RC document upload                           │
│       │         │     - GST applicability                            │
│       │         │     - Vehicle images upload                        │
│       │         │     - Offer end date + time                        │
│       │         │         │                                          │
│       │         │         ▼                                          │
│       │         │    Submit → API call (multipart/form-data)         │
│       │         │         │                                          │
│       │         │         ├── Success → Snackbar → Back to Buy/Sell  │
│       │         │         └── Failure → Snackbar error               │
│       │         │                                                    │
│       │         ├──► [BUY] Button ─────────────────────────┐         │
│       │         │                                           │         │
│       │         │                                           ▼         │
│       │         │    5. Vehicle Listings (/approved-vehicle-listings) │
│       │         │     - Paginated grid (20 per page)                 │
│       │         │     - Filtered by selected category                │
│       │         │     - Infinite scroll                              │
│       │         │         │                                          │
│       │         │         ▼                                          │
│       │         │    6. Vehicle Detail (/approved-vehicle-detail)     │
│       │         │         │                                          │
│       │         │         ├── [Book Now] → Payment → Booked           │
│       │         │         └── [Inspection] → Payment → Requested      │
│       │         │                                                    │
│       │         ▼                                                    │
│       │    My Bookings (/my-bookings) via drawer                     │
│       │    My Inspections (/my-inspections) via drawer               │
│       │                                                              │
│       └──► Other modules (Buy/Sell, Insurance, etc.)                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Role & Permission Handling

### User Type Detection

The vendor flow is triggered when the user's `user_type` resolves to `"VENDOR"`.

#### Detection Chain

```
┌──────────────────────────────────────────────────────────────┐
│              USER TYPE RESOLUTION FOR VENDOR                   │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Step 1: Read from StorageService                             │
│     └── storageService.getUserType()                          │
│     └── Key: 'user_type' in GetStorage                        │
│                                                               │
│  Step 2: Validate value                                       │
│     ├── null → Invalid, proceed to Step 3                     │
│     ├── '' (empty) → Invalid, proceed to Step 3               │
│     ├── 'user' → Legacy/invalid, proceed to Step 3            │
│     └── 'VENDOR' → ✅ Valid vendor, use this                  │
│                                                               │
│  Step 3: Fallback to profile API data                         │
│     └── categoryController.userProfileData.value.userType     │
│     └── If exists and non-empty → Use it                      │
│     └── If null → Default to 'CUSTOMER'                       │
│                                                               │
│  Step 4: Navigate based on resolved user_type                 │
│     └── 'VENDOR' → /approved-vehicle-buy-sell                 │
│     └── All others → /approved-vehicle-category               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

#### Navigation Implementation

```dart
// File: lib/shared/widgets/custom_drawer.dart

void _navigateToApprovedVehicle() {
  Get.back(); // Close drawer
  final storageService = Get.find<StorageService>();
  String? userType = storageService.getUserType();

  // Fallback: fetch from profile if storage is empty/invalid
  if (userType == null || userType.isEmpty || userType == 'user') {
    final profileData = categoryController.userProfileData.value;
    if (profileData != null && profileData.userType.isNotEmpty) {
      userType = profileData.userType;
    }
  }

  // Navigate based on user type
  if (userType?.toUpperCase() == 'VENDOR') {
    Get.toNamed(AppRoutes.approvedVehicleBuySell);
  } else {
    Get.toNamed(AppRoutes.approvedVehicleCategory);
  }
}
```

### Vendor Permissions Matrix

| Capability | VENDOR Access | Notes |
|-----------|--------------|-------|
| View Buy/Sell Landing | ✅ | Entry point for vendors |
| View Category Grid | ❌ (redirected) | Redirected to Buy/Sell |
| Access Sell Form | ✅ | From SELL button on category card |
| Submit Vehicle for Sale | ✅ | Via sell form |
| Browse Vehicle Listings | ✅ | Via BUY button |
| View Vehicle Details | ✅ | Same as customer |
| Book Vehicle | ✅ | Same as customer |
| Request Inspection | ✅ | Same as customer |
| View My Bookings | ✅ | Via drawer |
| View My Inspections | ✅ | Via drawer |
| Access Inspection/Valuation Form | ❌ | INTERNAL only |

### User Type Update Points for Vendor

| Event | Storage Action | user_type Value |
|-------|---------------|-----------------|
| **Vendor Registration** | `storageService.write('user_type', 'VENDOR')` | `'VENDOR'` |
| **Vendor Login** | `storageService.write('user_type', response.user_type)` | `'VENDOR'` |
| **Profile Fetch** | `storageService.saveUserType(profileData.userType)` | `'VENDOR'` |
| **Profile Update** | Updated via profile response | `'VENDOR'` (or changed) |
| **Logout** | `storageService.removeUserType()` | `null` |
| **Session Expired** | `_clearSessionData()` clears all | `null` |

---

## 3. Vendor Navigation & Routing

### Route Definitions

| Route Constant | Path | Screen Class | Description |
|---------------|------|-------------|-------------|
| `approvedVehicleBuySell` | `/approved-vehicle-buy-sell` | `ApprovedVehicleBuySellView` | Vendor landing page |
| `approvedVehicleSellForm` | `/approved-vehicle-sell-form` | `ApprovedVehicleSellForm` | Sell vehicle form |
| `approvedVehicleListings` | `/approved-vehicle-listings` | `ApprovedVehicleListingsView` | Vehicle listings (BUY flow) |
| `approvedVehicleDetail` | `/approved-vehicle-detail` | `ApprovedVehicleDetailView` | Vehicle detail + payment |
| `myBookings` | `/my-bookings` | `ApprovedVehicleUserBookedView` | User's booked vehicles |
| `myInspections` | `/my-inspections` | `ApprovedVehicleUserBookedView` | User's inspection requests |

### Route Registration

```dart
// File: lib/routes/app_pages.dart

GetPage(
  name: AppRoutes.approvedVehicleBuySell,
  page: () => const ApprovedVehicleBuySellView(),
  binding: AuctionBinding(),
),
GetPage(
  name: AppRoutes.approvedVehicleSellForm,
  page: () => const ApprovedVehicleSellForm(),
  binding: AuctionBinding(),
),
```

### Vendor Navigation Flow Diagram

```
Drawer ("Approved Vehicle")
    │
    │  [user_type == "VENDOR"]
    ▼
/approved-vehicle-buy-sell  (BuySell Landing)
    │
    ├──► SELL button on category card
    │       │
    │       ▼
    │    /approved-vehicle-sell-form
    │       │  arguments: {categoryName, categoryCode}
    │       │
    │       ├── Success → Snackbar → /approved-vehicle-buy-sell
    │       └── Failure → Snackbar (stays on form)
    │
    ├──► BUY button on category card
    │       │
    │       ▼
    │    /approved-vehicle-listings
    │       │  arguments: {category: ApprovedVehicleCategory}
    │       │
    │       ▼
    │    /approved-vehicle-detail
    │       │  arguments: {listing: ApprovedVehicleListing}
    │       │
    │       ├── [Book Now] → Payment Dialog → PayU SDK
    │       │       │
    │       │       ├── Success → updateApprovedVehicleUserInterest()
    │       │       │       → Listings refreshed
    │       │       └── Failure → Snackbar error
    │       │
    │       └── [Inspection] → Payment Dialog → PayU SDK
    │               │
    │               ├── Success → updateApprovedVehicleUserInterest()
    │               │       → Listings refreshed
    │               └── Failure → Snackbar error
    │
    ├──► My Bookings (via drawer)
    │       │
    │       ▼
    │    /my-bookings
    │
    └──► My Inspections (via drawer)
            │
            ▼
         /my-inspections
```

### Back Navigation Handling

The Buy/Sell view implements custom back navigation:

```dart
WillPopScope(
  onWillPop: () async {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      // Fallback to approved vehicle category screen
      Get.offAllNamed(AppRoutes.approvedVehicleCategory);
    }
    return false; // Prevent default back action
  },
  // ...
)
```

**Behavior:**
- If navigation stack has previous screens → Go back normally
- If no previous screen (deep link / fresh launch) → Navigate to category grid as fallback

---

## 4. API Documentation (Vendor Endpoints)

### 4.1 Get Approved Vehicle Categories (Shared)

> Used by both Vendor Buy/Sell landing and Customer Category grid. Same API, different UI presentation.

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-categories`
- **Constant:** `ApiConstants.approvedVechileCategoriesEndpoint`

#### Request

```json
{
  "user_id": "string (required)",
  "status": "Active",
  "page": 1,
  "limit": 100
}
```

#### Response

```json
{
  "data": {
    "categories": [
      {
        "id": 1,
        "category_code": "TRUCK",
        "category_name": "Truck",
        "status": "Active",
        "subscription_amount": 5000.00,
        "category_plan": "PLAN_TRUCK_001",
        "sorting_order": 1,
        "icon_name": "https://cdn.example.com/icons/truck.svg",
        "approved_veh_available_count": 25,
        "inserted_at": "2024-01-15T10:30:00Z",
        "modified_at": "2024-06-01T14:20:00Z",
        "inserted_by": "admin_user_id",
        "modified_by": null
      }
    ],
    "total_count": 8
  }
}
```

#### Vendor Usage

This data populates the `BuySellItemCard` list in the Vendor Buy/Sell landing:
- `category_name` → Card title
- `approved_veh_available_count` → "Available Vehicles: X"
- `icon_name` → Category icon (SVG or raster image URL)
- `category_code` → Passed to sell form as argument

---

### 4.2 Get Approved Vehicle Listings (Shared — BUY Flow)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-listings`
- **Constant:** `ApiConstants.approvedVechileListingsEndpoint`

#### Request

```json
{
  "user_id": "string (required)",
  "status": "approved",
  "category_type": "TRUCK (from selected category)",
  "page": 1,
  "limit": 20
}
```

#### Vendor Usage

Triggered when vendor taps the **BUY** button on a category card. The `category_type` is set from the selected category's `category_code`.

#### Response

Same as documented in the main Approved Vehicles documentation (Section 2.2). Key fields:

```json
{
  "data": {
    "listings": [
      {
        "id": 101,
        "approved_vehicle_id": "AVH-2024-001",
        "category_type": "TRUCK",
        "registration_number": "MH01AB1234",
        "brand": "Tata",
        "price": 2500000.00,
        "is_booked": "no",
        "inspection_requested": "no",
        "inspection_subscription": { "inspection_amount": 2000.00, "category_plan": "INSPECT_TRUCK_001" },
        "category_subscription": { "subscription_amount": 5000.00, "appr_veh_common_sub_plan": "SUB_TRUCK_001" },
        "files": { "images": [...], "rc_documents": [...], "insurance_documents": [...] }
      }
    ],
    "total_count": 150
  }
}
```

---

### 4.3 Submit Approved Vehicle (SELL Form — Vendor Primary Action)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-submit`
- **Constant:** `ApiConstants.approvedVechileSubmitEndpoint`
- **Content-Type:** `multipart/form-data`

#### Request (FormData)

```json
{
  "user_id": "string (auto-attached from StorageService)",
  "category_type": "string (from category code, e.g., TRUCK)",
  "registration_number": "string (required)",
  "state_code": "string (resolved from state name)",
  "city_code": "string (resolved from city name)",
  "fitness_available": "Yes/No (required)",
  "brand": "string (free text, required)",
  "original_invoice_available": "Yes/No (required)",
  "owner_mobile_number": "string (required)",
  "asset_description": "string (required)",
  "year_of_manufacturing": "string (required, e.g., '2022')",
  "price": "string (required, e.g., '2500000')",
  "offer_end_date": "YYYY-MM-DD (required)",
  "offer_end_time": "HH:MM:SS (required, IST)",
  "chassis_number": "string (optional)",
  "insurance": "Yes/No (required)",
  "gst_applicable": "Yes/No (required)",
  "vehicle_insurance_date": "YYYY-MM-DD (optional)",

  // File uploads (multipart)
  "vehicle_images[]": [file1.jpg, file2.jpg, ...],      // Required, max 10 files, 12MB each
  "rc_documents[]": [rc1.pdf, ...],                      // Optional, max 10 files, 12MB each
  "insurance_documents[]": [ins1.pdf, ...]               // Optional, max 10 files, 12MB each
}
```

#### Field Mapping (Controller → FormData)

| Form Controller | FormData Key | Required | Notes |
|----------------|-------------|----------|-------|
| `sellCategoryCodeC.text` | `category_type` | ✅ | Pre-filled, readonly |
| `sellRegNumberC.text` | `registration_number` | ✅ | User input |
| `sellStateC.text` → resolved `stateId` | `state_code` | ✅ | Autocomplete, resolved to ID |
| `sellCityC.text` → resolved `cityId` | `city_code` | ✅ | Autocomplete, resolved to ID |
| `sellFitness.value` | `fitness_available` | ✅ | Yes/No toggle |
| `sellBrandC.text` | `brand` | ✅ | Free text input |
| `sellChassisC.text` | `chassis_number` | ❌ | Optional text |
| `sellOriginalInvoice.value` | `original_invoice_available` | ✅ | Yes/No toggle |
| `sellAssetDescC.text` | `asset_description` | ✅ | Text (max 3 lines) |
| `sellOwnerMobileC.text` | `owner_mobile_number` | ✅ | Phone input |
| `sellPriceC.text` | `price` | ✅ | Number input |
| `sellMfgYear.value` | `year_of_manufacturing` | ✅ | Year picker (1950 → current year) |
| `sellInsurance.value` | `insurance` | ✅ | Yes/No toggle |
| `sellInsuranceDate.value` | `vehicle_insurance_date` | ❌ | Date picker |
| `sellGSTApplicability.value` | `gst_applicable` | ✅ | Yes/No toggle |
| `sellOfferEndDate.value` | `offer_end_date` | ✅ | Date picker → YYYY-MM-DD |
| `sellOfferEndTime.value` | `offer_end_time` | ✅ | Time picker → HH:MM:SS |
| `sellVehicleImages` | `vehicle_images[]` | ✅ | File picker, multipart |
| `sellRCFiles` | `rc_documents[]` | ❌ | File picker, multipart |
| `sellInsuranceFiles` | `insurance_documents[]` | ❌ | File picker, multipart |

#### Response

```json
{
  "success": true,
  "message": "Vehicle submitted successfully"
}
```

#### Error Responses

```json
// Validation error
{
  "success": false,
  "message": "Registration number already exists"
}

// Server error
{
  "success": false,
  "message": "Internal server error"
}
```

---

### 4.4 Update User Interest (Post-Payment)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-user-interest`
- **Constant:** `ApiConstants.approvedVechileUserInterestEndpoint`

#### Request

```json
{
  "user_id": "string",
  "approved_vehicle_id": "string",
  "is_interested": "yes/no",
  "is_booked": "yes/no"
}
```

#### Vendor Usage

Same as customer — called after successful PayU payment for booking or inspection.

| Vendor Action | `is_interested` | `is_booked` |
|--------------|----------------|-------------|
| **Book Now** | `"yes"` | `"yes"` |
| **Inspection** | `"yes"` | `"no"` |

---

### 4.5 Get User Booked/Inspected Vehicles (Shared)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-user-booked`
- **Constant:** `ApiConstants.approvedVechileUserBookedEndpoint`

#### Request

```json
// My Bookings
{ "user_id": "string", "booked_vehicles": "yes", "page": 1, "limit": 20 }

// My Inspections
{ "user_id": "string", "inspection_requested": "yes", "page": 1, "limit": 20 }
```

---

### API Dependency Map (Vendor)

```
Buy/Sell Landing
    └── GET Categories (/appr-veh-categories)

SELL Button
    └── SUBMIT Vehicle (/appr-veh-submit) [multipart/form-data]
        └── Depends on: States API, Cities API (from location module)

BUY Button
    └── GET Listings (/appr-veh-listings)
        └── GET Categories (for category_code filter)

Book Now / Inspection
    └── POST User Interest (/appr-veh-user-interest)
        └── Depends on: PayU Payment (payment initiate + success)

My Bookings / My Inspections
    └── GET User Booked (/appr-veh-user-booked)
```

---

## 5. Data Models

### 5.1 ApprovedVehicleCategory (Used in Buy/Sell Landing)

**File:** `lib/modules/auction/models/approved_vehicle_category_model.dart`

```dart
class ApprovedVehicleCategory {
  final int id;
  final String categoryCode;           // e.g., "TRUCK"
  final String categoryName;           // e.g., "Truck"
  final String status;                 // "Active" / "Inactive"
  final double subscriptionAmount;     // Booking price
  final String categoryPlan;           // PayU plan code
  final int sortingOrder;              // Display order
  final String iconName;               // Icon URL (SVG or raster)
  final int approvedVehAvailableCount; // Available vehicles
  final DateTime insertedAt;
  final DateTime modifiedAt;
  final String insertedBy;
  final String? modifiedBy;
}
```

#### Field Usage in Vendor Buy/Sell Card

| Field | Used In Card | Purpose |
|-------|-------------|---------|
| `categoryName` | Title text | e.g., "Truck" |
| `approvedVehAvailableCount` | Subtitle | "Available Vehicles: 25" |
| `iconName` | Left icon | Loaded as SVG or network image |
| `categoryCode` | Sell form argument | Passed as `categoryCode` to sell form |
| `categoryName` | Sell form argument | Passed as `categoryName` to sell form |

### 5.2 ApprovedVehicleListing (Used in BUY Flow)

```dart
class ApprovedVehicleListing {
  final int id;
  final String approvedVehicleId;
  final String categoryType;
  final String registrationNumber;
  final String stateName;
  final String cityName;
  final String fitnessAvailable;
  final String? brand;
  final String chassisNumber;
  final String originalInvoiceAvailable;
  final String ownerMobileNumber;
  final String assetDescription;
  final int yearOfManufacturing;
  final String vehicleInsuranceDate;
  final double price;
  final String vehicleStatus;
  final String gstApplicable;
  final String offerEndDate;
  final String offerEndTime;
  final String insertedAt;
  final String modifiedAt;
  final String insertedBy;
  final String modifiedBy;
  final InspectionSubscription? inspectionSubscription;
  final CategorySubscription? categorySubscription;
  final VehicleFiles? files;
  final String isBooked;               // "yes" / "no"
  final String inspectionRequested;    // "yes" / "no"
}
```

### 5.3 Location Models (Dependencies for Sell Form)

```dart
// File: lib/modules/location/models/states_model.dart
class StateItem {
  final String stateId;
  final String stateName;
}

// File: lib/modules/location/models/cities_model.dart
class CityItem {
  final String cityId;
  final String cityName;
  final String stateId;
}
```

---

## 6. Vendor Screens & User Flows

### 6.1 Buy/Sell Landing Screen (Vendor Entry Point)

**File:** `lib/modules/auction/views/aproved_vechicle_buy_sell.dart`
**Route:** `/approved-vehicle-buy-sell`
**Class:** `ApprovedVehicleBuySellView`

#### Purpose
Primary entry point for VENDOR users into the Approved Vehicles module. Displays vehicle categories as a vertical list with SELL and BUY action buttons.

#### Screen Layout

```
┌──────────────────────────────────────────────┐
│  [Drawer]  Approved Vehicles          [Bell] │  ← CustomAppBar
├──────────────────────────────────────────────┤
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [🚛]  Truck              [SELL→] [BUY→]│  │  ← BuySellItemCard
│  │       Available Vehicles: 25           │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [🚌]  Bus                [SELL→] [BUY→]│  │
│  │       Available Vehicles: 12           │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │ [🏗️]  Excavator          [SELL→] [BUY→]│  │
│  │       Available Vehicles: 8            │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ... (scrollable list)                       │
│                                              │
└──────────────────────────────────────────────┘
```

#### States

| State | Condition | UI |
|-------|-----------|-----|
| **Loading** | `isLoadingApprovedCategories == true` | 6 shimmer `BuySellItemCard.shimmer()` skeletons |
| **Error** | `approvedCategoriesError.isNotEmpty` | Center text: "Error: {message}" |
| **Empty** | `approvedCategories.isEmpty` | Center text: "No categories found." |
| **Loaded** | `approvedCategories.isNotEmpty` | ListView of `BuySellItemCard` widgets |

#### Lifecycle

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.fetchApprovedCategories();  // API call on screen load
  });
}
```

#### Actions

| Action | Trigger | Handler | Result |
|--------|---------|---------|--------|
| **SELL** | Tap SELL button on card | `_handleSellTap(categoryName, categoryCode)` | Navigate to `/approved-vehicle-sell-form` with arguments |
| **BUY** | Tap BUY button on card | `_handleBuyTap(category)` | Navigate to `/approved-vehicle-listings` via `controller.onApprovedCategoryTap(category)` |
| **Back** | System back / swipe | Custom `WillPopScope` | If can pop → `Get.back()`, else → `/approved-vehicle-category` fallback |

---

### 6.2 Vehicle Listings Screen (BUY Flow)

**File:** `lib/modules/auction/views/approved_vehicle_listings_view.dart`
**Route:** `/approved-vehicle-listings`
**Class:** `ApprovedVehicleListingsView`

#### Purpose
Displays paginated grid of approved vehicles for the category selected via the BUY button.

#### Layout
- **AppBar:** "Approved Vehicles" with drawer
- **Body:** 2-column grid of `ApprovedVehicleListingCard` widgets
- **Pagination:** 20 items per page, infinite scroll (90% threshold or 50px from bottom)

#### States

| State | UI |
|-------|-----|
| **Loading (initial)** | 6 shimmer skeleton cards in 2-column grid |
| **Loaded** | Vehicle cards with pull-to-refresh |
| **Empty** | Car icon + "No approved vehicles available" + "Refresh" button |
| **Loading more** | 2 shimmer cards appended at bottom |

#### Navigation
- Tap card → `/approved-vehicle-detail` with listing argument

---

### 6.3 Vehicle Detail Screen (BUY Flow)

**File:** `lib/modules/auction/views/approved_vehicle_detail_view.dart`
**Route:** `/approved-vehicle-detail`
**Class:** `ApprovedVehicleDetailView`

#### Purpose
Shows complete vehicle information with booking and inspection payment actions.

#### Key Sections
1. **Image Carousel** — `CustomImageContainer` with arrows, 240px height
2. **Vehicle Title** — Brand | Year | ID | Description
3. **Detail Rows** — 15+ rows with alternating backgrounds
4. **Action Buttons** — "Book Now" / "Inspection" with state-aware labels

#### Button States

| Condition | Book Now Button | Inspection Button |
|-----------|----------------|-------------------|
| Neither booked nor inspected | Active, "Book Now" | Active, "Inspection" |
| Already booked (`isBooked == "yes"`) | Disabled, grey, "Booked" | Active (still available) |
| Already inspected (`inspectionRequested == "yes"`) | Active | Disabled, "Requested" |
| Both booked and inspected | Disabled, "Booked" | Disabled, "Requested" |

---

## 7. Sell Form — Complete Specification

**File:** `lib/modules/auction/views/approved_vehicle_sell_form.dart`
**Route:** `/approved-vehicle-sell-form`
**Class:** `ApprovedVehicleSellForm`

### 7.1 Form Fields

#### Pre-filled Fields (from navigation arguments)

| Field | Controller | Editable | Source |
|-------|-----------|----------|--------|
| Vehicle Type (Category Name) | `sellCategoryNameC` | ❌ Disabled | `Get.arguments['categoryName']` |
| Category Code (hidden) | `sellCategoryCodeC` | ❌ Hidden | `Get.arguments['categoryCode']` |

#### Required Fields

| Field | Controller/State | Input Type | Validation |
|-------|-----------------|------------|------------|
| Registration Number | `sellRegNumberC` | Text input | Non-empty |
| State | `sellStateC` | Autocomplete (`StateItem`) | Non-empty, must select from list |
| City | `sellCityC` | Autocomplete (`CityItem`) | Non-empty, must select from list, filtered by selected state |
| Fitness | `sellFitness` (RxString) | Yes/No toggle buttons | Must select Yes or No |
| Brand | `sellBrandC` | Text input | Non-empty |
| Original Invoice | `sellOriginalInvoice` (RxString) | Yes/No toggle buttons | Must select Yes or No |
| Asset Description | `sellAssetDescC` | Text input (max 3 lines) | Non-empty |
| Owner Mobile Number | `sellOwnerMobileC` | Phone keyboard | Non-empty, 10 digits |
| Price | `sellPriceC` | Number keyboard | Non-empty, valid number |
| Manufacturing Year | `sellMfgYear` (RxString) | Year picker (1950 → current year) | Non-empty |
| Insurance | `sellInsurance` (RxString) | Yes/No toggle buttons | Must select Yes or No |
| GST Applicability | `sellGSTApplicability` (RxString) | Yes/No toggle buttons | Must select Yes or No |
| Vehicle Images | `sellVehicleImages` (RxList<PlatformFile>) | File picker (multiple) | At least 1 file required |
| Offer End Date | `sellOfferEndDate` (Rxn<DateTime>) | Date picker | Non-null, must be a valid date |
| Offer End Time | `sellOfferEndTime` (Rxn<TimeOfDay>) | Time picker | Non-null, valid time |

#### Optional Fields

| Field | Controller/State | Input Type |
|-------|-----------------|------------|
| Chassis Number | `sellChassisC` | Text input |
| Insurance Upload | `sellInsuranceFiles` (RxList<PlatformFile>) | File picker (multiple, max 10, 12MB each) |
| Vehicle Insurance Date | `sellInsuranceDate` (Rxn<DateTime>) | Date picker |
| RC Document Upload | `sellRCFiles` (RxList<PlatformFile>) | File picker (multiple, max 10, 12MB each) |

### 7.2 Form Initialization

```dart
// On screen load (called once per screen instance)
if (!_isInitialized && categoryCode.isNotEmpty) {
  _isInitialized = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Only clear if it's a different category
    if (controller.sellCategoryCodeC.text != categoryCode) {
      controller.clearSellForm();
    }
    // Pre-fill category fields
    controller.sellCategoryNameC.text = categoryName;
    controller.sellCategoryCodeC.text = categoryCode;
    // Load states for autocomplete
    buySellController.loadStatesIfNeeded();
  });
}
```

### 7.3 State/City Autocomplete Behavior

```
State Selection:
    User types in state field
        → Autocomplete filters buySellController.states by stateName
        → User selects a StateItem
            → sellStateC.text = stateName
            → buySellController.selectStateForSell(state)
            → buySellController.loadCitiesForSell(state.stateId)  // Loads cities for this state
            → validateSellState()

City Selection (depends on state):
    User types in city field
        → Autocomplete filters buySellController.cities by cityName
        → Only cities for the selected state are shown
        → User selects a CityItem
            → sellCityC.text = cityName
            → buySellController.selectCityForSell(city)
            → validateSellCity()
```

### 7.4 Validation Rules

#### Individual Field Validation

| Field | Rule | Error Message |
|-------|------|--------------|
| Category | Non-empty | "Category is required" |
| Registration Number | Non-empty | "Registration number is required" |
| State | Non-empty | "State is required" |
| City | Non-empty | "City is required" |
| Fitness | Non-empty (Yes/No) | "Fitness is required" |
| Brand | Non-empty | "Brand is required" |
| Original Invoice | Non-empty (Yes/No) | "Original invoice is required" |
| Asset Description | Non-empty | "Asset description is required" |
| Owner Mobile | Non-empty + 10 digits | "Owner mobile number is required" / "Enter valid 10-digit mobile number" |
| Price | Non-empty + valid number | "Price is required" / "Enter valid price" |
| Manufacturing Year | Non-empty | "Manufacturing year is required" |
| Insurance | Non-empty (Yes/No) | "Insurance is required" |
| GST Applicability | Non-empty (Yes/No) | "GST applicability is required" |
| Vehicle Images | At least 1 file | "Vehicle images are required" |
| Offer End Date | Non-null | "Offer end date is required" |
| Offer End Time | Non-null | "Offer end time is required" |

#### Form-Level Validation

```dart
bool validateSellForm() {
  validateSellCategory();
  validateSellRegNumber();
  validateSellState();
  validateSellCity();
  validateSellFitness();
  validateSellBrand();
  validateSellOriginalInvoice();
  validateSellAssetDesc();
  validateSellMfgYear();
  validateSellInsurance();
  validateSellGSTApplicability();
  validateSellVehicleImages();
  validateSellOfferEndDate();
  validateSellOfferEndTime();
  validateSellOwnerMobile();
  validateSellPrice();

  // Return true only if ALL error strings are empty
  return sellCategoryError.value.isEmpty &&
         sellRegNumberError.value.isEmpty &&
         sellStateError.value.isEmpty &&
         sellCityError.value.isEmpty &&
         sellFitnessError.value.isEmpty &&
         sellBrandError.value.isEmpty &&
         sellOriginalInvoiceError.value.isEmpty &&
         sellAssetDescError.value.isEmpty &&
         sellMfgYearError.value.isEmpty &&
         sellInsuranceError.value.isEmpty &&
         sellGSTApplicabilityError.value.isEmpty &&
         sellVehicleImagesError.value.isEmpty &&
         sellOfferEndDateError.value.isEmpty &&
         sellOfferEndTimeError.value.isEmpty &&
         sellOwnerMobileError.value.isEmpty &&
         sellPriceError.value.isEmpty;
}
```

### 7.5 Form Submission Flow

```
User taps "Submit"
    │
    ▼
validateSellForm()
    │
    ├── false → Snackbar: "Please fix validation errors"
    │           (Errors displayed inline on each field)
    │
    ▼
isSellFormLoading = true
    │
    ▼
Resolve state_code from state name
    └── buySellController.selectedState?.stateId ?? text input

Resolve city_code from city name
    └── buySellController.cities.firstWhere(cityName match).cityId

Build FormData with:
    - Text fields (MapEntry)
    - Yes/No fields (default "No" if empty)
    - Date fields (YYYY-MM-DD format)
    - Time fields (HH:MM:SS format)
    - File uploads (vehicle_images, rc_documents, insurance_documents)
    │
    ▼
ApiRepository.submitApprovedVehicleSellForm(formData)
    │
    ├── Success
    │   ├── Snackbar: "Vehicle submitted successfully"
    │   ├── clearSellForm()
    │   └── Navigate to /approved-vehicle-buy-sell
    │
    └── Failure
        ├── Snackbar: Error message
        └── Stay on form
    │
    ▼
isSellFormLoading = false (in finally block)
```

### 7.6 Loading Overlay

The form uses a `LoadingOverlay` widget during submission:

```dart
LoadingOverlay(
  isLoading: controller.isSellFormLoading.value,
  message: 'Submitting vehicle details...',
  showMessage: true,
  overlayColor: Colors.black.withOpacity(0.7),
  child: SingleChildScrollView(/* form content */),
)
```

### 7.7 Form Clear on Exit

```dart
WillPopScope(
  onWillPop: () async {
    _isInitialized = false;  // Reset static flag
    controller.clearSellForm();  // Clear all fields
    return true;  // Allow navigation
  },
  // ...
)
```

---

## 8. Buy Flow — Vendor Path

### 8.1 SELL vs BUY Button Actions

Both buttons are on the same `BuySellItemCard`, but lead to different flows:

#### SELL Flow

```
SELL button tap
    │
    ▼
_handleSellTap(categoryName, categoryCode)
    │
    ▼
Get.toNamed('/approved-vehicle-sell-form', arguments: {
  'categoryName': 'Truck',
  'categoryCode': 'TRUCK'
})
    │
    ▼
ApprovedVehicleSellForm receives arguments
    │
    ▼
Form pre-filled with category, user fills remaining fields
    │
    ▼
Submit → multipart/form-data POST
```

#### BUY Flow

```
BUY button tap
    │
    ▼
_handleBuyTap(category)
    │
    ▼
controller.onApprovedCategoryTap(category)
    │
    ├── Sets selectedListingCategoryType = category.categoryCode
    ├── Sets selectedListingStatus = "approved"
    ├── Resets pagination: page=1, hasMore=true, listings=[]
    │
    ▼
Get.toNamed('/approved-vehicle-listings', arguments: {'category': category})
    │
    ▼
ApprovedVehicleListingsView
    │
    ├── fetchApprovedVehicleListings(isRefresh: true)
    │   └── POST /appr-veh-listings with category_type filter
    │
    ▼
User taps a listing card
    │
    ▼
controller.onApprovedListingTap(listing)
    │
    ▼
Get.toNamed('/approved-vehicle-detail', arguments: {'listing': listing})
    │
    ▼
ApprovedVehicleDetailView
    │
    ├── View vehicle details
    ├── [Book Now] → Payment → Booked
    └── [Inspection] → Payment → Requested
```

### 8.2 Vendor Buy Flow — Same as Customer

After the BUY button, the vendor follows the **exact same flow** as a customer:
1. **Listings** — Paginated grid with same API, same pagination logic
2. **Detail** — Same detail screen with same fields
3. **Book Now** — Same payment dialog → PayU → User Interest API
4. **Inspection** — Same payment dialog → PayU → User Interest API

---

## 9. UI Components (Vendor-Specific)

### 9.1 BuySellItemCard

**Path:** `lib/modules/buy_and_sell/widgets/buy_sell_item_card.dart`

#### Purpose
Card widget used in the Vendor Buy/Sell landing page. Displays a category with SELL and BUY action buttons.

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `title` | `String` | ✅ | Category name (e.g., "Truck") |
| `vehicleCount` | `int?` | ❌ | Available vehicle count |
| `imageUrl` | `String` | ✅ | Category icon URL (SVG or raster) |
| `onSellTap` | `VoidCallback` | ✅ | SELL button handler |
| `onBuyTap` | `VoidCallback` | ✅ | BUY button handler |

#### Visual Layout

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│  ┌────┐   Truck                        ┌──────────┐ │
│  │icon│                                │  SELL  → │ │  ← White bg, orange text
│  │50x50│  Available Vehicles: 25       └──────────┘ │
│  └────┘                                ┌──────────┐ │
│                                        │  BUY   → │ │  ← Green bg (#469C15), white text
│                                        └──────────┘ │
│                                                      │
└──────────────────────────────────────────────────────┘
```

#### Image Handling

The card supports both SVG and raster images:

```dart
// Detection logic
if (imageUrl.toLowerCase().endsWith('.svg')) {
  // Load via SvgPicture.network()
} else {
  // Load via Image.network()
}

// Fallback on empty URL
if (imageUrl.isEmpty) {
  return Icon(Icons.image_not_supported);
}
```

#### Shimmer Skeleton

```dart
BuySellItemCard.shimmer()  // Static method for loading state

// Renders:
// - 50x50 grey box (icon placeholder)
// - 100x16 grey box (title placeholder)
// - 140x12 grey box (subtitle placeholder)
// - 100x40 grey box (SELL button placeholder)
// - 100x40 grey box (BUY button placeholder)
```

#### Design Specs

| Element | Spec |
|---------|------|
| Card height | 100px |
| Card background | White |
| Card border radius | 12px |
| Card shadow | black @ 5%, blur 4px, offset (0, 2) |
| SELL text color | `#FF5C00` (orange) |
| SELL background | White |
| BUY text color | White |
| BUY background | `#469C15` (green) |
| SELL/BUY width | 100px, height 40px |
| SELL/BUY border radius | topLeft 20px, bottomRight 12px |
| Arrow icon | `Icons.arrow_forward_ios`, 16px |
| Icon size | 50x50px |
| Card margin bottom | 12px |

### 9.2 Yes/No Toggle Widget (Sell Form)

Built inline within the sell form as `_buildYesNoField()`.

#### Props

| Prop | Type | Description |
|------|------|-------------|
| `label` | `String` | Field label (e.g., "Fitness *") |
| `currentValue` | `String` | Current selection ("Yes" / "No" / "") |
| `onYesPressed` | `VoidCallback` | Yes button handler |
| `onNoPressed` | `VoidCallback` | No button handler |
| `errorText` | `String?` | Validation error message |
| `yesText` | `String` | Localized "Yes" text |
| `noText` | `String` | Localized "No" text |

#### Visual Behavior

- Selected button: `AppColors.buttonPrimary` background, white text
- Unselected button: `Colors.grey[200]` background, black text
- Error state: Red border on both buttons + red error text below

### 9.3 Shared Components Used by Vendor

| Component | Path | Vendor Usage |
|-----------|------|-------------|
| `CustomAppBar` | `lib/shared/widgets/custom_app_bar.dart` | All vendor screens |
| `CustomDrawer` | `lib/shared/widgets/custom_drawer.dart` | All vendor screens (categoryType: 'approved_vehicles') |
| `CustomTextFormField` | `lib/shared/widgets/custom_text_field.dart` | Sell form text inputs |
| `CustomAutocomplete` | `lib/shared/widgets/custom_autocomplete.dart` | State/City selection in sell form |
| `CustomMultipleUploadWidget` | `lib/shared/widgets/custom_multiple_upload_widget.dart` | File uploads in sell form |
| `CustomButton` | `lib/shared/widgets/custom_button.dart` | Submit button in sell form |
| `CustomYearPicker` | `lib/shared/widgets/custom_year_picker.dart` | Manufacturing year picker |
| `CustomDatePicker` | `lib/shared/widgets/custom_date_picker.dart` | Insurance date, offer end date |
| `CustomTimePicker` | `lib/shared/widgets/custom_time_picker.dart` | Offer end time |
| `LoadingOverlay` | `lib/shared/widgets/loading_widget.dart` | Sell form submission overlay |
| `ShimmerWidget` | `lib/shared/widgets/shimmer_widget.dart` | Loading skeletons |
| `SizeConfig` | `lib/shared/widgets/size_config.dart` | Responsive sizing |
| `CustomImageContainer` | `lib/shared/widgets/custom_image_container.dart` | Detail view image carousel |
| `PlatformRefreshIndicator` | `lib/shared/widgets/platform_refresh_indicator.dart` | Pull-to-refresh |

---

## 10. State Management

### Framework: **GetX**

All vendor-related state is managed through `AuctionController` (GetX controller).

### Observable State Variables (Vendor-Relevant)

```dart
// ==================== Categories (Buy/Sell Landing) ====================
final RxList<ApprovedVehicleCategory> approvedCategories = <ApprovedVehicleCategory>[].obs;
final RxBool isLoadingApprovedCategories = false.obs;
final RxString approvedCategoriesError = ''.obs;

// ==================== Listings (BUY Flow) ====================
final RxList<ApprovedVehicleListing> approvedListings = <ApprovedVehicleListing>[].obs;
final RxBool isLoadingApprovedListings = false.obs;
final RxInt approvedListingsPage = 1.obs;
final RxBool hasMoreApprovedListings = true.obs;

// ==================== Sell Form State ====================
// Text Controllers
final sellCategoryNameC = TextEditingController();
final sellCategoryCodeC = TextEditingController();
final sellRegNumberC = TextEditingController();
final sellStateC = TextEditingController();
final sellCityC = TextEditingController();
final sellBrandC = TextEditingController();
final sellChassisC = TextEditingController();
final sellAssetDescC = TextEditingController();
final sellOwnerMobileC = TextEditingController();
final sellPriceC = TextEditingController();

// Observable Selections
final RxString sellFitness = ''.obs;
final RxString sellOriginalInvoice = ''.obs;
final RxString sellMfgYear = ''.obs;
final RxString sellInsurance = ''.obs;
final Rxn<DateTime> sellInsuranceDate = Rxn<DateTime>();
final RxString sellGSTApplicability = ''.obs;
final Rxn<DateTime> sellOfferEndDate = Rxn<DateTime>();
final Rxn<TimeOfDay> sellOfferEndTime = Rxn<TimeOfDay>();

// File Uploads
final RxList<PlatformFile> sellInsuranceFiles = <PlatformFile>[].obs;
final RxList<PlatformFile> sellRCFiles = <PlatformFile>[].obs;
// Note: Vehicle images stored separately in sellVehicleImages

// Loading State
final RxBool isSellFormLoading = false.obs;

// Validation Errors
final RxString sellCategoryError = ''.obs;
final RxString sellRegNumberError = ''.obs;
final RxString sellStateError = ''.obs;
final RxString sellCityError = ''.obs;
final RxString sellFitnessError = ''.obs;
final RxString sellBrandError = ''.obs;
final RxString sellOriginalInvoiceError = ''.obs;
final RxString sellAssetDescError = ''.obs;
final RxString sellMfgYearError = ''.obs;
final RxString sellInsuranceError = ''.obs;
final RxString sellInsuranceFilesError = ''.obs;
final RxString sellRCFilesError = ''.obs;
final RxString sellGSTApplicabilityError = ''.obs;
final RxString sellVehicleImagesError = ''.obs;
final RxString sellOfferEndDateError = ''.obs;
final RxString sellOfferEndTimeError = ''.obs;
final RxString sellOwnerMobileError = ''.obs;
final RxString sellPriceError = ''.obs;
```

### Controller Methods (Vendor-Relevant)

| Method | Purpose | Called From |
|--------|---------|------------|
| `fetchApprovedCategories()` | Load categories from API | Buy/Sell Landing `initState` |
| `onApprovedCategoryTap(category)` | Navigate to listings | BUY button handler |
| `fetchApprovedVehicleListings({isRefresh})` | Load/refresh listings | Listings screen |
| `loadMoreApprovedListings()` | Load next page | Scroll threshold |
| `onApprovedListingTap(listing)` | Navigate to detail | Listing card tap |
| `submitApprovedVehicleSellForm()` | Submit sell form | Submit button |
| `validateSellForm()` | Validate all fields | Before submission |
| `validateSell*()` (16 methods) | Individual field validation | On field change |
| `clearSellForm()` | Reset all form fields | On exit / after submit |
| `updateApprovedVehicleUserInterest()` | Post-payment update | Payment success callback |
| `setSellInsuranceFiles(files)` | Set insurance file list | File picker callback |
| `setSellRCFiles(files)` | Set RC file list | File picker callback |
| `setSellVehicleImages(files)` | Set vehicle image list | File picker callback |

### Controller Dependencies

```
AuctionController
    ├── StorageService (user_id, payment context)
    ├── ApiRepository (API calls)
    ├── PaymentController (PayU integration)
    ├── BuySellController (states, cities, autocomplete)
    └── CategoryController (profile data, dashboard images)
```

---

## 11. Business Rules & Validation

### 11.1 Sell Form Business Rules

| Rule | Implementation |
|------|---------------|
| Category is pre-filled and readonly | `CustomTextFormField(enabled: false)` |
| Category code passed from navigation args | `Get.arguments['categoryCode']` |
| Brand is free text (not autocomplete) | Direct text input, no brand selection |
| Chassis number is optional | No validation required |
| Insurance upload is optional | No validation required |
| RC upload is optional | No validation required |
| Insurance date is optional | No validation required |
| Offer end date format: YYYY-MM-DD | `DateFormat('yyyy-MM-dd')` |
| Offer end time format: HH:MM:SS | `'{hour}:{minute}:00'` |
| Default Yes/No values: "No" if empty | `sellFitness.value.isEmpty ? 'No' : sellFitness.value` |
| Form clears on back navigation | `WillPopScope` + `clearSellForm()` |
| Form initializes once per screen | `_isInitialized` static flag |
| Loading overlay during submission | `LoadingOverlay` widget |

### 11.2 Booking Business Rules

| Rule | Detail |
|------|--------|
| A vehicle can only be booked once | `is_booked` checked client-side and server-side |
| Booked vehicles filtered from listings | Client-side `.where((l) => l.isBooked != 'yes')` |
| Subscription must exist | If `categorySubscription == null` → Snackbar error, action blocked |
| Payment required before booking | PayU payment flow must complete successfully |
| Button state persists | Once booked, button shows "Booked" (disabled) |

### 11.3 Inspection Business Rules

| Rule | Detail |
|------|--------|
| Inspection can be requested independently of booking | Both actions available simultaneously |
| Inspection subscription must exist | If `inspectionSubscription == null` → Snackbar error |
| Inspection-requested vehicles stay in listings | Not filtered out (unlike booked) |
| Payment required before inspection request | PayU payment flow must complete |

### 11.4 Status Transitions (Vendor Perspective)

```
Vehicle Submitted (SELL Form)
    │
    ▼
Backend Review (Vendor cannot see this)
    │
    ├── Approved → Appears in BUY listings
    └── Rejected → Not visible to anyone

Vehicle in Listings (Vendor sees in BUY flow)
    │
    ├── Vendor taps "Book Now"
    │   ├── Payment Success
    │   │   ├── API: is_booked="yes", is_interested="yes"
    │   │   ├── Button → "Booked" (disabled)
    │   │   ├── Vehicle removed from listings (client filter)
    │   │   └── Appears in "My Bookings"
    │   └── Payment Failure
    │       └── Error snackbar, no state change
    │
    └── Vendor taps "Inspection"
        ├── Payment Success
        │   ├── API: is_booked="no", is_interested="yes"
        │   ├── Button → "Requested" (disabled)
        │   ├── Vehicle stays in listings
        │   └── Appears in "My Inspections"
        └── Payment Failure
            └── Error snackbar, no state change
```

---

## 12. Payment Flow (Vendor)

### 12.1 Book Now Payment

```
Vendor taps "Book Now" on detail screen
    │
    ▼
Check: categorySubscription exists?
    │
    ├── No → Snackbar: "Category subscription not available" → STOP
    │
    ▼
Show Payment Dialog
    │
    ├── Title: "Book Vehicle"
    ├── Description: "Pay to book this vehicle and access full details"
    ├── Amount: categorySubscription.subscriptionAmount (e.g., ₹5,000)
    ├── Button: "Pay Now"
    │
    ▼
Vendor taps "Pay Now"
    │
    ├── Close dialog
    │
    ├── Save payment context to StorageService:
    │   ├── approved_vehicle_id = listing.approvedVehicleId
    │   ├── approved_vehicle_subscription_type = "category"
    │   ├── pending_auction_id = "approved_vehicle_category"
    │   └── pending_auction_title = "Approved Vehicle - {registrationNumber}"
    │
    ▼
PaymentController.startPayment(planCode: categorySubscription.apprVehCommonSubPlan)
    │
    ├── PayU SDK launches
    │
    ├── SUCCESS
    │   ├── PaymentController stores payment_id
    │   ├── Calls updateApprovedVehicleUserInterest(
    │   │     approvedVehicleId: id,
    │   │     subscriptionType: "category"
    │   │   )
    │   ├── API: POST /appr-veh-user-interest
    │   │   { user_id, approved_vehicle_id, is_interested: "yes", is_booked: "yes" }
    │   ├── Refresh listings (fetchApprovedVehicleListings)
    │   └── Snackbar: Success message
    │
    └── FAILURE
        └── Snackbar: "Payment failed"
```

### 12.2 Inspection Payment

```
Vendor taps "Inspection" on detail screen
    │
    ▼
Check: inspectionSubscription exists?
    │
    ├── No → Snackbar: "Inspection subscription not available" → STOP
    │
    ▼
Show Payment Dialog
    │
    ├── Title: "Request Vehicle Inspection"
    ├── Description: "Pay to request professional inspection for this vehicle"
    ├── Amount: inspectionSubscription.inspectionAmount (e.g., ₹2,000)
    ├── Button: "Pay Now"
    │
    ▼
Vendor taps "Pay Now"
    │
    ├── Close dialog
    │
    ├── Save payment context to StorageService:
    │   ├── approved_vehicle_subscription_type = "inspection"
    │   ├── pending_auction_id = "approved_vehicle_inspection"
    │   └── pending_auction_title = "Vehicle Inspection - {registrationNumber}"
    │
    ▼
PaymentController.startPayment(planCode: inspectionSubscription.categoryPlan)
    │
    ├── SUCCESS
    │   ├── Calls updateApprovedVehicleUserInterest(
    │   │     approvedVehicleId: id,
    │   │     subscriptionType: "inspection"
    │   │   )
    │   ├── API: POST /appr-veh-user-interest
    │   │   { user_id, approved_vehicle_id, is_interested: "yes", is_booked: "no" }
    │   ├── Refresh listings
    │   └── Snackbar: Success
    │
    └── FAILURE
        └── Snackbar: "Payment failed"
```

---

## 13. Dependencies Between Modules

### Module Dependency Graph

```
┌─────────────────────────────────────────────────────────────┐
│                  VENDOR APPROVED VEHICLES                     │
│                    DEPENDENCY MAP                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐     ┌──────────────────────┐              │
│  │ Auth Module   │────►│ StorageService        │              │
│  │ (Login/Reg)   │     │ - user_id             │              │
│  │               │     │ - user_type           │              │
│  └──────────────┘     │ - payment context     │              │
│                        └──────────┬───────────┘              │
│                                   │                          │
│  ┌──────────────┐                │                          │
│  │ Location      │                │                          │
│  │ Module        │     ┌──────────▼───────────┐              │
│  │ - States API  │────►│ AuctionController     │              │
│  │ - Cities API  │     │ (Central Controller)  │              │
│  └──────────────┘     │                       │              │
│                        │  ┌─────────────────┐  │              │
│  ┌──────────────┐     │  │ Buy/Sell Form   │  │              │
│  │ BuySell       │────►│  │ State Mgmt      │  │              │
│  │ Controller    │     │  └─────────────────┘  │              │
│  │ - States      │     │                       │              │
│  │ - Cities      │     │  ┌─────────────────┐  │              │
│  │ - Autocomplete│     │  │ Approved Veh    │  │              │
│  └──────────────┘     │  │ Categories      │  │              │
│                        │  │ Listings        │  │              │
│  ┌──────────────┐     │  │ User Interest   │  │              │
│  │ Payment       │◄───►│  └─────────────────┘  │              │
│  │ Controller    │     │                       │              │
│  │ - PayU SDK    │     └───────────────────────┘              │
│  │ - Plan codes  │                                            │
│  └──────────────┘                                            │
│                                                              │
│  ┌──────────────┐     ┌──────────────────────┐              │
│  │ Category      │────►│ CustomDrawer          │              │
│  │ Controller    │     │ - Role-based routing  │              │
│  │ - Profile     │     │ - Vendor → Buy/Sell   │              │
│  │ - Dashboard   │     │ - Customer → Category │              │
│  └──────────────┘     └──────────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Details

| Module | Depends On | What's Used |
|--------|-----------|-------------|
| **AuctionController** | `StorageService` | `getUserId()`, payment context read/write |
| **AuctionController** | `ApiRepository` | All API calls |
| **AuctionController** | `PaymentController` | `startPayment(planCode)` |
| **AuctionController** | `BuySellController` | State/city data for sell form |
| **Sell Form** | `BuySellController` | `loadStatesIfNeeded()`, `selectStateForSell()`, `loadCitiesForSell()`, `selectCityForSell()` |
| **Sell Form** | `BuySellController` | `states`, `cities` RxLists for autocomplete |
| **Buy/Sell Landing** | `AuctionController` | `fetchApprovedCategories()`, `approvedCategories` |
| **Listings** | `AuctionController` | `fetchApprovedVehicleListings()`, pagination state |
| **Detail** | `PaymentController` | PayU payment flow |
| **Detail** | `AuctionController` | `updateApprovedVehicleUserInterest()` |
| **Drawer** | `StorageService` | `getUserType()` for role-based routing |
| **Drawer** | `CategoryController` | `userProfileData` as fallback for user type |

---

## 14. Edge Cases & Error Handling

### 14.1 Sell Form Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Category code is empty in arguments | Form still renders but category field shows empty; submission may fail validation |
| State name doesn't match any state ID | Falls back to using text value directly as `stateCode` |
| City name doesn't match any city | Uses `CityItem(cityId: '', cityName: '', stateId: '')` (empty ID) |
| User navigates back without submitting | `clearSellForm()` called in `WillPopScope` |
| Form submitted while already loading | Guarded by `isSellFormLoading` overlay (blocks interaction) |
| Network error during submission | Caught in try-catch, snackbar shown, stays on form |
| File picker returns empty list | Validation catches "Vehicle images are required" |
| `_isInitialized` static flag persists across navigations | Reset to `false` in `WillPopScope` on back |
| Same category re-selected | `clearSellForm()` only called if category code changed |

### 14.2 Buy Flow Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Booked vehicle in API response | Filtered out client-side: `.where((l) => l.isBooked != 'yes')` |
| Subscription is null | Snackbar error, payment dialog not shown |
| Payment fails after PayU SDK | Snackbar error, no state change |
| Network error during listings fetch | Error state shown with retry option |
| No images available for a listing | "No Images Available" placeholder in detail |
| Scroll to load more with no more data | `hasMoreApprovedListings` guard prevents API call |
| Rapid scrolling triggers multiple load-more | `_isLoadingMore` flag prevents duplicate requests |

### 14.3 Navigation Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Deep link to Buy/Sell with no navigation stack | Back button falls back to `/approved-vehicle-category` |
| User type not in storage | Falls back to profile API data |
| Profile data unavailable | Defaults to CUSTOMER routing |
| User type is legacy 'user' value | Treated as invalid, falls back to profile data |

---

## 15. Reusable Logic & Utilities

### 15.1 Shared Services

| Service | Path | Vendor Usage |
|---------|------|-------------|
| `StorageService` | `lib/core/services/storage_service.dart` | User ID, user type, payment context persistence |
| `ApiRepository` | `lib/core/api/api_repository.dart` | Centralized API calls |
| `NetworkService` | `lib/core/services/network_service.dart` | HTTP client with interceptors |
| `PaymentController` | `lib/modules/payu_sdk_payment/controllers/payment_controller.dart` | PayU payment processing |

### 15.2 Shared Controllers

| Controller | Path | Vendor Usage |
|-----------|------|-------------|
| `AuctionController` | `lib/modules/auction/controllers/auction_controller.dart` | All vendor business logic |
| `BuySellController` | `lib/modules/buy_and_sell/controllers/buy_sell_controller.dart` | States, cities for sell form |
| `CategoryController` | `lib/modules/category/controllers/category_controller.dart` | Profile data fallback |

### 15.3 Reusable Patterns

#### Autocomplete State/City Pattern

```dart
// Used in sell form for state selection
CustomAutocomplete<StateItem>(
  labelText: 'State *',
  textEditingController: controller.sellStateC,
  allOptions: buySellController.states,
  optionsBuilder: (textEditingValue) async {
    if (textEditingValue.text.isEmpty) return buySellController.states;
    return buySellController.states
        .where((s) => s.stateName.toLowerCase().contains(textEditingValue.text.toLowerCase()))
        .toList();
  },
  displayStringForOption: (option) => option.stateName,
  onSelected: (value) {
    controller.sellStateC.text = value.stateName;
    buySellController.selectStateForSell(value);
    buySellController.loadCitiesForSell(value.stateId);
    controller.validateSellState();
  },
)
```

#### Yes/No Toggle Pattern

```dart
// Reusable toggle for boolean fields
_buildYesNoField(
  context: context,
  label: 'Fitness *',
  currentValue: controller.sellFitness.value,
  onYesPressed: () {
    controller.sellFitness.value = 'Yes';
    controller.validateSellFitness();
  },
  onNoPressed: () {
    controller.sellFitness.value = 'No';
    controller.validateSellFitness();
  },
  errorText: controller.sellFitnessError.value.isEmpty ? null : controller.sellFitnessError.value,
  yesText: 'Yes',
  noText: 'No',
)
```

#### File Upload Pattern

```dart
// Reusable file upload widget
CustomMultipleUploadWidget(
  title: 'Vehicle Images *',
  onFilesSelected: controller.setSellVehicleImages,
  errorText: controller.sellVehicleImagesError.value.isEmpty ? null : controller.sellVehicleImagesError.value,
  maxFiles: 10,
  maxSizeInMB: 12,
)
```

### 15.4 Utility Functions

| Function | Location | Purpose |
|----------|----------|---------|
| `formatDate(dateStr)` | Detail view | ISO date → `dd MMM yyyy` |
| `NumberFormat('#,##,###')` | Detail view | Indian currency formatting |
| `DateFormat('yyyy-MM-dd')` | Sell form | Date → API format |
| `'{hour}:{minute}:00'` | Sell form | Time → API format (HH:MM:SS) |
| `imageUrl.endsWith('.svg')` | BuySellItemCard | SVG vs raster detection |

---

## 16. Architecture Summary

### Component Architecture (Vendor)

```
┌──────────────────────────────────────────────────────────────┐
│                     VENDOR ARCHITECTURE                        │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  PRESENTATION LAYER                                           │
│  ├── ApprovedVehicleBuySellView (Landing)                     │
│  │   └── BuySellItemCard (Category list items)                │
│  ├── ApprovedVehicleSellForm (Sell form)                      │
│  │   ├── CustomTextFormField (text inputs)                    │
│  │   ├── CustomAutocomplete (state/city)                      │
│  │   ├── Yes/No Toggle (inline widget)                        │
│  │   ├── CustomYearPicker                                     │
│  │   ├── CustomDatePicker                                     │
│  │   ├── CustomTimePicker                                     │
│  │   ├── CustomMultipleUploadWidget (file uploads)            │
│  │   └── LoadingOverlay (submission state)                    │
│  ├── ApprovedVehicleListingsView (BUY listings)               │
│  │   └── ApprovedVehicleListingCard (grid items)              │
│  └── ApprovedVehicleDetailView (Vehicle detail)               │
│      ├── CustomImageContainer (image carousel)                │
│      └── Payment Dialog (booking/inspection)                  │
│                                                               │
│  CONTROLLER LAYER                                             │
│  ├── AuctionController (central)                              │
│  │   ├── Categories state + fetch                             │
│  │   ├── Listings state + pagination                          │
│  │   ├── Sell form state + validation + submission            │
│  │   └── User interest update (post-payment)                  │
│  ├── BuySellController (dependency)                           │
│  │   └── States + Cities for autocomplete                     │
│  └── PaymentController (dependency)                           │
│      └── PayU SDK integration                                 │
│                                                               │
│  SERVICE LAYER                                                │
│  ├── ApiRepository → NetworkService → HTTP                    │
│  ├── StorageService (local persistence)                       │
│  └── CustomDrawer (role-based navigation)                     │
│                                                               │
│  DATA LAYER                                                   │
│  ├── ApprovedVehicleCategory model                            │
│  ├── ApprovedVehicleListing model                             │
│  ├── StateItem model                                          │
│  └── CityItem model                                           │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow (Vendor Sell)

```
User Input → TextEditingControllers / Rx observables
    │
    ▼
Validation (16 individual validators)
    │
    ▼
FormData construction (text fields + file uploads)
    │
    ▼
ApiRepository.submitApprovedVehicleSellForm(formData)
    │
    ▼
NetworkService (Dio with interceptors)
    │
    ▼
POST /api/v1/approved-veh/appr-veh-submit (multipart/form-data)
    │
    ▼
Response → Success/Failure handling
```

### Data Flow (Vendor Buy)

```
Category selection (BUY tap)
    │
    ▼
API: POST /appr-veh-listings {category_type, page, limit}
    │
    ▼
Response → ApprovedVehicleListingResponse.fromJson()
    │ (filters out is_booked == "yes" client-side)
    ▼
approvedListings observable list updated
    │
    ▼
UI rebuilds via Obx()
    │
    ▼
User taps listing → Navigate to detail
    │
    ▼
User taps Book/Inspection → Payment dialog → PayU
    │
    ▼
Payment success → updateApprovedVehicleUserInterest()
    │
    ▼
API: POST /appr-veh-user-interest
    │
    ▼
Listings refreshed → UI updates
```

---

## 17. Suggested Improvements

### 17.1 Current Limitations

1. **No direct vendor dashboard** — Vendors land on the same Buy/Sell card list; there's no vendor-specific dashboard showing their submitted vehicles and their approval status
2. **No vehicle submission tracking** — After submitting a vehicle via the sell form, the vendor cannot track its approval status (pending/approved/rejected)
3. **No edit/delete submitted vehicles** — Once submitted, the vendor cannot edit or withdraw their vehicle listing
4. **No vendor-specific analytics** — No data on how many views their listed vehicles received, how many bookings, etc.
5. **Brand is free text** — No validation or autocomplete for brand names, which can lead to inconsistent data
6. **State/city resolution is fragile** — If the text doesn't match exactly, the code falls back to empty IDs

### 17.2 UI/UX Improvements

1. **Vendor Dashboard** — Add a dashboard showing: submitted vehicles count, approved count, pending count, rejected count
2. **Submission Status Tracker** — After selling, show a status tracker (Submitted → Under Review → Approved/Rejected)
3. **Vehicle Edit Capability** — Allow vendors to edit their submitted vehicles before approval
4. **Image Preview Before Upload** — Show thumbnails of selected images before form submission
5. **Progress Indicator on Multi-Step Form** — Break the long sell form into steps with a progress indicator
6. **Auto-save Draft** — Save form data as draft periodically to prevent data loss on accidental navigation
7. **Registration Number Auto-fill** — Use registration number to auto-populate brand, year, etc. from RTO data
8. **Better Empty States** — More informative empty states with CTAs (e.g., "No vehicles listed yet. Sell your first vehicle!")

### 17.3 Performance Optimizations

1. **Debounce validation** — Current validation triggers on every keystroke; debounce to 300ms
2. **Compress images before upload** — Large images (12MB) should be compressed client-side
3. **Cache states/cities** — Location data should be cached locally to avoid repeated API calls
4. **Lazy load sell form sections** — Load city dropdown only when state is selected
5. **Optimistic UI for submission** — Show success state immediately while API processes in background

### 17.4 Code Refactoring

1. **Extract Sell Form Controller** — Separate `ApprovedVehicleSellController` from monolithic `AuctionController`
2. **Extract Buy Flow Controller** — Separate `ApprovedVehicleBuyController` for listings and detail management
3. **Create Form Validation Mixin** — Extract common validation patterns into a reusable mixin
4. **Create Base Form View** — Generic form view with built-in validation display, loading overlay, and submission handling
5. **Standardize Yes/No Toggle** — Extract into a shared `YesNoToggleField` widget (currently built inline)
6. **Create Vendor Repository** — Separate API layer for vendor-specific endpoints

### 17.5 Reusability for New Application

When rebuilding the Vendor Approved Vehicles module in a new application:

1. **Preserve the API contract** — All endpoints, request payloads, and response structures must remain the same
2. **Preserve the form field list** — All 18+ fields with their validation rules
3. **Preserve the state/city dependency** — State selection must trigger city loading
4. **Preserve the payment context pattern** — Save context → Payment SDK → Post-payment API call
5. **Preserve the client-side booking filter** — Filter `is_booked == "yes"` from listings
6. **Preserve the role-based routing** — Vendor gets Buy/Sell landing, Customer gets Category grid
7. **Implement the same pagination** — 20 items per page, scroll threshold at 90% or 50px
8. **Keep the multipart/form-data submission** — File uploads must use multipart encoding
9. **Keep the Yes/No field pattern** — Binary choices use toggle buttons, not checkboxes
10. **Keep the form lifecycle** — Initialize once, clear on exit, loading overlay during submission

---

## File Reference Summary

| File | Purpose | Vendor Relevance |
|------|---------|-----------------|
| `lib/modules/auction/views/aproved_vechicle_buy_sell.dart` | **Buy/Sell Landing** | Primary vendor entry point |
| `lib/modules/auction/views/approved_vehicle_sell_form.dart` | **Sell Form** | Core vendor sell functionality |
| `lib/modules/auction/views/approved_vehicle_listings_view.dart` | **Listings Grid** | Vendor BUY flow |
| `lib/modules/auction/views/approved_vehicle_detail_view.dart` | **Vehicle Detail** | Vendor BUY → Book/Inspect |
| `lib/modules/auction/views/approved_vehicle_user_booked_view.dart` | **My Bookings/Inspections** | Vendor history view |
| `lib/modules/auction/controllers/auction_controller.dart` | **Controller** | All business logic & state |
| `lib/modules/auction/models/approved_vehicle_category_model.dart` | **Category Model** | Buy/Sell landing data |
| `lib/modules/auction/models/approved_vehicle_listing_model.dart` | **Listing Model** | BUY flow data |
| `lib/modules/buy_and_sell/widgets/buy_sell_item_card.dart` | **Card Widget** | Vendor landing UI component |
| `lib/shared/widgets/custom_drawer.dart` | **Drawer** | Role-based vendor routing |
| `lib/core/api/api_constant.dart` | **API Constants** | Endpoint definitions |
| `lib/core/api/api_repository.dart` | **API Repository** | API call implementations |
| `lib/core/services/storage_service.dart` | **Storage** | User type persistence |
| `lib/modules/buy_and_sell/controllers/buy_sell_controller.dart` | **BuySell Controller** | State/City data dependency |
| `lib/routes/app_routes.dart` | **Routes** | Path constants |
| `lib/routes/app_pages.dart` | **Route Pages** | Route → Screen bindings |
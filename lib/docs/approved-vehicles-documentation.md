# Approved Vehicles Module — Complete Documentation

> **Purpose:** This document provides a comprehensive specification of the Approved Vehicles functionality from the Vahaan Bazar mobile application. It is designed to enable another developer/team to rebuild the same business logic and workflows with a completely different UI/UX design.

---

## Table of Contents

1. [Functional Overview](#1-functional-overview)
2. [API Documentation](#2-api-documentation)
3. [Data Models](#3-data-models)
4. [UI Components Documentation](#4-ui-components-documentation)
5. [Screens & User Flows](#5-screens--user-flows)
6. [State Management](#6-state-management)
7. [Business Rules](#7-business-rules)
8. [Role-Based Access Control (RBAC)](#8-role-based-access-control-rbac)
9. [Reusable Logic](#9-reusable-logic)
10. [Navigation & Routes](#10-navigation--routes)
11. [Suggested Improvements](#11-suggested-improvements)

---

## 1. Functional Overview

### What is Approved Vehicles?

Approved Vehicles is a **marketplace module** within the Vahaan Bazar platform where users can browse, book, and request inspections for pre-approved/verified commercial vehicles (trucks, buses, tippers, excavators, etc.). It also allows vehicle owners to list their vehicles for sale through a sell form.

### Complete Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    USER JOURNEY                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Entry Point (Home/Drawer)                                │
│       │                                                      │
│       ▼                                                      │
│  2. Category Selection Screen                                │
│     (Browse vehicle categories: Truck, Bus, Tipper, etc.)    │
│       │                                                      │
│       ├──► 3a. Tap Category → Listings Grid                  │
│       │         │                                            │
│       │         ▼                                            │
│       │    4. Vehicle Listings (Paginated Grid)               │
│       │         │                                            │
│       │         ▼                                            │
│       │    5. Vehicle Detail Screen                           │
│       │         │                                            │
│       │         ├──► "Book Now" → Payment Dialog → PayU      │
│       │         │         │                                  │
│       │         │         ▼                                  │
│       │         │    Payment Success → User Interest Update   │
│       │         │         │                                  │
│       │         │         ▼                                  │
│       │         │    Vehicle marked as "Booked"               │
│       │         │                                            │
│       │         └──► "Inspection" → Payment Dialog → PayU    │
│       │                   │                                  │
│       │                   ▼                                  │
│       │              Payment Success → User Interest Update   │
│       │                   │                                  │
│       │                   ▼                                  │
│       │              Inspection "Requested"                   │
│       │                                                      │
│       └──► 3b. "Sell Your Vehicle" → Sell Form               │
│                    │                                         │
│                    ▼                                         │
│              Submit Vehicle (Multipart FormData)              │
│                                                              │
│  6. My Bookings / My Inspections (via Drawer)                │
│     (View user's booked and inspected vehicles)              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### User Roles

| Role | Internal Code | Capabilities |
|------|--------------|-------------|
| **Buyer/Dealer** | `CUSTOMER` | Browse categories, view listings, book vehicles, request inspections, pay via PayU |
| **Vehicle Owner/Seller** | `VENDOR` | Submit vehicles for sale via the sell form, view buy/sell landing page |
| **Internal Team** | `INTERNAL` | Access internal inspection/valuation forms, field inspection operations |
| **Admin** (backend only) | N/A | Manages categories, approves/rejects vehicles, manages subscription plans, processes bookings |

> **Important:** User roles are stored as `user_type` in local storage and retrieved from the profile API (`user_type` field). The role determines navigation paths, drawer menu items, and accessible screens. See [Section 8: Role-Based Access Control (RBAC)](#8-role-based-access-control-rbac) for complete details.

### Business Purpose

- Provides a curated marketplace of **pre-verified/approved** commercial vehicles
- Monetizes through **booking subscriptions** and **inspection fees**
- Integrates with **PayU payment gateway** for transactions
- Supports **document management** (RC, insurance, images)

---

## 2. API Documentation

### Base URL Pattern

All approved vehicle APIs use the prefix:

```
/api/v1/approved-veh
```

**Authentication:** All endpoints require authentication via the app's standard auth headers (managed by `NetworkService`/`ApiRepository`).

**Request Pattern:** All endpoints use `POST` method with JSON body (except submit which uses `multipart/form-data`).

---

### 2.1 Get Approved Vehicle Categories

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-categories`
- **Purpose:** Fetch all active approved vehicle categories (e.g., Truck, Bus, Tipper, Excavator)

#### Request Body

```json
{
  "user_id": "string (required)",
  "status": "Active (default)",
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
        "icon_name": "https://cdn.example.com/icons/truck.png",
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

#### Fields Description

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Category unique identifier |
| `category_code` | string | Code used to filter listings (e.g., `"TRUCK"`, `"BUS"`) |
| `category_name` | string | Display name for the category |
| `status` | string | Category status (`"Active"`, `"Inactive"`) |
| `subscription_amount` | double | Amount required to book a vehicle in this category |
| `category_plan` | string | PayU plan code for subscription payment |
| `sorting_order` | int | Display order in the grid |
| `icon_name` | string | URL to category icon image |
| `approved_veh_available_count` | int | Number of available approved vehicles in this category |

---

### 2.2 Get Approved Vehicle Listings

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-listings`
- **Purpose:** Fetch paginated list of approved vehicles with optional filters

#### Request Body

```json
{
  "user_id": "string (required)",
  "status": "approved (default)",
  "category_type": "TRUCK (optional)",
  "state_code": "MH (optional)",
  "city_code": "MUM (optional)",
  "min_price": 100000 (optional),
  "max_price": 5000000 (optional),
  "year_from": 2018 (optional),
  "year_to": 2024 (optional),
  "search_registration": "MH01 (optional)",
  "page": 1,
  "limit": 20
}
```

#### Query Parameters / Filters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | Yes | Authenticated user ID |
| `status` | string | No | Vehicle status filter (default: `"approved"`) |
| `category_type` | string | No | Category code to filter by |
| `state_code` | string | No | Filter by state |
| `city_code` | string | No | Filter by city |
| `min_price` | double | No | Minimum price filter |
| `max_price` | double | No | Maximum price filter |
| `year_from` | int | No | Manufacturing year range start |
| `year_to` | int | No | Manufacturing year range end |
| `search_registration` | string | No | Search by registration number |
| `page` | int | Yes | Current page number (default: 1) |
| `limit` | int | Yes | Items per page (default: 20) |

#### Response

```json
{
  "data": {
    "listings": [
      {
        "id": 101,
        "approved_vehicle_id": "AVH-2024-001",
        "category_type": "TRUCK",
        "registration_number": "MH01AB1234",
        "state_name": "Maharashtra",
        "city_name": "Mumbai",
        "fitness_available": "Yes",
        "brand": "Tata",
        "chassis_number": "MAT1234567890",
        "original_invoice_available": "Yes",
        "owner_mobile_number": "9876543210",
        "asset_description": "Tata Signa 2823.T 6x4",
        "year_of_manufacturing": 2022,
        "vehicle_insurance_date": "2025-03-15",
        "price": 2500000.00,
        "vehicle_status": "approved",
        "gst_applicable": "Yes",
        "offer_end_date": "2024-12-31",
        "offer_end_time": "23:59:59",
        "inserted_at": "2024-06-01T10:00:00Z",
        "modified_at": "2024-06-15T12:00:00Z",
        "inserted_by": "admin",
        "modified_by": "admin",
        "is_booked": "no",
        "inspection_requested": "no",
        "inspection_subscription": {
          "inspection_amount": 2000.00,
          "category_plan": "INSPECT_TRUCK_001"
        },
        "category_subscription": {
          "subscription_amount": 5000.00,
          "appr_veh_common_sub_plan": "SUB_TRUCK_001"
        },
        "files": {
          "images": [
            {
              "id": 1,
              "file_type": "image",
              "file_url": "https://cdn.example.com/vehicles/img1.jpg",
              "status": "active",
              "uploaded_at": "2024-06-01T10:00:00Z"
            }
          ],
          "rc_documents": [
            {
              "id": 2,
              "file_type": "rc_document",
              "file_url": "https://cdn.example.com/vehicles/rc1.pdf",
              "status": "active",
              "uploaded_at": "2024-06-01T10:00:00Z"
            }
          ],
          "insurance_documents": [
            {
              "id": 3,
              "file_type": "insurance",
              "file_url": "https://cdn.example.com/vehicles/ins1.pdf",
              "status": "active",
              "uploaded_at": "2024-06-01T10:00:00Z"
            }
          ]
        }
      }
    ],
    "total_count": 150
  }
}
```

#### Important Notes

- **Booked vehicles are filtered out client-side:** The response may include vehicles where `is_booked == "yes"`, but the app filters these out in `ApprovedVehicleListingResponse.fromJson()`:
  ```dart
  .where((listing) => listing.isBooked != 'yes')
  ```
- **Pagination:** The app tracks `page` and checks `listings.length < total_count` to determine if more pages exist (`hasMoreApprovedListings`).
- **Scroll threshold:** Load-more is triggered at 90% scroll or 50px from bottom, whichever is less.

---

### 2.3 Submit Approved Vehicle (Sell Form)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-submit`
- **Purpose:** Submit a vehicle for sale (vehicle owner lists their vehicle)
- **Content-Type:** `multipart/form-data`

#### Request Body (FormData)

The form includes vehicle details and file uploads (images, RC documents, insurance documents). The exact fields are collected from the sell form and submitted as `dio.FormData`.

```json
// FormData fields include:
{
  "user_id": "string",
  "category_name": "string",
  "registration_number": "string",
  "chassis_number": "string",
  "brand": "string",
  "year_of_manufacturing": "number",
  "price": "number",
  "state_code": "string",
  "city_code": "string",
  "fitness_available": "Yes/No",
  "original_invoice_available": "Yes/No",
  "vehicle_insurance_date": "date string",
  "gst_applicable": "Yes/No",
  "asset_description": "string",
  // File uploads (images, rc_documents, insurance_documents)
}
```

#### Response

```json
{
  "success": true,
  "message": "Vehicle submitted successfully"
}
```

---

### 2.4 Update User Interest (Post-Payment)

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-user-interest`
- **Purpose:** Mark a vehicle as booked or inspection-requested after successful payment

#### Request Body

```json
{
  "user_id": "string (required)",
  "approved_vehicle_id": "string (required)",
  "is_interested": "yes/no",
  "is_booked": "yes/no"
}
```

#### Response

```json
{
  "data": {
    "subscription_id": 1001,
    "approved_vehicle_id": "AVH-2024-001",
    "user_id": "user_123",
    "inspection_requested": "yes",
    "is_booked": "no",
    "status": "active"
  }
}
```

#### Business Logic

| Action | `is_interested` | `is_booked` |
|--------|----------------|-------------|
| **Book Now** | `"yes"` | `"yes"` |
| **Inspection Request** | `"yes"` | `"no"` |

After calling this API, the controller automatically refreshes the approved vehicle listings to reflect updated status.

---

### 2.5 Get User Booked/Inspected Vehicles

- **Method:** `POST`
- **Endpoint:** `/api/v1/approved-veh/appr-veh-user-booked`
- **Purpose:** Fetch vehicles that the user has booked or requested inspection for

#### Request Body

```json
{
  "user_id": "string (required)",
  "booked_vehicles": "yes (optional - for my bookings)",
  "inspection_requested": "yes (optional - for my inspections)",
  "page": 1,
  "limit": 20
}
```

#### Usage Variants

| View | `booked_vehicles` | `inspection_requested` |
|------|-------------------|----------------------|
| **My Bookings** | `"yes"` | not sent |
| **My Inspections** | not sent | `"yes"` |

#### Response

```json
{
  "data": {
    "vehicles": [
      // Same structure as ApprovedVehicleListing (see 2.2)
    ],
    "total_count": 5,
    "page": 1,
    "limit": 20
  }
}
```

---

## 3. Data Models

### 3.1 ApprovedVehicleCategory

**File:** `lib/modules/auction/models/approved_vehicle_category_model.dart`

```dart
class ApprovedVehicleCategory {
  final int id;
  final String categoryCode;        // e.g., "TRUCK"
  final String categoryName;        // e.g., "Truck"
  final String status;              // "Active" / "Inactive"
  final double subscriptionAmount;  // Booking amount
  final String categoryPlan;        // PayU plan code
  final int sortingOrder;           // Display order
  final String iconName;            // Icon URL
  final int approvedVehAvailableCount; // Available vehicles count
  final DateTime insertedAt;
  final DateTime modifiedAt;
  final String insertedBy;
  final String? modifiedBy;
}
```

### 3.2 ApprovedVehicleListing

**File:** `lib/modules/auction/models/approved_vehicle_listing_model.dart`

```dart
class ApprovedVehicleListing {
  final int id;
  final String approvedVehicleId;      // e.g., "AVH-2024-001"
  final String categoryType;           // e.g., "TRUCK"
  final String registrationNumber;     // e.g., "MH01AB1234"
  final String stateName;              // e.g., "Maharashtra"
  final String cityName;               // e.g., "Mumbai"
  final String fitnessAvailable;       // "Yes" / "No"
  final String? brand;                 // e.g., "Tata"
  final String chassisNumber;
  final String originalInvoiceAvailable; // "Yes" / "No"
  final String ownerMobileNumber;
  final String assetDescription;       // e.g., "Tata Signa 2823.T 6x4"
  final int yearOfManufacturing;       // e.g., 2022
  final String vehicleInsuranceDate;   // ISO date string
  final double price;                  // e.g., 2500000.00
  final String vehicleStatus;          // "approved"
  final String gstApplicable;          // "Yes" / "No"
  final String offerEndDate;           // ISO date string
  final String offerEndTime;           // Time string
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

### 3.3 VehicleFiles

```dart
class VehicleFiles {
  final List<VehicleFile> images;
  final List<VehicleFile> rcDocuments;
  final List<VehicleFile> insuranceDocuments;
}
```

### 3.4 VehicleFile

```dart
class VehicleFile {
  final int id;
  final String fileType;    // "image", "rc_document", "insurance"
  final String fileUrl;     // Full URL to file
  final String status;      // "active"
  final String uploadedAt;  // ISO datetime string
}
```

### 3.5 InspectionSubscription

```dart
class InspectionSubscription {
  final double inspectionAmount;  // e.g., 2000.00
  final String categoryPlan;      // PayU plan code for inspection
}
```

### 3.6 CategorySubscription

```dart
class CategorySubscription {
  final double subscriptionAmount;     // e.g., 5000.00
  final String apprVehCommonSubPlan;   // PayU plan code for booking
}
```

### 3.7 ApprovedVehicleUserInterestResponse

```dart
class ApprovedVehicleUserInterestResponse {
  final int subscriptionId;
  final String approvedVehicleId;
  final String userId;
  final String inspectionRequested;  // "yes" / "no"
  final String isBooked;             // "yes" / "no"
  final String status;               // "active"
}
```

---

## 4. UI Components Documentation

### 4.1 ApprovedVehicleListingCard

**Path:** `lib/modules/auction/widgets/approved_vehicle_listing_card.dart`

#### Purpose
Displays a single approved vehicle in a card layout within the listings grid.

#### Props
| Prop | Type | Description |
|------|------|-------------|
| `listing` | `ApprovedVehicleListing` | Vehicle data to display |

#### Features
- Vehicle image (from `files.images[0].fileUrl`) via `CustomImageContainer`
- Registration number (bold, max 1 line)
- Asset description (secondary text, max 1 line)
- "KNOW MORE" button at bottom with top border
- Card with white background, rounded corners (8px), subtle shadow

#### Actions
- Tap "KNOW MORE" → Calls `controller.onApprovedListingTap(listing)` → Navigates to detail screen

#### Layout
```
┌──────────────────────┐
│   [Vehicle Image]    │  ← 100px height, full width
│                      │
│  Registration No.    │  ← Bold, 14px, max 1 line
│  Description         │  ← Regular, 12px, max 1 line
│                      │
│ ─────── ─────── ──── │  ← Divider
│      KNOW MORE       │  ← Clickable, centered text
└──────────────────────┘
```

---

### 4.2 Category Card (in ApprovedVehicleCategoryView)

**Path:** `lib/modules/auction/views/approved_vechile_category.dart`

#### Purpose
Displays a vehicle category in a grid card with icon and name.

#### Features
- Category icon loaded from `CachedNetworkImage` (from `category.iconName` URL)
- Fallback icon (`Icons.category`) on image load error
- Shimmer placeholder while loading
- Category name (up to 3 lines, centered)
- Haptic feedback on tap
- Responsive layout based on device type

#### Actions
- Tap → Calls `controller.onApprovedCategoryTap(category)` → Navigates to listings with category filter

---

### 4.3 CustomImageContainer (Shared)

**Path:** `lib/shared/widgets/custom_image_container.dart`

#### Purpose
Reusable image carousel component used in detail views.

#### Key Props
| Prop | Type | Description |
|------|------|-------------|
| `imageUrls` | `List<String>` | List of image URLs |
| `width` | `double` | Container width |
| `height` | `double` | Container height |
| `borderRadius` | `BorderRadius` | Corner radius |
| `imageFit` | `BoxFit` | Image fit mode |
| `showArrows` | `bool` | Show navigation arrows |
| `autoSlide` | `bool` | Auto-slide images |

---

### 4.4 CustomButton (Shared)

**Path:** `lib/shared/widgets/custom_button.dart`

#### Purpose
Standard button component used across the app.

#### Key Props
| Prop | Type | Description |
|------|------|-------------|
| `text` | `String` | Button label |
| `onPressed` | `VoidCallback?` | Tap handler (null = disabled) |
| `backgroundColor` | `Color` | Button background |
| `textColor` | `Color` | Text color |
| `width` | `double` | Button width |
| `height` | `double` | Button height |
| `borderRadius` | `double` | Corner radius |

---

### 4.5 Shared UI Components Used

| Component | Path | Usage |
|-----------|------|-------|
| `CustomAppBar` | `lib/shared/widgets/custom_app_bar.dart` | App bar with title and category type |
| `CustomDrawer` | `lib/shared/widgets/custom_drawer.dart` | Navigation drawer |
| `SizeConfig` | `lib/shared/widgets/size_config.dart` | Responsive sizing utilities |
| `PlatformRefreshIndicator` | `lib/shared/widgets/platform_refresh_indicator.dart` | Pull-to-refresh (platform-aware) |
| `ShimmerWidget` | `lib/shared/widgets/shimmer_widget.dart` | Loading skeleton |

---

## 5. Screens & User Flows

### 5.1 Approved Vehicle Category Selection Screen

**File:** `lib/modules/auction/views/approved_vechile_category.dart`
**Route:** `/approved-vehicle-category`
**Class:** `ApprovedVehicleCategoryView`

#### Purpose
Entry point for approved vehicles. Displays a grid of vehicle categories.

#### Layout
- **AppBar:** Title "Approved vehicle", drawer menu
- **Body:** Responsive grid of category cards + optional dashboard banner image at bottom
- **States:**
  - **Loading:** 6 shimmer skeleton cards in grid
  - **Loaded:** Category cards with icons and names
  - **Empty:** "No approved vehicle categories" message with "Pull down to refresh"

#### Responsive Grid Configuration

| Device Type | Columns | Aspect Ratio |
|-------------|---------|--------------|
| Mobile Small | 1 | 2.2 |
| Mobile Medium/Large | 2 | 1.35 |
| Mobile XLarge | 2 | 1.45 |
| Tablet | 3 | 1.55 |

#### Features
- Pull-to-refresh
- Shimmer loading state
- Dashboard banner image (from `CategoryController`) with zoom viewer
- Cached responsive config for performance

#### Navigation
- Tap category → `/approved-vehicle-listings` with category argument
- Dashboard image tap → Opens fullscreen zoom viewer

---

### 5.2 Approved Vehicle Listings Screen

**File:** `lib/modules/auction/views/approved_vehicle_listings_view.dart`
**Route:** `/approved-vehicle-listings`
**Class:** `ApprovedVehicleListingsView`

#### Purpose
Displays paginated grid of approved vehicles for a selected category.

#### Layout
- **AppBar:** Title "Approved Vehicles", drawer menu
- **Body:** 2-column grid of `ApprovedVehicleListingCard` widgets
- **States:**
  - **Loading (initial):** 6 shimmer cards in 2-column grid
  - **Loaded:** Vehicle cards with pull-to-refresh
  - **Empty:** Car icon + "No approved vehicles available" + "Refresh" button
  - **Loading more:** 2 additional shimmer cards appended at bottom

#### Pagination
- **Page size:** 20 items
- **Trigger:** Scroll reaches 90% of max extent OR within 50px of bottom
- **Guard:** Prevents duplicate requests with `_isLoadingMore` flag
- **Indicator:** Shimmer cards appended to grid during load-more

#### Features
- Infinite scroll pagination
- Pull-to-refresh (resets to page 1)
- Grid layout with `childAspectRatio: 0.85`
- Responsive spacing via `SizeConfig`

#### Navigation
- Tap card → `/approved-vehicle-detail` with listing argument

---

### 5.3 Approved Vehicle Detail Screen

**File:** `lib/modules/auction/views/approved_vehicle_detail_view.dart`
**Route:** `/approved-vehicle-detail`
**Class:** `ApprovedVehicleDetailView`

#### Purpose
Displays complete vehicle information with booking and inspection actions.

#### Layout
- **AppBar:** Title "Vehicle Details", drawer menu
- **Body:** Single scroll view with white card container

#### Content Sections

1. **Vehicle Images**
   - `CustomImageContainer` carousel with navigation arrows
   - 240px height, rounded corners
   - Fallback: "No Images Available" placeholder

2. **Vehicle Title**
   - Brand | Year of Manufacturing
   - Approved Vehicle ID | Asset Description

3. **Divider**

4. **Dynamic Detail Rows** (alternating background colors)
   - Category
   - Price (₹ formatted with Indian number format `#,##,###`)
   - Registration Number
   - Chassis Number
   - State
   - City
   - Fitness Certificate (Yes/No)
   - Original Invoice (Yes/No)
   - Insurance Valid Until (formatted as `dd MMM yyyy`)
   - GST Applicable
   - RC Document (Yes/No based on files)
   - Insurance Document (Yes/No based on files)
   - Offer End On
   - Status (uppercase)

5. **Action Buttons Row**
   - **"Book Now"** / **"Booked"** (if already booked, button disabled + grey)
   - **"Inspection"** / **"Requested"** (if already requested, button disabled + grey)

#### Actions

##### Book Now Flow
```
Tap "Book Now"
    │
    ├── Check: categorySubscription exists?
    │   ├── No → Snackbar: "Category subscription not available"
    │   └── Yes → Continue
    │
    ▼
Show Payment Dialog
    │
    ├── Title: "Book Vehicle"
    ├── Description: "Pay to book this vehicle and access full details"
    ├── Amount: categorySubscription.subscriptionAmount
    │
    ▼
Tap "Pay Now"
    │
    ├── Close dialog
    ├── Save payment context to StorageService:
    │   - approved_vehicle_id
    │   - approved_vehicle_subscription_type = "category"
    │   - pending_auction_id = "approved_vehicle_category"
    │   - pending_auction_title = "Approved Vehicle - {registrationNumber}"
    │
    ▼
PaymentController.startPayment(planCode)
    │
    ├── Success → PaymentController handles callback
    └── Failure → Snackbar error
```

##### Inspection Flow
```
Tap "Inspection"
    │
    ├── Check: inspectionSubscription exists?
    │   ├── No → Snackbar: "Inspection subscription not available"
    │   └── Yes → Continue
    │
    ▼
Show Payment Dialog
    │
    ├── Title: "Request Vehicle Inspection"
    ├── Description: "Pay to request professional inspection for this vehicle"
    ├── Amount: inspectionSubscription.inspectionAmount
    │
    ▼
Tap "Pay Now"
    │
    ├── Close dialog
    ├── Save payment context:
    │   - approved_vehicle_subscription_type = "inspection"
    │   - pending_auction_id = "approved_vehicle_inspection"
    │   - pending_auction_title = "Vehicle Inspection - {registrationNumber}"
    │
    ▼
PaymentController.startPayment(planCode)
```

#### Error State
- If listing is null (navigation error): Shows error icon + "Vehicle details not available" + "Go Back" button

---

### 5.4 Payment Dialog

**Location:** `ApprovedVehicleDetailView._showPaymentDialog()`

#### Purpose
Confirmation dialog before initiating PayU payment.

#### Design
- Background: `AppColors.activeBlue`
- Rounded corners (16px)
- Non-dismissible (`barrierDismissible: false`)
- Contains: Title, verify icon (SVG), description, amount, "Pay Now" button

#### Flow
1. User sees amount and description
2. Taps "Pay Now"
3. Dialog closes
4. Payment context saved to `StorageService`
5. `PaymentController.startPayment()` called with plan code
6. On success: `PaymentController.onPaymentSuccess` triggers `updateApprovedVehicleUserInterest()`

---

### 5.5 Approved Vehicle Sell Form

**File:** `lib/modules/auction/views/approved_vehicle_sell_form.dart`
**Route:** `/approved-vehicle-sell-form`
**Class:** `ApprovedVehicleSellForm`

#### Purpose
Form for vehicle owners to submit their vehicle for sale.

#### Features
- Collects vehicle details (category, registration, chassis, brand, year, price, location, etc.)
- File uploads (images, RC documents, insurance documents) via `file_picker`
- Form validation
- Submits as `multipart/form-data` via `dio.FormData`
- On success: Clears form and navigates to `/approved-vehicle-buy-sell`

---

### 5.6 My Bookings / My Inspections Screen

**File:** `lib/modules/auction/views/approved_vehicle_user_booked_view.dart`
**Routes:** `/my-bookings`, `/my-inspections`
**Class:** `ApprovedVehicleUserBookedView`

#### Purpose
Displays user's booked vehicles or inspection-requested vehicles.

#### Variants
| Route | Data Source | Filter |
|-------|------------|--------|
| `/my-bookings` | `fetchMyBookings()` | `booked_vehicles: "yes"` |
| `/my-inspections` | `fetchMyInspections()` | `inspection_requested: "yes"` |

---

### 5.7 Buy/Sell Home Screen

**File:** `lib/modules/auction/views/aproved_vechicle_buy_sell.dart`
**Route:** `/approved-vehicle-buy-sell`

#### Purpose
Landing page for approved vehicle buy/sell section. Provides entry points to browse categories (buy) or submit vehicle (sell).

---

## 6. State Management

### Framework: **GetX**

All state is managed through `AuctionController` which extends `GetxController` with `GetTickerProviderStateMixin`.

### Observable State Variables

```dart
// ==================== Approved Vehicle Categories ====================
final RxList<ApprovedVehicleCategory> approvedCategories = <ApprovedVehicleCategory>[].obs;
final RxBool isLoadingApprovedCategories = false.obs;
final RxString approvedCategoriesError = ''.obs;
final RxInt approvedCategoriesTotalCount = 0.obs;

// ==================== Approved Vehicle Listings ====================
final RxList<ApprovedVehicleListing> approvedListings = <ApprovedVehicleListing>[].obs;
final RxBool isLoadingApprovedListings = false.obs;
final RxString approvedListingsError = ''.obs;
final RxInt approvedListingsTotalCount = 0.obs;
final RxInt approvedListingsPage = 1.obs;
final RxBool hasMoreApprovedListings = true.obs;

// ==================== My Bookings ====================
final RxList<ApprovedVehicleListing> myBookedVehicles = <ApprovedVehicleListing>[].obs;
final RxBool isLoadingMyBookings = false.obs;

// ==================== My Inspections ====================
final RxList<ApprovedVehicleListing> myInspectedVehicles = <ApprovedVehicleListing>[].obs;
final RxBool isLoadingMyInspections = false.obs;

// ==================== Filters ====================
final RxString selectedListingStatus = ''.obs;
// selectedListingCategoryType (set when navigating from category)
```

### Controller Methods

| Method | Purpose | Parameters |
|--------|---------|------------|
| `fetchApprovedCategories()` | Load categories | `status: "Active"` |
| `refreshApprovedCategories()` | Refresh categories | None |
| `onApprovedCategoryTap(category)` | Navigate to listings | `ApprovedVehicleCategory` |
| `fetchApprovedVehicleListings({isRefresh})` | Load/refresh listings | `isRefresh: bool` |
| `loadMoreApprovedListings()` | Load next page | None |
| `refreshApprovedListings()` | Refresh listings | None |
| `onApprovedListingTap(listing)` | Navigate to detail | `ApprovedVehicleListing` |
| `updateApprovedVehicleUserInterest(...)` | Post-payment update | `approvedVehicleId`, `subscriptionType` |
| `clearApprovedListingFilters()` | Reset filters | None |
| `fetchMyBookings({isRefresh})` | Load booked vehicles | `isRefresh: bool` |
| `fetchMyInspections({isRefresh})` | Load inspected vehicles | `isRefresh: bool` |
| `submitApprovedVehicleSellForm()` | Submit sell form | None (uses form controllers) |

### API Integration Chain

```
Controller → ApiRepository → NetworkService → HTTP POST
                                ↓
                         Response parsed into Model
                                ↓
                         Observable list updated
                                ↓
                         UI rebuilds via Obx()
```

### Dependencies

| Service | Usage |
|---------|-------|
| `StorageService` | Save/read user ID, payment context |
| `ApiRepository` | All API calls |
| `PaymentController` | PayU payment initiation |
| `FirebaseMessagingService` | Push notifications |
| `CategoryController` | Dashboard images |

---

## 7. Business Rules

### 7.1 Approval & Status Transitions

```
Vehicle Submitted (Sell Form)
        │
        ▼
   Under Review (Backend)
        │
        ├── Rejected → Not shown to users
        │
        ▼
    Approved (vehicle_status = "approved")
        │
        ├── Listed in listings (is_booked = "no")
        │
        ├── User Books → is_booked = "yes"
        │       │
        │       └── Filtered out from listings (client-side)
        │
        └── User Requests Inspection → inspection_requested = "yes"
                │
                └── Still visible in listings
```

### 7.2 Payment Conditions

| Action | Required Subscription | Amount Source | Plan Code Source |
|--------|----------------------|---------------|-----------------|
| **Book Now** | `categorySubscription` | `subscriptionAmount` | `apprVehCommonSubPlan` |
| **Inspection** | `inspectionSubscription` | `inspectionAmount` | `categoryPlan` |

- If subscription is `null`, the action is blocked with a snackbar message
- Payment is processed through PayU SDK via `PaymentController`

### 7.3 Booking Rules

- A vehicle can only be booked if `is_booked != "yes"`
- Once booked, the "Book Now" button becomes disabled (grey) with text "Booked"
- Booked vehicles are **filtered out** from the listings grid (client-side filtering)
- Booked vehicles appear in "My Bookings" section

### 7.4 Inspection Rules

- A vehicle can be inspected even if already booked
- Once inspection is requested, the "Inspection" button becomes disabled with text "Requested"
- Inspection-requested vehicles remain visible in listings
- Inspection-requested vehicles appear in "My Inspections" section

### 7.5 Permission Handling

- All API calls require authenticated `user_id`
- User ID is retrieved from `StorageService`
- Payment context is persisted in `StorageService` for post-payment callback handling
- User type (`CUSTOMER`, `VENDOR`, `INTERNAL`) is stored in `StorageService` under key `user_type`
- Role-based navigation is enforced at both the auth controller level and the drawer level
- See [Section 8: RBAC](#8-role-based-access-control-rbac) for detailed permission matrix

### 7.6 Edge Cases Handled

| Edge Case | Handling |
|-----------|----------|
| Null listing in detail view | Error screen with "Go Back" button |
| No images available | "No Images Available" placeholder |
| No categories available | Empty state with pull-to-refresh |
| No vehicles in listing | Empty state with refresh button |
| Subscription is null | Snackbar error, action blocked |
| Payment fails | Snackbar error message |
| Invalid date format | Returns raw string instead of formatted |
| Booked vehicle in API response | Filtered out client-side |

### 7.7 Display Rules

- Price is formatted with Indian number system: `₹25,00,000`
- Dates are formatted as `dd MMM yyyy` (e.g., "15 Mar 2024")
- Status is displayed in UPPERCASE
- Fields with null/empty/"null" values are hidden from detail rows

---

## 8. Role-Based Access Control (RBAC)

### 8.1 Overview

The Approved Vehicles module implements role-based access control at the **navigation level** and **UI level**. User roles determine:
- Which screens/routes the user can access
- What drawer menu items are displayed
- Which forms are presented (e.g., Customer vs Internal team forms)
- The entry point into the Approved Vehicles module

### 8.2 User Types (Roles)

| User Type Code | Description | Registration Default |
|---------------|-------------|---------------------|
| `CUSTOMER` | Regular buyers/dealers who browse, book, and inspect vehicles | Default role on registration |
| `VENDOR` | Vehicle owners/sellers who list vehicles for sale | Set during registration or profile update |
| `INTERNAL` | Internal team members (inspectors, field agents) | Set by admin |

### 8.3 Role Storage & Retrieval

User type is managed through multiple layers:

```
┌─────────────────────────────────────────────────────────┐
│              USER TYPE RETRIEVAL CHAIN                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. Primary: StorageService.getUserType()                │
│     └── Reads from GetStorage key: 'user_type'           │
│                                                          │
│  2. Fallback: CategoryController.userProfileData         │
│     └── Fetches from profile API response                │
│     └── Field: profileData.userType                      │
│                                                          │
│  3. On profile fetch success:                            │
│     └── Updates storage: storageService.saveUserType()   │
│                                                          │
│  4. On login/register:                                   │
│     └── API response.user_type saved to storage          │
│                                                          │
│  5. On logout:                                           │
│     └── storageService.removeUserType()                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

#### Storage Service Methods

```dart
// File: lib/core/services/storage_service.dart

class StorageService {
  static const String userType = 'user_type';

  // Get user type
  String? getUserType() {
    final storedUserType = _storage.read(userType);
    return storedUserType;
  }

  // Save user type (called on login/register/profile update)
  Future<void> saveUserType(String userTypeValue) async {
    await _storage.write(userType, userTypeValue);
  }

  // Remove user type (called on logout)
  Future<void> removeUserType() async {
    await _storage.remove(userType);
  }
}
```

#### Profile Model (from API)

```dart
// File: lib/modules/category/models/profile_model.dart

class ProfileData {
  final String userId;
  final String username;
  final String phoneNumber;
  final String userType;   // <-- "CUSTOMER", "VENDOR", "INTERNAL"
  final String state;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      userId: json['user_id'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      userType: json['user_type'],    // <-- Role from API
      state: json['state'],
    );
  }
}
```

### 8.4 Role-Based Navigation Matrix

#### Entry Point Navigation (from Auth Controller)

After login/registration, users are routed based on their role:

```dart
// File: lib/modules/auth/controllers/auth_controller.dart

void _navigateBasedOnUserType(String? userType) {
  switch (userType?.toUpperCase()) {
    case 'CUSTOMER':
      Get.offAllNamed(AppRoutes.categories);  // → Main category home
      break;
    case 'INTERNAL':
      Get.offAllNamed(AppRoutes.inspectionValuation);  // → Inspection form
      break;
    default:
      Get.offAllNamed(AppRoutes.categories);  // → Default to categories
      break;
  }
}
```

| User Type | Post-Login Route | Screen |
|-----------|-----------------|--------|
| `CUSTOMER` | `/categories` | Main category home (browse all modules) |
| `VENDOR` | `/categories` | Main category home (same as customer) |
| `INTERNAL` | `/inspection-valuation` | Inspection/Valuation form |
| Default/Unknown | `/categories` | Fallback to main category home |

#### Approved Vehicles Entry Point Navigation (from Drawer)

When a user taps "Approved Vehicle" in the navigation drawer, the destination changes based on role:

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
    Get.toNamed(AppRoutes.approvedVehicleBuySell);  // → Buy/Sell landing
  } else {
    Get.toNamed(AppRoutes.approvedVehicleCategory);  // → Category grid (default)
  }
}
```

| User Type | Approved Vehicle Entry Route | Screen | Rationale |
|-----------|------------------------------|--------|-----------|
| `VENDOR` | `/approved-vehicle-buy-sell` | Buy/Sell Landing Page | Vendors primarily sell vehicles |
| `CUSTOMER` | `/approved-vehicle-category` | Category Selection Grid | Customers primarily browse/buy |
| `INTERNAL` | `/approved-vehicle-category` | Category Selection Grid | Internal team can browse |
| Default/Unknown | `/approved-vehicle-category` | Category Selection Grid | Safe default |

### 8.5 Role-Based Screen Access

#### Complete Access Matrix

| Screen / Route | CUSTOMER | VENDOR | INTERNAL |
|---------------|----------|--------|----------|
| `/categories` (Home) | ✅ | ✅ | ❌ |
| `/approved-vehicle-category` | ✅ | ❌ (redirected to buy-sell) | ✅ |
| `/approved-vehicle-buy-sell` | ❌ (not primary path) | ✅ | ❌ |
| `/approved-vehicle-listings` | ✅ | ✅ (via buy-sell → category) | ✅ |
| `/approved-vehicle-detail` | ✅ | ✅ | ✅ |
| `/approved-vehicle-sell-form` | ✅ | ✅ | ❌ |
| `/my-bookings` | ✅ | ✅ | ❌ |
| `/my-inspections` | ✅ | ✅ | ❌ |
| `/inspection-valuation` | ✅ (CustomerForm) | ❌ | ✅ (InternalTeamForm) |

#### Inspection/Valuation Role-Based Forms

```dart
// File: lib/modules/inspection_valuation/views/inspection_valuation_view.dart

switch (userType?.toUpperCase()) {
  case 'CUSTOMER':
    return CustomerForm();        // Standard customer inspection form
  case 'INTERNAL':
    return InternalTeamForm();    // Internal team inspection form
  default:
    return CustomerForm();        // Default fallback
}
```

### 8.6 Role-Based Drawer Menu Items

The navigation drawer shows different menu items based on context:

#### For Approved Vehicles Module (`categoryType == 'approved_vehicles'`):

```dart
// Menu items shown:
[
  // ... common items ...
  DrawerMenuItem(
    icon: Icons.gavel,
    title: 'Approved Vehicle',
    onTap: () => _navigateToApprovedVehicle(),  // Role-based routing
  ),
  // ... other items ...
]
```

The same "Approved Vehicle" menu item is shown to all roles, but the `_navigateToApprovedVehicle()` method routes them to different screens based on their `user_type`.

### 8.7 Role-Based Action Permissions

#### Detail Screen Actions

| Action | CUSTOMER | VENDOR | INTERNAL |
|--------|----------|--------|----------|
| View Vehicle Details | ✅ | ✅ | ✅ |
| Book Now | ✅ | ✅ | ✅ (if permitted) |
| Request Inspection | ✅ | ✅ | ✅ (if permitted) |
| View Images | ✅ | ✅ | ✅ |
| View Documents | ✅ | ✅ | ✅ |

#### Sell Form Actions

| Action | CUSTOMER | VENDOR | INTERNAL |
|--------|----------|--------|----------|
| Access Sell Form | ✅ | ✅ | ❌ |
| Submit Vehicle | ✅ | ✅ | ❌ |
| Upload Images | ✅ | ✅ | ❌ |
| Upload Documents | ✅ | ✅ | ❌ |

### 8.8 Role Validation Flow (Pseudocode)

```
┌──────────────────────────────────────────────────────────┐
│              ROLE VALIDATION FLOW                          │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  User taps "Approved Vehicle" in drawer                   │
│       │                                                   │
│       ▼                                                   │
│  Read userType from StorageService                        │
│       │                                                   │
│       ├── userType is null/empty/"user"?                  │
│       │       │                                           │
│       │       ▼                                           │
│       │   Fetch from CategoryController.userProfileData   │
│       │       │                                           │
│       │       ├── Profile exists?                         │
│       │       │       ├── Yes → Use profileData.userType  │
│       │       │       └── No  → Default to "CUSTOMER"     │
│       │       │                                           │
│       │       └── Update storage with resolved userType   │
│       │                                                   │
│       ▼                                                   │
│  Route based on resolved userType:                        │
│       │                                                   │
│       ├── "VENDOR" → /approved-vehicle-buy-sell           │
│       └── Others   → /approved-vehicle-category           │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 8.9 User Type Update Points

| Event | Action | Storage Updated? |
|-------|--------|-----------------|
| **Login** (OTP or password) | `response.user_type` saved | ✅ `storageService.write('user_type', ...)` |
| **Registration** | `response.user_type` saved (default: `CUSTOMER`) | ✅ |
| **Profile Fetch** | `profileData.userType` saved | ✅ `storageService.saveUserType(...)` |
| **Profile Update** | User type may change | ✅ (via profile response) |
| **Logout** | User type cleared | ✅ `storageService.removeUserType()` |
| **Session Expired** | All data cleared (including user type) | ✅ via `_clearSessionData()` |

### 8.10 Implementation Notes for New Application

When replicating RBAC in a new application:

1. **Store user type locally** — Persist the role after login for quick access without API calls
2. **Implement fallback chain** — Always have a fallback to fetch from profile API if local storage is empty
3. **Default to least-privileged role** — If user type is unknown, default to `CUSTOMER` (browse-only access)
4. **Validate on every navigation** — Check role at navigation entry points, not just at login
5. **Case-insensitive comparison** — Always compare with `.toUpperCase()` to handle backend inconsistencies
6. **Handle "user" edge case** — The codebase explicitly checks for `'user'` as an invalid/legacy value
7. **Persist across sessions** — User type should survive app restarts (use persistent storage, not just in-memory)
8. **Clear on logout** — Always clear user type on logout to prevent stale role data

---

## 9. Reusable Logic

### 9.1 Shared Hooks & Services

| Component | Path | Reuse |
|-----------|------|-------|
| `StorageService` | `lib/core/services/storage_service.dart` | User auth, payment context storage |
| `ApiRepository` | `lib/core/api/api_repository.dart` | Centralized API layer |
| `NetworkService` | `lib/core/services/network_service.dart` | HTTP client with interceptors |
| `PaymentController` | `lib/modules/payu_sdk_payment/controllers/payment_controller.dart` | PayU payment processing |
| `SizeConfig` | `lib/shared/widgets/size_config.dart` | Responsive sizing |

### 9.2 Utility Functions

| Function | Location | Purpose |
|----------|----------|---------|
| `_formatDate(dateStr)` | `ApprovedVehicleDetailView` | Parse ISO date → `dd MMM yyyy` |
| `NumberFormat('#,##,###')` | Detail view | Indian currency formatting |
| `_parseDouble()` / `_parseInt()` | Category model | Safe type parsing |
| `_parseDateTime()` | Category model | Safe datetime parsing |

### 9.3 Common Patterns

**Pagination Pattern:**
```dart
// Page tracking
final RxInt page = 1.obs;
final RxBool hasMore = true.obs;
final RxBool isLoading = false.obs;

// Load more guard
if (!hasMore.value || isLoading.value) return;
page.value++;
await fetchData();

// hasMore calculation
hasMore.value = currentList.length < response.totalCount;
```

**Post-Payment Pattern:**
```dart
// 1. Save context to StorageService
await storageService.write('approved_vehicle_id', id);
await storageService.savePendingAuctionId('approved_vehicle_category');

// 2. Start payment
final success = await paymentController.startPayment(planCode: planCode);

// 3. On success, PaymentController calls updateApprovedVehicleUserInterest()
// 4. Listings are refreshed to reflect status changes
```

**Scroll-to-Load Pattern:**
```dart
// Trigger at 90% scroll or 50px from bottom
final threshold90Percent = maxScroll * 0.9;
final threshold50px = maxScroll - 50.0;
final triggerPoint = threshold90Percent < threshold50px 
    ? threshold90Percent 
    : threshold50px;
```

---

## 10. Navigation & Routes

### Route Definitions

**File:** `lib/routes/app_routes.dart`

| Route | Path | Screen |
|-------|------|--------|
| `approvedVehicle` | `/approved-vehicle` | Main approved vehicles entry |
| `approvedVehicleCategory` | `/approved-vehicle-category` | Category selection grid |
| `approvedVehicleBuySell` | `/approved-vehicle-buy-sell` | Buy/Sell home |
| `approvedVehicleSellForm` | `/approved-vehicle-sell-form` | Sell vehicle form |
| `approvedVehicleListings` | `/approved-vehicle-listings` | Vehicle listings grid |
| `approvedVehicleDetail` | `/approved-vehicle-detail` | Vehicle detail view |
| `myBookings` | `/my-bookings` | User's booked vehicles |
| `myInspections` | `/my-inspections` | User's inspection requests |

### Navigation Flow

```
Home / Drawer
    │
    ├──► /approved-vehicle-category
    │         │
    │         ├──► /approved-vehicle-listings (with category argument)
    │         │         │
    │         │         └──► /approved-vehicle-detail (with listing argument)
    │         │                   │
    │         │                   ├──► PayU Payment Flow
    │         │                   │
    │         │                   └──► /approved-vehicle-listings (refresh after payment)
    │         │
    │         └──► /approved-vehicle-buy-sell
    │                   │
    │                   └──► /approved-vehicle-sell-form
    │                             │
    │                             └──► /approved-vehicle-buy-sell (on success)
    │
    ├──► /my-bookings (via drawer)
    │
    └──► /my-inspections (via drawer)
```

### Binding

All approved vehicle routes use `AuctionBinding()` which registers `AuctionController` in GetX dependency injection.

### Arguments

| Route | Arguments | Type |
|-------|-----------|------|
| `/approved-vehicle-listings` | `{'category': ApprovedVehicleCategory}` | `Map<String, dynamic>` |
| `/approved-vehicle-detail` | `{'listing': ApprovedVehicleListing}` | `Map<String, dynamic>` |

---

## 11. Suggested Improvements

### 11.1 Current Limitations

1. **Client-side booking filter:** Booked vehicles are filtered out on the client after receiving the full list. This wastes bandwidth and can cause page size inconsistency (e.g., requesting 20 items but displaying fewer).

2. **No debouncing on scroll:** The scroll listener uses a manual `_isLoadingMore` flag but lacks proper debouncing, which could lead to rapid-fire requests on fast scrolling.

3. **Monolithic controller:** `AuctionController` handles auctions, approved vehicles, bids, wins, subscriptions, and more (5575+ lines). This should be split into separate controllers.

4. **No error retry mechanism:** On API failure, only a snackbar is shown. There's no automatic retry or manual retry button (except on the empty state).

5. **Hardcoded strings:** UI strings like "Book Now", "Inspection", error messages are hardcoded rather than using localization keys.

6. **No image caching strategy in listings:** Images are loaded directly without size parameters, which could be slow for large vehicle photos.

### 11.2 UI/UX Improvements

1. **Skeleton loading for detail view:** Currently no loading state for detail screen.
2. **Pull-to-refresh on detail view:** Could allow refreshing vehicle status.
3. **Share vehicle:** Add share functionality for vehicle listings.
4. **Search within listings:** Although `searchRegistration` filter exists in the API, it's not exposed in the listings UI.
5. **Price range filter:** API supports `min_price`/`max_price` but no UI filter exists.
6. **Sort options:** No sorting UI despite having data to sort by (price, year, etc.).
7. **Offline support:** Cache recently viewed vehicles for offline access.

### 11.3 Performance Optimizations

1. **Pagination fix:** Request filtered results from server instead of client-side filtering.
2. **Image optimization:** Request appropriately sized thumbnails for grid cards vs full-size for detail view.
3. **Memoize responsive config:** Already done in category view, should be applied to listings too.
4. **Lazy load detail sections:** Use `SliverList` with lazy building for detail rows.
5. **Reduce API payload:** Request only needed fields if the API supports field selection.

### 11.4 Code Refactoring Opportunities

1. **Extract ApprovedVehicleController:** Split from monolithic `AuctionController`.
2. **Create Repository pattern for approved vehicles:** Separate `ApprovedVehicleRepository`.
3. **Extract payment flow into a service:** `ApprovedVehiclePaymentService` to handle booking/inspection payment logic.
4. **Create base list view with pagination:** Generic paginated grid/list component reusable across modules.
5. **Extract detail row builder into a reusable widget:** `_buildDynamicDetailRows()` and `_buildDetailRow()` could be a shared `DetailRowsWidget`.
6. **Standardize error handling:** Create a consistent error handling pattern with retry capabilities.

### 11.5 Reusability for New Application

When rebuilding with a different UI:

1. **Keep the data models unchanged** — they map directly to API responses
2. **Keep the API request/response structures** — they define the contract
3. **Replicate the payment flow** — save context → start payment → update interest
4. **Replicate the pagination logic** — page tracking, hasMore calculation, scroll threshold
5. **Replicate the booking filter** — filter `is_booked == "yes"` from listings
6. **Replicate the status transitions** — button states based on `isBooked` and `inspectionRequested`
7. **Replicate the subscription validation** — check for null subscriptions before allowing actions

---

## File Reference Summary

| File | Purpose |
|------|---------|
| `lib/modules/auction/controllers/auction_controller.dart` | All business logic & state |
| `lib/modules/auction/models/approved_vehicle_category_model.dart` | Category request/response models |
| `lib/modules/auction/models/approved_vehicle_listing_model.dart` | Listing request/response models |
| `lib/modules/auction/models/approved_vehicle_user_interest_model.dart` | User interest update models |
| `lib/modules/auction/models/approved_vehicle_user_booked_model.dart` | Booked/inspected vehicles models |
| `lib/modules/auction/views/approved_vechile_category.dart` | Category selection screen |
| `lib/modules/auction/views/approved_vehicle_listings_view.dart` | Listings grid screen |
| `lib/modules/auction/views/approved_vehicle_detail_view.dart` | Vehicle detail + payment screen |
| `lib/modules/auction/views/approved_vehicle_sell_form.dart` | Sell form screen |
| `lib/modules/auction/views/aproved_vechicle_buy_sell.dart` | Buy/Sell home screen |
| `lib/modules/auction/views/approved_vehicle_user_booked_view.dart` | My Bookings/Inspections screen |
| `lib/modules/auction/widgets/approved_vehicle_listing_card.dart` | Listing card widget |
| `lib/core/api/api_constant.dart` | API endpoint constants |
| `lib/core/api/api_repository.dart` | API call implementations |
| `lib/routes/app_routes.dart` | Route path constants |
| `lib/routes/app_pages.dart` | Route page bindings |
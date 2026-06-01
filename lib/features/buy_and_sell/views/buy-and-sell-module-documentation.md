# Buy & Sell Module — Complete Technical Documentation

> **Purpose:** This document provides a comprehensive blueprint of the Buy & Sell module's business logic, UI components, state management, APIs, and user workflows. It is designed to enable a development team to fully replicate the functionality in a different application with a different UI/UX design.

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Architecture & File Structure](#2-architecture--file-structure)
3. [API Documentation](#3-api-documentation)
4. [Data Models](#4-data-models)
5. [State Management (Controller)](#5-state-management-controller)
6. [UI Screens & User Flows](#6-ui-screens--user-flows)
7. [Widgets & Components](#7-widgets--components)
8. [Sell Vehicle Flow](#8-sell-vehicle-flow)
9. [Buy Vehicle Flow](#9-buy-vehicle-flow)
10. [Vehicle Details & Actions](#10-vehicle-details--actions)
11. [Subscription & Payment Logic](#11-subscription--payment-logic)
12. [Filters & Search](#12-filters--search)
13. [Business Rules & Validations](#13-business-rules--validations)
14. [Role-Based Functionality](#14-role-based-functionality)
15. [Error & Loading Handling](#15-error--loading-handling)
16. [Reusable Services & Utilities](#16-reusable-services--utilities)
17. [Dependencies](#17-dependencies)
18. [Edge Cases](#18-edge-cases)
19. [Suggested Improvements](#19-suggested-improvements)

---

## 1. Module Overview

### 1.1 Purpose

The Buy & Sell module enables users to:
- **Sell vehicles**: Post vehicles for sale with details, images, documents
- **Buy vehicles**: Browse, filter, search approved vehicles
- **Manage vehicles**: Edit, update sold status, track approval status
- **Show interest**: Express interest, make offers, request inspections
- **Subscribe**: Access premium features via subscription plans
- **Access details**: Request owner contact info and vehicle details (paid feature)

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Sell Vehicle** | User posts a vehicle for sale; goes through admin approval |
| **Buy Vehicle** | Approved vehicles visible to all users for purchase |
| **Subscribed Vehicle** | Vehicles the user has subscribed to (paid access) |
| **User Interest** | Expressing interest, making offers, requesting inspections |
| **Vehicle Approval** | Admin reviews and approves/rejects vehicle postings |
| **Dynamic Form** | Category-specific forms loaded from API based on vehicle type |

### 1.3 User Roles

| Role | Capabilities |
|------|-------------|
| **Guest** | Can view buy vehicle listings (limited) |
| **Seller/Vendor** | Post vehicles, edit vehicles, manage listings, mark as sold |
| **Buyer** | Browse vehicles, show interest, make offers, request inspections |
| **Admin** | Approve/reject vehicles, manage all listings |

---

## 2. Architecture & File Structure

### 2.1 Directory Structure

```
lib/modules/buy_and_sell/
├── bindings/
│   └── buy_sell_binding.dart          # GetX dependency injection
├── controllers/
│   ├── buy_sell_controller.dart       # Main controller (4962 lines)
│   └── clean_vehicle_controller.dart  # Clean/reset vehicle state
├── models/
│   ├── form_field_model.dart          # Dynamic form field model
│   ├── list_buy_subscribed_vechile_req.dart
│   ├── list_buy_subscribed_vechile_res.dart
│   ├── list_buy_vehicles_request.dart
│   ├── list_buy_vehicles_response.dart
│   ├── list_sell_vehicles_request.dart
│   ├── list_sell_vehicles_response.dart
│   ├── sell_vehicle_request.dart
│   ├── sell_vehicle_response.dart
│   ├── update_vehicle_images.dart
│   ├── update_vehicle_request.dart
│   ├── update_vehicle_response.dart
│   ├── user_interest_request.dart
│   ├── user_interest_response.dart
│   ├── vehicle_brand_model.dart
│   ├── vehicle_category_model.dart
│   ├── vehicle_details_by_id_request.dart
│   ├── vehicle_sold_request.dart
│   ├── vehicle_sold_response.dart
│   ├── vehicle_tire_model.dart
│   └── VehicleListResponseByVehicleID.dart
├── services/
│   └── vehicle_category_service.dart  # Category-specific form field service
├── views/
│   ├── buy_sell_dashboard.dart        # Dashboard/home view
│   ├── buy_sell_home_view.dart        # Main tabbed view
│   ├── buy_vehicles_list_view.dart    # Buy vehicles list
│   ├── buy_vehicles_view.dart         # Buy vehicles by category
│   ├── buy_view.dart                  # Buy tab view
│   ├── edit_vehicle_view.dart         # Edit vehicle form
│   ├── my_vehicles.dart               # My vehicles list
│   ├── sell_view.dart                 # Sell tab/form
│   ├── simple_vehicle_list_page.dart  # Simple list page
│   └── subscribed_vehicle.dart        # Subscribed vehicles list
└── widgets/
    ├── buy_item_card.dart             # Buy item card component
    ├── buy_item_shimmer_card.dart     # Loading shimmer for buy items
    ├── buy_sell_item_card.dart        # Shared buy/sell card
    ├── buy_sell_subscription_plan.dart # Subscription plan display
    ├── buy_vehicle_card.dart          # Buy vehicle card with details
    ├── buy_vehicle_details_new.dart   # New vehicle details page
    ├── buy_vehicle_details.dart       # Vehicle details page
    ├── category_style_buy_item_card.dart
    ├── category_style_shimmer_card.dart
    ├── dynamic_form_field_widget.dart # Dynamic form field renderer
    ├── editable_document_upload_widget.dart
    ├── image_upload_page.dart         # Image upload component
    ├── interest_card.dart             # Interest/actions card
    ├── single_subscription_plan.dart
    ├── vechile_card.dart              # Generic vehicle card
    ├── vechileDetails.dart            # Vehicle details component
    ├── vehicle_category_autocomplete.dart
    └── vehicle_category_usage_example.dart
```

### 2.2 Architecture Pattern

- **Pattern**: MVC with GetX
- **State Management**: GetX reactive (Rx observables)
- **Dependency Injection**: GetX Bindings
- **Navigation**: GetX named routes
- **API Layer**: Repository pattern via `_apiRepository`

---

## 3. API Documentation

### 3.1 Buy Vehicle APIs

#### List Buy Vehicles (with Filters)

- **Method:** `GET`
- **Endpoint:** `/api/v1/sell-buy/list-buy-vehicles`
- **Purpose:** Fetch approved buy vehicles with pagination and filters

**Request Model:** `ListBuyVehiclesRequest`

```json
{
  "user_id": "VB0000001",
  "limit": 10,
  "page": 1,
  "category_code": "CAR",
  "brand_code": "TATA",
  "state_code": "MH",
  "tyre_code": "4",
  "year": "2023",
  "body_type": "open",
  "fuel_type": "diesel",
  "kv": "100",
  "tonnage": "5",
  "search": "truck"
}
```

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | String | Yes | Current user ID |
| `limit` | int | No | Items per page (default: 10) |
| `page` | int | No | Page number (default: 1) |
| `category_code` | String | No | Vehicle category filter |
| `brand_code` | String | No | Brand filter |
| `state_code` | String | No | State filter |
| `tyre_code` | String | No | Tyre count filter |
| `year` | String | No | Manufacturing year |
| `body_type` | String | No | Body type filter |
| `fuel_type` | String | No | Fuel type filter |
| `kv` | String | No | KV rating filter |
| `tonnage` | String | No | Tonnage filter |
| `search` | String | No | Free text search |

**Response:** `ListBuyVehiclesResponse`

```json
{
  "status": "success",
  "code": 200,
  "data": {
    "vehicles": [
      {
        "sb_vehicle_id": "V001",
        "category_name": "Truck",
        "category_code": "TRUCK",
        "brand_name": "TATA",
        "brand_code": "TATA",
        "model": "Signa 2518.T",
        "registration_number": "MH12AB1234",
        "manufacturing_year": 2023,
        "price": 2500000,
        "city": "Pune",
        "state": "Maharashtra",
        "fuel_type": "Diesel",
        "image_urls": ["https://..."],
        "status": "active",
        "approved": "yes",
        "is_sold": "no",
        "created_at": "2024-01-15"
      }
    ],
    "total_count": 150,
    "total_pages": 15,
    "current_page": 1,
    "has_more": true
  }
}
```

---

#### Get Buy Vehicle Details by ID

- **Method:** `GET`
- **Endpoint:** `/api/v1/sell-buy/vehicle-details`
- **Purpose:** Fetch detailed vehicle information by ID

**Request Model:** `VehicleDetailsByIdRequest`

```json
{
  "user_id": "VB0000001",
  "sb_vehicle_id": "V001",
  "category_code": "TRUCK"
}
```

**Response:** `VehicleListResponseByVehicleID`

```json
{
  "status": "success",
  "data": {
    "vehicles": [
      {
        "sb_vehicle_id": "V001",
        "category_name": "Truck",
        "brand_name": "TATA",
        "model": "Signa 2518.T",
        "registration_number": "MH12AB1234",
        "chassis_number": "MAT1234567890",
        "manufacturing_year": 2023,
        "price": 2500000,
        "odometer": "50000",
        "fuel_type": "Diesel",
        "body_type": "Open",
        "tonnage": "16 ton",
        "owner_mobile": "9876543210",
        "owner_details_access": "yes",
        "vehicle_details_access": "yes",
        "inspection_requested": "no",
        "is_interested": "yes",
        "vehicle_offer": 2300000,
        "image_urls": ["https://..."],
        "rc_document_url": "https://...",
        "insurance_document_url": "https://...",
        "fitness_certificate": true,
        "insurance_valid": true,
        "original_invoice": true,
        "gst_applicable": false,
        "state": "Maharashtra",
        "city": "Pune",
        "seller_name": "John Doe",
        "created_at": "2024-01-15"
      }
    ]
  }
}
```

---

#### List Subscribed Vehicles

- **Method:** `GET`
- **Endpoint:** `/api/v1/sell-buy/list-subscribed-vehicles`
- **Purpose:** Fetch vehicles the user has subscribed to

**Request Model:** `ListBuySubscribedVechileReq`

```json
{
  "user_id": "VB0000001",
  "limit": 10,
  "page": 1
}
```

**Response:** `ListBuySubscribedVechileRes`

```json
{
  "status": "success",
  "data": {
    "vehicles": [
      {
        "sb_vehicle_id": "V001",
        "category_name": "Truck",
        "category_code": "TRUCK",
        "brand_name": "TATA",
        "model": "Signa 2518.T",
        "registration_number": "MH12AB1234",
        "price": 2500000,
        "subscription_type": "gold",
        "subscription_expiry": "2024-06-15",
        "image_urls": ["https://..."]
      }
    ],
    "total_count": 25,
    "total_pages": 3
  }
}
```

---

### 3.2 Sell Vehicle APIs

#### Create Sell Vehicle

- **Method:** `POST`
- **Endpoint:** `/api/v1/sell-buy/create-sell-vehicle`
- **Purpose:** Post a new vehicle for sale (multipart/form-data)
- **Content-Type:** `multipart/form-data`

**Request Model:** `SellVehicleRequest`

**Form Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | String | Yes | Seller's user ID |
| `category_code` | String | Yes | Vehicle category |
| `brand_code` | String | Yes | Brand code |
| `asset_desc_or_model` | String | Yes | Model name/description |
| `registration_number` | String | Yes | Vehicle registration |
| `manufacturing_year` | int | Yes | Manufacturing year |
| `chassis_number` | String | Yes | Chassis number |
| `price` | double | Yes | Asking price |
| `odometer` | String | No | Odometer reading |
| `no_of_tyres` | String | No | Number of tyres |
| `owner_mobile` | String | Yes | Owner's mobile |
| `state_code` | String | Yes | State code |
| `city_code` | String | Yes | City code |
| `fitness` | bool | No | Fitness certificate |
| `insurance` | String | No | Insurance status |
| `original_invoice` | bool | No | Has original invoice |
| `gst_applicability` | bool | No | GST applicable |
| `tonnage` | String | No | For trucks/tippers |
| `hours` | String | No | For machinery |
| `body_type` | String | No | Body type |
| `fuel_type` | String | No | Fuel type |
| `kv` | String | No | KV rating (generators) |
| `other_brand` | String | No | Custom brand name |
| `other_tipper` | String | No | Custom tipper type |
| `other_body_type` | String | No | Custom body type |
| `other_tyre` | String | No | Custom tyre info |
| `vehicle_images` | File[] | Yes | Vehicle photos (multiple) |
| `rc_document` | File | Yes | RC document |
| `insurance_document` | File | No | Insurance document |

**Response:** `SellVehicleResponse`

```json
{
  "status": "success",
  "code": 200,
  "message": "Vehicle submitted for approval",
  "data": {
    "sb_vehicle_id": "V001"
  }
}
```

---

#### Update Vehicle

- **Method:** `POST`
- **Endpoint:** `/api/v1/sell-buy/update-sell-vehicle`
- **Purpose:** Update an existing vehicle listing
- **Content-Type:** `multipart/form-data`

**Request Model:** `UpdateVehicleRequest` — same fields as create, plus:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sb_vehicle_id` | String | Yes | Vehicle ID to update |

**Response:** `UpdateVehicleResponse`

```json
{
  "status": "success",
  "message": "Vehicle updated successfully. Changes pending admin approval."
}
```

---

#### List Sell Vehicles

- **Method:** `GET`
- **Endpoint:** `/api/v1/sell-buy/list-sell-vehicles`
- **Purpose:** Fetch vehicles posted by the current user

**Request Model:** `ListSellVehiclesRequest`

```json
{
  "user_id": "VB0000001",
  "limit": 10,
  "page": 1
}
```

**Response:** `ListSellVehiclesResponse`

```json
{
  "status": "success",
  "data": {
    "vehicles": [
      {
        "sb_vehicle_id": "V001",
        "category_name": "Truck",
        "brand_name": "TATA",
        "model": "Signa 2518.T",
        "registration_number": "MH12AB1234",
        "price": 2500000,
        "status": "pending",
        "approved": "no",
        "is_sold": "no",
        "rejection_reason": null,
        "image_urls": ["https://..."],
        "created_at": "2024-01-15"
      }
    ],
    "total_count": 5,
    "total_pages": 1
  }
}
```

---

#### Update Vehicle Sold Status

- **Method:** `POST`
- **Endpoint:** `/api/v1/sell-buy/update-vehicle-sold`
- **Purpose:** Mark a vehicle as sold/unsold

**Request Model:** `VehicleSoldRequest`

```json
{
  "sb_vehicle_id": "V001",
  "is_sold": "yes",
  "user_id": "VB0000001"
}
```

**Response:** `VehicleSoldResponse`

```json
{
  "status": "success",
  "message": "Vehicle marked as sold"
}
```

---

### 3.3 User Interest APIs

#### Create User Interest

- **Method:** `POST`
- **Endpoint:** `/api/v1/sell-buy/user-interest`
- **Purpose:** Express interest, make offer, request access, or request inspection

**Request Model:** `UserInterestRequest`

```json
{
  "user_id": "VB0000001",
  "vehicle_id": "V001",
  "is_interested": "yes",
  "vehicle_offer": 2300000,
  "owner_details_access": "yes",
  "vehicle_details_access": "no",
  "inspection_request": "yes"
}
```

**All fields are optional except `user_id` and `vehicle_id`. The action depends on which fields are provided:**

| Action | Fields Sent |
|--------|------------|
| Show Interest | `is_interested: "yes"/"no"` |
| Make Offer | `vehicle_offer: <amount>` |
| Request Owner Access | `owner_details_access: "yes"/"no"` |
| Request Vehicle Access | `vehicle_details_access: "yes"/"no"` |
| Request Inspection | `inspection_request: "yes"/"no"` |

**Response:** `UserInterestResponse`

```json
{
  "status": "success",
  "code": 200,
  "message": "Interest recorded successfully"
}
```

---

### 3.4 Supporting Data APIs

#### Get Vehicle Categories

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/categories`
- **Purpose:** Fetch all vehicle categories with form field configs

**Response:** `List<VehicleCategory>`

#### Get Vehicle Brands

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/brands`
- **Purpose:** Fetch all vehicle brands

**Response:** `List<VehicleBrand>`

#### Get Vehicle Tyres

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/tyres`
- **Purpose:** Fetch tyre count options

**Response:** `List<VehicleTire>`

#### Get States

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/states`
- **Purpose:** Fetch all states

#### Get Cities by State

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/cities`
- **Query:** `state_code`
- **Purpose:** Fetch cities for a state

#### Get Form Fields by Category

- **Method:** `GET`
- **Endpoint:** `/api/v1/vehicles/form-fields`
- **Query:** `category_code`
- **Purpose:** Fetch dynamic form field configuration for a category

---

## 4. Data Models

### 4.1 BuyVehicle

```dart
class BuyVehicle {
  final String sbVehicleId;
  final String categoryName;
  final String categoryCode;
  final String brandName;
  final String brandCode;
  final String model;
  final String registrationNumber;
  final int manufacturingYear;
  final double price;
  final String city;
  final String state;
  final String fuelType;
  final String? bodyType;
  final String? tonnage;
  final String? odometer;
  final List<String> imageUrls;
  final String status;
  final String approved;
  final String isSold;
  final String createdAt;
}
```

**File:** `lib/modules/buy_and_sell/models/list_buy_vehicles_response.dart`

### 4.2 SellVehicle

```dart
class SellVehicle {
  final String sbVehicleId;
  final String categoryName;
  final String brandName;
  final String model;
  final String registrationNumber;
  final double price;
  final String status;        // pending, approved, rejected
  final String approved;      // yes, no
  final String isSold;        // yes, no
  final String? rejectionReason;
  final List<String> imageUrls;
  final String createdAt;
}
```

**File:** `lib/modules/buy_and_sell/models/list_sell_vehicles_response.dart`

### 4.3 SubscribedVehicle

```dart
class SubscribedVehicle {
  final String sbVehicleId;
  final String categoryName;
  final String categoryCode;
  final String brandName;
  final String model;
  final String registrationNumber;
  final double price;
  final String subscriptionType;
  final String subscriptionExpiry;
  final List<String> imageUrls;
}
```

**File:** `lib/modules/buy_and_sell/models/list_buy_subscribed_vechile_res.dart`

### 4.4 VehicleBrand

```dart
class VehicleBrand {
  final String brandCode;
  final String brandName;
  final String displayName;
}
```

**File:** `lib/modules/buy_and_sell/models/vehicle_brand_model.dart`

### 4.5 VehicleCategory

```dart
class VehicleCategory {
  final String categoryCode;
  final String categoryName;
  final List<FormFieldConfig> formFields;
}
```

**File:** `lib/modules/buy_and_sell/models/vehicle_category_model.dart`

### 4.6 VehicleTire

```dart
class VehicleTire {
  final String tyreCode;
  final String displayName;
}
```

**File:** `lib/modules/buy_and_sell/models/vehicle_tire_model.dart`

### 4.7 FormFieldModel

```dart
class FormFieldModel {
  final String fieldName;
  final String fieldType;    // text, number, dropdown, file, boolean, date
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final dynamic defaultValue;
  final String? validationRegex;
  final String? apiFieldName;  // Maps to API field name
}
```

**File:** `lib/modules/buy_and_sell/models/form_field_model.dart`

---

## 5. State Management (Controller)

### 5.1 Controller Overview

**File:** `lib/modules/buy_and_sell/controllers/buy_sell_controller.dart` (4962 lines)

The `BuySellController` extends `GetxController` and manages all state for the Buy & Sell module.

### 5.2 Key Reactive Variables

```dart
// ==================== LISTS ====================
final RxList<BuyVehicle> buyVehiclesList = <BuyVehicle>[].obs;
final RxList<SellVehicle> sellVehiclesList = <SellVehicle>[].obs;
final RxList<SubscribedVehicle> subscribedVehiclesList = <SubscribedVehicle>[].obs;

// ==================== PAGINATION ====================
final RxInt buyVehiclesPage = 1.obs;
final RxInt buyVehiclesTotalPages = 1.obs;
final RxInt buyVehiclesTotalCount = 0.obs;
final RxBool hasMoreBuyVehicles = true.obs;

final RxInt sellVehiclesPage = 1.obs;
final RxBool hasMoreSellVehicles = true.obs;

final RxInt subscribedVehiclesPage = 1.obs;
final RxBool hasMoreSubscribedVehicles = true.obs;

// ==================== LOADING STATES ====================
final RxBool isLoadingBuyVehiclesList = false.obs;
final RxBool isLoadingSellVehiclesList = false.obs;
final RxBool isLoadingSubscribedVehicles = false.obs;
final RxBool isSubmittingSellForm = false.obs;
final RxBool isLoadingVehicleDetails = false.obs;

// ==================== SELL FORM STATE ====================
final RxList<DynamicFormField> dynamicFormFields = <DynamicFormField>[].obs;
final RxMap<String, dynamic> dynamicFormValues = <String, dynamic>{}.obs;
final RxMap<String, String?> dynamicFormErrors = <String, String?>{}.obs;
final RxList<File> vehicleImages = <File>[].obs;
final RxList<File> rcDocuments = <File>[].obs;
final RxList<File> insuranceDocuments = <File>[].obs;

// ==================== FILTER STATE ====================
final RxString selectedCategory = ''.obs;
final RxString selectedBrand = ''.obs;
final RxString selectedState = ''.obs;
final RxString selectedTyre = ''.obs;
final RxString selectedYear = ''.obs;
final RxString selectedBodyType = ''.obs;
final RxString selectedFuelType = ''.obs;
final RxString selectedKv = ''.obs;
final RxString selectedTonnage = ''.obs;
final TextEditingController searchController = TextEditingController();

// ==================== FILTER DATA ====================
final RxList<VehicleBrand> brands = <VehicleBrand>[].obs;
final RxList<VehicleTire> tyres = <VehicleTire>[].obs;
final RxList<VehicleCategory> categories = <VehicleCategory>[].obs;

// ==================== VEHICLE DETAILS STATE ====================
final RxList<dynamic> vechicleDetailsByID = [].obs;
final RxBool _isInterested = false.obs;
final RxBool _isSubmittingOffer = false.obs;
final RxBool _isSubscriptionLoading = false.obs;

// ==================== OTHER STATE ====================
final RxInt selectedTabIndex = 0.obs;  // 0=Buy, 1=Sell, 2=My Vehicles
```

### 5.3 Key Controller Methods

#### Sell Methods

| Method | Purpose |
|--------|---------|
| `fetchSellVehiclesList(isRefresh)` | Load user's posted vehicles with pagination |
| `loadMoreSellVehicles()` | Infinite scroll - load next page |
| `submitSellForm()` | Submit new vehicle for sale |
| `updateVehicle(vehicleId)` | Update existing vehicle |
| `updateVehicleSoldStatus(vehicleId, isSold)` | Mark vehicle as sold/unsold |
| `initializeDynamicForm(category)` | Load dynamic form fields for category |
| `validateAllDynamicFields()` | Validate entire sell form |
| `resetSellForm()` | Clear sell form state |

#### Buy Methods

| Method | Purpose |
|--------|---------|
| `fetchBuyVehiclesList(isRefresh)` | Load buy vehicles with pagination |
| `fetchBuyVehiclesWithFilters(...)` | Load with specific filters |
| `fetchBuyVehiclesByCategory(categoryCode)` | Load by category |
| `loadMoreBuyVehicles()` | Infinite scroll - load next page |
| `fetchBuyVehicleDetailsById(id, categoryCode)` | Get vehicle details |
| `refreshBuyVehiclesList()` | Pull-to-refresh |

#### Interest Methods

| Method | Purpose |
|--------|---------|
| `showInterest(vehicleId, interested)` | Toggle interest |
| `makeOffer(vehicleId, offerAmount)` | Submit price offer |
| `requestOwnerDetailsAccess(vehicleId, requestAccess)` | Request owner contact |
| `requestVehicleDetailsAccess(vehicleId, requestAccess)` | Request vehicle details |
| `requestVehicleInspection(vehicleId, requestInspection)` | Request inspection |

#### Filter Methods

| Method | Purpose |
|--------|---------|
| `fetchBrands()` | Load brand list |
| `fetchTyres()` | Load tyre options |
| `applyAllActiveFilters(categoryCode)` | Apply all current filter values |
| `clearAllFilters()` | Reset all filters |
| `getBrandByName(name)` | Lookup brand by name |
| `getTireByDisplayName(name)` | Lookup tyre by display name |

#### Subscription Methods

| Method | Purpose |
|--------|---------|
| `fetchSubscribedVehicles(isRefresh)` | Load subscribed vehicles |
| `loadMoreSubscribedVehicles()` | Load more subscribed |

#### Helper Methods

| Method | Purpose |
|--------|---------|
| `getBuyVehicleById(id)` | Find vehicle in buy list |
| `getBuyVehiclesByStatus(status)` | Filter buy list by status |
| `getApprovedBuyVehicles()` | Get only approved vehicles |
| `getPendingBuyVehicles()` | Get only pending vehicles |
| `getSubscribedVehicleById(id)` | Find vehicle in subscribed list |

---

## 6. UI Screens & User Flows

### 6.1 Main Dashboard (`buy_sell_home_view.dart`)

```
┌──────────────────────────────────────────┐
│          Buy & Sell Dashboard            │
├──────────────────────────────────────────┤
│  [Buy Tab]  [Sell Tab]  [My Vehicles]    │
├──────────────────────────────────────────┤
│                                          │
│  Tab Content Area (switches by tab)      │
│                                          │
└──────────────────────────────────────────┘
```

**Navigation:** Bottom tab navigation between Buy, Sell, and My Vehicles
**State:** `selectedTabIndex` tracks active tab

### 6.2 Buy Tab (`buy_view.dart`)

```
┌──────────────────────────────────────────┐
│  [Search Bar 🔍]      [Filter Icon ⚙️]  │
├──────────────────────────────────────────┤
│  Category Chips:                         │
│  [All] [Truck] [Bus] [Car] [Tipper] ...  │
├──────────────────────────────────────────┤
│                                          │
│  VehicleCard 1                           │
│  ├── Image                               │
│  ├── Brand, Model                        │
│  ├── Price: ₹25,00,000                   │
│  ├── Year: 2023 | Fuel: Diesel           │
│  └── [View Details]                      │
│                                          │
│  VehicleCard 2                           │
│  ...                                     │
│                                          │
│  [Loading More...]                       │
└──────────────────────────────────────────┘
```

**Features:**
- Search by keyword
- Category filter chips
- Advanced filter bottom sheet
- Infinite scroll pagination
- Pull-to-refresh

### 6.3 Sell Tab (`sell_view.dart`)

```
┌──────────────────────────────────────────┐
│         Post Your Vehicle                │
├──────────────────────────────────────────┤
│                                          │
│  Step 1: Select Category                 │
│  [Category Dropdown]                     │
│                                          │
│  Step 2: Fill Vehicle Details            │
│  [Dynamic Form Fields]                   │
│  ├── Brand (autocomplete/dropdown)       │
│  ├── Model                               │
│  ├── Registration Number                 │
│  ├── Manufacturing Year                  │
│  ├── Chassis Number                      │
│  ├── Price                               │
│  ├── Odometer                            │
│  ├── Number of Tyres                     │
│  ├── Owner Mobile                        │
│  ├── State                               │
│  ├── City                                │
│  ├── [Category-specific fields]          │
│  │   ├── Tonnage (trucks)                │
│  │   ├── Hours (machinery)               │
│  │   ├── Body Type                       │
│  │   ├── Fuel Type                       │
│  │   └── KV (generators)                 │
│  └── [Toggle fields]                     │
│      ├── Fitness Certificate             │
│      ├── Insurance                       │
│      ├── Original Invoice                │
│      └── GST Applicability               │
│                                          │
│  Step 3: Upload Documents                │
│  [Vehicle Images] (multiple, required)   │
│  [RC Document] (required)                │
│  [Insurance Document] (optional)         │
│                                          │
│  [Submit for Approval]                   │
└──────────────────────────────────────────┘
```

**Features:**
- Dynamic form fields based on category
- Autocomplete for brands
- Image upload with preview
- Document upload (RC, Insurance)
- Validation on all required fields
- "Other" option for brands, tipper types, body types, tyres

### 6.4 My Vehicles (`my_vehicles.dart`)

```
┌──────────────────────────────────────────┐
│          My Vehicles                     │
├──────────────────────────────────────────┤
│  Filter: [All] [Pending] [Approved]      │
│          [Sold] [Rejected]               │
├──────────────────────────────────────────┤
│                                          │
│  MyVehicleCard                           │
│  ├── Vehicle Image                       │
│  ├── Brand, Model                        │
│  ├── Status Badge: [Approved ✅]         │
│  ├── Price: ₹25,00,000                   │
│  ├── [Edit] [Mark as Sold]              │
│  └── [Delete]                            │
│                                          │
│  MyVehicleCard                           │
│  ├── Status Badge: [Pending ⏳]          │
│  └── [Edit]                              │
│                                          │
└──────────────────────────────────────────┘
```

### 6.5 Vehicle Details (`buy_vehicle_details.dart` / `buy_vehicle_details_new.dart`)

```
┌──────────────────────────────────────────┐
│  [← Back]     Vehicle Details            │
├──────────────────────────────────────────┤
│  ┌──────────────────────────────────┐    │
│  │  [Image Carousel / Gallery]      │    │
│  └──────────────────────────────────┘    │
│                                          │
│  Brand: TATA Signa 2518.T               │
│  Price: ₹25,00,000                       │
│  Year: 2023                              │
│  Registration: MH12AB1234                │
│  Fuel: Diesel | Body: Open               │
│  Odometer: 50,000 km                     │
│  Location: Pune, Maharashtra             │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │  📋 Vehicle Information          │    │
│  │  Chassis: MAT1234567890          │    │
│  │  Tonnage: 16 ton                 │    │
│  │  Tyres: 6                        │    │
│  │  Fitness: ✅ | Insurance: ✅     │    │
│  └──────────────────────────────────┘    │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │  📄 Documents                    │    │
│  │  [View RC] [View Insurance]      │    │
│  └──────────────────────────────────┘    │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │  👤 Owner Details                │    │
│  │  [Request Access 🔒]             │    │
│  │  (Requires subscription)         │    │
│  └──────────────────────────────────┘    │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │  ⭐ Actions                      │    │
│  │  [❤️ Show Interest]              │    │
│  │  [💰 Make Offer]                 │    │
│  │  [🔍 Request Inspection]         │    │
│  │  [📋 Vehicle Details Access]     │    │
│  └──────────────────────────────────┘    │
│                                          │
│  [📞 Contact Seller]                     │
└──────────────────────────────────────────┘
```

### 6.6 Edit Vehicle (`edit_vehicle_view.dart`)

Same as sell form but pre-populated with existing vehicle data.

### 6.7 Subscribed Vehicles (`subscribed_vehicle.dart`)

Lists vehicles the user has subscribed to with premium access badges.

---

## 7. Widgets & Components

### 7.1 BuyVehicleCard

**Path:** `widgets/buy_vehicle_card.dart`

**Purpose:** Display a buy vehicle in card format

**Features:**
- Vehicle image (with placeholder on error)
- Brand name, model
- Price (formatted with currency)
- Key specs (year, fuel, body type)
- Location (city, state)
- Status badge
- Tap to navigate to details

### 7.2 BuyItemCard

**Path:** `widgets/buy_item_card.dart`

**Purpose:** Compact vehicle card for list views

### 7.3 BuyItemShimmerCard

**Path:** `widgets/buy_item_shimmer_card.dart`

**Purpose:** Loading placeholder with shimmer animation

### 7.4 CategoryStyleBuyItemCard

**Path:** `widgets/category_style_buy_item_card.dart`

**Purpose:** Category-optimized card layout

### 7.5 CategoryStyleShimmerCard

**Path:** `widgets/category_style_shimmer_card.dart`

**Purpose:** Category-style loading placeholder

### 7.6 DynamicFormFieldWidget

**Path:** `widgets/dynamic_form_field_widget.dart`

**Purpose:** Renders form fields dynamically based on category configuration

**Supported Field Types:**
- `text` → TextFormField
- `number` → TextFormField with numeric keyboard
- `dropdown` → DropdownButtonFormField
- `autocomplete` → AutocompleteTextField (for brands)
- `file` → File picker (single/multiple)
- `boolean` → Switch/Toggle
- `date` → Date picker
- `toggle` → Toggle buttons (for insurance status)

### 7.7 ImageUploadPage

**Path:** `widgets/image_upload_page.dart`

**Purpose:** Multi-image upload with preview and reorder

**Features:**
- Pick from gallery/camera
- Preview thumbnails
- Remove individual images
- Maximum image count limit
- Image compression

### 7.8 EditableDocumentUploadWidget

**Path:** `widgets/editable_document_upload_widget.dart`

**Purpose:** Upload and manage vehicle documents (RC, Insurance)

### 7.9 InterestCard

**Path:** `widgets/interest_card.dart`

**Purpose:** Display and manage user interest actions

**Actions:**
- Show/Remove Interest
- Make Offer (with amount input)
- Request Owner Details Access
- Request Vehicle Details Access
- Request Inspection

### 7.10 BuySellSubscriptionPlan

**Path:** `widgets/buy_sell_subscription_plan.dart`

**Purpose:** Display subscription plan options

### 7.11 VehicleCategoryAutocomplete

**Path:** `widgets/vehicle_category_autocomplete.dart`

**Purpose:** Autocomplete field for vehicle categories

### 7.12 VechileDetails / VechileCard

**Path:** `widgets/vechileDetails.dart` / `widgets/vechile_card.dart`

**Purpose:** Generic vehicle details display and card components

---

## 8. Sell Vehicle Flow

### 8.1 Complete Sell Flow

```
User taps "Sell" tab
        │
        ▼
Select Vehicle Category
        │
        ▼
Dynamic Form Fields Loaded (from API)
        │
        ▼
User fills in details
        │
        ├── Brand (autocomplete or "Other")
        ├── Model
        ├── Registration Number
        ├── Manufacturing Year
        ├── Chassis Number
        ├── Price
        ├── Odometer
        ├── Tyres
        ├── Owner Mobile
        ├── State → City (cascading)
        ├── [Category-specific fields]
        └── [Toggle fields]
        │
        ▼
Upload Documents
        │
        ├── Vehicle Images (1-10 photos)
        ├── RC Document (required)
        └── Insurance Document (optional)
        │
        ▼
Client-side Validation
        │
        ├── Required fields check
        ├── Format validation (mobile, chassis, reg number)
        ├── Price range validation
        ├── Image count validation
        └── Document format validation
        │
        ▼
Submit to API (multipart/form-data)
        │
        ▼
Server Response
        │
        ├── Success → Show "Pending Approval" message
        │             Navigate to My Vehicles
        │
        └── Error → Show error message
                    Keep form state intact
        │
        ▼
Admin Reviews → Approve / Reject
        │
        ├── Approved → Vehicle appears in Buy listings
        │
        └── Rejected → Rejection reason shown
                       User can edit and resubmit
```

### 8.2 Dynamic Form System

The sell form is **dynamic** — fields change based on selected vehicle category.

**Flow:**
1. User selects category (e.g., "Truck")
2. Controller calls `VehicleCategoryService.getFormFieldsByCategory("TRUCK")`
3. API returns field configuration for that category
4. `DynamicFormFieldWidget` renders each field
5. Category-specific fields appear (e.g., Tonnage for trucks, KV for generators)

**Category-Specific Fields:**

| Category | Extra Fields |
|----------|-------------|
| Truck | Tonnage, Body Type |
| Tipper | Tonnage, Tipper Type |
| Bus | Seating Capacity |
| Car | Fuel Type, Body Type |
| Generator | KV Rating |
| Crane | Tonnage |
| Excavator | Hours |
| Roller | Tonnage |
| Tractor | HP Rating |
| LCV/ICV | Tonnage, Body Type |

### 8.3 Vehicle Edit Flow

```
My Vehicles → Tap "Edit" on a vehicle
        │
        ▼
EditVehicleView loads with pre-populated data
        │
        ├── Existing values filled in form
        ├── Existing images shown with option to add/remove
        ├── Existing documents shown with option to replace
        └── Modified fields highlighted
        │
        ▼
User makes changes
        │
        ▼
Client-side Validation
        │
        ▼
UpdateVehicleRequest sent (only changed fields)
        │
        ▼
Success → "Changes pending admin approval"
        │
        ▼
Admin Reviews updated vehicle → Approve / Reject
```

### 8.4 Mark as Sold Flow

```
My Vehicles → Tap "Mark as Sold"
        │
        ▼
Confirmation Dialog: "Mark this vehicle as sold?"
        │
        ├── Confirm → updateVehicleSoldStatus(id, "yes")
        │            → Vehicle badge shows "SOLD"
        │            → Vehicle hidden from Buy listings
        │
        └── Cancel → No action
```

---

## 9. Buy Vehicle Flow

### 9.1 Browse & Search Flow

```
User opens Buy tab
        │
        ▼
API call: fetchBuyVehiclesList(page: 1, limit: 10)
        │
        ▼
Vehicle cards displayed in list/grid
        │
        ├── Scroll down → loadMoreBuyVehicles()
        │                → fetch next page
        │                → append to list
        │
        ├── Pull down → refreshBuyVehiclesList()
        │             → reset to page 1
        │             → reload from API
        │
        ├── Search → searchController.text
        │          → debounce (300ms)
        │          → fetchBuyVehiclesWithFilters(search: query)
        │
        └── Category chip → fetchBuyVehiclesByCategory(code)
                          → filter by category
```

### 9.2 Filter Flow

```
User taps Filter icon
        │
        ▼
Filter Bottom Sheet opens
        │
        ├── Brand (autocomplete)
        ├── State
        ├── Tyre Count
        ├── Year
        ├── Body Type (dynamic)
        ├── Fuel Type (dynamic)
        ├── KV (dynamic)
        └── Tonnage (dynamic)
        │
        ▼
User selects filters
        │
        ▼
"Apply Filters" button
        │
        ▼
applyAllActiveFilters(categoryCode)
        │
        ▼
fetchBuyVehiclesWithFilters(
  categoryCode, brandCode, stateCode,
  tyreCode, year, bodyType, fuelType,
  kv, tonnage, search
)
        │
        ▼
Filtered results displayed
```

### 9.3 Category Browse Flow

```
Buy Tab → Category chip (e.g., "Truck")
        │
        ▼
fetchBuyVehiclesByCategory(categoryCode: "TRUCK")
        │
        ▼
BuyVehiclesView or SimpleVehicleListPage
        │
        ├── Category-specific cards
        ├── Category-specific filters available
        └── Infinite scroll pagination
```

---

## 10. Vehicle Details & Actions

### 10.1 Vehicle Details Page

**Features:**
- Image gallery/carousel
- Full vehicle specifications
- Document viewer (RC, Insurance)
- Action buttons (Interest, Offer, Inspection, Access)
- Owner details (if access granted)
- Contact seller (if access granted)

### 10.2 User Interest Actions

#### Show Interest

```
User taps "Show Interest" ❤️
        │
        ▼
showInterest(vehicleId: id, interested: true)
        │
        ▼
API: POST /user-interest { is_interested: "yes" }
        │
        ▼
Success → Heart icon filled
        → Snackbar: "Interest recorded"
        │
        ▼
Tap again → showInterest(interested: false)
         → Heart icon unfilled
         → Snackbar: "Interest removed"
```

#### Make Offer

```
User taps "Make Offer" 💰
        │
        ▼
Amount input dialog
        │
        ├── Enter offer amount
        ├── Validation: Must be > 0
        └── [Submit] / [Cancel]
        │
        ▼
makeOffer(vehicleId: id, offerAmount: 2300000)
        │
        ▼
API: POST /user-interest { vehicle_offer: 2300000 }
        │
        ▼
Success → Snackbar: "Offer of ₹23,00,000 submitted"
        │
        ▼
Error → Snackbar: "Failed to make offer"
```

#### Request Owner Details Access

```
User taps "Request Owner Access" 🔒
        │
        ▼
Confirmation dialog: "Request access to owner details?"
        │
        ├── Confirm → requestOwnerDetailsAccess(vehicleId, true)
        │           → API call
        │           → Refresh vehicle details
        │           → Owner info visible (if approved)
        │
        └── Cancel → No action
```

#### Request Vehicle Details Access

```
User taps "Vehicle Details Access" 📋
        │
        ▼
requestVehicleDetailsAccess(vehicleId, true)
        │
        ▼
API call → Refresh details → Extended info visible
```

#### Request Inspection

```
User taps "Request Inspection" 🔍
        │
        ▼
requestVehicleInspection(vehicleId, true)
        │
        ▼
API call → Refresh details → Inspection status shown
```

### 10.3 Card Expansion States

The vehicle details page uses expandable cards:

```dart
vehicleDetailCardExpanded = {
  'contact': false,    // Contact information
  'interest': false,   // Interest actions
  'schedule': false,   // Schedule viewing
  'share': false,      // Share options
}
```

Each card can be independently expanded/collapsed via `toggleCardExpansion(cardType)`.

---

## 11. Subscription & Payment Logic

### 11.1 Subscription Plans

**Widget:** `buy_sell_subscription_plan.dart`

The module supports subscription-based access to premium features:

| Feature | Free | Subscribed |
|---------|------|-----------|
| Browse vehicles | ✅ | ✅ |
| View basic details | ✅ | ✅ |
| Show interest | ✅ | ✅ |
| Owner details access | ❌ | ✅ |
| Vehicle details access | ❌ | ✅ |
| Make offers | Limited | ✅ |
| Request inspections | ❌ | ✅ |
| Direct contact | ❌ | ✅ |

### 11.2 Subscription Flow

```
User tries to access premium feature
        │
        ▼
Check subscription status
        │
        ├── Active → Grant access
        │
        └── No subscription / Expired
                │
                ▼
        Show subscription plan options
                │
                ▼
        User selects plan
                │
                ▼
        Payment gateway (PayU SDK)
                │
                ├── Success → Activate subscription
                │            → Grant access
                │
                └── Failed → Show error
                           → Retry option
```

### 11.3 Subscribed Vehicles

After subscribing, vehicles appear in the "Subscribed" list with:
- Premium badge
- Extended details visible
- Direct contact information
- Subscription expiry date

---

## 12. Filters & Search

### 12.1 Filter Dimensions

| Filter | Type | Source | Dependency |
|--------|------|--------|------------|
| Category | Chip/Dropdown | Static list | None |
| Brand | Autocomplete | API (`/vehicles/brands`) | None |
| State | Dropdown | Static list | None |
| Tyre Count | Dropdown | API (`/vehicles/tyres`) | None |
| Year | Dynamic | Category form config | Category |
| Body Type | Dynamic | Category form config | Category |
| Fuel Type | Dynamic | Category form config | Category |
| KV | Dynamic | Category form config | Category |
| Tonnage | Dynamic | Category form config | Category |
| Search | Text input | Free text | None |

### 12.2 Dynamic Filters

Some filters are **dynamic** — they come from the category's form field configuration:

```dart
// Get dynamic filter controller
final controller = getDynamicFilterController('Body Type');

// Get API value for the selected display value
final apiValue = getCurrentFilterApiValue('Body Type');
```

**Dynamic filter mapping:**
- Display value (e.g., "Open Body") → API value (e.g., "open")
- Stored in `dynamicFilterMappings` map

### 12.3 Search Implementation

```dart
// Debounced search
searchController.addListener(() {
  debounce(searchQuery, (_) {
    if (searchQuery.value.isNotEmpty) {
      fetchBuyVehiclesWithFilters(search: searchQuery.value);
    }
  }, time: Duration(milliseconds: 300));
});
```

### 12.4 Pagination

```
Page 1: Initial load (limit: 10)
        │
        ▼
Scroll to bottom detected
        │
        ▼
Check: hasMoreBuyVehicles && !isLoadingBuyVehiclesList
        │
        ├── Yes → loadMoreBuyVehicles()
        │       → page++
        │       → append results
        │
        └── No → Stop loading (all data loaded)
```

**Pagination State:**
```dart
buyVehiclesPage.value        // Current page
buyVehiclesTotalPages.value  // Total pages from API
buyVehiclesTotalCount.value  // Total items
hasMoreBuyVehicles.value     // Boolean: more data available
```

---

## 13. Business Rules & Validations

### 13.1 Sell Form Validation Rules

| Field | Rule | Error Message |
|-------|------|--------------|
| Category | Required | "Please select a category" |
| Brand | Required | "Please select a brand" |
| Model | Required, min 2 chars | "Please enter model name" |
| Registration | Required, format: `XX00XX0000` | "Invalid registration number" |
| Year | Required, 1900-current+1 | "Invalid manufacturing year" |
| Chassis | Required, min 10 chars | "Invalid chassis number" |
| Price | Required, > 0 | "Please enter valid price" |
| Owner Mobile | Required, 10 digits | "Invalid mobile number" |
| State | Required | "Please select state" |
| City | Required | "Please select city" |
| Images | At least 1, max 10 | "Please add at least 1 image" |
| RC Document | Required | "Please upload RC document" |

### 13.2 Status Transitions

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  DRAFT   │────▶│ PENDING  │────▶│ APPROVED │
└──────────┘     └──────────┘     └──────────┘
                       │                │
                       │                ▼
                       │           ┌──────────┐
                       │           │   SOLD   │
                       │           └──────────┘
                       │
                       ▼
                 ┌──────────┐
                 │ REJECTED │
                 └──────────┘
                       │
                       ▼
                 [Edit & Resubmit]
                       │
                       ▼
                 ┌──────────┐
                 │ PENDING  │
                 └──────────┘
```

| From | To | Trigger | Condition |
|------|----|---------|-----------|
| Draft | Pending | Submit form | All validations pass |
| Pending | Approved | Admin action | Admin reviews and approves |
| Pending | Rejected | Admin action | Admin rejects with reason |
| Approved | Sold | Seller action | Seller marks as sold |
| Rejected | Pending | Seller action | Edit and resubmit |
| Sold | — | Terminal state | Cannot be changed |

### 13.3 Permission Rules

| Action | Guest | Buyer | Seller | Admin |
|--------|-------|-------|--------|-------|
| View buy listings | ✅ | ✅ | ✅ | ✅ |
| View vehicle details | ✅ | ✅ | ✅ | ✅ |
| Show interest | ❌ | ✅ | ✅ | ✅ |
| Make offer | ❌ | ✅ | ✅ | ✅ |
| Request access | ❌ | ✅ | ❌ | ✅ |
| Post vehicle | ❌ | ❌ | ✅ | ✅ |
| Edit own vehicle | ❌ | ❌ | ✅ | ✅ |
| Mark as sold | ❌ | ❌ | ✅ | ✅ |
| Approve/reject | ❌ | ❌ | ❌ | ✅ |

### 13.4 Offer Rules

- Offer amount must be greater than 0
- Offer amount cannot exceed the listed price (recommended but not enforced)
- Multiple offers can be made on the same vehicle
- Latest offer overwrites previous offer
- Offer is visible to seller after submission

### 13.5 Access Rules

- Owner details access may require active subscription
- Vehicle details access may require active subscription
- Inspection requests are forwarded to admin/team
- Access grants are per-vehicle, not global

---

## 14. Role-Based Functionality

### 14.1 Seller/Vendor Workflow

```
1. Register/Login
2. Navigate to "Sell" tab
3. Select vehicle category
4. Fill dynamic form with vehicle details
5. Upload images and documents
6. Submit for approval
7. Wait for admin approval
8. Track status in "My Vehicles"
9. Edit/repost if rejected
10. Mark as sold when deal is done
```

### 14.2 Buyer Workflow

```
1. Register/Login
2. Navigate to "Buy" tab
3. Browse approved vehicles
4. Search/filter by category, brand, location
5. View vehicle details
6. Show interest / Make offer
7. Request owner details (may need subscription)
8. Request vehicle inspection
9. Contact seller
10. Complete purchase offline
```

### 14.3 Admin Workflow (Backend)

```
1. Review pending vehicle submissions
2. Approve or reject with reason
3. Monitor reported listings
4. Manage subscription plans
5. View analytics
```

---

## 15. Error & Loading Handling

### 15.1 Loading States

| State | Variable | UI Behavior |
|-------|----------|-------------|
| Buy list loading | `isLoadingBuyVehiclesList` | Shimmer cards |
| Sell list loading | `isLoadingSellVehiclesList` | Shimmer cards |
| Subscribed loading | `isLoadingSubscribedVehicles` | Shimmer cards |
| Form submitting | `isSubmittingSellForm` | Disabled button + spinner |
| Vehicle details loading | `isLoadingVehicleDetails` | Loading indicator |
| Interest loading | `isUserInterestLoading` | Button spinner |
| Offer submitting | `isSubmittingOffer` | Button spinner |
| Subscription loading | `isSubscriptionLoading` | Loading overlay |

### 15.2 Error Handling Pattern

```dart
try {
  isLoading.value = true;
  final response = await _apiRepository.someMethod(request);
  // Handle success
} catch (e) {
  Get.snackbar(
    'Error',
    'Failed to ...: ${e.toString()}',
    snackPosition: SnackPosition.TOP,
    backgroundColor: AppColors.red,
    colorText: AppColors.white,
  );
} finally {
  isLoading.value = false;
}
```

### 15.3 Empty States

| Screen | Empty State Message |
|--------|-------------------|
| Buy vehicles | "No vehicles found" |
| Buy vehicles (filtered) | "No vehicles found for selected filters" |
| Sell vehicles | "You haven't posted any vehicles yet" |
| Subscribed vehicles | "No subscribed vehicles" |
| Search results | "No results found for '{query}'" |

### 15.4 Error Recovery

| Error | Recovery |
|-------|----------|
| Network error | Show retry button |
| Auth error (401) | Redirect to login |
| Form validation error | Highlight invalid fields |
| API error | Show snackbar with message |
| Image upload error | Allow retry for failed uploads |

---

## 16. Reusable Services & Utilities

### 16.1 Services

| Service | File | Purpose |
|---------|------|---------|
| `VehicleCategoryService` | `services/vehicle_category_service.dart` | Fetch category-specific form configs |
| `ApiRepository` | `lib/core/services/` | All API calls |
| `StorageService` | `lib/core/services/` | Local storage, auth tokens, user ID |
| `NetworkService` | `lib/core/services/` | HTTP client |

### 16.2 Reusable Widgets

| Widget | Reuse Context |
|--------|--------------|
| `DynamicFormFieldWidget` | Any dynamic form system |
| `ImageUploadPage` | Any image upload flow |
| `EditableDocumentUploadWidget` | Any document upload |
| `VehicleCategoryAutocomplete` | Category selection anywhere |
| `BuySellSubscriptionPlan` | Subscription display |
| `InterestCard` | Any interest/action card |

### 16.3 Constants

| Constant | File | Purpose |
|----------|------|---------|
| `ApiConstants` | `lib/core/api/api_constant.dart` | API endpoints |
| `AppColors` | `lib/shared/constants/` | Color palette |
| `AssetConstants` | `lib/shared/constants/` | Icon/image paths |

### 16.4 Binding

**File:** `lib/modules/buy_and_sell/bindings/buy_sell_binding.dart`

```dart
class BuySellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuySellController>(() => BuySellController());
  }
}
```

---

## 17. Dependencies

### 17.1 Flutter Packages

| Package | Purpose |
|---------|---------|
| `get` | State management, navigation, DI |
| `image_picker` | Camera/gallery image selection |
| `file_picker` | Document file selection |
| `shimmer` | Loading placeholder animations |
| `cached_network_image` | Image caching |
| `flutter_svg` | SVG icon rendering |
| `intl` | Number/date formatting |

### 17.2 Internal Dependencies

| Module | Dependency |
|--------|-----------|
| Auth Module | User ID, authentication |
| Payment Module | Subscription payments |
| Core API | HTTP client, interceptors |
| Core Services | Storage, network |

---

## 18. Edge Cases

| Scenario | Behavior |
|----------|----------|
| User not logged in | Redirect to login before sell/interest actions |
| Duplicate vehicle posting | Allowed (no dedup check) |
| Vehicle images too large | Compress before upload |
| Network timeout on submit | Show error, preserve form data |
| Category has no form fields | Show error: "Category not supported" |
| Empty buy list | Show empty state with illustration |
| Filter returns no results | "No vehicles found for filters" |
| Infinite scroll race condition | Guard with `isLoading` check |
| Image upload fails mid-way | Allow retry for failed images only |
| Vehicle sold by another user | Show "Vehicle no longer available" |
| Subscription expires mid-session | Gracefully degrade to free features |
| Offer amount is 0 | Validation error |
| Same user tries to buy own vehicle | Allow (self-purchase) |
| Multiple tabs open | Sync state via GetX observables |

---

## 19. Suggested Improvements

### 19.1 Current Limitations

1. **Monolithic Controller**: 4962-line controller should be split into multiple controllers
2. **No caching**: Vehicle lists are re-fetched every time
3. **No offline support**: No local storage of vehicle data
4. **No image compression on client**: Large images uploaded directly
5. **No retry logic**: Failed API calls don't auto-retry
6. **No analytics**: No tracking of user actions

### 19.2 UI/UX Improvements

1. Add skeleton loading instead of shimmer
2. Implement pull-to-refresh gesture on all lists
3. Add vehicle comparison feature
4. Add price range filter (min-max slider)
5. Implement virtual scrolling for large lists
6. Add "Recently Viewed" section
7. Add "Similar Vehicles" recommendations
8. Implement deep linking to vehicle details

### 19.3 Performance Optimizations

1. Implement pagination caching (store pages locally)
2. Lazy load images with progressive loading
3. Debounce all search inputs
4. Cache API responses for brands, tyres, categories
5. Use `const` widgets where possible
6. Implement `AutomaticKeepAliveClientMixin` for tab views

### 19.4 Code Refactoring

1. Split `BuySellController` into:
   - `BuyVehicleController`
   - `SellVehicleController`
   - `VehicleFilterController`
   - `VehicleDetailsController`
   - `UserInterestController`
   - `SubscriptionController`
2. Create abstract `BaseVehicleController` for shared logic
3. Implement repository pattern with interfaces
4. Add unit tests for all business logic
5. Add widget tests for all screens
6. Implement proper error types (not just strings)

### 19.5 Architecture Improvements

1. Use Riverpod or BLoC instead of GetX for better testability
2. Implement clean architecture layers (data/domain/presentation)
3. Add proper dependency injection with interfaces
4. Implement proper state machines for vehicle status
5. Add API response caching with TTL
6. Implement proper error handling with sealed classes

---

## Appendix: File Reference Map

| File | Lines | Purpose |
|------|-------|---------|
| `controllers/buy_sell_controller.dart` | 4962 | Main controller — ALL state & logic |
| `controllers/clean_vehicle_controller.dart` | — | Clean/reset vehicle state utility |
| `views/buy_sell_home_view.dart` | — | Main tabbed view |
| `views/buy_view.dart` | — | Buy tab content |
| `views/sell_view.dart` | — | Sell tab/form |
| `views/my_vehicles.dart` | — | My vehicles list |
| `views/buy_vehicles_list_view.dart` | — | Buy vehicles list page |
| `views/buy_vehicles_view.dart` | — | Buy vehicles by category |
| `views/edit_vehicle_view.dart` | — | Edit vehicle form |
| `views/subscribed_vehicle.dart` | — | Subscribed vehicles list |
| `views/simple_vehicle_list_page.dart` | — | Simple vehicle list |
| `views/buy_sell_dashboard.dart` | — | Dashboard view |
| `models/*.dart` | — | All data models |
| `services/vehicle_category_service.dart` | — | Category form service |
| `widgets/*.dart` | — | All UI components |
| `bindings/buy_sell_binding.dart` | — | GetX binding |

---

## Appendix: API Endpoint Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/sell-buy/list-buy-vehicles` | GET | List buy vehicles with filters |
| `/sell-buy/vehicle-details` | GET | Vehicle details by ID |
| `/sell-buy/list-subscribed-vehicles` | GET | List subscribed vehicles |
| `/sell-buy/list-sell-vehicles` | GET | List user's sell vehicles |
| `/sell-buy/create-sell-vehicle` | POST | Create sell vehicle (multipart) |
| `/sell-buy/update-sell-vehicle` | POST | Update sell vehicle (multipart) |
| `/sell-buy/update-vehicle-sold` | POST | Mark vehicle sold/unsold |
| `/sell-buy/user-interest` | POST | User interest/offer/access/inspection |
| `/vehicles/categories` | GET | Vehicle categories |
| `/vehicles/brands` | GET | Vehicle brands |
| `/vehicles/tyres` | GET | Tyre options |
| `/vehicles/states` | GET | States list |
| `/vehicles/cities` | GET | Cities by state |
| `/vehicles/form-fields` | GET | Form fields by category |

---

> **Note:** This documentation captures the complete business logic and architecture of the Buy & Sell module as implemented in the Flutter codebase. The API endpoints are based on the `ApiConstants` definitions and the request/response models. Actual endpoint URLs may vary based on the backend configuration.
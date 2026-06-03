# Spare & FMS Module — Complete Documentation

> **Purpose**: This document provides a comprehensive overview of the **Spare & FMS (Fleet Management Services)** module from the Vahaan Bazar mobile Flutter app. It is intended to serve as a reference guide for recreating the module in another project with a different architecture.

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Directory Structure](#2-directory-structure)
3. [Architecture & Design Patterns](#3-architecture--design-patterns)
4. [Dependencies & Shared Services](#4-dependencies--shared-services)
5. [API Endpoints](#5-api-endpoints)
6. [Data Models](#6-data-models)
7. [Repository Layer](#7-repository-layer)
8. [Controllers (State Management)](#8-controllers-state-management)
9. [Views (UI Screens)](#9-views-ui-screens)
10. [Widgets (Reusable Components)](#10-widgets-reusable-components)
11. [Bindings (Dependency Injection)](#11-bindings-dependency-injection)
12. [Key Flows & Business Logic](#12-key-flows--business-logic)
13. [Navigation & Routes](#13-navigation--routes)
14. [Error Handling Patterns](#14-error-handling-patterns)
15. [Recreation Checklist](#15-recreation-checklist)

---

## 1. Module Overview

The **Spare & FMS** module provides two main features:

### 1.1 Spare Parts (E-commerce)
- Browse spare parts catalog with pagination
- View spare part details (images, price, description, suits-for info)
- Record interest in a spare part (creates an order/booking)
- View "My Bookings" — list of spare orders placed by the user
- Navigate to order detail view

### 1.2 FMS — Fleet Management Services (Shops)
- Browse shops near the user's GPS location
- Filter shops by category type: **CE** (Construction Equipment) or **CV** (Commercial Vehicle)
- View shop details with distance, rating, address
- Subscribe to a shop for contact access (paid flow via subscription plan)
- Subscription source: `SUBT007`

### 1.3 Module Entry Point
The module uses a **3-tab layout**:
- **Tab 0: Spare** — Spare parts browsing & interest recording
- **Tab 1: FMS** — E-commerce spare parts listing (alternative view)
- **Tab 2: Spare Support** — Shop listing by category (CE/CV) with location-based search

---

## 2. Directory Structure

```
lib/modules/spare_and_fms/
├── bindings/
│   └── spare_and_fms_binding.dart          # GetX dependency injection binding
├── controllers/
│   ├── spare_and_fms_controller.dart       # Main controller (1669 lines) — location, shops, orders, subscriptions
│   └── spare_parts_controller.dart         # Simpler controller (288 lines) — tab management, spare interest
├── models/
│   ├── spare_parts_models.dart             # SparePart, SpareOrder, pagination, request/response models (580 lines)
│   ├── spare_orders_model.dart             # Spare order specific models
│   └── shop_models.dart                    # Shop, ShopListResponse, UserLocation, ShopPagination (151 lines)
├── services/
│   └── spare_parts_repository.dart         # Repository layer — all API calls (277 lines)
├── views/
│   ├── spare_parts_view.dart               # Main entry view with TabBar
│   ├── spare_parts_tab_view.dart           # Spare parts catalog tab
│   ├── fms_tab_view.dart                   # FMS e-commerce tab
│   ├── fms_detail_view.dart                # Spare part detail view
│   ├── shop_list_view.dart                 # Shop listing with category filter
│   ├── spare_orders_view.dart              # "My Bookings" — user's spare orders
│   └── spare_support_tab_view.dart         # Spare support tab with shop categories
└── widgets/
    └── shop_card.dart                      # Reusable shop card widget
```

---

## 3. Architecture & Design Patterns

### 3.1 State Management: GetX
The module uses **GetX** as the primary framework for:
- **State Management**: Reactive observables (`Rx` types: `.obs`, `RxList`, `RxInt`, `RxBool`, `RxString`)
- **Dependency Injection**: `Get.put()`, `Get.lazyPut()` with `fenix: true`
- **Navigation**: `Get.toNamed()`, `Get.back()`, `Get.dialog()`
- **Service Location**: `Get.find<T>()`

### 3.2 Architecture Pattern: Repository Pattern
```
Views → Controllers → Repository → NetworkService (Dio) → API
```

- **Views**: Pure UI widgets, observe controller state via `Obx()`
- **Controllers**: Business logic, state management, coordinate between views and repository
- **Repository**: Single source of truth for API calls, handles HTTP requests/responses
- **NetworkService**: Core service wrapping Dio HTTP client (provided by app core)
- **Models**: Data classes with `fromJson()`/`toJson()` serialization

### 3.3 Reactive State Pattern
```dart
// Reactive variables
var isLoading = false.obs;
var sparesList = <SparePart>[].obs;
var currentTabIndex = 0.obs;

// In UI - Obx widget
Obx(() => isLoading.value 
  ? CircularProgressIndicator() 
  : ListView.builder(...)
)

// In Controller - update state
isLoading.value = true;
sparesList.assignAll(newData);
isLoading.value = false;
```

### 3.4 Tab Controller Pattern
```dart
class Controller extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var currentTabIndex = 0.obs;
  final List<String> tabs = ['Spare', 'FMS'];
  
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChanged);
  }
  
  void _onTabChanged() {
    currentTabIndex.value = tabController.index;
    _loadTabData(tabController.index);
  }
}
```

### 3.5 App Lifecycle Observer Pattern
```dart
class Controller extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Handle app resume logic
    }
  }
}
```

---

## 4. Dependencies & Shared Services

### 4.1 Internal Dependencies (from `lib/core/`)

| Service | Import Path | Purpose |
|---------|-------------|---------|
| `StorageService` | `core/services/storage_service.dart` | Local storage — get user ID, save subscription source, pending shop ID |
| `LocationService` | `core/services/location_service.dart` | GPS location — get current location, check if enabled, open settings |
| `NetworkService` | `core/services/network_service.dart` | HTTP client (Dio wrapper) — POST/GET requests |
| `ApiConstants` | `core/api/api_constant.dart` | API endpoint constants |
| `AppColors` | `core/constants/app_colors.dart` | Color constants (primary, warning, info, textPrimary, etc.) |
| `AppTextStyles` | `core/constants/app_text_styles.dart` | Text style helper (`getPoppinsStyle()`) |
| `AppRoutes` | `routes/app_routes.dart` | Route name constants |

### 4.2 Shared Widgets

| Widget | Import Path | Purpose |
|--------|-------------|---------|
| `FinanceSuccessDialog` | `shared/widgets/finance_success_dialog.dart` | Success popup shown after interest/subscription recording |

### 4.3 External Packages

| Package | Usage |
|---------|-------|
| `get` | State management, DI, navigation |
| `geolocator` | GPS location permission and position |
| `flutter/material.dart` | UI framework |

---

## 5. API Endpoints

All endpoints are under the base prefix: **`/api/v1/spares-fms`**

Base URL: `https://api.prod.vahaanbazar.in`

### 5.1 Endpoints Summary

| # | Constant Name | Endpoint Path | HTTP Method | Description |
|---|---------------|---------------|-------------|-------------|
| 1 | `listSparesEndpoint` | `/api/v1/spares-fms/list-spares` | POST | Fetch paginated spare parts list |
| 2 | `listShopsEndpoint` | `/api/v1/spares-fms/list-shops` | POST | Fetch shops list (basic or with location/category filter) |
| 3 | `userSpareInterestEndpoint` | `/api/v1/spares-fms/user-spare-interest` | POST | Record user interest in a spare part |
| 4 | `userShopSubscriptionEndpoint` | `/api/v1/spares-fms/user-shop-subscription` | POST | Subscribe to a shop / Record shop subscription |
| 5 | `userSparesOrdersListingEndpoint` | `/api/v1/spares-fms/user-spares-orders-listing` | POST | Fetch user's spare orders (My Bookings) |

### 5.2 Endpoint Details

#### 5.2.1 List Spares (`/api/v1/spares-fms/list-spares`)

**Request Body:**
```json
{
  "page": 1,
  "limit": 20,
  "user_id": "optional-user-id"
}
```

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Spares fetched successfully",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    "count": 50,
    "spares": [
      {
        "id": 1,
        "spare_part_id": "SP001",
        "spare_name": "Brake Pad",
        "spare_description": "High quality brake pad",
        "suits_for": "Tata Ace",
        "price": "1500",
        "photos": "url1,url2",
        "status": "active",
        "star_rating": "4.5",
        "inserted_at": "2024-01-01",
        "modified_by": "admin",
        "modified_at": "2024-01-01"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_count": 50,
      "limit": 10,
      "has_next": true,
      "has_previous": false
    }
  }
}
```

**Used In:**
- `SparePartsRepository.getSparesList()`
- `SpareAndFmsController._loadFmsData()`
- `SparePartsController._loadFmsData()`

---

#### 5.2.2 List Shops (`/api/v1/spares-fms/list-shops`)

**Request Body (Basic):**
```json
{
  "page": 1,
  "limit": 20,
  "user_id": "optional-user-id"
}
```

**Request Body (With Location & Category Filter):**
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "shop_category_type": "CE",
  "user_id": "user-id",
  "page": 1,
  "limit": 20
}
```

> `shop_category_type` values: `"CE"` (Construction Equipment) or `"CV"` (Commercial Vehicle)

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Shops fetched successfully",
  "data": {
    "user_location": {
      "latitude": 12.9716,
      "longitude": 77.5946
    },
    "count": 25,
    "shops": [
      {
        "id": 1,
        "shop_id": "SH001",
        "shop_name": "ABC Spare Parts",
        "address_line1": "123 Main Street",
        "address_line2": "Bangalore",
        "state": "Karnataka",
        "mobile_number": "9876543210",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "type": "retail",
        "category": "CE",
        "status": "active",
        "priority": "1",
        "star_rating": "4.2",
        "distance_km": 2.5
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_count": 25,
      "limit": 20,
      "has_next": true,
      "has_previous": false
    }
  }
}
```

**Used In:**
- `SparePartsRepository.getShopsList()` — basic call
- `SparePartsRepository.getShopsListByCategory()` — with lat/lng + category
- `SpareAndFmsController.loadShopsByCategory()`

---

#### 5.2.3 User Spare Interest (`/api/v1/spares-fms/user-spare-interest`)

**Request Body:**
```json
{
  "spare_id": "SP001",
  "user_id": "user-id"
}
```

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Interest recorded successfully",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    "id": 1,
    "spare_order_id": "SO001",
    "user_id": "user-id",
    "spare_id": "SP001",
    "order_status": "pending",
    "spare_name": "Brake Pad",
    "spare_price": "1500",
    "inserted_at": "2024-01-01",
    "modified_at": "2024-01-01"
  }
}
```

**Used In:**
- `SparePartsRepository.recordSpareInterest()`
- `SpareAndFmsController.recordSpareInterest()`
- `SparePartsController.recordSpareInterest()`

---

#### 5.2.4 User Shop Subscription (`/api/v1/spares-fms/user-shop-subscription`)

**Request Body (Record Subscription):**
```json
{
  "shop_id": "SH001",
  "user_id": "user-id"
}
```

**Request Body (Create Subscription with Number Access):**
```json
{
  "shop_id": "SH001",
  "user_id": "user-id",
  "number_access_subscription": "yes"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Shop subscription created successfully"
}
```

**Used In:**
- `SparePartsRepository.recordShopSubscription()` — basic
- `SparePartsRepository.createShopSubscription()` — with number access
- `SpareAndFmsController.handleShopSubscriptionPaymentSuccess()`
- `SpareAndFmsController.subscribeToShop()`

---

#### 5.2.5 User Spares Orders Listing (`/api/v1/spares-fms/user-spares-orders-listing`)

**Request Body:**
```json
{
  "user_id": "user-id",
  "page": 1,
  "limit": 20
}
```

**Response:**
```json
{
  "status": "success",
  "code": 200,
  "message": "Orders fetched successfully",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    "orders": [
      {
        "id": 1,
        "spare_order_id": "SO001",
        "order_status": "pending",
        "order_inserted_at": "2024-01-01",
        "order_modified_at": "2024-01-01",
        "spare_id": "SP001",
        "spare_name": "Brake Pad",
        "spare_description": "High quality brake pad",
        "suits_for": "Tata Ace",
        "price": "1500",
        "photos": "url1,url2",
        "spare_status": "active",
        "star_rating": "4.5",
        "spare_inserted_at": "2024-01-01",
        "spare_modified_at": "2024-01-01"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 50,
      "limit": 20,
      "has_next": true,
      "has_previous": false
    }
  }
}
```

**Used In:**
- `SparePartsRepository.getUserSparesOrders()`
- `SpareAndFmsController.loadUserSpareOrders()`
- `SpareAndFmsController.loadMoreSpareOrders()`

---

### 5.3 API Constant Definitions (in code)

```dart
static const String sparePartsPrefix = '/api/v1/spares-fms';
static const String listShopsEndpoint = '$sparePartsPrefix/list-shops';
static const String listSparesEndpoint = '$sparePartsPrefix/list-spares';
static const String userSpareInterestEndpoint = '$sparePartsPrefix/user-spare-interest';
static const String userShopSubscriptionEndpoint = '$sparePartsPrefix/user-shop-subscription';
static const String userSparesOrdersListingEndpoint = '$sparePartsPrefix/user-spares-orders-listing';
```

---

## 6. Data Models

### 6.1 SparePart (`spare_parts_models.dart`)

Core model representing a spare part item.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| `id` | `int` | `id` | Database ID |
| `sparePartId` | `String` | `spare_part_id` | Unique spare part identifier |
| `spareName` | `String` | `spare_name` | Name of the spare part |
| `spareDescription` | `String` | `spare_description` | Description |
| `suitsFor` | `String` | `suits_for` | Vehicle models this part suits |
| `price` | `String` | `price` | Price (stored as string) |
| `photos` | `List<String>` | `photos` | Photo URLs (comma-separated string OR list) |
| `status` | `String` | `status` | Status (active/inactive) |
| `starRating` | `String` | `star_rating` | Rating (stored as string) |
| `insertedAt` | `String` | `inserted_at` | Creation timestamp |
| `modifiedBy` | `String` | `modified_by` | Last modifier |
| `modifiedAt` | `String` | `modified_at` | Last modification timestamp |

**Helper Getters:**
- `primaryPhoto` → first photo URL or empty string
- `priceAsDouble` → parsed price as double
- `ratingAsDouble` → parsed rating as double

**Photos Handling:**
```dart
// Photos can be comma-separated string or List
if (json['photos'] is String) {
  photosList = (json['photos'] as String).split(',').map((e) => e.trim()).toList();
} else if (json['photos'] is List) {
  photosList = List<String>.from(json['photos']);
}
```

---

### 6.2 SpareOrder (`spare_parts_models.dart`)

Represents a user's spare part order/booking. Includes both order and spare part data (denormalized).

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| `id` | `int` | `id` | Database ID |
| `spareOrderId` | `String` | `spare_order_id` | Unique order identifier |
| `orderStatus` | `String` | `order_status` | Order status (pending/confirmed/etc.) |
| `orderInsertedAt` | `String` | `order_inserted_at` | Order creation timestamp |
| `orderModifiedAt` | `String` | `order_modified_at` | Order modification timestamp |
| `spareId` | `String` | `spare_id` | Reference to spare part |
| `spareName` | `String` | `spare_name` | Spare part name |
| `spareDescription` | `String` | `spare_description` | Spare part description |
| `suitsFor` | `String` | `suits_for` | Vehicle compatibility |
| `price` | `String` | `price` | Price |
| `photos` | `List<String>` | `photos` | Photo URLs |
| `spareStatus` | `String` | `spare_status` | Spare part status |
| `starRating` | `String` | `star_rating` | Rating |
| `spareInsertedAt` | `String` | `spare_inserted_at` | Spare creation timestamp |
| `spareModifiedAt` | `String` | `spare_modified_at` | Spare modification timestamp |

**Key Method:**
```dart
/// Convert SpareOrder to SparePart for compatibility with existing UI components
SparePart toSparePart() {
  return SparePart(
    id: id,
    sparePartId: spareId,
    spareName: spareName,
    spareDescription: spareDescription,
    suitsFor: suitsFor,
    price: price,
    photos: photos,
    status: spareStatus,
    starRating: starRating,
    insertedAt: spareInsertedAt,
    modifiedBy: '',
    modifiedAt: spareModifiedAt,
  );
}
```

---

### 6.3 Shop (`shop_models.dart`)

Represents a shop/store in the FMS system.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| `id` | `int` | `id` | Database ID |
| `shopId` | `String` | `shop_id` | Unique shop identifier |
| `shopName` | `String` | `shop_name` | Shop name |
| `addressLine1` | `String` | `address_line1` | Address line 1 |
| `addressLine2` | `String` | `address_line2` | Address line 2 |
| `state` | `String` | `state` | State |
| `mobileNumber` | `String` | `mobile_number` | Contact number (may be empty/"null"/"0") |
| `latitude` | `double` | `latitude` | GPS latitude |
| `longitude` | `double` | `longitude` | GPS longitude |
| `type` | `String` | `type` | Shop type (retail/wholesale) |
| `category` | `String` | `category` | Category (CE/CV) |
| `status` | `String` | `status` | Status |
| `priority` | `String` | `priority` | Priority level |
| `starRating` | `String` | `star_rating` | Rating |
| `distanceKm` | `double` | `distance_km` | Distance from user in km |

**Helper Getter:**
- `ratingAsDouble` → parsed rating as double

---

### 6.4 Pagination Models

Three pagination models exist:

**SparePartPagination** (for spare parts list):
```dart
{
  current_page: int,
  total_pages: int,
  total_count: int,
  limit: int,
  has_next: bool,
  has_previous: bool
}
```

**ShopPagination** (for shops list):
```dart
{
  current_page: int,
  total_pages: int,
  total_count: int,
  limit: int,
  has_next: bool,
  has_previous: bool
}
```

**SpareOrderPagination** (for orders list):
```dart
{
  current_page: int,
  total_pages: int,
  total_items: int,   // Note: "total_items" not "total_count"
  limit: int,
  has_next: bool,
  has_previous: bool
}
```

---

### 6.5 Response Wrapper Models

| Model | Purpose | Contains |
|-------|---------|----------|
| `SparePartResponse` | Wraps list-spares response | `status`, `code`, `message`, `timestamp`, `data: SparePartData`, `error` |
| `SparePartData` | Data payload for spares | `count`, `spares: List<SparePart>`, `pagination: SparePartPagination` |
| `SpareInterestResponse` | Wraps spare-interest response | `status`, `code`, `message`, `timestamp`, `data: SpareInterestData`, `error` |
| `SpareInterestData` | Data payload for interest | `id`, `spareOrderId`, `userId`, `spareId`, `orderStatus`, `spareName`, `sparePrice`, timestamps |
| `SpareOrderResponse` | Wraps orders-listing response | `status`, `code`, `message`, `timestamp`, `data: SpareOrderData`, `error` |
| `SpareOrderData` | Data payload for orders | `orders: List<SpareOrder>`, `pagination: SpareOrderPagination` |
| `ShopListResponse` | Wraps list-shops response | `status`, `code`, `message`, `data: ShopData` |
| `ShopData` | Data payload for shops | `userLocation`, `count`, `shops: List<Shop>`, `pagination: ShopPagination` |
| `UserLocation` | User's GPS coordinates | `latitude`, `longitude` |

---

### 6.6 Request Models

**SpareInterestRequest:**
```dart
class SpareInterestRequest {
  final String spareId;
  final String userId;
  Map<String, dynamic> toJson() => {'spare_id': spareId, 'user_id': userId};
}
```

---

### 6.7 Additional Models (Defined but not actively used)

| Model | Purpose |
|-------|---------|
| `SpareCategory` | Category model with `id`, `name`, `description`, `iconUrl`, `itemCount` |
| `SupportTicket` | Support ticket model with `id`, `title`, `description`, `status`, `priority`, `createdAt` |

---

## 7. Repository Layer

### 7.1 Class: `SparePartsRepository extends GetxService`

Located at: `lib/modules/spare_and_fms/services/spare_parts_repository.dart`

**Dependencies:**
```dart
final NetworkService _networkService = Get.find<NetworkService>();
```

### 7.2 Methods

| Method | Endpoint | Parameters | Returns | Description |
|--------|----------|------------|---------|-------------|
| `getSparesList()` | `listSparesEndpoint` | `page`, `limit`, `userId?` | `Future<SparePartResponse>` | Fetch paginated spare parts |
| `recordSpareInterest()` | `userSpareInterestEndpoint` | `spareId`, `userId` | `Future<SpareInterestResponse>` | Record interest in spare part |
| `getShopsList()` | `listShopsEndpoint` | `page`, `limit`, `userId?` | `Future<Map<String, dynamic>>` | Basic shop list fetch |
| `getShopsListByCategory()` | `listShopsEndpoint` | `latitude`, `longitude`, `shopCategoryType`, `userId`, `page`, `limit` | `Future<ShopListResponse>` | Location-based shop list with category filter |
| `recordShopSubscription()` | `userShopSubscriptionEndpoint` | `shopId`, `userId` | `Future<Map<String, dynamic>>` | Record shop subscription |
| `createShopSubscription()` | `userShopSubscriptionEndpoint` | `shopId`, `userId`, `numberAccessSubscription` | `Future<Map<String, dynamic>>` | Create shop subscription with number access |
| `getUserSparesOrders()` | `userSparesOrdersListingEndpoint` | `page`, `limit`, `userId?` | `Future<SpareOrderResponse>` | Fetch user's spare orders |

### 7.3 Pattern for API Calls

```dart
Future<T> someApiCall({required params}) async {
  try {
    final requestData = {/* params */};
    final response = await _networkService.post(endpoint, data: requestData);
    
    if (response.statusCode == 200) {
      return ResponseModel.fromJson(response.data);
    } else {
      throw Exception('Failed: ${response.statusMessage}');
    }
  } catch (e) {
    rethrow;
  }
}
```

---

## 8. Controllers (State Management)

### 8.1 Main Controller: `SpareAndFmsController` (1669 lines)

Located at: `lib/modules/spare_and_fms/controllers/spare_and_fms_controller.dart`

**Mixins:** `GetSingleTickerProviderStateMixin`, `WidgetsBindingObserver`

#### 8.1.1 Reactive State Variables

```dart
// Tab management
var currentTabIndex = 0.obs;

// Loading states
var isLoading = false.obs;
var isSpareLoading = false.obs;
var isFmsLoading = false.obs;
var isRecordingInterest = false.obs;
var hasFmsInitiallyLoaded = false.obs;

// Data lists
var sparesList = <SparePart>[].obs;
var fmsList = <SparePart>[].obs;
var shopsList = <Map<String, dynamic>>[].obs;
var shopsListData = <Shop>[].obs;

// Shop state
var isShopsLoading = false.obs;
var hasShopsInitiallyLoaded = false.obs;
var currentShopCategory = ''.obs;

// Spare orders (My Bookings)
var spareOrdersList = <SpareOrder>[].obs;
var isSpareOrdersLoading = false.obs;
var spareOrdersCurrentPage = 1.obs;
var spareOrdersTotalPages = 1.obs;
var hasMoreSpareOrders = false.obs;
var isLoadingMoreSpareOrders = false.obs;

// FMS pagination
var currentPage = 1.obs;
var totalPages = 1.obs;
var hasMoreData = false.obs;
var isLoadingMore = false.obs;
```

#### 8.1.2 Key Methods

| Method | Description |
|--------|-------------|
| `onInit()` | Initialize tabs, listen to tab changes, register lifecycle observer, load initial data |
| `_initializeData()` | Get user ID, initialize location in background, load tab 0 data |
| `_initializeLocationInBackground()` | Get GPS location without blocking UI |
| `_loadTabData(tabIndex)` | Route to correct data loader based on tab index |
| `_loadFmsData(isRefresh)` | Load spare parts from API (page 1, limit 10) |
| `loadMoreFmsItems()` | Load next page of FMS items (pagination) |
| `refreshFmsData()` | Pull-to-refresh for FMS tab |
| `loadShopsByCategory(categoryType)` | Load shops near user filtered by CE/CV |
| `refreshShopsData()` | Pull-to-refresh for shops |
| `subscribeToShop(shop)` | Handle shop subscription flow |
| `_navigateToShopSubscriptionPlan(shop)` | Navigate to subscription plan with SUBT007 |
| `handleShopSubscriptionPaymentSuccess(shopId)` | Post-payment: call createShopSubscription API |
| `loadUserSpareOrders(isRefresh)` | Load user's spare orders with pagination |
| `loadMoreSpareOrders()` | Load next page of spare orders |
| `navigateToSpareOrderDetail(spareOrder)` | Navigate to FMS detail view with order data |
| `recordSpareInterest(spare)` | Record interest in a spare part |
| `enableLocationFromUI()` | Trigger location permission flow from UI |
| `refreshLocationAndReloadShops()` | Clear cached data, re-fetch GPS, reload shops |
| `forceCheckGpsStatus()` | Force GPS status check |
| `ensureLocationAvailable()` | Check and handle GPS availability |
| `hasShopMobileNumber(shop)` | Check if shop has valid mobile number |
| `getDisplayShopMobileNumber(shop)` | Get mobile number (subscription check TODO) |

#### 8.1.3 Location Handling Flow

```
1. _initializeLocationInBackground()
   └── _locationService.getCurrentLocation()
   
2. loadShopsByCategory(categoryType)
   └── _getUserLocation()
       ├── GPS enabled? → get lat/lng
       ├── Permission denied? → _showLocationPermissionDialog()
       │   └── User allows → request permission
       │       ├── Permanently denied → _showOpenSettingsDialog()
       │       └── Granted → get location
       └── GPS disabled? → _showEnableGpsDialog()
           └── User enables → Geolocator.openLocationSettings()
               └── On app resume → _showRetryAfterSettingsDialog()

3. Dialogs:
   - _showLocationPermissionDialog() — Request location permission
   - _showEnableGpsDialog() — Ask user to enable GPS
   - _showOpenSettingsDialog() — Open app settings for permanent denial
   - _showRetryAfterSettingsDialog() — Retry after returning from settings
```

#### 8.1.4 App Lifecycle Handling

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed && _openedLocationSettings) {
    Future.delayed(Duration(milliseconds: 300), () {
      _showRetryAfterSettingsDialog();
      _openedLocationSettings = false;
    });
  }
}
```

---

### 8.2 Secondary Controller: `SparePartsController` (288 lines)

Located at: `lib/modules/spare_and_fms/controllers/spare_parts_controller.dart`

A simpler controller focused on tab management and basic spare operations.

**Note:** This is a separate class with the same name `SpareAndFmsController` — in the actual codebase it's in a different file. For clarity, this document refers to it as the "secondary controller."

#### 8.2.1 Key Methods

| Method | Description |
|--------|-------------|
| `onInit()` | Initialize tab controller (2 tabs), load initial data |
| `_loadTabData(tabIndex)` | Tab 0: Spare (no-op), Tab 1: FMS data |
| `_loadFmsData()` | Load FMS spare parts (page 1, limit 10) |
| `loadMoreSpares()` | Pagination for spare parts |
| `recordSpareInterest(spare)` | Record interest → show success dialog |
| `recordShopSubscription(shopId)` | Record shop subscription → show success dialog |
| `refreshCurrentTab()` | Reload current tab data |
| `switchToTab(index)` | Programmatically switch tabs |

---

## 9. Views (UI Screens)

### 9.1 `spare_parts_view.dart` — Main Entry View

**Purpose:** Main screen with `TabBar` containing Spare and FMS tabs.

**Controller:** `SpareAndFmsController`

**Key Components:**
- `Scaffold` with `AppBar`
- `TabBar` with tabs: ['Spare', 'FMS']
- `TabBarView` loading `SparePartsTabView()` and `FmsTabView()`
- `Obx()` for reactive tab index updates

---

### 9.2 `spare_parts_tab_view.dart` — Spare Parts Catalog Tab

**Purpose:** Browse spare parts catalog with grid/list layout.

**Key Components:**
- Spare parts grid/list
- Image display from `photos` URLs
- Price, name, rating display
- "Show Interest" button per item
- Pull-to-refresh
- Infinite scroll pagination

---

### 9.3 `fms_tab_view.dart` — FMS E-commerce Tab

**Purpose:** E-commerce style listing of spare parts (alternative view).

**Key Components:**
- `Obx(() => isFmsLoading.value)` for loading state
- `ListView.builder` with spare part cards
- Pull-to-refresh via `RefreshIndicator`
- Scroll listener for infinite pagination (`loadMoreFmsItems()`)
- Empty state handling

---

### 9.4 `fms_detail_view.dart` — Spare Part Detail View

**Purpose:** Detailed view of a single spare part.

**Receives Arguments:**
```dart
{
  'sparePart': SparePart,
  'isFromOrders': bool,      // true if navigated from My Bookings
  'orderStatus': String,      // order status if from orders
  'orderId': String,          // order ID if from orders
}
```

**Key Components:**
- Image carousel/gallery from `sparePart.photos`
- Spare name, description, price, rating
- "Suits For" information
- "Book Now" / "Show Interest" button (or order status if from orders)
- Conditional UI based on `isFromOrders` flag

---

### 9.5 `shop_list_view.dart` — Shop Listing

**Purpose:** Display shops filtered by category (CE/CV) near user's location.

**Controller:** `SpareAndFmsController`

**Key Components:**
- Category selector (CE/CV toggle)
- `Obx(() => isShopsLoading.value)` for loading state
- `ListView.builder` with `ShopCard` widgets
- Location permission states handling
- Pull-to-refresh
- Empty state with "Enable Location" CTA

---

### 9.6 `spare_orders_view.dart` — My Bookings

**Purpose:** Display user's spare part orders/bookings.

**Key Components:**
- `Obx(() => isSpareOrdersLoading.value)` for loading state
- `ListView.builder` with order cards
- Order status display
- Infinite scroll pagination (`loadMoreSpareOrders()`)
- Tap to navigate to order detail
- Pull-to-refresh

---

### 9.7 `spare_support_tab_view.dart` — Spare Support Tab

**Purpose:** Entry point for spare support features — shows category options (CE/CV) for shop browsing.

**Key Components:**
- Category cards (CE and CV)
- Navigation to `ShopListView` with selected category
- "My Bookings" access point

---

## 10. Widgets (Reusable Components)

### 10.1 `ShopCard` (`widgets/shop_card.dart`)

**Purpose:** Reusable card widget for displaying shop information.

**Props/Parameters:**
- `Shop shop` — Shop data model
- `VoidCallback? onSubscribe` — Subscribe button callback
- `VoidCallback? onCall` — Call button callback (if number available)

**Key Features:**
- Shop name and address display
- Distance in km
- Star rating display
- Mobile number visibility (hidden until subscription)
- Category badge (CE/CV)
- Responsive layout

---

## 11. Bindings (Dependency Injection)

### 11.1 `SpareAndFmsBinding`

Located at: `lib/modules/spare_and_fms/bindings/spare_and_fms_binding.dart`

```dart
class SpareAndFmsBinding extends Bindings {
  @override
  void dependencies() {
    // Repository — lazy singleton
    Get.lazyPut<SparePartsRepository>(
      () => SparePartsRepository(),
      fenix: true,  // Recreate if disposed
    );
    
    // Controller — lazy singleton
    Get.lazyPut<SpareAndFmsController>(
      () => SpareAndFmsController(),
      fenix: true,  // Recreate if disposed
    );
  }
}
```

**Key Points:**
- `fenix: true` means the instance will be recreated if it was previously disposed
- Repository is registered before controller (controller depends on repository)
- Both use `lazyPut` — instantiated only when first accessed

---

## 12. Key Flows & Business Logic

### 12.1 Spare Parts Browsing Flow

```
User opens Spare & FMS module
    │
    ├── SpareAndFmsBinding.dependencies() called
    │   ├── SparePartsRepository registered
    │   └── SpareAndFmsController registered
    │
    ├── SpareAndFmsController.onInit()
    │   ├── TabController initialized (2 tabs)
    │   ├── Tab change listener added
    │   ├── _initializeData()
    │   │   ├── Get user ID from StorageService
    │   │   ├── _initializeLocationInBackground()
    │   │   └── _loadTabData(0) — default Spare tab
    │   └── WidgetsBindingObserver registered
    │
    └── User switches to FMS tab
        └── _loadFmsData()
            ├── POST /api/v1/spares-fms/list-spares {page:1, limit:10}
            ├── Parse SparePartResponse
            └── fmsList.assignAll(response.data.spares)
```

### 12.2 Spare Interest Recording Flow

```
User taps "Show Interest" on spare part
    │
    ├── recordSpareInterest(spare)
    │   ├── Check user logged in (currentUserId != null)
    │   ├── Set isRecordingInterest = true
    │   ├── POST /api/v1/spares-fms/user-spare-interest
    │   │   Body: {spare_id, user_id}
    │   ├── Parse SpareInterestResponse
    │   ├── Show FinanceSuccessDialog
    │   └── Set isRecordingInterest = false
    │
    └── On error: Show snackbar with error message
```

### 12.3 Shop Loading & Location Flow

```
User navigates to Shop List with category (CE/CV)
    │
    ├── loadShopsByCategory(categoryType)
    │   ├── Set isShopsLoading = true
    │   ├── _getUserLocation()
    │   │   ├── Check GPS enabled
    │   │   ├── Check location permission
    │   │   ├── Request permission if needed (with dialogs)
    │   │   └── Return {latitude, longitude} or null
    │   │
    │   ├── If location null → stop, show empty state
    │   │
    │   ├── POST /api/v1/spares-fms/list-shops
    │   │   Body: {latitude, longitude, shop_category_type, user_id, page:1, limit:20}
    │   ├── Parse ShopListResponse
    │   ├── shopsListData.assignAll(response.data.shops)
    │   └── Set isShopsLoading = false
    │
    └── Location permission permanently denied?
        └── _showOpenSettingsDialog()
            └── User taps "Settings"
                ├── _openedLocationSettings = true
                ├── openLocationSettings()
                └── On app resume → _showRetryAfterSettingsDialog()
```

### 12.4 Shop Subscription Payment Flow

```
User taps "Subscribe" on shop card
    │
    ├── subscribeToShop(shop)
    │   ├── Check mobile number availability
    │   ├── If empty → navigate to subscription plan
    │   └── If available → still navigate to subscription plan
    │
    ├── _navigateToShopSubscriptionPlan(shop)
    │   ├── Save shop_id to storage: _storageService.write('pending_shop_id', shop.shopId)
    │   ├── Save subscription source: _storageService.saveSubscriptionSource('SUBT007')
    │   └── Navigate to AppRoutes.singleSubscriptionPlan
    │       arguments: {
    │         subscriptionSource: 'SUBT007',
    │         shop: {shop_id, shop_name, category, mobile_number, distance_km, address}
    │       }
    │
    ├── After successful payment (PayU flow)
    │   └── handleShopSubscriptionPaymentSuccess(shopId)
    │       ├── POST /api/v1/spares-fms/user-shop-subscription
    │       │   Body: {shop_id, user_id, number_access_subscription: "yes"}
    │       ├── On success: Clear pending_shop_id, show success snackbar
    │       └── On error: Clear pending_shop_id, show error snackbar
    │
    └── refreshAfterShopPaymentSuccess()
        └── Reload shops for current category
```

### 12.5 Spare Orders (My Bookings) Flow

```
User opens My Bookings
    │
    ├── loadUserSpareOrders(isRefresh: true)
    │   ├── Reset spareOrdersCurrentPage = 1
    │   ├── Clear spareOrdersList
    │   ├── Set isSpareOrdersLoading = true
    │   ├── POST /api/v1/spares-fms/user-spares-orders-listing
    │   │   Body: {user_id, page: 1, limit: 20}
    │   ├── Parse SpareOrderResponse
    │   ├── spareOrdersList = orders
    │   ├── Update pagination state
    │   └── Set isSpareOrdersLoading = false
    │
    ├── User scrolls to bottom → loadMoreSpareOrders()
    │   ├── Increment spareOrdersCurrentPage
    │   ├── POST with next page
    │   ├── spareOrdersList.addAll(newOrders)
    │   └── Update hasMoreSpareOrders
    │
    └── User taps order → navigateToSpareOrderDetail(spareOrder)
        ├── Convert SpareOrder to SparePart via toSparePart()
        └── Navigate to AppRoutes.fmsDetail
            arguments: {
              sparePart, isFromOrders: true, orderStatus, orderId
            }
```

### 12.6 FMS Pagination Flow

```
Initial load: _loadFmsData()
    └── POST with page:1, limit:10

User scrolls → loadMoreFmsItems()
    ├── Check: !isLoadingMore && hasMoreData
    ├── isLoadingMore = true
    ├── currentPage++
    ├── POST with page:currentPage, limit:20
    ├── fmsList.addAll(newItems)
    ├── Update hasMoreData
    └── isLoadingMore = false

Pull to refresh → refreshFmsData()
    ├── currentPage = 1
    └── _loadFmsData(isRefresh: true)
```

---

## 13. Navigation & Routes

### 13.1 Route Constants Used

| Route Constant | Purpose | Used In |
|----------------|---------|---------|
| `AppRoutes.singleSubscriptionPlan` | Subscription plan page | `_navigateToShopSubscriptionPlan()` |
| `AppRoutes.fmsDetail` | Spare part detail page | `navigateToSpareOrderDetail()` |

### 13.2 Navigation Patterns

**Navigate with arguments:**
```dart
Get.toNamed(
  AppRoutes.fmsDetail,
  arguments: {
    'sparePart': sparePart,
    'isFromOrders': true,
    'orderStatus': spareOrder.orderStatus,
    'orderId': spareOrder.spareOrderId,
  },
);
```

**Navigate to subscription plan:**
```dart
Get.toNamed(
  AppRoutes.singleSubscriptionPlan,
  arguments: {
    'subscriptionSource': 'SUBT007',
    'shop': {
      'shop_id': shop.shopId,
      'shop_name': shop.shopName,
      'category': shop.category,
      'mobile_number': shop.mobileNumber,
      'distance_km': shop.distanceKm,
      'address': '${shop.addressLine1}, ${shop.addressLine2}',
    },
  },
);
```

**Show dialog:**
```dart
Get.dialog(
  AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    contentPadding: EdgeInsets.zero,
    content: Container(/* styled content */),
  ),
);
```

**Show snackbar:**
```dart
Get.snackbar(
  'Error',
  'Message',
  backgroundColor: Colors.red,
  colorText: Colors.white,
);
```

---

## 14. Error Handling Patterns

### 14.1 Try-Catch-Finally Pattern
```dart
try {
  isLoading.value = true;
  final response = await _repository.someMethod();
  if (response.status == 'success') {
    dataList.assignAll(response.data.items);
  } else {
    throw Exception(response.message);
  }
} catch (e) {
  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
} finally {
  isLoading.value = false;
}
```

### 14.2 Pagination Error Recovery
```dart
try {
  isLoadingMore.value = true;
  currentPage.value++;
  // ... API call ...
} catch (e) {
  currentPage.value--; // Revert page increment on error
} finally {
  isLoadingMore.value = false;
}
```

### 14.3 Location Error Handling
```dart
// Null return indicates location not available (dialog already shown)
final locationData = await _getUserLocation();
if (locationData == null) {
  isShopsLoading.value = false;
  hasShopsInitiallyLoaded.value = true;
  shopsListData.clear();
  return;
}
```

### 14.4 Mobile Number Validation
```dart
bool hasShopMobileNumber(Shop shop) {
  return shop.mobileNumber.isNotEmpty &&
      shop.mobileNumber != 'null' &&
      shop.mobileNumber != '0';
}
```

---

## 15. Recreation Checklist

When recreating this module in another project, ensure the following:

### 15.1 Core Services Required
- [ ] HTTP client service (equivalent to `NetworkService` with Dio)
- [ ] Local storage service (equivalent to `StorageService` for user ID, preferences)
- [ ] Location/GPS service (equivalent to `LocationService` for geolocation)
- [ ] API base URL configuration

### 15.2 Models to Create
- [ ] `SparePart` — with photos handling (comma-separated OR list)
- [ ] `SpareOrder` — with `toSparePart()` converter
- [ ] `Shop` — with `ratingAsDouble` getter
- [ ] `UserLocation`
- [ ] Pagination models (3 variants)
- [ ] Response wrapper models (SparePartResponse, ShopListResponse, etc.)
- [ ] Request models (SpareInterestRequest)

### 15.3 API Endpoints to Implement
- [ ] `POST /list-spares` — spare parts catalog
- [ ] `POST /list-shops` — shops list (basic + with location/category)
- [ ] `POST /user-spare-interest` — record spare interest
- [ ] `POST /user-shop-subscription` — shop subscription
- [ ] `POST /user-spares-orders-listing` — user's orders

### 15.4 Controllers to Create
- [ ] Main controller with tab management, location handling, shops, orders
- [ ] Secondary controller (simpler) for basic tab operations

### 15.5 UI Views to Create
- [ ] Main view with TabBar (Spare + FMS tabs)
- [ ] Spare parts catalog tab (grid/list with images)
- [ ] FMS e-commerce tab (list with pagination)
- [ ] Spare part detail view (image gallery, info, book button)
- [ ] Shop list view (category filter, location-based)
- [ ] My Bookings view (orders with pagination)
- [ ] Spare support tab (category entry point)

### 15.6 Widgets to Create
- [ ] Shop card component

### 15.7 External Integration Points
- [ ] Subscription plan navigation (SUBT007 source)
- [ ] Payment flow integration (PayU or equivalent)
- [ ] Success dialog component
- [ ] Route definitions for detail and subscription pages

### 15.8 State Management Requirements
- [ ] Reactive loading states (RxBool)
- [ ] Reactive data lists (RxList)
- [ ] Pagination state management
- [ ] Tab controller with change listener
- [ ] App lifecycle observer for settings flow

---

## Appendix A: File-by-File Summary

| File | Lines | Purpose |
|------|-------|---------|
| `models/spare_parts_models.dart` | 580 | SparePart, SpareOrder, pagination, request/response models, SpareCategory, SupportTicket |
| `models/shop_models.dart` | 151 | Shop, ShopListResponse, UserLocation, ShopPagination |
| `models/spare_orders_model.dart` | — | Spare order specific models |
| `controllers/spare_and_fms_controller.dart` | 1669 | Main controller: tabs, location, shops, orders, subscriptions, dialogs |
| `controllers/spare_parts_controller.dart` | 288 | Secondary controller: basic tab management, spare interest, shop subscription |
| `services/spare_parts_repository.dart` | 277 | Repository: 7 API methods covering 5 endpoints |
| `bindings/spare_and_fms_binding.dart` | 20 | DI binding for repository and controller |
| `views/spare_parts_view.dart` | — | Main entry with TabBar |
| `views/spare_parts_tab_view.dart` | — | Spare parts catalog |
| `views/fms_tab_view.dart` | — | FMS e-commerce listing |
| `views/fms_detail_view.dart` | — | Spare part detail |
| `views/shop_list_view.dart` | — | Shop listing with location |
| `views/spare_orders_view.dart` | — | My Bookings |
| `views/spare_support_tab_view.dart` | — | Spare support categories |
| `widgets/shop_card.dart` | — | Reusable shop card |

---

## Appendix B: Storage Keys Used

| Key | Type | Purpose |
|-----|------|---------|
| `pending_shop_id` | `String` | Stored before navigating to subscription plan, cleared after payment |
| `subscription_source` | `String` | Set to `SUBT007` for shop subscriptions |
| `user_id` | `String` | Current logged-in user ID |

---

## Appendix C: Subscription Source Mapping

| Source Code | Description | Module |
|-------------|-------------|--------|
| `SUBT007` | Shop contact number access subscription | Spare & FMS |

---

*Document generated from codebase analysis on 2026-03-06.*
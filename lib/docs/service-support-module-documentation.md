# Service Support Module — Complete Documentation

> **Purpose**: This document provides a comprehensive, field-level overview of the **Service Support** module from the Vahaan Bazar mobile Flutter app. It is intended to serve as a complete reference guide for recreating the module in another project with a different architecture — ensuring no feature, validation, field, or business logic is missed.

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Directory Structure](#2-directory-structure)
3. [Architecture & Design Patterns](#3-architecture--design-patterns)
4. [Dependencies & Shared Services](#4-dependencies--shared-services)
5. [API Endpoints](#5-api-endpoints)
6. [Data Models](#6-data-models)
7. [Service Support Home View — Complete UI Specification](#7-service-support-home-view--complete-ui-specification)
8. [Service Provider List View — Complete UI Specification](#8-service-provider-list-view--complete-ui-specification)
9. [Subscribed Mechanics View](#9-subscribed-mechanics-view)
10. [Controller State Variables](#10-controller-state-variables)
11. [Key Business Logic & Flows](#11-key-business-logic--flows)
12. [Location Permission Dialog Flows](#12-location-permission-dialog-flows)
13. [Subscription & Payment Flow](#13-subscription--payment-flow)
14. [Validation Strategy](#14-validation-strategy)
15. [Shared Widgets Used](#15-shared-widgets-used)
16. [Navigation & Routes](#16-navigation--routes)
17. [Error Handling Patterns](#17-error-handling-patterns)
18. [Recreation Checklist](#18-recreation-checklist)

---

## 1. Module Overview

The **Service Support** module provides vehicle owners with access to nearby mechanics/service providers based on their GPS location. It features subscription-gated mobile number access, meaning users must have an active subscription (type `SUBT006`) to view and call mechanic phone numbers.

| Feature | Description |
|---------|-------------|
| **Landing Page** | A promotional page showcasing "24/7 Breakdown Assistance" with a CTA button to find mechanics. |
| **Mechanic Listing** | A GPS-powered, paginated list of mechanics near the user's location. Shows garage name, mechanic name, address, distance, star rating, and subscription-gated phone numbers. |
| **Location Permission Flow** | Multi-step GPS + permission handling: GPS check → Enable GPS dialog → Permission request → App Settings → "Check Again" on app resume. |
| **Subscription Gate** | Users must have an active `SUBT006` subscription to view mechanic mobile numbers. Without subscription, clicking "Call" redirects to the subscription plan page. |
| **Subscribed Mechanics View** | Displays the user's active mechanic subscription details (mechanic ID, access level, dates). |

The module uses a **two-screen flow**: the landing page (`ServiceSupportView`) → the mechanic list (`ServiceProviderListView`), with a separate `SubscribedMechanicsView` accessible from the drawer.

---

## 2. Directory Structure

```
lib/modules/service_support/
├── bindings/
│   └── service_support_binding.dart              # GetX dependency injection binding
├── controllers/
│   └── service_support_controller.dart           # Main controller (1593 lines) — all state, location, subscription, pagination logic
├── models/
│   └── mechanic_model.dart                       # All data models — request/response classes, Mechanic, Pagination, Subscription
└── views/
    ├── service_support_view.dart                 # Landing page — "24/7 Breakdown Assistance" with "Contact Mechanic" CTA
    ├── service_provider_list_view.dart           # Mechanic list view — search, filter, pagination, pull-to-refresh
    └── subscribed_mechanics_view.dart            # Subscribed mechanics detail view
```

### Shared Dependencies (Outside Module)

```
lib/core/
├── api/
│   ├── api_constant.dart                         # API endpoint constants (serviceSupportPrefix, listMechanicsEndpoint, listMechanicsSubscriptionEndpoint)
│   └── api_repository.dart                       # API repository (listMechanics(), createMechanicSubscription(), getMySubscription())
├── constants/
│   ├── app_colors.dart                           # Color constants (AppColors.buttonPrimary, AppColors.success, AppColors.warning, etc.)
│   ├── app_images.dart                           # Image assets (AppImages.serviceSupport)
│   └── app_text_styles.dart                      # Text style helper (AppTextStyles.getPoppinsStyle())
├── services/
│   ├── storage_service.dart                      # SharedPreferences — getUserId(), userData, savePendingMechanicId(), removePendingMechanicId(), saveSubscriptionSource()
│   └── location_service.dart                     # GPS/Location — getCurrentLocation(), requestLocationPermission(), openLocationSettings(), hasLocation, isLocationEnabled, latitude, longitude

lib/shared/widgets/
├── custom_app_bar.dart                           # CustomAppBar widget
├── custom_button.dart                            # CustomButton widget
├── custom_drawer.dart                            # CustomDrawer widget (with categoryType: 'service_support')
└── ...

lib/routes/
├── app_routes.dart                               # Route name constants
└── app_pages.dart                                # Route page definitions
```

---

## 3. Architecture & Design Patterns

### Pattern: GetX Controller-Service-Model-View

```
┌──────────────────────┐     ┌──────────────────────────────────┐     ┌─────────────────────┐
│       Views           │────▶│    ServiceSupportController      │────▶│   ApiRepository     │
│ (UI Screens)          │     │  - GPS location management       │     │   (API Layer)       │
│ - ServiceSupportView  │     │  - Mechanic list state            │     └──────────┬──────────┘
│ - ServiceProviderList │     │  - Subscription checking          │                │
│ - SubscribedMechanics │     │  - Pagination logic               │     ┌──────────▼──────────┐
└──────────────────────┘     │  - Location permission dialogs    │     │   NetworkService    │
                              │  - App lifecycle observation       │     │   (Dio HTTP)        │
                              │  - Debounce & concurrency control  │     └─────────────────────┘
                              └──────────────────────────────────┘
                                           │
                              ┌─────────────┼─────────────┐
                              ▼             ▼             ▼
                        StorageService  LocationService  Geolocator
                        (SharedPrefs)   (GPS wrapper)    (Platform)
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **GPS-only (no default coordinates)** | Ensures mechanics shown are always relevant to user's actual location. If GPS fails, the user is prompted rather than showing stale/default data. |
| **Subscription gating via `SUBT006`** | A specific subscription type code (`SUBT006`) controls access to mechanic phone numbers. Checked via API (`getMySubscription`) with local storage fallback. |
| **App lifecycle observer** | The controller implements `WidgetsBindingObserver` to detect when the user returns from device settings (after enabling GPS/permissions) and shows a "Check Again" dialog. |
| **Debounce on refresh** | A 2-second minimum between refreshes prevents rapid duplicate API calls from UI interactions. |
| **Mutex for API calls** | `_isApiCallInProgress` flag prevents concurrent API calls, with a timeout mechanism (10s max wait). |
| **Controller cleanup on navigation** | The landing page deletes the existing `ServiceSupportController` before navigating to the list view to ensure fresh state. |

---

## 4. Dependencies & Shared Services

### Flutter/Dart Packages

| Package | Usage |
|---------|-------|
| `get` | State management (`.obs` observables), dependency injection (`Get.find`), navigation (`Get.toNamed`, `Get.back`, `Get.dialog`, `Get.snackbar`) |
| `geolocator` | Platform-level GPS checks (`Geolocator.isLocationServiceEnabled()`) |
| `flutter/material.dart` | UI framework, `WidgetsBindingObserver` for app lifecycle |

### Internal Services

| Service | Methods/Properties Used |
|---------|------------------------|
| `ApiRepository` | `listMechanics(ListMechanicsRequest)`, `createMechanicSubscription(MechanicSubscriptionRequest)`, `getMySubscription(MySubscriptionRequest)` |
| `StorageService` | `getUserId()`, `userData`, `setUserData()`, `savePendingMechanicId()`, `removePendingMechanicId()`, `saveSubscriptionSource()` |
| `LocationService` | `getCurrentLocation()`, `requestLocationPermission()`, `openLocationSettings()`, `hasLocation`, `isLocationEnabled`, `latitude`, `longitude` |

### Shared Widgets

| Widget | Import | Usage |
|--------|--------|-------|
| `CustomAppBar` | `shared/widgets/custom_app_bar.dart` | App bar with title |
| `CustomButton` | `shared/widgets/custom_button.dart` | "Contact Mechanic" CTA button |
| `CustomDrawer` | `shared/widgets/custom_drawer.dart` | Navigation drawer with `categoryType: 'service_support'` |
| `AppColors` | `core/constants/app_colors.dart` | Color constants |
| `AppTextStyles` | `core/constants/app_text_styles.dart` | `getPoppinsStyle()` helper |
| `AppImages` | `core/constants/app_images.dart` | `AppImages.serviceSupport` asset |

---

## 5. API Endpoints

### Base Configuration

```
Base URL: https://api.prod.vahaanbazar.in
API Key Header: X-API-Key: 7B0F2K4R1MSS3P0D
API Prefix: /api/v1/service-support
```

---

### 5.1 List Mechanics

**Endpoint**: `POST /api/v1/service-support/list-mechanics`

**Description**: Returns a paginated list of mechanics near the user's GPS location, ordered by distance.

#### Request Headers

| Header | Value |
|--------|-------|
| `Content-Type` | `application/json` |
| `Authorization` | `Bearer {access_token}` |
| `X-API-Key` | `7B0F2K4R1MSS3P0D` |

#### Request Body

```json
{
  "user_id": "string (required)",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "page": 1,
  "limit": 20
}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `user_id` | `string` | ✅ | — | Authenticated user's ID from storage |
| `latitude` | `double` | ✅ | — | User's current GPS latitude (no default fallback) |
| `longitude` | `double` | ✅ | — | User's current GPS longitude (no default fallback) |
| `page` | `int` | ❌ | `1` | Page number for pagination |
| `limit` | `int` | ❌ | `20` | Number of results per page |

#### Success Response (200)

```json
{
  "status": "success",
  "code": 200,
  "message": "Mechanics retrieved successfully",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "user_location": {
      "lat": 12.9716,
      "lon": 77.5946
    },
    "count": 45,
    "mechanics": [
      {
        "id": 1,
        "mechanic_id": "MECH001",
        "description": "Engine Repair, Body Work",
        "garage_name": "AutoCare Garage",
        "mechanic_name": "Rajesh Kumar",
        "address_line_1": "123 Main Street",
        "address_line_2": "Near Bus Stand",
        "state": "Karnataka",
        "pin_code": "560001",
        "mobile_number": "9876543210",
        "latitude": 12.9750,
        "longitude": 77.6000,
        "priority": "high",
        "star_rating": "4.5",
        "distance_km": 2.3
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_count": 45,
      "limit": 20,
      "has_next": true,
      "has_previous": false
    }
  },
  "error": null
}
```

#### Error Response (4xx/5xx)

```json
{
  "status": "error",
  "code": 400,
  "message": "Invalid coordinates",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": null,
  "error": { "detail": "Latitude and longitude are required" }
}
```

#### cURL Example

```bash
curl -X POST https://api.prod.vahaanbazar.in/api/v1/service-support/list-mechanics \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {access_token}" \
  -H "X-API-Key: 7B0F2K4R1MSS3P0D" \
  -d '{
    "user_id": "USER123",
    "latitude": 12.9716,
    "longitude": 77.5946,
    "page": 1,
    "limit": 20
  }'
```

---

### 5.2 User Mechanic Subscription (Create)

**Endpoint**: `POST /api/v1/service-support/user-mechanic-subscription`

**Description**: Creates a mechanic subscription record for the user, granting access to the mechanic's mobile number after successful payment.

#### Request Body

```json
{
  "user_id": "string (required)",
  "mechanic_id": "string (required)",
  "number_access_subscription": "yes"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | `string` | ✅ | Authenticated user's ID |
| `mechanic_id` | `string` | ✅ | The mechanic's unique ID (e.g., `MECH001`) |
| `number_access_subscription` | `string` | ✅ | Always `"yes"` — grants mobile number access |

#### Success Response (200)

```json
{
  "status": "success",
  "code": 200,
  "message": "Subscription created successfully",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "id": 101,
    "user_id": "USER123",
    "mechanic_id": "MECH001",
    "mechanic_number_access": "yes",
    "operation": "insert",
    "inserted_at": "2025-01-15T10:30:00Z",
    "modified_at": "2025-01-15T10:30:00Z"
  },
  "error": null
}
```

#### cURL Example

```bash
curl -X POST https://api.prod.vahaanbazar.in/api/v1/service-support/user-mechanic-subscription \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {access_token}" \
  -H "X-API-Key: 7B0F2K4R1MSS3P0D" \
  -d '{
    "user_id": "USER123",
    "mechanic_id": "MECH001",
    "number_access_subscription": "yes"
  }'
```

---

### 5.3 My Subscriptions (Shared Endpoint — Used for Subscription Check)

**Endpoint**: `POST /api/v1/subscription/my-subscriptions`

**Description**: Retrieves all active subscriptions for the user. The service support module checks for a subscription with `typeCode == 'SUBT006'` and `status == 'active'` to determine if the user can access mechanic phone numbers.

#### Request Body

```json
{
  "user_id": "string (required)"
}
```

#### Key Response Fields (used by Service Support)

```json
{
  "data": {
    "subscriptions": [
      {
        "type_code": "SUBT006",
        "status": "active",
        "plan_name": "Mechanic Contact Plan",
        "end_date": "2025-06-15"
      }
    ]
  }
}
```

The controller checks: `subscription.typeCode == 'SUBT006' && subscription.status == 'active'`

---

## 6. Data Models

### 6.1 ListMechanicsRequest

```dart
class ListMechanicsRequest {
  final String userId;
  final double latitude;
  final double longitude;
  final int page;
  final int limit;
}
```

| Field | JSON Key | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `userId` | `user_id` | `String` | — | User ID from storage |
| `latitude` | `latitude` | `double` | — | GPS latitude (required, no default) |
| `longitude` | `longitude` | `double` | — | GPS longitude (required, no default) |
| `page` | `page` | `int` | `1` | Pagination page number |
| `limit` | `limit` | `int` | `20` | Results per page |

---

### 6.2 ListMechanicsResponse

```dart
class ListMechanicsResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final MechanicsData data;
  final dynamic error;
}
```

| Field | JSON Key | Type | Description |
|-------|----------|------|-------------|
| `status` | `status` | `String` | `"success"` or `"error"` |
| `code` | `code` | `int` | HTTP status code |
| `message` | `message` | `String` | Human-readable message |
| `timestamp` | `timestamp` | `String` | ISO 8601 timestamp |
| `data` | `data` | `MechanicsData` | Nested response data |
| `error` | `error` | `dynamic` | Error details (null on success) |

---

### 6.3 MechanicsData

```dart
class MechanicsData {
  final UserLocation userLocation;
  final int count;
  final List<Mechanic> mechanics;
  final PaginationInfo pagination;
}
```

| Field | JSON Key | Type | Description |
|-------|----------|------|-------------|
| `userLocation` | `user_location` | `UserLocation` | Echoed back user coordinates |
| `count` | `count` | `int` | Total mechanics found |
| `mechanics` | `mechanics` | `List<Mechanic>` | Array of mechanic objects |
| `pagination` | `pagination` | `PaginationInfo` | Pagination metadata |

---

### 6.4 UserLocation

```dart
class UserLocation {
  final double lat;
  final double lon;
}
```

| Field | JSON Key | Type | Description |
|-------|----------|------|-------------|
| `lat` | `lat` | `double` | User latitude |
| `lon` | `lon` | `double` | User longitude |

---

### 6.5 Mechanic (Complete Field Specification)

```dart
class Mechanic {
  final int id;
  final String mechanicId;
  final String description;
  final String garageName;
  final String mechanicName;
  final String addressLine1;
  final String addressLine2;
  final String state;
  final String pinCode;
  final String mobileNumber;
  final double latitude;
  final double longitude;
  final String priority;
  final String starRating;
  final double distanceKm;
}
```

| Field | JSON Key | Type | Default (if null) | Description |
|-------|----------|------|--------------------|-------------|
| `id` | `id` | `int` | `0` | Auto-increment database ID |
| `mechanicId` | `mechanic_id` | `String` | `""` | Unique mechanic identifier (e.g., `MECH001`) |
| `description` | `description` | `String` | `""` | Service specializations (e.g., "Engine Repair, Body Work") |
| `garageName` | `garage_name` | `String` | `""` | Name of the garage/workshop |
| `mechanicName` | `mechanic_name` | `String` | `""` | Full name of the mechanic |
| `addressLine1` | `address_line_1` | `String` | `""` | Primary address line |
| `addressLine2` | `address_line_2` | `String` | `""` | Secondary address line (landmark, area) |
| `state` | `state` | `String` | `""` | State name |
| `pinCode` | `pin_code` | `String` | `""` | PIN/ZIP code (converted to string) |
| `mobileNumber` | `mobile_number` | `String` | `""` | Phone number (subscription-gated) |
| `latitude` | `latitude` | `double` | `0.0` | Garage GPS latitude |
| `longitude` | `longitude` | `double` | `0.0` | Garage GPS longitude |
| `priority` | `priority` | `String` | `""` | Priority level (e.g., "high", "medium", "low") |
| `starRating` | `star_rating` | `String` | `"0"` | Rating as string (e.g., "4.5") |
| `distanceKm` | `distance_km` | `double` | `0.0` | Distance from user in kilometers |

#### Computed Properties

| Property | Return Type | Description |
|----------|-------------|-------------|
| `fullAddress` | `String` | Joins `addressLine1`, `addressLine2`, `state`, `pinCode` with ", " (skips empty parts) |
| `serviceTypes` | `List<String>` | Returns `[description]` as a list |
| `rating` | `double` | Parses `starRating` string to double, defaults to `0.0` |

---

### 6.6 PaginationInfo

```dart
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;
}
```

| Field | JSON Key | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `currentPage` | `current_page` | `int` | `1` | Current page number |
| `totalPages` | `total_pages` | `int` | `1` | Total number of pages |
| `totalCount` | `total_count` | `int` | `0` | Total mechanics count |
| `limit` | `limit` | `int` | `20` | Results per page |
| `hasNext` | `has_next` | `bool` | `false` | Whether more pages exist |
| `hasPrevious` | `has_previous` | `bool` | `false` | Whether previous pages exist |

---

### 6.7 MechanicSubscriptionRequest

```dart
class MechanicSubscriptionRequest {
  final String userId;
  final String mechanicId;
  final String numberAccessSubscription;
}
```

| Field | JSON Key | Type | Description |
|-------|----------|------|-------------|
| `userId` | `user_id` | `String` | User ID |
| `mechanicId` | `mechanic_id` | `String` | Mechanic's unique ID |
| `numberAccessSubscription` | `number_access_subscription` | `String` | Always `"yes"` |

---

### 6.8 MechanicSubscriptionResponse

```dart
class MechanicSubscriptionResponse {
  final String status;
  final int code;
  final String message;
  final String timestamp;
  final MechanicSubscriptionData data;
  final dynamic error;
}
```

---

### 6.9 MechanicSubscriptionData

```dart
class MechanicSubscriptionData {
  final int id;
  final String userId;
  final String mechanicId;
  final String mechanicNumberAccess;
  final String operation;
  final String insertedAt;
  final String modifiedAt;
}
```

| Field | JSON Key | Type | Description |
|-------|----------|------|-------------|
| `id` | `id` | `int` | Subscription record ID |
| `userId` | `user_id` | `String` | User ID |
| `mechanicId` | `mechanic_id` | `String` | Mechanic ID |
| `mechanicNumberAccess` | `mechanic_number_access` | `String` | Access level (`"yes"`) |
| `operation` | `operation` | `String` | Operation type (`"insert"`) |
| `insertedAt` | `inserted_at` | `String` | Creation timestamp |
| `modifiedAt` | `modified_at` | `String` | Last modification timestamp |

---

## 7. Service Support Home View — Complete UI Specification

**File**: `service_support_view.dart` (84 lines)

### Screen Layout

```
┌─────────────────────────────────────┐
│         CustomAppBar                │
│     title: "Service & Support"      │
│     [Drawer Icon]                   │
├─────────────────────────────────────┤
│                                     │
│                                     │
│    "24/7 Breakdown Assistance"      │  ← Bold, 24px, Poppins, Black
│                                     │
│    Instant Help. Anytime,           │  ← Regular, 16px, Poppins, Black
│    Anywhere. Quick response         │     Centered, horizontal padding 40
│    and reliable roadside            │
│    assistance at your fingertips.   │
│                                     │
│    ┌─────────────────────────┐      │
│    │                         │      │
│    │   Service Support       │      │  ← Image: AppImages.serviceSupport
│    │   Illustration          │      │     Height: 350px
│    │                         │      │
│    └─────────────────────────┘      │
│                                     │
│    ┌─────────────────────────┐      │
│    │  📞 Contact Mechanic    │      │  ← CustomButton
│    └─────────────────────────┘      │     Width: 220, Height: 55
│                                     │     Border radius: 90 (pill shape)
│                                     │     Background: AppColors.buttonPrimary
│                                     │     Prefix icon: Icons.phone (white)
│                                     │
└─────────────────────────────────────┘
```

### Widget Properties

| Element | Property | Value |
|---------|----------|-------|
| `Scaffold` | `backgroundColor` | `AppColors.background` |
| `CustomAppBar` | `title` | `'Service & Support '` |
| `CustomDrawer` | `categoryType` | `'service_support'` |
| Title Text | `fontSize` | `24` |
| Title Text | `fontWeight` | `FontWeight.bold` |
| Title Text | `color` | `AppColors.black` |
| Subtitle Text | `fontSize` | `16` |
| Subtitle Text | `fontWeight` | `FontWeight.w400` |
| Subtitle Text | `textAlign` | `TextAlign.center` |
| Subtitle Text | `padding` | `horizontal: 40, vertical: 8` |
| Image | `asset` | `AppImages.serviceSupport` |
| Image | `height` | `350` |
| Button | `width` | `220` |
| Button | `height` | `55` |
| Button | `borderRadius` | `90` |
| Button | `backgroundColor` | `AppColors.buttonPrimary` |
| Button | `prefixIcon` | `Icons.phone` |
| Button | `iconColor` | `AppColors.white` |
| Button | `text` | `'Contact Mechanic'` |
| Button | `allowMultiLine` | `true` |

### "Contact Mechanic" Button Action

```dart
onPressed: () {
  // 1. Delete existing controller to ensure fresh state
  Get.delete<ServiceSupportController>();

  // 2. Navigate to mechanic list view
  Get.toNamed(AppRoutes.serviceSupportListView);
}
```

**Important**: The controller is explicitly deleted before navigation to ensure a clean state (no stale GPS coordinates, mechanics list, or subscription data).

---

## 8. Service Provider List View — Complete UI Specification

**File**: `service_provider_list_view.dart`

### Screen Layout

```
┌─────────────────────────────────────┐
│         CustomAppBar                │
│     title: "Service Providers"      │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ 🔍 Search mechanics...       │  │  ← Search bar (by name/garage/city)
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Mechanic Card 1               │  │  ← Mechanic list card
│  │  Garage Name                  │  │
│  │  Mechanic Name                │  │
│  │  Address (formatted)          │  │
│  │  ⭐ 4.5  |  📍 2.3 km        │  │
│  │  [📞 Call] or [🔒 Subscribe] │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Mechanic Card 2               │  │
│  │  ...                          │  │
│  └───────────────────────────────┘  │
│  ...                                │
│                                     │
│  ┌───────────────────────────────┐  │
│  │      Load More                │  │  ← Pagination button (if hasMore)
│  └───────────────────────────────┘  │
│                                     │
│  (or "No mechanics found" if empty) │
└─────────────────────────────────────┘
```

### States

| State | UI Display |
|-------|------------|
| **Initial** | Shows "Contact Mechanic" button to trigger GPS + API |
| **Loading** | CircularProgressIndicator centered |
| **Loading More** | CircularProgressIndicator at bottom of list |
| **Loaded** | Scrollable list of mechanic cards |
| **Empty** | "No mechanics found near your location" message |
| **Location Error** | Location permission dialog (see Section 12) |

### Mechanic Card Fields

Each card displays:
- **Garage Name** (bold, primary)
- **Mechanic Name** (secondary text)
- **Description/Service Types** (if available)
- **Formatted Address** — `addressLine1, addressLine2, state, pinCode`
- **Star Rating** — parsed from `starRating` string
- **Distance** — `distanceKm` in kilometers
- **Mobile Number** — only shown if user has `SUBT006` subscription; otherwise shows "Subscribe to view" or lock icon

### Pull-to-Refresh

The list supports pull-to-refresh which:
1. Resets coordinates to `0.0, 0.0`
2. Clears existing mechanics
3. Re-triggers `loadMechanics(refresh: true)` with fresh GPS check

---

## 9. Subscribed Mechanics View

**File**: `subscribed_mechanics_view.dart`

Displays the user's active mechanic subscription details. Accessible from the navigation drawer.

### Data Displayed

| Field | Source |
|-------|--------|
| Mechanic ID | `MechanicSubscriptionData.mechanicId` |
| Number Access | `MechanicSubscriptionData.mechanicNumberAccess` |
| Operation | `MechanicSubscriptionData.operation` |
| Inserted At | `MechanicSubscriptionData.insertedAt` |
| Modified At | `MechanicSubscriptionData.modifiedAt` |

---

## 10. Controller State Variables

### Public Observable Properties

| Variable | Type | Initial Value | Description |
|----------|------|---------------|-------------|
| `isLoading` | `RxBool` | `false` | Initial data loading state |
| `isLoadingMore` | `RxBool` | `false` | Pagination "load more" loading state |
| `mechanics` | `RxList<Mechanic>` | `[]` | List of loaded mechanics |
| `currentPage` | `RxInt` | `1` | Current pagination page |
| `hasMore` | `RxBool` | `true` | Whether more pages are available |
| `totalCount` | `RxInt` | `0` | Total mechanics count from API |
| `hasAttemptedLoad` | `RxBool` | `false` | Whether at least one API call was attempted |
| `hasSubscription` | `RxBool` | `false` | Whether user has active SUBT006 subscription |
| `userLatitude` | `RxDouble` | `0.0` | Current user GPS latitude |
| `userLongitude` | `RxDouble` | `0.0` | Current user GPS longitude |

### Private State

| Variable | Type | Description |
|----------|------|-------------|
| `_apiRepository` | `ApiRepository` | API client (from GetX DI) |
| `_storageService` | `StorageService` | Local storage (from GetX DI) |
| `_locationService` | `LocationService?` | Lazy-initialized GPS service |
| `_isApiCallInProgress` | `bool` | Mutex flag to prevent concurrent API calls |
| `_openedLocationSettings` | `bool` | Tracks if user was sent to device settings (for resume detection) |
| `_lastRefreshTime` | `DateTime?` | Timestamp of last refresh (for debounce) |
| `_refreshDebounceTimer` | `Timer?` | Debounce timer |
| `_refreshDebounceSeconds` | `int` | `2` — minimum seconds between refreshes |

### Computed Properties

| Property | Return Type | Description |
|----------|-------------|-------------|
| `locationService` | `LocationService?` | Safe lazy getter for LocationService |
| `isGpsLocationAvailable` | `bool` | `true` if GPS is enabled AND location data exists |

---

## 11. Key Business Logic & Flows

### 11.1 Complete Flow: User Opens Service Support

```
User taps "Service & Support" in drawer
    │
    ▼
ServiceSupportView (Landing Page)
    │  Shows "24/7 Breakdown Assistance" + illustration
    │  Controller checks subscription status (SUBT006) on init
    │
    ▼
User taps "Contact Mechanic"
    │  Deletes existing ServiceSupportController
    │  Navigates to AppRoutes.serviceSupportListView
    │
    ▼
ServiceProviderListView
    │  New controller created via binding
    │  No auto-load on init — waits for user action
    │
    ▼
User taps "Contact Mechanic" button (in list view)
    │
    ▼
contactMechanics() called
    │
    ├── _isApiCallInProgress? → return early
    │
    ▼
_getUserLocation()
    │
    ├── LocationService available?
    │   ├── No → Show "Location Service" snackbar → return null
    │   └── Yes → Continue
    │
    ├── getCurrentLocation() → refresh location
    │   ├── Failed → Show Location Permission Dialog → return null
    │   └── Success → Continue
    │
    ├── hasLocation && isLocationEnabled?
    │   ├── No → Clear mechanics → Show Location Permission Dialog → return null
    │   └── Yes → Return {latitude, longitude}
    │
    ▼
Set userLatitude, userLongitude
    │
    ▼
loadMechanics(refresh: true)
    │
    ├── Check for concurrent API calls (wait up to 10s)
    │
    ├── Validate coordinates (not 0.0, 0.0)
    │   ├── 0.0 → Call _getUserLocation() again
    │   └── Valid → Continue
    │
    ├── Get userId from StorageService
    │
    ├── Build ListMechanicsRequest
    │
    ├── Call API: POST /api/v1/service-support/list-mechanics
    │
    ├── Process response:
    │   ├── Set totalCount
    │   ├── Add mechanics to list (refresh: clear first, else: addAll)
    │   ├── Update hasMore, currentPage
    │   └── Increment currentPage
    │
    └── Handle errors → Show error snackbar
```

### 11.2 Subscription Check Flow

```
ServiceSupportController.onInit()
    │
    ▼
checkSubscriptionStatus()
    │
    ├── Get userId from StorageService
    │   ├── null → hasSubscription = false → return
    │   └── Continue
    │
    ├── Call API: POST /api/v1/subscription/my-subscriptions
    │   { user_id: userId }
    │
    ├── Find subscription where:
    │   typeCode == 'SUBT006' && status == 'active'
    │
    ├── Found → hasSubscription = true
    │   Not found → hasSubscription = false
    │
    └── On error → Fallback to local storage:
        StorageService.userData['mechanic_subscription_status'] == 'active'
```

### 11.3 Mechanic Contact Flow (Subscription-Gated)

```
User taps "Call" on a mechanic card
    │
    ▼
callMechanic(mechanic)
    │
    ├── mobileNumber empty/null/"0"?
    │   └── Yes → _navigateToSubscriptionPlan(mechanic)
    │
    ├── hasSubscription == true?
    │   └── Yes → _makeDirectCall(mechanic)
    │       Shows snackbar with phone number
    │       (TODO: Implement url_launcher tel: call)
    │
    └── hasSubscription == false?
        └── _navigateToSubscriptionPlan(mechanic)
```

### 11.4 Subscription Purchase Flow

```
_navigateToSubscriptionPlan(mechanic)
    │
    ├── Save mechanic ID to StorageService
    │   (savePendingMechanicId, saveSubscriptionSource('SUBT006'))
    │
    ├── Navigate to AppRoutes.singleSubscriptionPlan
    │   Arguments:
    │   {
    │     subscriptionSource: 'SUBT006',
    │     mechanic: {
    │       mechanic_id, garage_name, mechanic_name,
    │       mobile_number, distance_km, address
    │     }
    │   }
    │
    ▼
[Payment Flow — handled by PaymentController]
    │
    ▼
Payment Success →
    │
    ▼
handleMechanicSubscriptionPaymentSuccess(mechanicId)
    │
    ├── Call createMechanicSubscription API
    │   POST /api/v1/service-support/user-mechanic-subscription
    │   { user_id, mechanic_id, number_access_subscription: 'yes' }
    │
    ├── Set hasSubscription = true
    │
    ├── Remove pending mechanic ID from storage
    │
    └── refreshAfterPaymentSuccess()
        ├── Refresh subscription status
        └── Refresh mechanics list (if previously loaded)
```

### 11.5 Pagination Flow

```
User scrolls to bottom of list
    │
    ▼
loadMoreMechanics()
    │
    ├── isLoadingMore == false && hasMore == true?
    │   ├── No → return (already loading or no more data)
    │   └── Yes → loadMechanics() (without refresh flag)
    │
    ▼
loadMechanics()
    │
    ├── currentPage > 1 → isLoadingMore = true
    │
    ├── API call with current page
    │
    ├── Response → mechanics.addAll(newMechanics)
    │
    ├── hasMore = response.pagination.hasNext
    │
    └── currentPage++
```

### 11.6 Pull-to-Refresh Flow

```
User pulls down on list
    │
    ▼
refreshMechanics()
    │
    ├── Reset coordinates to 0.0, 0.0
    ├── Clear mechanics list
    │
    └── loadMechanics(refresh: true)
        │
        ├── Triggers fresh GPS check (since coords are 0.0)
        ├── Gets new GPS location
        └── Reloads mechanics from page 1
```

### 11.7 App Lifecycle Observer

```
User sent to device settings (GPS/Permission)
    │
    _openedLocationSettings = true
    │
    ▼
User returns to app (AppLifecycleState.resumed)
    │
    ├── _openedLocationSettings == true?
    │   ├── Yes → Wait 300ms → _showCheckAgainDialog()
    │   │         "Settings Updated? Did you enable location?"
    │   │         [Cancel]  [Check Again]
    │   │                        │
    │   │                        ▼
    │   │                   _handleLocationEnabling() (retry)
    │   │
    │   └── No → Normal behavior
    │
    └── Reset _openedLocationSettings = false
```

### 11.8 Debounce Mechanism

```dart
// Prevents rapid refreshes within 2 seconds
static const int _refreshDebounceSeconds = 2;

// In refreshAfterPaymentSuccess():
if (_lastRefreshTime != null &&
    now.difference(_lastRefreshTime!).inSeconds < _refreshDebounceSeconds) {
  return; // Skip this refresh
}
_lastRefreshTime = now;
```

### 11.9 Concurrent API Call Prevention

```dart
// Mutex pattern with timeout
bool _isApiCallInProgress = false;

if (_isApiCallInProgress) {
  // Wait up to 10 seconds for current call to complete
  int waitCount = 0;
  while (_isApiCallInProgress && waitCount < 20) {
    await Future.delayed(Duration(milliseconds: 500));
    waitCount++;
  }
  if (_isApiCallInProgress) {
    // Force reset after timeout
    _isApiCallInProgress = false;
  } else {
    return; // Previous call completed
  }
}
```

---

## 12. Location Permission Dialog Flows

The module implements a **4-dialog progressive disclosure pattern** for location permissions:

### Dialog 1: Location Required (Initial)

**Trigger**: `_getUserLocation()` returns null (no GPS data available)

```
┌──────────────────────────────────────┐
│                                      │
│         📍 (circle icon)             │
│                                      │
│     "Location Required"              │  ← Bold, 22px
│                                      │
│   This app needs location access     │  ← Regular, 16px
│   to find service providers near     │     Secondary color
│   you. We will help you enable       │
│   GPS and grant location             │
│   permission.                        │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ ✅ Find nearest service        │  │  ← Green check marks
│  │    providers                   │  │     Background: success/10%
│  │ ✅ Get accurate service        │  │     Border: success/30%
│  │    estimates                   │  │
│  │ ✅ Personalized                │  │
│  │    recommendations             │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌──────────┐  ┌──────────────────┐  │
│  │  Cancel  │  │     Enable       │  │  ← [Cancel] [Enable]
│  └──────────┘  └──────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

**Buttons**:
- **Cancel** → `Get.back()` (dismiss dialog)
- **Enable** → `_handleLocationEnabling()` (proceed to GPS check)

---

### Dialog 2: Enable GPS (GPS is off)

**Trigger**: `_handleLocationEnabling()` detects `Geolocator.isLocationServiceEnabled() == false`

```
┌──────────────────────────────────────┐
│                                      │
│         🛑 (warning circle)          │
│                                      │
│        "Enable GPS"                  │  ← Bold, 22px
│                                      │
│   Please turn on GPS/Location        │  ← Regular, 16px
│   Services in your device            │
│   settings, then come back           │
│   to the app.                        │
│                                      │
│  ┌──────────┐  ┌──────────────────┐  │
│  │  Cancel  │  │    Settings      │  │  ← [Cancel] [Settings]
│  └──────────┘  └──────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

**Buttons**:
- **Cancel** → `Get.back()`
- **Settings** → Set `_openedLocationSettings = true`, call `locService.openLocationSettings()`, close dialog. On app resume → Dialog 4.

---

### Dialog 3: Permission Required (Permission denied)

**Trigger**: `_handleLocationEnabling()` → `requestLocationPermission()` returns `false`

```
┌──────────────────────────────────────┐
│                                      │
│     ⚙️ (settings circle)            │
│                                      │
│     "Permission Required"            │  ← Bold, 22px
│                                      │
│   Location permission is required    │  ← Regular, 16px
│   to find service providers.         │
│   Please enable it in app            │
│   settings.                          │
│                                      │
│  ┌──────────┐  ┌──────────────────┐  │
│  │  Cancel  │  │    Settings      │  │  ← Warning colored button
│  └──────────┘  └──────────────────┘  │     with settings icon
│                                      │
└──────────────────────────────────────┘
```

**Buttons**:
- **Cancel** → `Get.back()`
- **Settings** → Set `_openedLocationSettings = true`, open app settings. On resume → Dialog 4.

---

### Dialog 4: Check Again (After returning from settings)

**Trigger**: App resumes and `_openedLocationSettings == true`

```
┌──────────────────────────────────────┐
│                                      │
│         🔄 (info circle)             │
│                                      │
│     "Settings Updated?"              │  ← Bold, 22px
│                                      │
│   Did you enable location            │  ← Regular, 16px
│   permission? Tap "Check Again"      │
│   to retry finding service           │
│   providers.                         │
│                                      │
│  ┌──────────┐  ┌──────────────────┐  │
│  │  Cancel  │  │    Retry         │  │  ← Info colored button
│  └──────────┘  └──────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

**Buttons**:
- **Cancel** → `Get.back()`
- **Retry** → `_handleLocationEnabling()` (restart the whole flow)

---

### Error Dialog (Fallback)

**Trigger**: Exception in `_handleLocationEnabling()`

```
Title: "Location Error"
Content: "Unable to enable location services. Please check your device settings and try again."
Actions: [OK] [Try Again]
```

---

## 13. Subscription & Payment Flow

### Subscription Type: SUBT006

The service support module uses subscription type code `SUBT006` (Mechanic Contact Plan) to gate access to mechanic phone numbers.

### Storage Keys Used

| Key | Method | Purpose |
|-----|--------|---------|
| `pendingMechanicId` | `savePendingMechanicId()` / `removePendingMechanicId()` | Stores the mechanic ID for post-payment callback |
| `subscriptionSource` | `saveSubscriptionSource('SUBT006')` | Identifies which subscription flow initiated payment |
| `userData['mechanic_subscription_status']` | `setUserData()` / `userData` | Local fallback for subscription status |

### Post-Payment Refresh Flow

```dart
refreshAfterPaymentSuccess() {
  // 1. Debounce check (2-second minimum)
  // 2. Prevent concurrent refreshes
  // 3. Refresh subscription status (checkSubscriptionStatus)
  // 4. If mechanics list was previously loaded, refresh it
  //    (This updates the UI to show unlocked phone numbers)
}
```

### Display Logic for Mobile Numbers

| Condition | Display |
|-----------|---------|
| `hasSubscription == true` AND `mobileNumber` is valid | Show full phone number + "Call" action |
| `hasSubscription == true` AND `mobileNumber` is empty/null/"0" | Show "No number available" |
| `hasSubscription == false` AND `mobileNumber` is valid | Show lock icon + "Subscribe to view" → Navigate to subscription |
| `hasSubscription == false` AND `mobileNumber` is empty/null/"0" | Navigate to subscription plan |

---

## 14. Validation Strategy

### Input Validation

| Validation | Implementation |
|------------|---------------|
| **User ID required** | Checked before API call; throws exception if null/empty |
| **GPS coordinates must be valid** | No default fallback; if `0.0, 0.0`, triggers fresh GPS check |
| **Mobile number format** | Checks `isEmpty`, `== 'null'`, `== '0'` before displaying |
| **Pagination bounds** | `hasMore` checked before loading more; `currentPage` incremented only after successful response |

### API Response Validation

| Check | Action |
|-------|--------|
| `response.status == 'success'` | Process data |
| `response.status != 'success'` | Throw exception with `response.message` |
| Network error | Catch exception, show error snackbar |
| API call timeout (10s wait) | Force reset `_isApiCallInProgress` |

### State Consistency

| Scenario | State Reset |
|----------|-------------|
| GPS unavailable | `mechanics.clear()`, `hasAttemptedLoad = true` |
| API error | `isLoading = false`, `isLoadingMore = false`, `_isApiCallInProgress = false` |
| Refresh | `currentPage = 1`, `hasMore = true`, `mechanics.clear()`, `hasAttemptedLoad = false` |
| Force reset | All loading flags set to `false`, `_isApiCallInProgress = false` |

---

## 15. Shared Widgets Used

| Widget | Source | Usage in Service Support |
|--------|--------|--------------------------|
| `CustomAppBar` | `shared/widgets/custom_app_bar.dart` | App bar on all screens |
| `CustomButton` | `shared/widgets/custom_button.dart` | "Contact Mechanic" CTA (pill shape, phone icon) |
| `CustomDrawer` | `shared/widgets/custom_drawer.dart` | Navigation drawer with `categoryType: 'service_support'` |
| `AppColors` | `core/constants/app_colors.dart` | `.background`, `.buttonPrimary`, `.white`, `.black`, `.success`, `.warning`, `.info`, `.textPrimary`, `.textSecondary`, `.error` |
| `AppTextStyles` | `core/constants/app_text_styles.dart` | `.getPoppinsStyle(fontSize, fontWeight, color)` |
| `AppImages` | `core/constants/app_images.dart` | `.serviceSupport` (landing page illustration) |

---

## 16. Navigation & Routes

### Route Constants

| Constant | Path | Screen |
|----------|------|--------|
| `AppRoutes.serviceSupport` | `/service-support` | `ServiceSupportView` (landing) |
| `AppRoutes.serviceSupportListView` | `/service-support-list` | `ServiceProviderListView` (mechanic list) |
| `AppRoutes.subscribedMechanics` | `/subscribed-mechanics` | `SubscribedMechanicsView` |
| `AppRoutes.singleSubscriptionPlan` | `/single-subscription-plan` | Subscription plan page (shared) |

### Navigation Flow

```
Drawer → ServiceSupportView (landing)
              │
              ├── "Contact Mechanic" button
              │   → ServiceProviderListView (mechanic list)
              │       │
              │       ├── "Call" (with subscription)
              │       │   → Shows phone number snackbar
              │       │
              │       └── "Call" (without subscription)
              │           → SingleSubscriptionPlan (with SUBT006 args)
              │               │
              │               └── Payment Success
              │                   → handleMechanicSubscriptionPaymentSuccess()
              │                   → refreshAfterPaymentSuccess()
              │
              └── Drawer → SubscribedMechanicsView
```

### Navigation Arguments

#### To SingleSubscriptionPlan

```dart
Get.toNamed(
  AppRoutes.singleSubscriptionPlan,
  arguments: {
    'subscriptionSource': 'SUBT006',
    'mechanic': {
      'mechanic_id': mechanic.mechanicId,
      'garage_name': mechanic.garageName,
      'mechanic_name': mechanic.mechanicName,
      'mobile_number': mechanic.mobileNumber,
      'distance_km': mechanic.distanceKm,
      'address': formatAddress(mechanic),  // "addressLine1, addressLine2, state, pinCode"
    },
  },
);
```

---

## 17. Error Handling Patterns

### Snackbar Notifications

| Scenario | Background Color | Text Color | Duration | Position |
|----------|-----------------|------------|----------|----------|
| Location service unavailable | `Colors.red` | `White` | 4s | Top |
| Location enabled successfully | `Colors.green` | `White` | 3s | Top |
| Location required (no GPS) | `Colors.orange` | `White` | 3s | Top |
| Location updated | `Colors.green` | `White` | 2s | Top |
| Mechanic subscription success | `Colors.green` | `White` | 3s | Top |
| Mechanic subscription error | `Colors.red` | `White` | 3s | Top |
| Contact available | `Colors.green` | `White` | 4s | Top |
| General API error | `Theme.error` | `Theme.onError` | 4s | Top |
| Location refresh error | `Theme.error` | `Theme.onError` | default | default |

### Dialog Patterns

| Dialog | Shape | Border Radius | Content Padding |
|--------|-------|---------------|-----------------|
| Location Required | `RoundedRectangleBorder` | `20` | `EdgeInsets.zero` (inner container: `24`) |
| Enable GPS | `RoundedRectangleBorder` | `20` | `EdgeInsets.zero` (inner container: `24`) |
| Permission Required | `RoundedRectangleBorder` | `20` | `EdgeInsets.zero` (inner container: `24`) |
| Check Again | `RoundedRectangleBorder` | `20` | `EdgeInsets.zero` (inner container: `24`) |
| Error Dialog | Default `AlertDialog` | default | default |

### Button Styles in Dialogs

| Button Type | Height | Border Radius | Style |
|-------------|--------|---------------|-------|
| Cancel (Outlined) | `50` | `12` | `OutlinedButton` with secondary/50% border |
| Action (Elevated) | `50` | `12` | `ElevatedButton` with theme-specific background |
| Warning (Elevated) | `50` | `12` | `ElevatedButton` with `AppColors.warning` background |

---

## 18. Recreation Checklist

Use this checklist when integrating the Service Support module into a new application:

### Prerequisites

- [ ] Set up HTTP client (Dio or equivalent) with auth token interceptor
- [ ] Set up API key header support (`X-API-Key`)
- [ ] Implement local storage service (SharedPreferences or equivalent) for:
  - [ ] User ID retrieval
  - [ ] User data storage
  - [ ] Pending mechanic ID storage
  - [ ] Subscription source storage
- [ ] Implement location service wrapping Geolocator:
  - [ ] `getCurrentLocation()` → returns bool
  - [ ] `requestLocationPermission()` → returns bool
  - [ ] `openLocationSettings()` → opens device settings
  - [ ] Observable: `hasLocation`, `isLocationEnabled`, `latitude`, `longitude`
- [ ] Install `geolocator` package
- [ ] Install state management (GetX or equivalent)
- [ ] Prepare app colors, text styles, and image assets

### API Layer

- [ ] Create API constants:
  - [ ] `POST /api/v1/service-support/list-mechanics`
  - [ ] `POST /api/v1/service-support/user-mechanic-subscription`
  - [ ] `POST /api/v1/subscription/my-subscriptions` (shared endpoint)
- [ ] Implement `listMechanics(ListMechanicsRequest)` → `ListMechanicsResponse`
- [ ] Implement `createMechanicSubscription(MechanicSubscriptionRequest)` → `MechanicSubscriptionResponse`
- [ ] Implement `getMySubscription(MySubscriptionRequest)` → `MySubscriptionResponse` (checks for SUBT006)

### Models

- [ ] Create `ListMechanicsRequest` (userId, latitude, longitude, page, limit)
- [ ] Create `ListMechanicsResponse` → `MechanicsData` → `UserLocation` + `List<Mechanic>` + `PaginationInfo`
- [ ] Create `Mechanic` model with all 15 fields + computed properties (`fullAddress`, `serviceTypes`, `rating`)
- [ ] Create `PaginationInfo` (currentPage, totalPages, totalCount, limit, hasNext, hasPrevious)
- [ ] Create `MechanicSubscriptionRequest` (userId, mechanicId, numberAccessSubscription)
- [ ] Create `MechanicSubscriptionResponse` → `MechanicSubscriptionData`

### Controller

- [ ] Create `ServiceSupportController` with:
  - [ ] All observable state variables (isLoading, isLoadingMore, mechanics, currentPage, hasMore, totalCount, hasAttemptedLoad, hasSubscription, userLatitude, userLongitude)
  - [ ] Private state (_isApiCallInProgress, _openedLocationSettings, debounce fields)
  - [ ] `onInit()` — check subscription status, register lifecycle observer
  - [ ] `onClose()` — cancel timers, remove lifecycle observer
  - [ ] `_getUserLocation()` — GPS-only location with permission dialogs
  - [ ] `loadMechanics({refresh})` — paginated API call with mutex
  - [ ] `refreshMechanics()` — reset coords + fresh load
  - [ ] `loadMoreMechanics()` — pagination trigger
  - [ ] `contactMechanics()` — main entry point for GPS + load
  - [ ] `simpleLoadMechanics()` — GPS-only load helper
  - [ ] `checkSubscriptionStatus()` — SUBT006 check with local fallback
  - [ ] `createMechanicSubscription()` — API call for subscription creation
  - [ ] `handleMechanicSubscriptionPaymentSuccess()` — post-payment handler
  - [ ] `refreshAfterPaymentSuccess()` — debounced refresh
  - [ ] `callMechanic()` — subscription-gated contact action
  - [ ] `formatAddress()` — address formatter
  - [ ] `forceResetStates()`, `resetForFreshStart()`, `clearLocationAndMechanicsData()` — state reset helpers
  - [ ] `didChangeAppLifecycleState()` — resume detection for settings dialog
  - [ ] All 4 location permission dialogs (Location Required, Enable GPS, Permission Required, Check Again)
  - [ ] Error dialog and error snackbar helpers

### Views

- [ ] Create `ServiceSupportView` (landing page):
  - [ ] CustomAppBar with title "Service & Support"
  - [ ] CustomDrawer with categoryType 'service_support'
  - [ ] "24/7 Breakdown Assistance" title + subtitle
  - [ ] Service support illustration image
  - [ ] "Contact Mechanic" pill-shaped button with phone icon
  - [ ] Delete controller before navigation

- [ ] Create `ServiceProviderListView` (mechanic list):
  - [ ] Search bar for filtering mechanics
  - [ ] Mechanic cards (garage name, mechanic name, address, rating, distance)
  - [ ] Subscription-gated phone number display
  - [ ] "Load More" pagination button
  - [ ] Pull-to-refresh
  - [ ] Empty state message
  - [ ] Loading indicators (initial + pagination)

- [ ] Create `SubscribedMechanicsView` (subscription details)

### Navigation

- [ ] Register routes:
  - [ ] `/service-support` → ServiceSupportView
  - [ ] `/service-support-list` → ServiceProviderListView
  - [ ] `/subscribed-mechanics` → SubscribedMechanicsView
- [ ] Create GetX binding for ServiceSupportController
- [ ] Handle navigation to subscription plan with SUBT006 arguments
- [ ] Handle payment success callback flow

### Platform Configuration

- [ ] **Android**: Add location permissions to `AndroidManifest.xml`:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
- [ ] **iOS**: Add location usage descriptions to `Info.plist`:
  - `NSLocationWhenInUseUsageDescription`
  - `NSLocationAlwaysUsageDescription`
- [ ] **iOS**: Add `NSLocationWhenInUseUsageDescription` with user-facing explanation text

### Testing

- [ ] Test GPS disabled → "Enable GPS" dialog flow
- [ ] Test GPS enabled but permission denied → "Permission Required" → "Settings" → "Check Again" flow
- [ ] Test GPS enabled + permission granted → Mechanic list loads
- [ ] Test pagination (scroll to bottom → load more)
- [ ] Test pull-to-refresh (resets GPS + reloads)
- [ ] Test subscription check (SUBT006 active → phone numbers visible)
- [ ] Test subscription check (no SUBT006 → "Subscribe to view" + navigation to plan)
- [ ] Test post-payment flow (payment success → subscription created → list refreshed)
- [ ] Test concurrent API call prevention (rapid button taps)
- [ ] Test debounce (rapid refresh triggers within 2 seconds)
- [ ] Test app lifecycle (minimize → return from settings → "Check Again" dialog)
- [ ] Test error states (network failure, invalid user ID, empty mechanics list)
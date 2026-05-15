# Auction Module — Complete Documentation

> **Purpose:** This document provides a comprehensive technical and business specification to rebuild the Auction functionality in another application with a different UI/UX design, while preserving all business logic and workflows.

---

## Table of Contents

1. [Functional Overview](#1-functional-overview)
2. [API Documentation](#2-api-documentation)
3. [UI Components Documentation](#3-ui-components-documentation)
4. [Screens & User Flows](#4-screens--user-flows)
5. [State Management](#5-state-management)
6. [Business Rules](#6-business-rules)
7. [Reusable Logic](#7-reusable-logic)
8. [Data Models](#8-data-models)
9. [Suggested Improvements](#9-suggested-improvements)

---

## 1. Functional Overview

### 1.1 Auction Module Workflow

The Auction module is a vehicle auction platform supporting a complete bidding lifecycle:

```
┌─────────────────────────────────────────────────────────────────┐
│                     AUCTION MODULE FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐   │
│  │  Browse   │───▶│ View Auction │───▶│ View Vehicle Details │   │
│  │ Auctions  │    │  Vehicles    │    │  (Search/Filter)     │   │
│  └──────────┘    └──────────────┘    └──────────────────────┘   │
│       │                                       │                 │
│       ▼                                       ▼                 │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐   │
│  │  Filter   │    │ Place Bid    │───▶│ Bid Validation       │   │
│  │ Auctions  │    │ (with ₹)     │    │ (Limit Check)        │   │
│  └──────────┘    └──────────────┘    └──────────────────────┘   │
│                                       │                         │
│                               ┌───────┴───────┐                 │
│                               ▼               ▼                 │
│                      ┌─────────────┐  ┌─────────────┐           │
│                      │ Bid Accepted│  │ Bid Limit    │           │
│                      │ (My Bids)   │  │ Exceeded →   │           │
│                      └─────────────┘  │ Subscribe    │           │
│                               │       └─────────────┘           │
│                               ▼                                 │
│                      ┌─────────────┐                             │
│                      │  Won Auction│                             │
│                      │  (My Wins)  │                             │
│                      └─────────────┘                             │
│                               │                                 │
│                               ▼                                 │
│                      ┌─────────────┐    ┌──────────────┐        │
│                      │ Winning     │───▶│  Insurance    │        │
│                      │ Letter      │    │  Interest     │        │
│                      └─────────────┘    └──────────────┘        │
│                               │                                 │
│                               ▼                                 │
│                      ┌─────────────┐                             │
│                      │  Payment    │                             │
│                      │  (PayU)     │                             │
│                      └─────────────┘                             │
│                               │                                 │
│                               ▼                                 │
│                      ┌─────────────────┐                         │
│                      │ Refund Initiate │                         │
│                      └─────────────────┘                         │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 User Roles

| Role | Capabilities |
|------|-------------|
| **Buyer/Dealer** | Browse auctions, place bids, view my bids, view my wins, download winning letters, initiate refunds |
| **Auction Participant** | Search/filter vehicles within auctions, view vehicle details, check bid limits |

### 1.3 Core Features Summary

| Feature | Description |
|---------|-------------|
| **Auction Listing** | Three-tab view: Live, Closing Today, Upcoming with infinite scroll pagination |
| **Vehicle Listing** | Vehicles within an auction with search by registration number, category/state filters, infinite scroll |
| **Bid Placement** | Place bids with minimum bid validation, bid limit checking against subscription limits |
| **My Bids** | Track all user bids with statuses: Active, Winning, Won, Outbid, Cancelled |
| **My Wins** | View won auctions with winning letter PDF download |
| **Insurance Interest** | Toggle insurance interest for won vehicles |
| **Payments** | PayU SDK integration for subscription payments |
| **Notifications** | FCM push notifications for bid events (placed, outbid, approved, rejected, won, limit exceeded) |
| **Refunds** | Initiate refund requests for auction payments |

---

## 2. API Documentation

### Base Configuration

```
Base URL: https://api.prod.vahaanbazar.in
API Key Header: X-API-Key: 7B0F2K4R1MSS3P0D
Authentication: Bearer Token (JWT) in Authorization header
```

### 2.1 Auction Endpoints

---

#### Get Auction Listings (Paginated)

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/auction-listings-pagination`
- **Purpose:** Fetch auction listings filtered by type (Live, Closing Today, Upcoming) with pagination and optional filters

**Request Body:**
```json
{
  "page": 1,
  "limit": 10,
  "auction_type": "live_auctions",
  "category_type": "Bank",
  "vehicle_type": "4W",
  "state_id": "ST001",
  "region_id": "RG001"
}
```

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| page | number | Yes | Current page number (default: 1) |
| limit | number | Yes | Items per page (default: 10) |
| auction_type | string | Yes | `live_auctions`, `closing_today`, `upcoming_auctions` |
| category_type | string | No | `Bank`, `Customer`, `Insurance` |
| vehicle_type | string | No | `2W`, `3W`, `4W`, `CV`, `CE`, `FE` |
| state_id | string | No | State ID for filtering |
| region_id | string | No | Region ID for filtering |

**Response:**
```json
{
  "status": "success",
  "data": {
    "auctions": [
      {
        "auction_id": "AUC001",
        "auction_title": "Bank Auction - Q2 2024",
        "auction_type": "bank",
        "start_date": "2024-06-01T10:00:00Z",
        "end_date": "2024-06-15T18:00:00Z",
        "total_vehicles": 150,
        "status": "live"
      }
    ],
    "total_count": 50,
    "page": 1,
    "limit": 10
  }
}
```

---

#### Get Vehicle Listings for Auction (Paginated + Search)

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/vehicle-listings-pagination`
- **Purpose:** Fetch all vehicles in a specific auction with search, filter, and pagination

**Request Body:**
```json
{
  "auction_id": "AUC001",
  "page": 1,
  "limit": 10,
  "search_value": "MH02",
  "category_type": "Bank",
  "state_code": "MH",
  "city_code": "MUM",
  "min_price": 100000,
  "max_price": 500000,
  "year_from": 2018,
  "year_to": 2023
}
```

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| auction_id | string | Yes | Auction identifier |
| page | number | Yes | Current page |
| limit | number | Yes | Items per page |
| search_value | string | No | Search by registration number |
| category_type | string | No | Vehicle category filter |
| state_code | string | No | State filter |
| city_code | string | No | City filter |
| min_price | number | No | Minimum price filter |
| max_price | number | No | Maximum price filter |
| year_from | number | No | Manufacturing year from |
| year_to | number | No | Manufacturing year to |

**Response:**
```json
{
  "status": "success",
  "data": {
    "vehicles": [
      {
        "vehicle_id": "VEH001",
        "auction_id": "AUC001",
        "make": "Maruti",
        "model": "Swift",
        "registration_number": "MH02AB1234",
        "year_of_manufacturing": 2020,
        "category_type": "Bank",
        "vehicle_type": "4W",
        "current_bid_amount": 450000,
        "minimum_bid_amount": 400000,
        "total_bids": 12,
        "bid_start_time": "2024-06-01T10:00:00Z",
        "bid_end_time": "2024-06-15T18:00:00Z",
        "state_name": "Maharashtra",
        "city_name": "Mumbai",
        "images": ["https://..."],
        "vehicle_status": "active"
      }
    ],
    "total_count": 150,
    "page": 1,
    "limit": 10,
    "has_next": true
  }
}
```

---

#### Place Vehicle Bid

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/auction-vehicle-bid`
- **Purpose:** Place a bid on a specific vehicle in an auction

**Request Body:**
```json
{
  "vehicle_id": "VEH001",
  "auction_id": "AUC001",
  "bid_amount": 460000,
  "user_id": "USR001"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Bid placed successfully",
  "data": {
    "bid_id": "BID001",
    "vehicle_id": "VEH001",
    "bid_amount": 460000,
    "bid_status": "active",
    "current_highest_bid": 460000,
    "total_bids": 13
  }
}
```

**Response (Error - Bid too low):**
```json
{
  "status": "error",
  "message": "Bid amount must be higher than current highest bid of 455000.00"
}
```

**Response (Error - Limit exceeded):**
```json
{
  "status": "error",
  "message": "Bid limit exceeded. Your available limit is ₹500,000",
  "error_code": "BID_LIMIT_EXCEEDED"
}
```

---

#### Get My Bids (Paginated)

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/auction-my-bids-pagination`
- **Purpose:** Fetch user's bidding history with pagination

**Request Body:**
```json
{
  "user_id": "USR001",
  "page": 1,
  "limit": 10
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "bids": [
      {
        "bid_id": "BID001",
        "vehicle_id": "VEH001",
        "auction_id": "AUC001",
        "bid_amount": 460000,
        "bid_status": "winning",
        "vehicle_title": "2020 Maruti Swift VDI",
        "registration_number": "MH02AB1234",
        "bid_time": "2024-06-10T14:30:00Z",
        "auction_title": "Bank Auction Q2 2024"
      }
    ],
    "total_count": 25,
    "page": 1,
    "limit": 10
  }
}
```

---

#### Get My Wins (Paginated)

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/auction-my-wins-pagination`
- **Purpose:** Fetch user's won auctions with pagination

**Request Body:**
```json
{
  "user_id": "USR001",
  "page": 1,
  "limit": 10
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "wins": [
      {
        "win_id": "WIN001",
        "vehicle_id": "VEH001",
        "auction_id": "AUC001",
        "winning_bid_amount": 460000,
        "vehicle_title": "2020 Maruti Swift VDI",
        "registration_number": "MH02AB1234",
        "auction_title": "Bank Auction Q2 2024",
        "insurance_interest": false
      }
    ],
    "total_count": 5,
    "page": 1,
    "limit": 10
  }
}
```

---

#### Get Winning Letter

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/winning-letter`
- **Purpose:** Download winning letter PDF for a won auction

**Request Body:**
```json
{
  "win_id": "WIN001",
  "vehicle_id": "VEH001",
  "auction_id": "AUC001"
}
```

**Response:** PDF file download

---

#### Update Insurance Interest

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/update-insurance-interest`
- **Purpose:** Toggle insurance interest for a won vehicle

**Request Body:**
```json
{
  "vehicle_id": "VEH001",
  "auction_id": "AUC001",
  "insurance_interest": true
}
```

---

#### Vehicle Search

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/vehicle-search`
- **Purpose:** Search vehicles across auctions by registration number

**Request Body:**
```json
{
  "search_value": "MH02AB",
  "auction_id": "AUC001"
}
```

---

#### Vehicle Excel Download

- **Method:** `POST`
- **Endpoint:** `/api/v1/auctions/vehicle-excel-download`
- **Purpose:** Export vehicle list as Excel file

---

#### Auction Refund Initiate

- **Method:** `POST`
- **Endpoint:** `/api/v1/dashboard/auction-refund-initiate`
- **Purpose:** Request refund for auction payment

---

### 2.2 Supporting Endpoints

#### Get Regions

- **Method:** `GET`
- **Endpoint:** `/api/v1/locations/regions`
- **Purpose:** Fetch all regions for filter dropdown

#### Get States by Region

- **Method:** `GET`
- **Endpoint:** `/api/v1/locations/regions/{region_id}/states`
- **Purpose:** Fetch states within a specific region

---

## 3. UI Components Documentation

### 3.1 AuctionView

**Path:** `lib/modules/auction/views/auction_view.dart`

**Purpose:** Main auction screen with three-tab layout and filter system

#### Features
- **TabBar** with 3 tabs: Live, Closing Today, Upcoming
- **Infinite scroll** pagination with 80% scroll threshold trigger
- **Shimmer loading** states for initial load and load-more
- **Empty state** with icon, title, and message per tab
- **Error state** with retry button
- **Pull-to-refresh** per tab
- **Filter bottom sheet** with DraggableScrollableSheet

#### Filter Bottom Sheet
- Category dropdown: Bank, Customer, Insurance
- Vehicle Type dropdown: 2W, 3W, 4W, CV, CE, FE
- Region dropdown (API-loaded)
- State dropdown (cascading, loaded when region selected)
- Reset / Apply buttons
- Previous filter restore on dismiss/cancel
- Previous filters backup button

#### Back Navigation
- If filters are active → reset filters and reload data (no navigation back)
- If no filters → normal back navigation

---

### 3.2 AuctionListCard

**Path:** `lib/modules/auction/widgets/auction_list_card.dart`

**Purpose:** Displays an auction summary in the list

#### Features
- Auction title and description
- Date/time information (start/end)
- Vehicle count badge
- Status indicator (Live/Upcoming/Ended)
- Tap to navigate to vehicle list

---

### 3.3 AuctionVehicleCard

**Path:** `lib/modules/auction/widgets/auction_vehicle_card.dart`

**Purpose:** Displays individual vehicle within an auction

#### Features
- Vehicle image preview
- Make/Model/Year display
- Registration number
- Current bid amount (formatted)
- Minimum bid amount
- Total bids count
- Category badge
- Status indicator
- Search highlight when matched

---

### 3.4 Common/Shared Components Used

| Component | Path | Purpose |
|-----------|------|---------|
| `CustomAppBar` | `lib/shared/widgets/custom_app_bar.dart` | App bar with title, category type, filter button |
| `CustomDrawer` | `lib/shared/widgets/custom_drawer.dart` | Navigation drawer with module links |
| `ShimmerWidget` | `lib/shared/widgets/shimmer_widget.dart` | Skeleton loading placeholder |
| `PlatformRefreshIndicator` | `lib/shared/widgets/platform_refresh_indicator.dart` | Pull-to-refresh (platform-adaptive) |
| `CustomDropdownField` | `lib/shared/widgets/custom_dropdown_field.dart` | Reusable dropdown with icon prefix |
| `SizeConfig` | `lib/shared/widgets/size_config.dart` | Responsive sizing utilities |
| `AppTextStyles` | `lib/core/constants/app_text_styles.dart` | Consistent text styles |
| `AppColors` | `lib/core/constants/app_colors.dart` | Color constants |

---

## 4. Screens & User Flows

### 4.1 Auction Listing Screen

**Route:** `/auctions`
**Entry Point:** Bottom navigation or drawer → Auctions

**Flow:**
1. Load controller → fetch paginated auctions for current tab (default: Live)
2. Display tab bar + auction list with shimmer loading
3. User can switch tabs → triggers new API call (cached per tab)
4. Pull-to-refresh → resets to page 1
5. Scroll to 80% → load more pagination
6. Tap filter icon → open filter bottom sheet
7. Tap auction card → navigate to vehicle listing

**State Transitions:**
```
Initial Load → Shimmer Loading → Data Loaded
                              → Empty State (no data)
                              → Error State (with retry)
Tab Switch → Load new tab data
Filter Apply → Reset pagination → Reload current tab
```

---

### 4.2 Vehicle Listing Screen

**Route:** `/auctions/vehicles`
**Arguments:** `auction_id`

**Flow:**
1. Load vehicles for auction (paginated)
2. Search bar for registration number search
3. Category/State/City/Price/Year filters
4. Infinite scroll pagination
5. Pull-to-refresh
6. Tap vehicle → navigate to vehicle detail

---

### 4.3 Vehicle Detail Screen

**Route:** `/auctions/vehicle-detail`
**Arguments:** `vehicle` object

**Flow:**
1. Display vehicle details (images, specs, bid info)
2. Show bid amount input with currency keyboard
3. "Place Bid" action:
   - Validate bid > current highest bid
   - Check user's subscription bid limit
   - If limit exceeded → navigate to subscription plan
   - If valid → submit bid API → refresh vehicle data
4. Show bid history for this vehicle

**Bid Placement Flow:**
```
User enters bid amount
        │
        ▼
Validate: amount > minimum_bid_amount?
        │
    No ─┤──▶ Show error: "Minimum bid is ₹X"
        │
    Yes ▼
Check: amount <= current_highest_bid?
        │
    Yes ┤──▶ Show error: "Must be higher than ₹X"
        │
    No  ▼
Check: user has active subscription?
        │
    No  ┤──▶ Navigate to subscription plan
        │
    Yes ▼
Check: bid_amount <= available_limit?
        │
    No  ┤──▶ Show limit exceeded notification
        │    Navigate to subscription plan
    Yes ▼
POST /auction-vehicle-bid
        │
        ├──▶ Success: Show success → Refresh vehicle data
        │    Send "bid placed" notification
        │
        └──▶ Error: Parse error message
             If "higher than current" → show specific error
             Else → show generic error notification
```

---

### 4.4 My Bids Screen

**Route:** `/auctions/my-bids`

**Flow:**
1. Fetch paginated bid history
2. Display bid cards with status badges
3. Color-coded statuses:
   - 🟢 Winning → Green
   - 🔵 Won → Blue/Primary
   - 🔴 Outbid → Red
   - ⚪ Cancelled → Grey
   - 🟡 Active → Warning/Yellow
4. Infinite scroll pagination
5. Pull-to-refresh

---

### 4.5 My Wins Screen

**Route:** `/auctions/my-wins`

**Flow:**
1. Fetch paginated won auctions
2. Display win cards with winning amount
3. "Download Winning Letter" action → PDF download
4. Toggle insurance interest
5. Infinite scroll pagination
6. Pull-to-refresh

---

### 4.6 Initiate Refund Screen

**Route:** `/initiate-refund`
**Arguments:** `auctionId`

**Flow:**
1. Display refund form for auction payment
2. Submit refund request
3. Show confirmation/status

---

## 5. State Management

### 5.1 Architecture Pattern

**Pattern:** GetX (Controller + Reactive State)
**Controller:** `AuctionController` extends `GetxController`
**Binding:** Registered via GetX dependency injection

### 5.2 Controller State Variables

#### Auction Tab State
```dart
// Tab management
currentTabIndex: RxInt (0=Live, 1=Closing Today, 2=Upcoming)
tabController: TabController (3 tabs)

// Loading states per tab
isLoadingLive: RxBool
isLoadingClosingToday: RxBool
isLoadingUpcoming: RxBool

// Load-more states per tab
isLoadingMoreLive: RxBool
isLoadingMoreClosingToday: RxBool
isLoadingMoreUpcoming: RxBool

// Pagination per tab
livePage: RxInt
closingTodayPage: RxInt
upcomingPage: RxInt

// Data per tab
liveAuctions: Rx<AuctionListResponse>
closingTodayAuctions: Rx<AuctionListResponse>
upcomingAuctions: Rx<AuctionListResponse>
```

#### Vehicle List State
```dart
vechileData: RxList<VechileData>
vechileListResponse: Rxn<VechileListResponse>
isLoadingVechileList: RxBool
isLoadingMoreVehicles: RxBool
vehiclePage: RxInt
vehiclePagination: Rxn<PaginationInfo>

// Search state
hasSearchResults: RxBool
isSearching: RxBool
```

#### Bid State
```dart
isSubmittingBid: RxBool
pendingBidAmount: RxString
pendingVehicleId: RxString
pendingAuctionId: RxString
bidButtonText: RxString
```

#### My Bids State
```dart
myBids: RxList<MyBidData>
isLoadingMyBids: RxBool
isLoadingMoreMyBids: RxBool
myBidsPage: RxInt
myBidsTotalCount: RxInt
hasMoreMyBids: RxBool
```

#### My Wins State
```dart
myWins: RxList<MyWinData>
isLoadingMyWins: RxBool
isLoadingMoreMyWins: RxBool
myWinsPage: RxInt
myWinsTotalCount: RxInt
hasMoreMyWins: RxBool
```

#### Filter State
```dart
// Current filters
selectedCategory: RxnString
selectedVehicleType: RxnString
selectedRegion: Rxn<Region>
selectedState: Rxn<StateByRegion>

// Previous filters (backup for restore)
_previousCategory: RxnString
_previousVehicleType: RxnString
_previousRegion: Rxn<Region>
_previousState: Rxn<StateByRegion>
hasPreviousFilters: RxBool

// Filter data
regions: RxList<Region>
statesByRegion: RxList<StateByRegion>
isLoadingRegions: RxBool
isLoadingStatesByRegion: RxBool
```

### 5.3 Service Layer

**Primary Repository:** `ApiRepository` (injected via GetX)
**Network Layer:** `NetworkService` (Dio-based HTTP client)
**Storage:** `StorageService` (Secure storage for user ID, tokens)

### 5.4 Caching Strategy

- **Tab data caching:** Each tab (Live/Closing Today/Upcoming) maintains its own data in memory
- **Pagination state preserved:** When switching tabs, the loaded pages and data are retained
- **No disk caching:** All data is fetched fresh on app restart
- **Refresh resets to page 1:** Pull-to-refresh clears and reloads from page 1

---

## 6. Business Rules

### 6.1 Bid Placement Rules

| Rule | Description |
|------|-------------|
| **Minimum Bid** | Bid must be > `minimum_bid_amount` from vehicle data |
| **Current Bid** | If current highest bid exists, bid must be > `current_bid_amount` |
| **Subscription Required** | User must have active subscription to place bids |
| **Bid Limit** | Bid amount cannot exceed user's available bid limit (from subscription) |
| **Auction Active** | Vehicle auction must be in "live" status |
| **Error Parsing** | Backend error messages are parsed to extract current highest bid amount |

### 6.2 Bid Status Transitions

```
Active ──────────▶ Winning (when highest bidder)
  │                    │
  │                    ├──▶ Won (auction ends, still highest)
  │                    │
  └──▶ Outbid (someone bids higher)
  
Won ──▶ [Admin Action] ──▶ Approved / Rejected

Any Status ──▶ Cancelled (admin action)
```

### 6.3 Filter Rules

| Rule | Description |
|------|-------------|
| **Filter Backup** | Current filters are saved before opening filter sheet |
| **Cancel Restore** | If filter sheet dismissed without Apply, previous filters are restored |
| **Previous Filters** | After applying new filters, can revert to previous set via "Previous" button |
| **Back Button with Filters** | Back button first clears filters (if active) instead of navigating back |
| **Region-State Cascade** | States load only after region is selected; changing region clears state |

### 6.4 Pagination Rules

| Rule | Description |
|------|-------------|
| **Page Size** | Auctions: 10 per page; Vehicles: 10 per page |
| **Load Threshold** | Triggers at 80% scroll position |
| **Duplicate Prevention** | `isLoadingMore` flag prevents concurrent load-more requests |
| **Has More** | Compares loaded count vs total count from API |
| **Refresh Reset** | Pull-to-refresh always resets to page 1 |

### 6.5 Notification Rules

| Event | Notification Type | Trigger |
|-------|-------------------|---------|
| Bid Placed | `bid_placed` | Immediately after successful bid |
| Outbid | `outbid` | When another user places higher bid (server-triggered) |
| Bid Approved | `bid_approved` | Admin approves bid |
| Bid Rejected | `bid_rejected` | Admin rejects bid |
| Auction Won | `auction_won` | User wins auction |
| Payment Confirmation | `payment_confirmation` | After successful payment |
| Bid Limit Exceeded | `bid_limit_exceeded` | When bid > available limit |
| Bid Failed | `bid_failed` | When bid placement API fails |

### 6.6 Payment Rules

| Rule | Description |
|------|-------------|
| **Payment Gateway** | PayU SDK integration |
| **Subscription Payment** | Required before bidding (SUBT002, plan: "vehicle") |
| **Payment Failure** | Show error, user must retry |
| **Payment Success** | Activate subscription → Allow bid placement |

---

## 7. Reusable Logic

### 7.1 Currency Formatting

```dart
String formatCurrency(double amount) {
  if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
  if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
  return '₹${amount.toStringAsFixed(0)}';
}
```

### 7.2 Status Color Mapping

```dart
// Bid Status → Color
winning → AppColors.success (green)
won → AppColors.buttonPrimary (blue)
outbid → AppColors.error (red)
cancelled → AppColors.grey
active → AppColors.warning (yellow)

// Auction Status → Color
live → AppColors.success (green)
upcoming → AppColors.buttonPrimary (blue)
ended → AppColors.grey
cancelled → AppColors.error (red)
```

### 7.3 Filter Options (Constants)

```dart
categoryOptions: ['Bank', 'Customer', 'Insurance']
vehicleTypeOptions: ['2W', '3W', '4W', 'CV', 'CE', 'FE']
```

### 7.4 DateTime Parsing Utilities

```dart
// Safe parsing with fallback to DateTime.now()
static DateTime _parseDateTime(dynamic dateString)
static double _parseDouble(dynamic value)
static int _parseInt(dynamic value)
```

### 7.5 Bid Amount Error Parsing

```dart
// Extracts current highest bid from error messages like:
// "Bid amount must be higher than current highest bid of 2580000.00"
double? _parseCurrentHighestBid(String errorMessage)
```

### 7.6 Shared Services Used

| Service | Purpose |
|---------|---------|
| `StorageService` | Secure storage for userId, tokens |
| `NetworkService` | HTTP client (Dio wrapper) with auth interceptors |
| `FirebaseMessagingService` | FCM token management and notification sending |
| `ApiRepository` | API call abstraction layer |

---

## 8. Data Models

### 8.1 AuctionListResponse

```dart
class AuctionListResponse {
  final List<AuctionItem> auctions;
  final int totalCount;
  final int page;
  final int limit;
}
```

### 8.2 AuctionItem

```dart
class AuctionItem {
  final String auctionId;
  final String auctionTitle;
  final String auctionType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalVehicles;
  final String status;
  final String? description;
  final String? imageUrl;
}
```

### 8.3 VechileListResponse

```dart
class VechileListResponse {
  final List<VechileData> vehicles;
  final PaginationInfo? pagination;
}
```

### 8.4 VechileData (Key Fields)

```dart
class VechileData {
  final String vehicleId;
  final String auctionId;
  final String make;
  final String model;
  final String registrationNumber;
  final int yearOfManufacturing;
  final String categoryType;
  final String vehicleType;
  final double currentBidAmount;
  final double minimumBidAmount;
  final int totalBids;
  final String vehicleStatus;
  final String stateName;
  final String cityName;
  final List<String> images;
  // ... additional fields
}
```

### 8.5 MyBidData

```dart
class MyBidData {
  final String bidId;
  final String vehicleId;
  final String auctionId;
  final double bidAmount;
  final String bidStatus; // active, winning, won, outbid, cancelled
  final String vehicleTitle;
  final String registrationNumber;
  final DateTime bidTime;
  final String auctionTitle;
}
```

### 8.6 MyWinData

```dart
class MyWinData {
  final String winId;
  final String vehicleId;
  final String auctionId;
  final double winningBidAmount;
  final String vehicleTitle;
  final String registrationNumber;
  final String auctionTitle;
  final bool insuranceInterest;
}
```

### 8.7 PaginationInfo

```dart
class PaginationInfo {
  final int totalCount;
  final int page;
  final int limit;
  final bool hasNext;
}
```

### 8.8 Region

```dart
class Region {
  final String regionId;
  final String name;
}
```

### 8.9 StateByRegion

```dart
class StateByRegion {
  final String stateId;
  final String stateName;
  final String stateCode;
}
```

---

## 9. Suggested Improvements

### 9.1 Current Limitations

| Issue | Description |
|-------|-------------|
| **No offline support** | All data requires network; no local caching or offline mode |
| **No debouncing on search** | Vehicle search triggers API call on every character change |
| **Inconsistent naming** | Mix of `vechile`/`vehicle` spelling throughout codebase |
| **Large controller** | `AuctionController` is 5500+ lines; handles too many concerns |
| **No error retry for individual items** | Failed loads require full page refresh |
| **Tab data not synced** | Switching tabs may show stale data if auctions change status |

### 9.2 UI/UX Improvements

| Improvement | Description |
|-------------|-------------|
| **Skeleton screens** | Replace shimmer with more accurate skeleton matching final layout |
| **Bid amount suggestions** | Show suggested bid amounts (current + 5%, 10%, etc.) |
| **Real-time bid updates** | WebSocket integration for live bid updates without refresh |
| **Vehicle comparison** | Allow side-by-side comparison of vehicles |
| **Map integration** | Show vehicle locations on map |
| **Advanced search** | Multi-field search with autocomplete |
| **Bid history timeline** | Visual timeline of all bids on a vehicle |
| **Notification preferences** | Let users configure which notifications they want |

### 9.3 Performance Optimizations

| Optimization | Description |
|-------------|-------------|
| **Lazy tab loading** | Only load data for tab when it's first selected |
| **Image caching** | Implement proper image caching with `cached_network_image` |
| **Pagination prefetch** | Pre-fetch next page when user reaches 60% scroll |
| **API response compression** | Enable gzip compression for large listings |
| **Debounced search** | Add 300ms debounce to search input |
| **Virtual scrolling** | For very large lists, use virtualized list rendering |

### 9.4 Code Refactoring Opportunities

| Refactoring | Description |
|-------------|-------------|
| **Split controller** | Break into: `AuctionListController`, `VehicleListController`, `BidController`, `MyBidsController`, `MyWinsController` |
| **Use repository pattern** | Abstract API calls behind proper repository interfaces |
| **Extract filter logic** | Create dedicated `FilterManager` class |
| **Standardize error handling** | Create unified error handling with typed exceptions |
| **Add unit tests** | Current module has no test coverage |
| **Use code generation** | For models (freezed/json_serializable) to reduce boilerplate |

### 9.5 Reusability for New Application

| Aspect | Recommendation |
|--------|---------------|
| **API Layer** | Keep the same request/response structures; only change base URL |
| **Business Logic** | Port controller logic as-is; refactor into clean architecture |
| **Models** | Use code generation (freezed) for type safety |
| **Pagination** | Extract into a reusable `PaginatedListController<T>` mixin |
| **Filters** | Create a generic `FilterBottomSheet` widget accepting filter configuration |
| **Payment Flow** | Abstract payment gateway behind interface for easy swapping |
| **Notifications** | Keep FCM structure; abstract notification service |
| **State Management** | If migrating from GetX, map reactive variables to chosen solution (Riverpod/Bloc) |

---

## Appendix: File Structure Reference

```
lib/modules/auction/
├── controllers/
│   └── auction_controller.dart          # Main controller (5575 lines)
├── models/
│   ├── auction_list_model.dart
│   ├── auction_model.dart
│   ├── auction_vehicle_bid_model.dart
│   ├── excel_download_model.dart
│   ├── initiate_refund_model.dart
│   ├── insurance_interest_model.dart
│   ├── my_bids_model.dart
│   ├── my_subscription_model.dart
│   ├── my_wins_model.dart
│   ├── regions_model.dart
│   ├── state_regions_model.dart
│   ├── states_by_region_model.dart
│   ├── subscription_list_model.dart
│   ├── vechile_list_model.dart
│   ├── vehicle_search_model.dart
│   └── winning_letter_model.dart
├── services/
│   └── auction_service.dart             # Legacy service (mock data + API)
├── views/
│   ├── auction_view.dart                # Main auction listing (3 tabs)
│   ├── vechile_view.dart                # Vehicle listing for auction
│   ├── my_bids.dart                     # User's bid history
│   ├── my_wins.dart                     # User's won auctions
│   └── initiate_refund.dart             # Refund request screen
└── widgets/
    ├── auction_list_card.dart           # Auction summary card
    └── auction_vehicle_card.dart        # Vehicle card in auction

lib/core/api/
└── api_constant.dart                    # All API endpoint constants
```

---

## Appendix: Route Definitions

| Route | Screen | Arguments |
|-------|--------|-----------|
| `/auctions` | AuctionView | — |
| `/auctions/vehicles` | VehicleView | `auctionId` |
| `/auctions/vehicle-detail` | Vehicle Detail | `vehicle` object |
| `/auctions/my-bids` | MyBids | — |
| `/auctions/my-wins` | MyWins | — |
| `/subscription-plans` | Subscription | `source`, `planType` |
| `/initiate-refund` | Refund | `auctionId` |
# Inspection & Valuation Module — Complete Documentation

> **Purpose**: This document provides a comprehensive, field-level overview of the **Inspection & Valuation** module from the Vahaan Bazar mobile Flutter app. It is intended to serve as a complete reference guide for implementing the full module following the project's established architecture — ensuring no feature, validation, field, or business logic is missed.

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Directory Structure](#2-directory-structure)
3. [Architecture & Design Patterns](#3-architecture--design-patterns)
4. [Dependencies & Shared Services](#4-dependencies--shared-services)
5. [API Endpoints](#5-api-endpoints)
6. [Data Models](#6-data-models)
7. [Inspection Home View — Complete UI Specification](#7-inspection-home-view--complete-ui-specification)
8. [Customer Valuation Form View](#8-customer-valuation-form-view)
9. [Agent Valuation Form View](#9-agent-valuation-form-view)
10. [My Inspections List View](#10-my-inspections-list-view)
11. [Inspection Detail View](#11-inspection-detail-view)
12. [Controller State Variables](#12-controller-state-variables)
13. [Key Business Logic & Flows](#13-key-business-logic--flows)
14. [Validation Strategy](#14-validation-strategy)
15. [Shared Widgets Used](#15-shared-widgets-used)
16. [Navigation & Routes](#16-navigation--routes)
17. [Error Handling Patterns](#17-error-handling-patterns)
18. [Recreation Checklist](#18-recreation-checklist)

---

## 1. Module Overview

The **Inspection & Valuation** module provides vehicle inspection and valuation services to both customers and agents. It features two distinct user flows — one for customers requesting vehicle inspections and one for agents performing detailed vehicle valuations with multi-step forms and photo uploads.

| Feature | Description |
|---------|-------------|
| **Inspection Home** | A landing page showcasing inspection services with CTAs for both customer and agent flows. |
| **Customer Valuation Form** | A form where customers can submit vehicle details (registration, chassis, type, brand, location) along with RC, insurance, and GST document uploads. |
| **Agent Valuation Form** | A comprehensive multi-step form for agents to perform detailed vehicle inspections covering 12+ inspection categories with condition ratings, remarks, photo uploads, and market value assessment. |
| **My Inspections List** | A paginated, pull-to-refresh list of the user's past inspection submissions with status badges and vehicle details. |
| **Inspection Detail** | Detailed view of a single inspection submission showing all vehicle details, inspection results, condition ratings, uploaded images, and valuation. |
| **Valuation Dropdown Options** | Pre-loaded dropdown options for vehicle types, brands, states, cities, condition ratings, fuel types, transmission types, etc. |

The module supports two user roles:
- **Customer**: Can submit a vehicle for inspection/valuation with basic details and documents
- **Agent**: Can perform detailed on-site vehicle inspections with comprehensive condition assessments

---

## 2. Directory Structure

### Current State (Existing)

```
lib/modules/inspection_valuation/
├── models/
│   ├── agent_valuation_request.dart          # Agent valuation form request model (169 lines)
│   ├── customer_valuation_request.dart       # Customer valuation form request model (44 lines)
│   ├── customer_valuation_response.dart      # Customer valuation response model (221 lines)
│   ├── inspection_vehicle.dart               # Inspection vehicle list item model (51 lines)
│   ├── my_inspections_request.dart           # My inspections pagination request (24 lines)
│   ├── my_inspections_response.dart          # My inspections list response model (78 lines)
│   └── pagination.dart                       # Pagination model (shared)
```

### Target State (To Be Implemented)

```
lib/modules/inspection_valuation/
├── bindings/
│   └── inspection_valuation_binding.dart     # GetX dependency injection binding
├── controllers/
│   ├── inspection_valuation_controller.dart  # Main controller — home, customer form, my inspections
│   └── agent_inspection_controller.dart      # Agent-specific controller — multi-step form, image uploads
├── models/
│   ├── agent_valuation_request.dart          # [EXISTS] Agent valuation form request model
│   ├── customer_valuation_request.dart       # [EXISTS] Customer valuation form request model
│   ├── customer_valuation_response.dart      # [EXISTS] Customer valuation response model
│   ├── inspection_vehicle.dart               # [EXISTS] Inspection vehicle list item model
│   ├── my_inspections_request.dart           # [EXISTS] My inspections pagination request
│   ├── my_inspections_response.dart          # [EXISTS] My inspections list response model
│   ├── pagination.dart                       # [EXISTS] Pagination model
│   ├── inspection_detail_model.dart          # [NEW] Full inspection detail response model
│   ├── valuation_dropdown_options_model.dart # [NEW] Dropdown options for forms
│   └── inspection_submit_response.dart       # [NEW] Generic submission response model
├── views/
│   ├── inspection_home_view.dart             # Landing page with customer/agent CTAs
│   ├── customer_valuation_form_view.dart     # Customer form with document uploads
│   ├── agent_valuation_form_view.dart        # Multi-step agent inspection form
│   ├── my_inspections_view.dart              # Paginated inspection history list
│   └── inspection_detail_view.dart           # Single inspection detail view
└── widgets/
    ├── inspection_card.dart                  # Card widget for inspection list items
    ├── inspection_step_indicator.dart        # Step progress indicator for agent form
    ├── condition_rating_widget.dart          # Reusable condition rating selector
    ├── image_upload_section.dart             # Reusable image upload section
    ├── document_upload_widget.dart           # Reusable document upload widget
    └── valuation_summary_card.dart           # Summary card for valuation details
```

### Shared Dependencies (Outside Module)

```
lib/core/
├── api/
│   ├── api_constant.dart                     # [EXISTS] Inspection API endpoints defined
│   └── api_repository.dart                   # [TO ADD] Inspection API methods
├── constants/
│   ├── app_colors.dart                       # Color constants
│   ├── app_images.dart                       # Image assets (AppImages.inspection)
│   └── app_text_styles.dart                  # Text style helper
├── services/
│   ├── storage_service.dart                  # SharedPreferences — getUserId(), userData
│   └── location_service.dart                 # GPS/Location services

lib/shared/widgets/
├── custom_app_bar.dart                       # CustomAppBar widget
├── custom_button.dart                        # CustomButton widget
├── custom_drawer.dart                        # CustomDrawer (categoryType: 'inspection')
├── shimmer_widget.dart                       # Shimmer loading placeholder
├── custom_text_field.dart                    # Custom text input field
├── custom_dropdown.dart                      # Custom dropdown selector
├── size_config.dart                          # Responsive sizing utilities
└── zoomable_image_viewer.dart                # Full-screen image viewer
```

---

## 3. Architecture & Design Patterns

### GetX Pattern

The module follows the same **GetX architecture** as all other modules:

- **Bindings**: Lazy-loaded dependency injection via `Get.lazyPut<Controller>()`
- **Controllers**: Business logic, state management, API calls using `GetxController`
- **Views**: Stateless UI using `GetView<Controller>` for automatic controller access
- **Widgets**: Reusable, composable UI components

### Controller Responsibilities

| Controller | Scope |
|------------|-------|
| `InspectionValuationController` | Home view state, customer form submission, my inspections list, pagination, pull-to-refresh, dropdown options loading |
| `AgentInspectionController` | Multi-step form state, step navigation, image uploads, condition ratings, form validation, submission |

### State Management

- **Rx variables** (`RxString`, `RxInt`, `RxBool`, `RxList`) for reactive UI updates
- **isLoading**, **isSubmitting**, **hasError** flags for UI state management
- **Pagination** with `currentPage`, `totalPages`, `hasMore` for infinite scroll
- **ScrollController** for detecting scroll-to-bottom for lazy loading

---

## 4. Dependencies & Shared Services

### Required Flutter Packages

| Package | Purpose |
|---------|---------|
| `get` | State management, dependency injection, routing |
| `cached_network_image` | Image caching for vehicle photos |
| `image_picker` | Camera/gallery image selection for agent form |
| `url_launcher` | Opening web URLs (inspection reports) |
| `flutter_svg` | SVG icon rendering |
| `shimmer` | Loading skeleton animations |

### Internal Services

| Service | Usage |
|---------|-------|
| `StorageService` | Get user ID, auth token, user data |
| `LocationService` | Get current GPS coordinates for agent inspections |

---

## 5. API Endpoints

### Base Configuration

```
Base URL: https://api.prod.vahaanbazar.in
API Prefix: /api/v1/inspection-valuation
API Key Header: X-API-Key: 7B0F2K4R1MSS3P0D
Auth Header: Authorization: Bearer <token>
```

### Endpoint Details

#### 5.1 Valuation Dropdown Options

```
GET /api/v1/inspection-valuation/valuation-dropdown-options
```

**Description**: Fetches all dropdown options needed for forms (vehicle types, brands, states, cities, conditions, fuel types, transmission types, etc.)

**Response Model**: `ValuationDropdownOptionsModel`

```json
{
  "status": "success",
  "code": 200,
  "message": "Dropdown options fetched successfully",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "vehicle_types": ["Truck", "Bus", "Car", "Tractor", "JCB", "Crane"],
    "vehicle_brands": ["Tata", "Ashok Leyland", "Mahindra", "Eicher", "Bharat Benz"],
    "states": [
      { "id": "1", "name": "Maharashtra" },
      { "id": "2", "name": "Karnataka" }
    ],
    "cities": [
      { "id": "1", "state_id": "1", "name": "Mumbai" },
      { "id": "2", "state_id": "1", "name": "Pune" }
    ],
    "condition_options": ["Excellent", "Good", "Average", "Poor"],
    "fuel_types": ["Diesel", "Petrol", "CNG", "Electric", "LPG"],
    "transmission_types": ["Manual", "Automatic", "Semi-Automatic"],
    "case_types": ["Running", "Non-Running", "Accidental", "Scrap"],
    "hypothecation_options": ["Yes", "No"],
    "accidental_status_options": ["Yes", "No"],
    "tyre_condition_options": ["New", "Good", "Average", "Replace"]
  }
}
```

#### 5.2 Customer Inspection Form Submission

```
POST /api/v1/inspection-valuation/customer-inspection-form
Content-Type: multipart/form-data
```

**Description**: Customer submits vehicle for inspection with basic details and document uploads.

**Request Fields** (multipart/form-data):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vehicle_no` | String | ✅ | Vehicle registration number |
| `chasis_no` | String | ✅ | Chassis number |
| `vehicle_type` | String | ✅ | Type of vehicle (Truck, Bus, etc.) |
| `vehicle_brand` | String | ✅ | Vehicle brand/manufacturer |
| `vehicle_state` | String | ✅ | State where vehicle is registered |
| `vehicle_city` | String | ✅ | City where vehicle is located |
| `vehicle_owner_number` | String | ✅ | Owner's mobile number |
| `company_name` | String | ❌ | Company name (if applicable) |
| `rc_file` | File | ✅ | RC (Registration Certificate) document |
| `insurance_file` | File | ❌ | Insurance document |
| `company_gst_file` | File | ❌ | Company GST document |

**Response Model**: `CustomerValuationResponse`

```json
{
  "status": "success",
  "code": 201,
  "message": "Inspection request submitted successfully",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "submission_id": "INS-2025-001",
    "vehicle_id": "VH-12345",
    "category_plan": "basic",
    "subscription_amount": 500.00,
    "vehicle_details": {
      "vehicle_no": "MH-01-AB-1234",
      "chasis_no": "CHS123456789",
      "vehicle_type": "Truck",
      "vehicle_brand": "Tata",
      "vehicle_state": "Maharashtra",
      "vehicle_city": "Mumbai",
      "vehicle_owner_number": "9876543210"
    },
    "company_details": {
      "name": "ABC Transport"
    },
    "uploaded_files": {
      "rc_file": {
        "file_type": "pdf",
        "original_filename": "rc_document.pdf",
        "filename": "rc_20250115_abc123.pdf",
        "file_key": "inspections/files/rc_20250115_abc123.pdf",
        "file_url": "https://cdn.vahaanbazar.in/inspections/files/rc_20250115_abc123.pdf"
      },
      "insurance_file": null,
      "company_gst_file": null
    },
    "database_note": "Record created successfully",
    "status": "pending",
    "submitted_at": "2025-01-15T10:30:00Z"
  }
}
```

#### 5.3 Agent Valuation Form Submission

```
POST /api/v1/inspection-valuation/agent-valuation-form
Content-Type: multipart/form-data
```

**Description**: Agent submits a comprehensive vehicle inspection report with detailed condition assessments and multiple photo uploads.

**Request Fields** (multipart/form-data):

**Basic Vehicle Information:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `owner_name` | String | ❌ | Vehicle owner's name |
| `vehicle_registration_number` | String | ✅ | Vehicle registration number |
| `vehicle_type` | String | ✅ | Type of vehicle |
| `vehicle_brand` | String | ✅ | Vehicle brand |
| `vehicle_state` | String | ✅ | State |
| `vehicle_city` | String | ✅ | City |
| `chasis_number` | String | ❌ | Chassis number |
| `manufacturing_year` | String | ❌ | Manufacturing year |
| `engine_number` | String | ❌ | Engine number |
| `rto_location` | String | ❌ | RTO location |
| `owner_number` | String | ❌ | Owner's mobile number |

**Vehicle Condition & Documentation:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vehicle_condition_text` | String | ❌ | Overall vehicle condition description |
| `vehicle_condition_dropdown` | String | ❌ | Condition from dropdown (Excellent/Good/Average/Poor) |
| `insurance_valid_till` | String | ❌ | Insurance validity date |
| `fitness_valid_till` | String | ❌ | Fitness certificate validity date |
| `tax_pending` | String | ❌ | Pending tax amount/details |
| `hypothecation` | String | ❌ | Is vehicle hypothecated (Yes/No) |
| `hypothecated_to` | String | ❌ | Financier name if hypothecated |
| `case_type` | String | ❌ | Case type (Running/Non-Running/Accidental/Scrap) |
| `hours` | String | ❌ | Operating hours (for machinery) |
| `odometer` | String | ❌ | Odometer reading in KM |
| `fuel` | String | ❌ | Fuel type (Diesel/Petrol/CNG/Electric) |
| `transmission_type` | String | ❌ | Transmission type (Manual/Automatic) |
| `accidental_status` | String | ❌ | Has accidental history (Yes/No) |

**Inspection Categories (Condition + Remarks for each):**

| Category | Condition Field | Remarks Field | Image Upload Field |
|----------|----------------|---------------|---------------------|
| Engine | `engine_condition` | `engine_remarks` | `engine_images[]` |
| Transmission | `transmission_condition` | `transmission_remarks` | `transmission_images[]` |
| Suspension | `suspension_condition` | `suspension_remarks` | `suspension_images[]` |
| Tyres | — | — | `tyre_images[]` |
| Body | `body_condition` | `body_remarks` | `body_front_image[]`, `body_back_image[]`, `body_left_image[]`, `body_right_image[]` |
| Cabin/Interior | `cabin_interior_condition` | `cabin_interior_remarks` | `cabin_interior_images[]` |
| Electrical | `electrical_condition` | `electrical_remarks` | `electrical_images[]` |
| Chassis | `chasis_condition` | `chasis_remarks` | `chasis_images[]` |
| Odometer | — | `odometer_remarks` | `odometer_images[]` |

**Tyre Specific:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `front_axle_tyres_percentage` | Integer | ❌ | Front axle tyre life remaining (%) |
| `rear_axle_tyres_percentage` | Integer | ❌ | Rear axle tyre life remaining (%) |

**Valuation & Summary:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `asset_market_value` | Double | ❌ | Estimated market value |
| `other_remarks` | String | ❌ | Any additional remarks |
| `web_url` | String | ❌ | External inspection report URL |

**Image Uploads** (all multipart files, multiple files per field):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `engine_images` | File[] | ❌ | Engine photos |
| `transmission_images` | File[] | ❌ | Transmission photos |
| `suspension_images` | File[] | ❌ | Suspension photos |
| `tyre_images` | File[] | ❌ | Tyre photos |
| `body_front_image` | File[] | ❌ | Body front photos |
| `body_back_image` | File[] | ❌ | Body back photos |
| `body_left_image` | File[] | ❌ | Body left side photos |
| `body_right_image` | File[] | ❌ | Body right side photos |
| `cabin_interior_images` | File[] | ❌ | Cabin/interior photos |
| `electrical_images` | File[] | ❌ | Electrical system photos |
| `chasis_images` | File[] | ❌ | Chassis photos |
| `odometer_images` | File[] | ❌ | Odometer reading photos |

#### 5.4 My Inspections List

```
GET /api/v1/inspection-valuation/my-inspections
Query Parameters:
  - user_id: String (required)
  - page: Integer (default: 1)
  - limit: Integer (default: 10)
```

**Description**: Fetches paginated list of user's inspection submissions.

**Response Model**: `MyInspectionsResponse`

```json
{
  "status": "success",
  "code": 200,
  "message": "Inspections fetched successfully",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "success": true,
    "message": "Data fetched successfully",
    "data": [
      {
        "vehicle_no": "MH-01-AB-1234",
        "chasis_no": "CHS123456789",
        "vehicle_type": "Truck",
        "vehicle_brand": "Tata",
        "vehicle_state": "Maharashtra",
        "vehicle_city": "Mumbai",
        "vehicle_owner_number": "9876543210",
        "web_url": "https://report.vahaanbazar.in/INS-001",
        "status": "completed"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 50,
      "limit": 10,
      "has_next": true,
      "has_previous": false
    }
  }
}
```

---

## 6. Data Models

### 6.1 InspectionVehicle [EXISTS]

**File**: `lib/modules/inspection_valuation/models/inspection_vehicle.dart`

Represents a single inspection item in the "My Inspections" list.

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| `vehicleNo` | `String` | `vehicle_no` | Vehicle registration number |
| `chasisNo` | `String` | `chasis_no` | Chassis number |
| `vehicleType` | `String` | `vehicle_type` | Vehicle type |
| `vehicleBrand` | `String` | `vehicle_brand` | Vehicle brand |
| `vehicleState` | `String` | `vehicle_state` | State |
| `vehicleCity` | `String` | `vehicle_city` | City |
| `vehicleOwnerNumber` | `String` | `vehicle_owner_number` | Owner phone |
| `webUrl` | `String` | `web_url` | Report URL |
| `status` | `String` | `status` | Status (pending/completed/rejected) |

### 6.2 CustomerValuationRequest [EXISTS]

**File**: `lib/modules/inspection_valuation/models/customer_valuation_request.dart`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vehicleNo` | `String` | ✅ | Registration number |
| `chasisNo` | `String` | ✅ | Chassis number |
| `vehicleType` | `String` | ✅ | Vehicle type |
| `vehicleBrand` | `String` | ✅ | Vehicle brand |
| `vehicleState` | `String` | ✅ | State |
| `vehicleCity` | `String` | ✅ | City |
| `vehicleOwnerNumber` | `String` | ✅ | Owner phone |
| `companyName` | `String?` | ❌ | Company name |
| `rcFile` | `File` | ✅ | RC document file |
| `insuranceFile` | `File?` | ❌ | Insurance document |
| `companyGstFile` | `File?` | ❌ | GST document |

### 6.3 CustomerValuationResponse [EXISTS]

**File**: `lib/modules/inspection_valuation/models/customer_valuation_response.dart`

Nested response structure:
- `CustomerValuationResponse` → `CustomerValuationData` → `VehicleDetails`, `CompanyDetails`, `UploadedFiles` → `FileDetails`

### 6.4 AgentValuationRequest [EXISTS]

**File**: `lib/modules/inspection_valuation/models/agent_valuation_request.dart`

Comprehensive model with 47+ fields covering:
- Basic vehicle info (11 fields)
- Vehicle condition & documentation (13 fields)
- Inspection categories with conditions, remarks (16 fields)
- Tyre percentages (2 fields)
- Valuation (2 fields)
- Image uploads (12 list fields, all `List<File>`)

### 6.5 MyInspectionsRequest [EXISTS]

**File**: `lib/modules/inspection_valuation/models/my_inspections_request.dart`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `userId` | `String` | required | User ID |
| `page` | `int` | `1` | Page number |
| `limit` | `int` | `10` | Items per page |

### 6.6 MyInspectionsResponse [EXISTS]

**File**: `lib/modules/inspection_valuation/models/my_inspections_response.dart`

Response structure: `MyInspectionsResponse` → `MyInspectionsData` → `List<InspectionVehicle>`, `Pagination`

### 6.7 ValuationDropdownOptionsModel [NEW — TO CREATE]

**File**: `lib/modules/inspection_valuation/models/valuation_dropdown_options_model.dart`

```dart
class ValuationDropdownOptionsModel {
  final List<String> vehicleTypes;
  final List<String> vehicleBrands;
  final List<LocationOption> states;
  final List<LocationOption> cities;
  final List<String> conditionOptions;
  final List<String> fuelTypes;
  final List<String> transmissionTypes;
  final List<String> caseTypes;
  final List<String> hypothecationOptions;
  final List<String> accidentalStatusOptions;
  final List<String> tyreConditionOptions;
  // ... factory fromJson, toJson
}

class LocationOption {
  final String id;
  final String name;
  final String? stateId; // for cities
  // ... factory fromJson, toJson
}
```

### 6.8 InspectionDetailModel [NEW — TO CREATE]

**File**: `lib/modules/inspection_valuation/models/inspection_detail_model.dart`

Full detail model for viewing a single inspection with all fields, images, and valuation data.

### 6.9 InspectionSubmitResponse [NEW — TO CREATE]

**File**: `lib/modules/inspection_valuation/models/inspection_submit_response.dart`

Generic response model for both customer and agent form submissions.

---

## 7. Inspection Home View — Complete UI Specification

**File**: `lib/modules/inspection_valuation/views/inspection_home_view.dart`

### Layout Structure

```
Scaffold
├── CustomAppBar (title: "Inspection & Valuation", drawer: true, notifications: true)
├── Drawer: CustomDrawer(categoryType: 'inspection_valuation')
└── SingleChildScrollView
    ├── Hero Section
    │   ├── Background Image (assets/images/inspection.png)
    │   ├── Title: "Vehicle Inspection & Valuation"
    │   └── Subtitle: "Get professional vehicle inspection and accurate valuation reports"
    ├── Service Cards Section
    │   ├── Card 1: Customer Inspection
    │   │   ├── Icon: clipboard/check icon
    │   │   ├── Title: "Request Inspection"
    │   │   ├── Description: "Submit your vehicle for professional inspection and valuation"
    │   │   └── CTA Button: "Get Started" → Customer Valuation Form
    │   └── Card 2: Agent Inspection
    │       ├── Icon: search/inspect icon
    │       ├── Title: "Agent Inspection"
    │       ├── Description: "Perform detailed on-site vehicle inspection and submit report"
    │       └── CTA Button: "Start Inspection" → Agent Valuation Form
    ├── My Inspections Card
    │   ├── Icon: list/history icon
    │   ├── Title: "My Inspections"
    │   ├── Description: "View your past inspection submissions and reports"
    │   └── CTA: "View History" → My Inspections List
    └── Footer / Info Section
        └── Contact info or help text
```

### Styling

- **Card Style**: Elevated cards with rounded corners (12px), subtle shadow
- **Hero Section**: Gradient overlay on background image
- **Colors**: Uses `AppColors` theme — `AppColors.buttonPrimary`, `AppColors.white`, `AppColors.black`
- **Typography**: `AppTextStyles.getPoppinsStyle()` with varying weights
- **Responsive**: Uses `SizeConfig` for responsive sizing across devices
- **Spacing**: Consistent padding using `SizeConfig.responsiveWidth/Height`

### Navigation Actions

| Action | Target |
|--------|--------|
| "Get Started" button | `AppRoutes.customerValuationForm` |
| "Start Inspection" button | `AppRoutes.agentValuationForm` |
| "View History" button | `AppRoutes.myInspections` |
| Drawer menu item | `CustomDrawer` handles navigation |

---

## 8. Customer Valuation Form View

**File**: `lib/modules/inspection_valuation/views/customer_valuation_form_view.dart`

### Layout Structure

```
Scaffold
├── AppBar (title: "Request Vehicle Inspection", back: true)
└── Form (GlobalKey<FormState>)
    ├── SingleChildScrollView
    │   ├── Vehicle Details Section
    │   │   ├── Section Header: "Vehicle Details"
    │   │   ├── TextField: Vehicle Registration Number* (vehicleno icon)
    │   │   ├── TextField: Chassis Number* (chassisnum icon)
    │   │   ├── Dropdown: Vehicle Type* (populated from dropdown options)
    │   │   ├── Dropdown: Vehicle Brand* (populated from dropdown options)
    │   │   ├── Dropdown: State* (populated, triggers city filter)
    │   │   ├── Dropdown: City* (filtered by selected state)
    │   │   └── TextField: Owner Mobile Number* (10 digits, numeric)
    │   ├── Company Details Section (Optional)
    │   │   ├── Section Header: "Company Details (Optional)"
    │   │   └── TextField: Company Name
    │   └── Document Upload Section
    │       ├── Section Header: "Upload Documents"
    │       ├── DocumentUploadWidget: RC Document* (PDF/Image)
    │       ├── DocumentUploadWidget: Insurance Document (PDF/Image)
    │       └── DocumentUploadWidget: Company GST (PDF/Image)
    └── Padding
        └── CustomButton: "Submit Inspection Request"
            (isLoading: controller.isSubmitting.value)
```

### Form Validation Rules

| Field | Rules |
|-------|-------|
| Vehicle Registration Number | Required, min 5 characters |
| Chassis Number | Required, min 5 characters |
| Vehicle Type | Required (dropdown selection) |
| Vehicle Brand | Required (dropdown selection) |
| State | Required (dropdown selection) |
| City | Required (dropdown selection) |
| Owner Mobile Number | Required, exactly 10 digits, numeric only, starts with 6-9 |
| RC Document | Required (file must be selected) |
| Insurance Document | Optional |
| Company GST | Optional |
| Company Name | Optional |

### User Flow

1. User fills in vehicle details
2. User optionally adds company details
3. User uploads required RC document and optional insurance/GST
4. User taps "Submit Inspection Request"
5. Controller validates form → calls API
6. On success: Show success dialog with submission ID → Navigate to My Inspections
7. On error: Show error snackbar with message

---

## 9. Agent Valuation Form View

**File**: `lib/modules/inspection_valuation/views/agent_valuation_form_view.dart`

### Multi-Step Form Architecture

The agent form uses a **6-step wizard** pattern with step indicator at the top.

### Step Indicator

```
InspectionStepIndicator
├── Step 1: Vehicle Info
├── Step 2: Documentation
├── Step 3: Mechanical
├── Step 4: Body & Interior
├── Step 5: Photos
└── Step 6: Valuation
```

### Step 1: Vehicle Information

```
├── Section: "Vehicle Information"
├── TextField: Owner Name
├── TextField: Vehicle Registration Number*
├── Dropdown: Vehicle Type*
├── Dropdown: Vehicle Brand*
├── Dropdown: State*
├── Dropdown: City* (filtered)
├── TextField: Chassis Number
├── TextField: Manufacturing Year
├── TextField: Engine Number
├── TextField: RTO Location
├── TextField: Owner Mobile Number
└── Navigation: [Next] button
```

### Step 2: Documentation & Condition

```
├── Section: "Documentation & Condition"
├── TextField: Vehicle Condition (text description)
├── Dropdown: Vehicle Condition (dropdown - Excellent/Good/Average/Poor)
├── TextField: Insurance Valid Till (date picker)
├── TextField: Fitness Valid Till (date picker)
├── TextField: Tax Pending
├── Dropdown: Hypothecation (Yes/No)
├── TextField: Hypothecated To (conditional - shown if hypothecation = Yes)
├── Dropdown: Case Type (Running/Non-Running/Accidental/Scrap)
├── TextField: Hours (for machinery)
├── TextField: Odometer (KM)
├── Dropdown: Fuel Type
├── Dropdown: Transmission Type
├── Dropdown: Accidental Status (Yes/No)
└── Navigation: [Back] [Next] buttons
```

### Step 3: Mechanical Inspection

```
├── Section: "Mechanical Inspection"
├── Engine
│   ├── ConditionRatingWidget: Engine Condition (Excellent/Good/Average/Poor)
│   └── TextField: Engine Remarks
├── Transmission
│   ├── ConditionRatingWidget: Transmission Condition
│   └── TextField: Transmission Remarks
├── Suspension
│   ├── ConditionRatingWidget: Suspension Condition
│   └── TextField: Suspension Remarks
├── Tyres
│   ├── Slider/TextField: Front Axle Tyres % (0-100)
│   └── Slider/TextField: Rear Axle Tyres % (0-100)
└── Navigation: [Back] [Next] buttons
```

### Step 4: Body & Interior Inspection

```
├── Section: "Body & Interior"
├── Body
│   ├── ConditionRatingWidget: Body Condition
│   └── TextField: Body Remarks
├── Cabin/Interior
│   ├── ConditionRatingWidget: Cabin Interior Condition
│   └── TextField: Cabin Interior Remarks
├── Electrical
│   ├── ConditionRatingWidget: Electrical Condition
│   └── TextField: Electrical Remarks
├── Chassis
│   ├── ConditionRatingWidget: Chassis Condition
│   └── TextField: Chassis Remarks
├── Odometer
│   └── TextField: Odometer Remarks
└── Navigation: [Back] [Next] buttons
```

### Step 5: Photo Upload

```
├── Section: "Photo Documentation"
├── ImageUploadSection: Engine Images (multiple)
├── ImageUploadSection: Transmission Images (multiple)
├── ImageUploadSection: Suspension Images (multiple)
├── ImageUploadSection: Tyre Images (multiple)
├── ImageUploadSection: Body Front (multiple)
├── ImageUploadSection: Body Back (multiple)
├── ImageUploadSection: Body Left (multiple)
├── ImageUploadSection: Body Right (multiple)
├── ImageUploadSection: Cabin/Interior (multiple)
├── ImageUploadSection: Electrical (multiple)
├── ImageUploadSection: Chassis (multiple)
├── ImageUploadSection: Odometer (multiple)
└── Navigation: [Back] [Next] buttons
```

**Image Upload Features**:
- Camera capture or gallery selection via `ImagePicker`
- Image preview thumbnails with delete option
- Max 5 images per category
- Image compression before upload
- Progress indicator during upload

### Step 6: Valuation & Summary

```
├── Section: "Valuation"
├── TextField: Asset Market Value (₹, numeric with decimal)
├── TextField: Other Remarks (multiline)
├── Section: "Inspection Summary"
│   └── ValuationSummaryCard
│       ├── Vehicle details summary
│       ├── Condition ratings summary
│       ├── Photo count per category
│       └── Total estimated value
└── Navigation: [Back] [Submit Inspection] button
```

### Submission Flow

1. User completes all 6 steps
2. User taps "Submit Inspection"
3. Controller validates all required fields across all steps
4. If validation fails: Navigate to first invalid step with error highlights
5. If valid: Show confirmation dialog
6. On confirm: Call API with multipart form data
7. Show loading overlay during submission
8. On success: Show success dialog → Navigate to My Inspections
9. On error: Show error snackbar, stay on current step

---

## 10. My Inspections List View

**File**: `lib/modules/inspection_valuation/views/my_inspections_view.dart`

### Layout Structure

```
Scaffold
├── AppBar (title: "My Inspections", back: true)
└── Column
    ├── Filter/Sort Bar (optional)
    │   └── Status filter chips: All | Pending | Completed | Rejected
    └── Expanded
        └── Obx(() => _buildBody())
            ├── Loading State: Shimmer list (5 shimmer cards)
            ├── Empty State:
            │   ├── Icon: clipboard empty
            │   ├── Text: "No inspections found"
            │   ├── Subtitle: "Your inspection requests will appear here"
            │   └── CTA: "Request Inspection" button
            ├── Error State:
            │   ├── Icon: error
            │   ├── Text: "Something went wrong"
            │   └── CTA: "Retry" button
            └── Data State: RefreshIndicator + ListView.builder
                ├── RefreshIndicator (pull-to-refresh)
                └── ListView.builder
                    ├── InspectionCard items (tap → Inspection Detail)
                    └── Load More indicator (at bottom, when hasMore)
```

### InspectionCard Widget

```
Card
├── Row
│   ├── Leading: Vehicle type icon (based on vehicleType)
│   └── Expanded
│       ├── Row: Vehicle Number + Status Badge
│       ├── Text: Brand + Type
│       ├── Text: City, State
│       ├── Text: Chassis No (truncated)
│       └── Row: Owner Number + View Report link (if webUrl exists)
```

**Status Badge Colors**:

| Status | Color | Text |
|--------|-------|------|
| `pending` | Orange/Yellow | "Pending" |
| `completed` | Green | "Completed" |
| `in_progress` | Blue | "In Progress" |
| `rejected` | Red | "Rejected" |

### Pagination Behavior

- **Initial load**: Page 1, 10 items
- **Scroll to bottom**: Auto-load next page
- **Pull-to-refresh**: Reset to page 1
- **Loading indicator**: Shimmer for initial, circular progress for load more
- **End of list**: "No more inspections" text at bottom

---

## 11. Inspection Detail View

**File**: `lib/modules/inspection_valuation/views/inspection_detail_view.dart`

### Layout Structure

```
Scaffold
├── AppBar (title: "Inspection Details", back: true, share: true)
└── SingleChildScrollView
    ├── Vehicle Info Card
    │   ├── Vehicle Number (large, bold)
    │   ├── Status Badge
    │   ├── Brand + Type
    │   ├── Chassis Number
    │   ├── State + City
    │   └── Owner Number (with call action)
    ├── Documentation Section (if agent inspection)
    │   ├── Insurance Valid Till
    │   ├── Fitness Valid Till
    │   ├── Case Type
    │   ├── Fuel Type
    │   └── Odometer Reading
    ├── Inspection Results (if agent inspection)
    │   ├── Condition cards for each category:
    │   │   ├── Engine: Condition badge + Remarks
    │   │   ├── Transmission: Condition badge + Remarks
    │   │   ├── Suspension: Condition badge + Remarks
    │   │   ├── Body: Condition badge + Remarks
    │   │   ├── Cabin/Interior: Condition badge + Remarks
    │   │   ├── Electrical: Condition badge + Remarks
    │   │   └── Chassis: Condition badge + Remarks
    │   └── Tyre condition percentages (visual bars)
    ├── Photo Gallery (if agent inspection)
    │   ├── Category tabs or expandable sections
    │   └── Grid of thumbnails → ZoomableImageViewer on tap
    ├── Valuation Section (if available)
    │   ├── Asset Market Value (₹, prominent)
    │   └── Other Remarks
    └── Report Link (if webUrl exists)
        └── "View Full Report" button → url_launcher
```

---

## 12. Controller State Variables

### InspectionValuationController

```dart
class InspectionValuationController extends GetxController {

  // ===== General State =====
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // ===== Dropdown Options =====
  final vehicleTypes = <String>[].obs;
  final vehicleBrands = <String>[].obs;
  final states = <LocationOption>[].obs;
  final cities = <LocationOption>[].obs;
  final conditionOptions = <String>[].obs;
  final fuelTypes = <String>[].obs;
  final transmissionTypes = <String>[].obs;
  final caseTypes = <String>[].obs;
  final filteredCities = <LocationOption>[].obs;

  // ===== Customer Form State =====
  final customerFormKey = GlobalKey<FormState>();
  final vehicleNoController = TextEditingController();
  final chasisNoController = TextEditingController();
  final ownerNumberController = TextEditingController();
  final companyNameController = TextEditingController();
  final selectedVehicleType = ''.obs;
  final selectedVehicleBrand = ''.obs;
  final selectedState = ''.obs;
  final selectedCity = ''.obs;
  final rcFile = Rx<File?>(null);
  final insuranceFile = Rx<File?>(null);
  final companyGstFile = Rx<File?>(null);

  // ===== My Inspections State =====
  final inspections = <InspectionVehicle>[].obs;
  final myInspectionsPage = 1.obs;
  final myInspectionsHasMore = true.obs;
  final isInspectionsLoading = false.obs;
  final isLoadMoreLoading = false.obs;
  ScrollController inspectionsScrollController = ScrollController();

  // ===== Filter State =====
  final selectedStatusFilter = 'all'.obs;

  // ===== Lifecycle =====
  @override
  void onInit() { ... }

  @override
  void onClose() { ... }

  // ===== Methods =====
  Future<void> loadDropdownOptions() async { ... }
  void onStateChanged(String state) { ... }  // Filter cities
  Future<void> submitCustomerForm() async { ... }
  Future<void> fetchMyInspections({bool refresh = false}) async { ... }
  Future<void> loadMoreInspections() async { ... }
  void setupScrollListener() { ... }
  void resetCustomerForm() { ... }
}
```

### AgentInspectionController

```dart
class AgentInspectionController extends GetxController {

  // ===== General State =====
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ===== Step Management =====
  final currentStep = 0.obs;  // 0-5 for 6 steps
  final totalSteps = 6;

  // ===== Step 1: Vehicle Info =====
  final agentFormKey = GlobalKey<FormState>();
  final ownerNameController = TextEditingController();
  final vehicleRegNoController = TextEditingController();
  // ... more text controllers

  // ===== Step 2: Documentation =====
  final selectedCondition = ''.obs;
  final insuranceValidTill = ''.obs;
  final fitnessValidTill = ''.obs;
  final selectedHypothecation = ''.obs;
  final selectedCaseType = ''.obs;
  final selectedFuel = ''.obs;
  final selectedTransmission = ''.obs;
  final selectedAccidentalStatus = ''.obs;

  // ===== Step 3: Mechanical =====
  final engineCondition = ''.obs;
  final engineRemarksController = TextEditingController();
  final transmissionCondition = ''.obs;
  // ... more condition/remarks
  final frontAxleTyresPercent = 0.obs;
  final rearAxleTyresPercent = 0.obs;

  // ===== Step 4: Body & Interior =====
  final bodyCondition = ''.obs;
  // ... more conditions

  // ===== Step 5: Photo Uploads =====
  final engineImages = <File>[].obs;
  final transmissionImages = <File>[].obs;
  final suspensionImages = <File>[].obs;
  final tyreImages = <File>[].obs;
  final bodyFrontImage = <File>[].obs;
  final bodyBackImage = <File>[].obs;
  final bodyLeftImage = <File>[].obs;
  final bodyRightImage = <File>[].obs;
  final cabinInteriorImages = <File>[].obs;
  final electricalImages = <File>[].obs;
  final chasisImages = <File>[].obs;
  final odometerImages = <File>[].obs;

  // ===== Step 6: Valuation =====
  final assetMarketValueController = TextEditingController();
  final otherRemarksController = TextEditingController();

  // ===== Methods =====
  void nextStep() { ... }
  void previousStep() { ... }
  bool validateCurrentStep() { ... }
  Future<void> pickImage(ImageSource source, RxList<File> targetList) async { ... }
  void removeImage(RxList<File> targetList, int index) { ... }
  Future<void> submitAgentForm() async { ... }
  AgentValuationRequest buildRequest() { ... }
  void resetForm() { ... }
}
```

---

## 13. Key Business Logic & Flows

### 13.1 Customer Inspection Flow

```
1. User opens Inspection Home
2. Taps "Request Inspection"
3. Fills in vehicle details (registration, chassis, type, brand, location, phone)
4. Optionally adds company details
5. Uploads RC document (required) + optional insurance/GST
6. Submits form
7. API returns submission ID + vehicle ID
8. Success dialog shown with details
9. User can view status in "My Inspections"
```

### 13.2 Agent Inspection Flow

```
1. User opens Inspection Home
2. Taps "Agent Inspection"
3. Step 1: Enter vehicle basic information
4. Step 2: Enter documentation and condition details
5. Step 3: Rate mechanical components (engine, transmission, suspension, tyres)
6. Step 4: Rate body, interior, electrical, chassis
7. Step 5: Upload photos for each inspection category
8. Step 6: Enter market value estimate and additional remarks
9. Reviews summary
10. Submits comprehensive inspection report
11. Success dialog with submission ID
12. Report available in "My Inspections"
```

### 13.3 State-City Filtering

```
When user selects a state:
1. Filter cities list to show only cities for that state
2. Clear selected city if it doesn't belong to new state
3. Update filteredCities reactive list
```

### 13.4 Image Management

```
For each image upload section:
1. User taps "+" button
2. Bottom sheet appears: "Take Photo" or "Choose from Gallery"
3. Image picked via ImagePicker
4. Image compressed (reduce file size for upload)
5. Added to respective RxList<File>
6. Preview shown with delete "X" button
7. Max 5 images per category (configurable)
```

### 13.5 Pagination Flow

```
My Inspections list:
1. On page load: Fetch page 1 with limit 10
2. ScrollController listens for scroll position
3. When scroll reaches 80% of max extent:
   a. Check hasMore && !isLoadMoreLoading
   b. Increment page
   c. Fetch next page
   d. Append results to existing list
4. Pull-to-refresh:
   a. Reset page to 1
   b. Clear existing list
   c. Fetch fresh data
5. End of list: Show "No more inspections" when hasMore = false
```

### 13.6 Dropdown Options Loading

```
1. On controller init, fetch dropdown options
2. Cache in memory for session duration
3. Populate all dropdowns from cached data
4. Handle loading state (shimmer or loading indicator)
5. Handle error state with retry option
6. State change triggers city filtering
```

---

## 14. Validation Strategy

### Customer Form Validation

| Field | Validation | Error Message |
|-------|------------|---------------|
| Vehicle Number | Required, minLength(5) | "Please enter valid vehicle number" |
| Chassis Number | Required, minLength(5) | "Please enter valid chassis number" |
| Vehicle Type | Required (not empty) | "Please select vehicle type" |
| Vehicle Brand | Required (not empty) | "Please select vehicle brand" |
| State | Required (not empty) | "Please select state" |
| City | Required (not empty) | "Please select city" |
| Owner Number | Required, exactly 10 digits, RegExp(r'^[6-9]\d{9}$') | "Please enter valid 10-digit mobile number" |
| RC File | File != null | "Please upload RC document" |

### Agent Form Step Validation

| Step | Required Fields | Validation |
|------|----------------|------------|
| Step 1 | vehicleRegistrationNumber, vehicleType, vehicleBrand, vehicleState, vehicleCity | Basic required validation |
| Step 2 | None (all optional) | — |
| Step 3 | None (all optional) | Tyre percentage: 0-100 range |
| Step 4 | None (all optional) | — |
| Step 5 | None (all optional) | Image count ≤ 5 per category |
| Step 6 | None (all optional) | Market value: positive number format |

### Cross-Step Validation

- When user reaches Step 6 and taps Submit, validate all required fields across all steps
- If validation fails, navigate to the first step with an error
- Highlight invalid fields with red borders and error text

---

## 15. Shared Widgets Used

| Widget | Source | Usage |
|--------|--------|-------|
| `CustomAppBar` | `lib/shared/widgets/custom_app_bar.dart` | App bar on all views |
| `CustomButton` | `lib/shared/widgets/custom_button.dart` | Submit buttons, CTA buttons |
| `CustomDrawer` | `lib/shared/widgets/custom_drawer.dart` | Navigation drawer (categoryType: 'inspection_valuation') |
| `ShimmerWidget` | `lib/shared/widgets/shimmer_widget.dart` | Loading skeleton for lists |
| `SizeConfig` | `lib/shared/widgets/size_config.dart` | Responsive sizing |
| `ZoomableImageViewer` | `lib/shared/widgets/zoomable_image_viewer.dart` | Full-screen image viewing |
| `CustomTextField` | `lib/shared/widgets/custom_text_field.dart` | Text input fields |
| `CustomDropdown` | `lib/shared/widgets/custom_dropdown.dart` | Dropdown selectors |

### New Module-Specific Widgets

| Widget | File | Purpose |
|--------|------|---------|
| `InspectionCard` | `widgets/inspection_card.dart` | List item card for My Inspections |
| `InspectionStepIndicator` | `widgets/inspection_step_indicator.dart` | 6-step progress indicator for agent form |
| `ConditionRatingWidget` | `widgets/condition_rating_widget.dart` | Selectable condition chips (Excellent/Good/Average/Poor) |
| `ImageUploadSection` | `widgets/image_upload_section.dart` | Image picker + preview grid with add/remove |
| `DocumentUploadWidget` | `widgets/document_upload_widget.dart` | File picker for PDF/image documents |
| `ValuationSummaryCard` | `widgets/valuation_summary_card.dart` | Summary card showing all inspection data |

---

## 16. Navigation & Routes

### Route Definitions to Add

```dart
// Add to lib/routes/app_routes.dart
static const String inspectionHome = '/inspection-home';
static const String customerValuationForm = '/customer-valuation-form';
static const String agentValuationForm = '/agent-valuation-form';
static const String myInspections = '/my-inspections';
static const String inspectionDetail = '/inspection-detail';
```

### Route Pages to Add

```dart
// Add to lib/routes/app_pages.dart
GetPage(
  name: AppRoutes.inspectionHome,
  page: () => const InspectionHomeView(),
  binding: InspectionValuationBinding(),
),
GetPage(
  name: AppRoutes.customerValuationForm,
  page: () => const CustomerValuationFormView(),
  binding: InspectionValuationBinding(),
),
GetPage(
  name: AppRoutes.agentValuationForm,
  page: () => const AgentValuationFormView(),
  binding: InspectionValuationBinding(),
),
GetPage(
  name: AppRoutes.myInspections,
  page: () => const MyInspectionsView(),
  binding: InspectionValuationBinding(),
),
GetPage(
  name: AppRoutes.inspectionDetail,
  page: () => const InspectionDetailView(),
  binding: InspectionValuationBinding(),
),
```

### Navigation Map

```
Category View (Home)
└── Tap "Inspection & Valuation"
    └── Inspection Home View
        ├── "Request Inspection" → Customer Valuation Form
        │   └── Submit → Success Dialog → My Inspections
        ├── "Agent Inspection" → Agent Valuation Form (6-step wizard)
        │   └── Submit → Success Dialog → My Inspections
        └── "My Inspections" → My Inspections List
            └── Tap card → Inspection Detail View
                └── "View Full Report" → External URL (url_launcher)
```

---

## 17. Error Handling Patterns

### API Error Handling

```dart
// Standard error handling pattern
try {
  final response = await _apiRepository.callInspectionAPI(...);
  if (response.statusCode == 200 || response.statusCode == 201) {
    // Success handling
  } else if (response.statusCode == 401) {
    // Token expired → Redirect to login
    Get.offAllNamed(AppRoutes.login);
  } else if (response.statusCode == 403) {
    // Subscription required → Redirect to subscription
    Get.toNamed(AppRoutes.subscription);
  } else {
    // Show error message from response
    _showError(response.body['message'] ?? 'Something went wrong');
  }
} on SocketException {
  _showError('No internet connection');
} on TimeoutException {
  _showError('Request timed out. Please try again.');
} catch (e) {
  _showError('An unexpected error occurred');
}
```

### UI Error States

| State | UI Response |
|-------|-------------|
| Network error | SnackBar with retry option |
| Validation error | Inline field error text + red border |
| 401 Unauthorized | Redirect to login screen |
| 403 Forbidden | Redirect to subscription page |
| 500 Server error | Error dialog with retry |
| Empty data | Empty state illustration + CTA |
| Image upload failure | Error toast + retry option |

### Loading States

| State | UI Element |
|-------|------------|
| Initial page load | Full-page shimmer skeleton |
| Form submission | Button loading spinner + disabled state |
| Load more (pagination) | Bottom circular progress indicator |
| Image upload | Per-image progress indicator |
| Pull-to-refresh | Material refresh indicator |
| Dropdown options loading | Linear progress at top |

---

## 18. Recreation Checklist

### Phase 1: Core Setup

- [ ] Create binding: `inspection_valuation_binding.dart`
- [ ] Create controllers: `inspection_valuation_controller.dart`, `agent_inspection_controller.dart`
- [ ] Add API repository methods for all 4 endpoints
- [ ] Add route definitions in `app_routes.dart` and `app_pages.dart`
- [ ] Create new models: `valuation_dropdown_options_model.dart`, `inspection_detail_model.dart`, `inspection_submit_response.dart`

### Phase 2: Shared Widgets

- [ ] Create `InspectionCard` widget
- [ ] Create `InspectionStepIndicator` widget
- [ ] Create `ConditionRatingWidget` widget
- [ ] Create `ImageUploadSection` widget
- [ ] Create `DocumentUploadWidget` widget
- [ ] Create `ValuationSummaryCard` widget

### Phase 3: Views

- [ ] Create `inspection_home_view.dart` — landing page with CTAs
- [ ] Create `customer_valuation_form_view.dart` — customer form with validation
- [ ] Create `agent_valuation_form_view.dart` — 6-step wizard form
- [ ] Create `my_inspections_view.dart` — paginated list with filters
- [ ] Create `inspection_detail_view.dart` — detail view with gallery

### Phase 4: Business Logic

- [ ] Implement dropdown options loading and caching
- [ ] Implement state-city filtering logic
- [ ] Implement customer form submission with multipart upload
- [ ] Implement agent form step validation and navigation
- [ ] Implement image picking, compression, and management
- [ ] Implement pagination with scroll detection and pull-to-refresh
- [ ] Implement inspection detail fetching

### Phase 5: Integration & Polish

- [ ] Add to category/home navigation
- [ ] Add drawer menu entry for "Inspection & Valuation"
- [ ] Add `AppImages.inspection` asset reference
- [ ] Test all form validations
- [ ] Test all navigation flows
- [ ] Test error handling scenarios
- [ ] Test responsive layouts on different screen sizes
- [ ] Test pull-to-refresh and pagination
- [ ] Test image upload flow end-to-end
- [ ] Verify API integration with backend

---

## Appendix A: API Constants (Already Defined)

```dart
// From lib/core/api/api_constant.dart
static const String inspectionValuationPrefix = '/api/v1/inspection-valuation';
static const String agentValuationFormEndpoint = '$inspectionValuationPrefix/agent-valuation-form';
static const String myInspectionsEndpoint = '$inspectionValuationPrefix/my-inspections';
static const String customerInspectionFormEndpoint = '$inspectionValuationPrefix/customer-inspection-form';
static const String valuationDropdownOptionsEndpoint = '$inspectionValuationPrefix/valuation-dropdown-options';
```

## Appendix B: API Repository Methods to Add

```dart
// Add to lib/core/api/api_repository.dart

/// Fetch valuation dropdown options
Future<Response> getValuationDropdownOptions() async {
  return await getRequest(
    endpoint: ApiConstants.valuationDropdownOptionsEndpoint,
  );
}

/// Submit customer inspection form
Future<Response> submitCustomerInspectionForm({
  required CustomerValuationRequest request,
}) async {
  return await multipartRequest(
    endpoint: ApiConstants.customerInspectionFormEndpoint,
    fields: request.toJson(),
    files: {
      'rc_file': request.rcFile,
      if (request.insuranceFile != null) 'insurance_file': request.insuranceFile!,
      if (request.companyGstFile != null) 'company_gst_file': request.companyGstFile!,
    },
  );
}

/// Submit agent valuation form
Future<Response> submitAgentValuationForm({
  required AgentValuationRequest request,
}) async {
  final files = <String, List<File>>{
    'engine_images': request.engineImages,
    'transmission_images': request.transmissionImages,
    'suspension_images': request.suspensionImages,
    'tyre_images': request.tyreImages,
    'body_front_image': request.bodyFrontImage,
    'body_back_image': request.bodyBackImage,
    'body_left_image': request.bodyLeftImage,
    'body_right_image': request.bodyRightImage,
    'cabin_interior_images': request.cabinInteriorImages,
    'electrical_images': request.electricalImages,
    'chasis_images': request.chasisImages,
    'odometer_images': request.odometerImages,
  };
  return await multipartRequest(
    endpoint: ApiConstants.agentValuationFormEndpoint,
    fields: request.toJson(),
    filesList: files,
  );
}

/// Get my inspections list
Future<Response> getMyInspections({
  required String userId,
  int page = 1,
  int limit = 10,
}) async {
  return await getRequest(
    endpoint: '${ApiConstants.myInspectionsEndpoint}?user_id=$userId&page=$page&limit=$limit',
  );
}
```

## Appendix C: Existing Model Files Reference

| File | Lines | Key Classes |
|------|-------|-------------|
| `inspection_vehicle.dart` | 51 | `InspectionVehicle` |
| `agent_valuation_request.dart` | 169 | `AgentValuationRequest` (47+ fields, 12 image lists) |
| `customer_valuation_request.dart` | 44 | `CustomerValuationRequest` (11 fields, 3 file fields) |
| `customer_valuation_response.dart` | 221 | `CustomerValuationResponse`, `CustomerValuationData`, `VehicleDetails`, `CompanyDetails`, `UploadedFiles`, `FileDetails` |
| `my_inspections_request.dart` | 24 | `MyInspectionsRequest` (userId, page, limit) |
| `my_inspections_response.dart` | 78 | `MyInspectionsResponse`, `MyInspectionsData` |

---

> **Document Version**: 1.0
> **Last Updated**: 2026-04-06
> **Module Status**: Models exist (7 files) — Controllers, Views, Widgets, Bindings, and API methods pending implementation
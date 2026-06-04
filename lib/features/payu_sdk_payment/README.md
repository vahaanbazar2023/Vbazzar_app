# PayU SDK Payment Module

A comprehensive PayU SDK integration module for Vahaan Bazar Flutter app.

## Overview

This module provides a complete PayU payment integration with the following features:

- **PayU Checkout Pro SDK Integration**: Complete integration with payu_checkoutpro_flutter
- **Secure Hash Generation**: Dynamic salt handling for secure payment processing
- **Comprehensive Configuration**: Centralized PayU configuration management
- **API Integration**: Complete payment initiation and callback handling
- **State Management**: GetX-based reactive state management
- **Error Handling**: Comprehensive error handling and user feedback

## Module Structure

```
payu_sdk_payment/
├── controllers/
│   ├── payment_controller.dart        # Main payment orchestration
├── models/
│   ├── initiate_payment_model.dart    # Payment initiation models
│   └── payment_status_callback.dart   # Payment callback models
├── services/
│   ├── payment_api_service.dart       # API communication
│   └── hash_service.dart              # Hash generation service
├── views/
│   └── payment_view.dart              # Payment UI
├── config/
│   └── payu_config.dart               # PayU configuration
├── test/
│   └── payu_sdk_payment_test.dart     # Module testing
└── payu_sdk_payment.dart              # Main module export
```

## Usage

### Basic Implementation

```dart
import 'package:vahaan_mobile_flutter/modules/payu_sdk_payment/payu_sdk_payment.dart';

// Navigate to payment view
Get.to(() => PaymentView());

// Or use controller directly
final paymentController = Get.put(PaymentController());
bool success = await paymentController.startPayment(
  planCode: 'VB_MONTHLY_PREMIUM',
  userId: 'user_12345',
);
```

### Configuration

Update `payu_config.dart` for your environment:

```dart
// Set production environment
static const bool isProduction = true; // Set to true for production

// Update credentials
static const merchantKey = "your_merchant_key";
static const salt = "your_dynamic_salt"; // Use dynamic salt from API
```

## Features

### PaymentController

- **startPayment()**: Initiates PayU payment flow
- **generateHash()**: Generates secure payment hash
- **Payment Callbacks**: Handles success, failure, cancellation, and errors
- **State Management**: Reactive payment state tracking

### PayUConfig

- **Environment Management**: Test/Production environment switching
- **Parameter Creation**: Automated PayU parameter generation
- **Configuration**: Centralized PayU SDK configuration

### PaymentApiService

- **Payment Initiation**: API call to initiate payment
- **Success/Failure Callbacks**: Notify backend of payment status

### HashService

- **Secure Hash Generation**: SHA512 hash generation with dynamic salt
- **Backend Integration**: Secure hash validation

## API Integration

The module integrates with your backend APIs:

1. **Payment Initiation**: `POST /api/v1/payments/initiate`
2. **Success Callback**: `POST /api/v1/payments/success`
3. **Failure Callback**: `POST /api/v1/payments/failure`

## Testing

Use the test view to verify integration:

```dart
import 'package:vahaan_mobile_flutter/modules/payu_sdk_payment/payu_sdk_payment.dart';

// Open test view
Get.to(() => PayUSDKPaymentTest());
```

## Security

- Hash generation uses dynamic salt from API response
- Sensitive configuration managed centrally
- Backend validation for all payment operations

## Dependencies

- `payu_checkoutpro_flutter`: PayU SDK
- `get`: State management
- `dio`: HTTP client
- `crypto`: Hash generation

## Environment Configuration

### Test Environment
- Merchant Key: `iZKr5a`
- Base URL: `https://api.test.vahaanbazar.in`

### Production Environment
- Update merchant key and base URL in `PayUConfig`
- Ensure backend provides dynamic salt

## Error Handling

The module provides comprehensive error handling:

- Network errors
- PayU SDK errors  
- Backend validation errors
- User cancellation
- Payment failures

All errors are logged and displayed to users with appropriate feedback.

# Custom Snackbar Component

A custom snackbar widget designed according to your specifications with animated progress bar.

## Design Specifications

- **Width**: 379px (responsive)
- **Height**: 52px
- **Margin Top**: 38px
- **Margin Left/Right**: 17px
- **Border Radius**: 4px
- **Border Width**: 1px
- **Position**: Top of screen
- **Animation**: Linear progress bar showing time remaining

## Features

✅ Four snackbar types: Success, Error, Warning, Info
✅ Animated progress bar showing remaining time
✅ Auto-dismiss with configurable duration
✅ Manual dismiss with close button
✅ Swipe up to dismiss
✅ Tap action support
✅ Custom title support
✅ Icon for each type
✅ Responsive design with ScreenUtil
✅ Smooth animations

## Usage

### Basic Usage

```dart
import 'package:vahaan_mobile_2_0/core/design_system/design_system.dart';

// Success message
CustomSnackbar.show(
  message: 'Operation completed successfully!',
  type: SnackbarType.success,
);

// Error message
CustomSnackbar.show(
  message: 'Something went wrong',
  type: SnackbarType.error,
);

// Warning message
CustomSnackbar.show(
  message: 'Please verify your information',
  type: SnackbarType.warning,
);

// Info message
CustomSnackbar.show(
  message: 'New update available',
  type: SnackbarType.info,
);
```

### Advanced Usage

```dart
// Custom title
CustomSnackbar.show(
  title: 'Payment Complete',
  message: 'Your payment has been processed',
  type: SnackbarType.success,
  duration: const Duration(seconds: 4),
);

// Without progress bar
CustomSnackbar.show(
  message: 'This stays until dismissed',
  type: SnackbarType.info,
  showProgressBar: false,
);

// With tap action
CustomSnackbar.show(
  message: 'Tap to view details',
  type: SnackbarType.success,
  onTap: () {
    // Handle tap
    Get.toNamed('/details');
  },
);
```

## Snackbar Types

| Type | Color | Icon | Use Case |
|------|-------|------|----------|
| `SnackbarType.success` | Green | ✓ | Successful operations |
| `SnackbarType.error` | Red | ⚠ | Errors and failures |
| `SnackbarType.warning` | Orange | ⚠ | Warnings and cautions |
| `SnackbarType.info` | Blue | ℹ | Information messages |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | String | required | Main message to display |
| `title` | String? | null | Optional title (defaults to type name) |
| `type` | SnackbarType | info | Snackbar variant |
| `duration` | Duration | 3 seconds | How long to show snackbar |
| `showProgressBar` | bool | true | Show/hide progress bar |
| `onTap` | VoidCallback? | null | Callback on tap |

## Examples

See `/lib/core/design_system/examples/custom_snackbar_example.dart` for complete examples.

## Implementation in Auth Flow

The custom snackbar is already integrated in:
- ✅ `auth_controller.dart` - OTP send/verify responses
- ✅ `verify_otp.dart` - Help messages
- ✅ `login_with_otp.dart` - Info messages

## Notes

- Positioned at the top of the screen (38px from top)
- Auto-dismissible with swipe up gesture
- Close button always visible
- Progress bar shows time remaining
- Fully responsive with ScreenUtil
- Works with GetX navigation

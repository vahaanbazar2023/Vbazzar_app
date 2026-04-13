/// Custom Snackbar Usage Examples
///
/// A custom snackbar component with progress bar and animation
///
/// Design Specifications:
/// - Width: 379px (responsive with ScreenUtil)
/// - Height: 52px
/// - Top margin: 38px
/// - Left/Right margin: 17px
/// - Border-radius: 4px
/// - Border-width: 1px
/// - Includes animated progress bar showing time remaining
///
/// Usage:

import 'package:flutter/material.dart';
import '../design_system.dart';

/// Example 1: Success Snackbar
void showSuccessExample() {
  CustomSnackbar.show(
    message: 'OTP sent successfully to your phone',
    type: SnackbarType.success,
    duration: const Duration(seconds: 3),
  );
}

/// Example 2: Error Snackbar
void showErrorExample() {
  CustomSnackbar.show(
    message: 'Failed to send OTP. Please try again.',
    type: SnackbarType.error,
    duration: const Duration(seconds: 4),
  );
}

/// Example 3: Warning Snackbar
void showWarningExample() {
  CustomSnackbar.show(
    message: 'Your session will expire in 5 minutes',
    type: SnackbarType.warning,
    duration: const Duration(seconds: 5),
  );
}

/// Example 4: Info Snackbar
void showInfoExample() {
  CustomSnackbar.show(
    message: 'Please check your email for verification',
    type: SnackbarType.info,
    duration: const Duration(seconds: 3),
  );
}

/// Example 5: Custom Title
void showCustomTitleExample() {
  CustomSnackbar.show(
    title: 'Payment Complete',
    message: 'Your payment has been processed successfully',
    type: SnackbarType.success,
  );
}

/// Example 6: Without Progress Bar
void showWithoutProgressBar() {
  CustomSnackbar.show(
    message: 'This message stays until dismissed',
    type: SnackbarType.info,
    showProgressBar: false,
    duration: const Duration(seconds: 10),
  );
}

/// Example 7: With Tap Action
void showWithTapAction() {
  CustomSnackbar.show(
    message: 'Tap to view order details',
    type: SnackbarType.success,
    onTap: () {
      // Navigate to order details
      print('Snackbar tapped!');
    },
  );
}

/// Example 8: Long Duration
void showLongDuration() {
  CustomSnackbar.show(
    message: 'Download in progress...',
    type: SnackbarType.info,
    duration: const Duration(seconds: 10),
    showProgressBar: true,
  );
}

/// INTEGRATION EXAMPLE IN A WIDGET:
class SnackbarDemoScreen extends StatelessWidget {
  const SnackbarDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Snackbar Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.show(
                  message: 'Operation completed successfully!',
                  type: SnackbarType.success,
                );
              },
              child: const Text('Show Success'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.show(
                  message: 'An error occurred. Please try again.',
                  type: SnackbarType.error,
                );
              },
              child: const Text('Show Error'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.show(
                  message: 'Warning: Low battery',
                  type: SnackbarType.warning,
                );
              },
              child: const Text('Show Warning'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.show(
                  message: 'New update available',
                  type: SnackbarType.info,
                );
              },
              child: const Text('Show Info'),
            ),
          ],
        ),
      ),
    );
  }
}

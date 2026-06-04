import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  final PaymentController controller = Get.put(PaymentController());

  // Form controllers for input fields
  final TextEditingController planCodeController = TextEditingController(
    text: 'VB_MONTHLY_PREMIUM',
  );

  PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vahaan Bazar Payment'),
        backgroundColor: const Color(0xFF4994EC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Obx(
              () => Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(controller.currentStep.value),
                            color: _getStatusColor(
                              controller.currentStep.value,
                            ),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Step: ${controller.currentStep.value.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (controller.paymentStatus.value.isNotEmpty)
                        Text(
                          'Status: ${controller.paymentStatus.value}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (controller.errorMessage.value.isNotEmpty)
                        Text(
                          'Error: ${controller.errorMessage.value}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Form
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Plan Code Input
                      TextFormField(
                        controller: planCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Plan Code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.card_membership),
                          hintText: 'e.g., VB_MONTHLY_PREMIUM',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Button
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.startPayment(
                                  planCode: planCodeController.text.trim(),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4994EC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Start Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Load Test Data Button
                      TextButton(
                        onPressed: () {
                          planCodeController.text = 'VB_MONTHLY_PREMIUM';
                        },
                        child: const Text(
                          'Load Test Data',
                          style: TextStyle(
                            color: Color(0xFF4994EC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Reset Button
                      TextButton(
                        onPressed: () => controller.resetPaymentState(),
                        child: const Text(
                          'Reset Payment State',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Transaction Details (if available)
            Obx(
              () => (controller.currentTransactionId?.isNotEmpty ?? false)
                  ? Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transaction Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Transaction ID: ${controller.currentTransactionId ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (controller.currentAmount != null)
                              Text(
                                'Amount: ₹${controller.currentAmount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            if (controller.currentPaymentId != null)
                              Text(
                                'Payment ID: ${controller.currentPaymentId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'idle':
        return Icons.payment;
      case 'initiating':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'idle':
        return Colors.blue;
      case 'initiating':
      case 'processing':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }
}

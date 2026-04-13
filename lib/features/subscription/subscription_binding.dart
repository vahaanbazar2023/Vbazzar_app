import 'package:get/get.dart';

import 'controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  final String subscriptionSource;

  SubscriptionBinding({required this.subscriptionSource});

  @override
  void dependencies() {
    Get.lazyPut(
      () => SubscriptionController(subscriptionSource: subscriptionSource),
      tag: subscriptionSource,
    );
  }
}

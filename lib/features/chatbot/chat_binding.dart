import 'package:get/get.dart';

import 'controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent so the conversation survives closing and reopening the chat
    // until the app is closed or the user taps "New chat".
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController(), permanent: true);
    }
  }
}

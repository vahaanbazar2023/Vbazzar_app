import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import 'chat_markdown.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            AppHeader(
              title: kBotName,
              actions: [
                Obx(
                  () => GestureDetector(
                    onTap: controller.messages.isEmpty
                        ? null
                        : controller.newChat,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 22.r,
                        color: controller.messages.isEmpty
                            ? AppColors.textPrimary.withValues(alpha: 0.3)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final msgs = controller.messages;
                          final busy = controller.busy.value;
                          return ListView(
                            controller: controller.scroll,
                            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
                            children: [
                              _Bubble(
                                message: ChatMessage(
                                  isUser: false,
                                  content: controller.greeting,
                                ),
                                typing: false,
                              ),
                              if (msgs.isEmpty)
                                _QuickStarts(onTap: controller.send),
                              for (var i = 0; i < msgs.length; i++) ...[
                                _Bubble(
                                  message: msgs[i],
                                  typing:
                                      busy &&
                                          i == msgs.length - 1 &&
                                          !msgs[i].isUser
                                      ? msgs[i].content.isEmpty
                                      : false,
                                ),
                                if (!busy &&
                                    i == msgs.length - 1 &&
                                    !msgs[i].isUser &&
                                    parseReply(
                                      msgs[i].content,
                                    ).chips.isNotEmpty)
                                  _Chips(
                                    chips: parseReply(msgs[i].content).chips,
                                    onTap: controller.send,
                                  ),
                              ],
                              if (controller.error.value.isNotEmpty)
                                _ErrorBanner(
                                  text: controller.error.value,
                                  onRetry: controller.retry,
                                ),
                            ],
                          );
                        }),
                      ),
                      _Composer(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool typing;
  const _Bubble({required this.message, required this.typing});

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    final body = user ? message.content : parseReply(message.content).body;
    if (!user && !typing && body.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.82),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(user ? 16.r : 4.r),
            bottomRight: Radius.circular(user ? 4.r : 16.r),
          ),
          border: user ? null : Border.all(color: AppColors.border),
        ),
        child: typing
            ? const _TypingDots()
            : user
            ? Text(
                body,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            : ChatMarkdown(text: body, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_c.value * 3) - i).clamp(0.0, 1.0);
          final lift = (t < 0.5 ? t : 1 - t) * 2;
          return Container(
            width: 7.w,
            height: 7.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
            transform: Matrix4.translationValues(0, -3 * lift, 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey500.withValues(alpha: 0.5 + 0.5 * lift),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickStarts extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _QuickStarts({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final q in kVaaniQuick)
          ActionChip(
            avatar: Icon(q.icon, size: 18.sp, color: AppColors.primary),
            label: Text(q.label),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            onPressed: () => onTap(q.ask),
          ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onTap;
  const _Chips({required this.chips, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 6.h,
        children: [
          for (final c in chips)
            ActionChip(
              label: Text(c, style: TextStyle(fontSize: 12.sp)),
              backgroundColor: AppColors.lightOrangeBackground,
              side: BorderSide.none,
              onPressed: () => onTap(c),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 4.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5.sp, color: AppColors.errorDark),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final ChatController controller;
  const _Composer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller.input,
              minLines: 1,
              maxLines: 4,
              maxLength: 4000,
              textInputAction: TextInputAction.send,
              onSubmitted: controller.send,
              decoration: InputDecoration(
                hintText: 'Ask $kBotName anything…',
                counterText: '',
                filled: true,
                fillColor: AppColors.grey100,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Obx(
            () => IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: controller.busy.value
                  ? null
                  : () => controller.send(controller.input.text),
              icon: controller.busy.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

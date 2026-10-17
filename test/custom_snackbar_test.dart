import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/custom_snackbar.dart';

void main() {
  Future<void> show(WidgetTester tester, String message) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => CustomSnackbar.show(
                    message: message,
                    type: SnackbarType.error,
                    showProgressBar: false,
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('one line for short text; long text wraps to two lines and is cut after that', (tester) async {
    // Heights are compared with each other (the test screen scales fonts).
    await show(tester, 'Refund requested');
    final oneLine = tester.getSize(find.text('Refund requested')).height;
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final long = List.filled(30, 'This is a long refund message').join(' ');
    await show(tester, long);
    final text = tester.widget<Text>(find.text(long));
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
    final twoLines = tester.getSize(find.text(long)).height;
    expect(twoLines, greaterThan(oneLine * 1.8), reason: 'wraps to a second line');
    expect(twoLines, lessThan(oneLine * 2.2), reason: 'never a third line');
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/design_system/organisms/network_image_carousel.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('shows the caption on a labelled slide only', (tester) async {
    await tester.pumpWidget(
      _host(
        const NetworkImageCarousel(
          imageUrls: ['https://x/p1.jpg', 'https://x/rc.jpg'],
          captions: [null, 'RC Copy'],
          height: 180,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('RC Copy'), findsNothing); // first slide is a photo
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('RC Copy'), findsOneWidget);
  });

  testWidgets('captions stay aligned when an empty URL is skipped', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const NetworkImageCarousel(
          imageUrls: ['', 'https://x/rc.jpg'],
          captions: [null, 'RC Copy'],
          height: 180,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('RC Copy'), findsOneWidget);
  });
}

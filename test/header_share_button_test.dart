import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/header_share_button.dart';

void main() {
  Widget host(Future<void> Function() onShare) => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      home: Scaffold(body: Center(child: HeaderShareButton(onShare: onShare))),
    ),
  );

  testWidgets('tap shares once; taps while preparing are ignored', (tester) async {
    var calls = 0;
    final gate = Completer<void>();
    await tester.pumpWidget(host(() {
      calls++;
      return gate.future;
    }));

    await tester.tap(find.byType(HeaderShareButton));
    await tester.pump();
    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(HeaderShareButton));
    await tester.pump();
    expect(calls, 1, reason: 'second tap ignored while busy');

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    await tester.tap(find.byType(HeaderShareButton));
    await tester.pump();
    expect(calls, 2, reason: 'usable again after the share finished');
    await tester.pumpAndSettle();
  });
}

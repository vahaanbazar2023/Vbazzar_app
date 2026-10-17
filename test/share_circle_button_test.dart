import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/share_circle_button.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/wishlist_button.dart';

void main() {
  Widget host(Future<void> Function() onShare, {VoidCallback? onHeart}) =>
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 20,
                  right: 20,
                  child: WishlistButton(onTap: onHeart, size: 32),
                ),
                // same placement rule as the auction card: 8 gap below the heart
                Positioned(
                  top: 20 + 32 + 8,
                  right: 20,
                  child: ShareCircleButton(size: 32, onShare: onShare),
                ),
              ],
            ),
          ),
        ),
      );

  testWidgets('share sits below the heart; each button only fires itself', (tester) async {
    var shares = 0, hearts = 0;
    await tester.pumpWidget(host(() async => shares++, onHeart: () => hearts++));

    final heart = tester.getRect(find.byType(WishlistButton));
    final share = tester.getRect(find.byType(ShareCircleButton));
    expect(share.top, greaterThanOrEqualTo(heart.bottom), reason: 'share below heart');
    expect(share.left, heart.left, reason: 'aligned in the same column');

    await tester.tap(find.byType(ShareCircleButton));
    await tester.pump();
    expect((shares, hearts), (1, 0));
    await tester.tap(find.byType(WishlistButton));
    await tester.pump();
    expect((shares, hearts), (1, 1));
  });

  testWidgets('shows a spinner and ignores repeat taps while sharing', (tester) async {
    var shares = 0;
    final gate = Completer<void>();
    await tester.pumpWidget(host(() {
      shares++;
      return gate.future;
    }));
    await tester.tap(find.byType(ShareCircleButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ShareCircleButton));
    await tester.pump();
    expect(shares, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.share_rounded), findsOneWidget);
  });
}

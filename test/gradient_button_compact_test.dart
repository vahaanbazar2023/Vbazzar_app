import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/design_system/atoms/gradient_text.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/gradient_button.dart';

Widget _host(Widget child) => ScreenUtilInit(
      designSize: const Size(402, 874),
      builder: (_, __) => MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('compact (PLACE BID) style: 28 tall, Montserrat 12 w600, 0.8 spacing', (tester) async {
    await tester.pumpWidget(_host(Row(children: [
      Expanded(
        child: GradientButton.outlined(
          text: 'CANCEL', width: double.infinity, height: 28, fontSize: 12,
          fontWeight: FontWeight.w600, fontFamily: 'Montserrat', letterSpacing: 0.8,
        ),
      ),
      Expanded(
        child: GradientButton.filled(
          text: 'LOGOUT', width: double.infinity, height: 28, fontSize: 12,
          fontWeight: FontWeight.w600, fontFamily: 'Montserrat', letterSpacing: 0.8,
        ),
      ),
    ])));
    for (final b in tester.widgetList<GradientButton>(find.byType(GradientButton))) {
      expect(b.height, 28);
    }
    final filled = tester.widget<Text>(find.text('LOGOUT')).style!;
    expect([filled.fontFamily, filled.fontWeight, filled.letterSpacing], ['Montserrat', FontWeight.w600, 0.8]);
    final outlined = tester.widget<GradientText>(find.byType(GradientText)).style!;
    expect([outlined.fontFamily, outlined.fontWeight, outlined.letterSpacing], ['Montserrat', FontWeight.w600, 0.8]);
    expect(tester.getSize(find.byType(GradientButton).first).height, 28);
  });

  testWidgets('defaults are unchanged for every other button', (tester) async {
    await tester.pumpWidget(_host(GradientButton.filled(text: 'GO')));
    final style = tester.widget<Text>(find.text('GO')).style!;
    expect(style.fontFamily, 'montserrat');
    expect(style.letterSpacing, isNull);
  });
}

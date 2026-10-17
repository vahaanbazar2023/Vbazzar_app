import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/core/design_system/molecules/collapsible_section.dart';
import 'package:vahaan_mobile_2_0/core/utils/scroll_chrome.dart';

void main() {
  Widget host(ScrollChrome chrome) => MaterialApp(
    home: Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: chrome.onNotification,
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (_, i) => SizedBox(height: 60, child: Text('row $i')),
        ),
      ),
    ),
  );

  testWidgets('hides while scrolling, shows again after it stops', (tester) async {
    final chrome = ScrollChrome(showDelay: const Duration(milliseconds: 300));
    await tester.pumpWidget(host(chrome));
    expect(chrome.hidden.value, false);

    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(chrome.hidden.value, true, reason: 'hidden as soon as it moves');

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(chrome.hidden.value, true, reason: 'still hidden right after release');

    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(chrome.hidden.value, false, reason: 'shown again once it stopped');
    chrome.dispose();
  });

  testWidgets('a tap without scrolling does not hide anything', (tester) async {
    final chrome = ScrollChrome();
    await tester.pumpWidget(host(chrome));
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    expect(chrome.hidden.value, false);
    chrome.dispose();
  });

  testWidgets('horizontal scrolling (tab pager) is ignored', (tester) async {
    final chrome = ScrollChrome();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: chrome.onNotification,
          child: PageView(children: const [Text('a'), Text('b')]),
        ),
      ),
    ));
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pump();
    expect(chrome.hidden.value, false);
    await tester.pumpAndSettle();
    chrome.dispose();
  });

  testWidgets('CollapsibleSection collapses, ignores taps while hidden, and returns', (tester) async {
    var hidden = false;
    var taps = 0;
    late StateSetter set;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (c, s) {
          set = s;
          return Column(children: [
            CollapsibleSection(
              hidden: hidden,
              child: SizedBox(width: double.infinity, height: 50, child: GestureDetector(onTap: () => taps++, child: const ColoredBox(color: Colors.red))),
            ),
            const Expanded(child: SizedBox()),
          ]);
        }),
      ),
    ));
    expect(tester.getSize(find.byType(CollapsibleSection)).height, 50);
    await tester.tapAt(const Offset(100, 25));
    expect(taps, 1);

    set(() => hidden = true);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CollapsibleSection)).height, 0);
    await tester.tapAt(const Offset(100, 25));
    expect(taps, 1, reason: 'no taps while hidden');

    set(() => hidden = false);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CollapsibleSection)).height, 50);
  });
}

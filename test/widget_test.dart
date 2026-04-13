import 'package:flutter_test/flutter_test.dart';
import 'package:vahaan_mobile_2_0/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VahaanApp());
    await tester.pump();
    expect(find.byType(VahaanApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:tecnoiso_demo/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TecnoisoApp());
    expect(find.text('TECNOISO'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}

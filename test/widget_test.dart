import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tecnoiso_demo/data/equipment_repository.dart';
import 'package:tecnoiso_demo/data/hive_setup.dart';
import 'package:tecnoiso_demo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('tecnoiso_widget_test_');
    await initHive(path: tempDir.path);
    registerAdapters();
    await openBoxes();
    await EquipmentRepository.instance.seedIfNeeded();
  });

  tearDown(() async {
    await closeHive();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TecnoisoApp());
    expect(find.text('TECNOISO'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets(
      'intro settles on the login screen, not the dashboard (D-04 gate)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TecnoisoApp());
    // Advance past the last staggered intro timer (fires at 3000ms) so the
    // fade-out and pushReplacement to AuthGate are triggered, then let
    // pumpAndSettle iterate frames until the transition and gate finish.
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    // Login screen is present.
    expect(find.text('Entrar'), findsWidgets);
    // A dashboard-only string is absent — proves the gate holds.
    expect(find.text('AÇÕES RÁPIDAS'), findsNothing);
  });
}

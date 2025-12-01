import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viatra_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VIATRA App Smoke Tests', () {
    testWidgets('app launches successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app launches
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('can navigate through main screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add basic navigation test
      // This is a placeholder - actual implementation depends on your route structure
    });
  });
}

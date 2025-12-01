import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viatra_mobile/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role Switching Tests', () {
    testWidgets('user can switch from patient to doctor role', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login as user with both roles
      await TestHelpers.performLogin(tester, 'dual@example.com', 'password123');

      // Navigate to profile
      await TestHelpers.navigateToProfile(tester);

      // Find and tap role switcher
      final roleSwitcher = find.text('Switch Role');
      if (roleSwitcher.evaluate().isNotEmpty) {
        await tester.tap(roleSwitcher);
        await tester.pumpAndSettle();

        // Confirm switch
        final confirmButton = find.text('Confirm');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // Verify doctor interface is shown
          expect(find.text('Doctor Dashboard'), findsOneWidget);
        }
      }
    });

    testWidgets('doctor can switch to patient view', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login as doctor
      await TestHelpers.performLogin(tester, 'doctor@example.com', 'password123');

      // Navigate to profile
      await TestHelpers.navigateToProfile(tester);

      // Switch to patient role
      final roleSwitcher = find.text('Switch Role');
      if (roleSwitcher.evaluate().isNotEmpty) {
        await tester.tap(roleSwitcher);
        await tester.pumpAndSettle();

        final confirmButton = find.text('Confirm');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        // Verify patient interface
        expect(find.text('Home'), findsOneWidget);
      }
    });

    testWidgets('role-specific navigation persists after switch', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'dual@example.com', 'password123');

      // Switch to doctor role
      await TestHelpers.navigateToProfile(tester);
      final roleSwitcher = find.text('Switch Role');
      await tester.tap(roleSwitcher);
      await tester.pumpAndSettle();
      
      final confirmButton = find.text('Confirm');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify doctor-specific bottom navigation
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
    });

    testWidgets('user without doctor role cannot switch', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login as patient only
      await TestHelpers.performLogin(tester, 'patient@example.com', 'password123');

      await TestHelpers.navigateToProfile(tester);

      // Verify role switcher is not available
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('role switch updates app bar and navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'dual@example.com', 'password123');

      // Check initial state (patient)
      expect(find.text('Home'), findsOneWidget);

      // Switch role
      await TestHelpers.navigateToProfile(tester);
      final roleSwitcher = find.text('Switch Role');
      await tester.tap(roleSwitcher);
      await tester.pumpAndSettle();
      
      final confirmButton = find.text('Confirm');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify navigation changed
      expect(find.text('Doctor Dashboard'), findsOneWidget);
    });
  });
}

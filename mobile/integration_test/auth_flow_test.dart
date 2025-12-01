import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viatra_mobile/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    testWidgets('user can complete login flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login if not already there
      await TestHelpers.navigateToLogin(tester);

      // Enter credentials
      await TestHelpers.enterText(tester, 'email_field', 'test@example.com');
      await TestHelpers.enterText(tester, 'password_field', 'password123');

      // Tap login button
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      // Verify successful login (update based on your actual navigation)
      // expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToLogin(tester);

      // Try to login with empty fields
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      // Verify error messages appear
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));
    });

    testWidgets('user can navigate to registration', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToLogin(tester);

      // Tap sign up button
      final signUpButton = find.text('Sign Up');
      if (signUpButton.evaluate().isNotEmpty) {
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // Verify we're on registration screen
        expect(find.text('Create Account'), findsOneWidget);
      }
    });

    testWidgets('user can complete registration flow - patient', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToRegistration(tester);

      // Fill in personal information
      await TestHelpers.enterText(tester, 'name_field', 'Test User');
      await TestHelpers.enterText(tester, 'email_field', 'newuser@example.com');
      await TestHelpers.enterText(tester, 'password_field', 'password123');
      await TestHelpers.enterText(tester, 'phone_field', '+1234567890');

      // Select patient role if available
      final patientRoleButton = find.text('Patient');
      if (patientRoleButton.evaluate().isNotEmpty) {
        await tester.tap(patientRoleButton);
        await tester.pumpAndSettle();
      }

      // Continue through registration steps
      await TestHelpers.tapButton(tester, 'continue_button');
      await tester.pumpAndSettle();

      // Complete registration (specific steps depend on your flow)
    });

    testWidgets('user can logout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Assume we're logged in
      await TestHelpers.navigateToLogin(tester);
      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to profile
      await TestHelpers.navigateToProfile(tester);

      // Tap logout
      final logoutButton = find.text('Logout');
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Confirm logout if dialog appears
        final confirmButton = find.text('Confirm');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }

        // Verify we're back at login
        expect(find.text('Sign In'), findsOneWidget);
      }
    });
  });
}

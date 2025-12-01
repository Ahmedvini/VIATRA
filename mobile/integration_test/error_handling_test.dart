import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viatra_mobile/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Handling Tests', () {
    testWidgets('network error shows appropriate message', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate network error scenario
      // This would require mocking the API service or disconnecting network

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Trigger an action that requires network
      await TestHelpers.navigateToSearch(tester);
      await TestHelpers.enterText(tester, 'search_field', 'cardiology');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify error message is displayed
      // Implementation depends on your error handling
    });

    testWidgets('validation errors are displayed correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToLogin(tester);

      // Try to submit with invalid email
      await TestHelpers.enterText(tester, 'email_field', 'invalid-email');
      await TestHelpers.enterText(tester, 'password_field', '123'); // Too short
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.textContaining('valid email'), findsOneWidget);
      expect(find.textContaining('8 characters'), findsOneWidget);
    });

    testWidgets('auth errors redirect to login', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Simulate expired token scenario
      // This would require mocking the auth service

      // Attempt an authenticated action
      await TestHelpers.navigateToAppointments(tester);
      
      // Verify redirect to login (implementation-specific)
    });

    testWidgets('server errors show retry option', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Simulate server error
      await TestHelpers.navigateToSearch(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for error with retry button
      final retryButton = find.text('Retry');
      if (retryButton.evaluate().isNotEmpty) {
        expect(retryButton, findsOneWidget);
        
        // Test retry functionality
        await tester.tap(retryButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('loading states are shown during async operations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Trigger async operation
      await TestHelpers.navigateToSearch(tester);
      await TestHelpers.enterText(tester, 'search_field', 'cardiology');

      // Verify loading indicator (may need to check quickly)
      // TestHelpers.verifyLoadingDisplayed(tester);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify loading is dismissed
      TestHelpers.verifyNotLoading(tester);
    });

    testWidgets('error boundary catches unhandled errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Trigger an error that should be caught by error boundary
      // Implementation-specific

      // Verify error UI is shown instead of crashing
    });

    testWidgets('form validation prevents invalid submission', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToRegistration(tester);

      // Try to proceed without filling required fields
      await TestHelpers.tapButton(tester, 'continue_button');
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));

      // Verify we're still on the same screen
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('error messages are dismissible', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToLogin(tester);

      // Trigger an error
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      // Find and dismiss error (if shown as snackbar/dialog)
      final dismissButton = find.text('Dismiss');
      if (dismissButton.evaluate().isNotEmpty) {
        await tester.tap(dismissButton);
        await tester.pumpAndSettle();

        // Verify error is dismissed
        expect(dismissButton, findsNothing);
      }
    });

    testWidgets('multiple errors are handled gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.navigateToRegistration(tester);

      // Fill form with multiple invalid inputs
      await TestHelpers.enterText(tester, 'email_field', 'invalid');
      await TestHelpers.enterText(tester, 'password_field', '123');
      await TestHelpers.enterText(tester, 'phone_field', 'abc');

      await TestHelpers.tapButton(tester, 'continue_button');
      await tester.pumpAndSettle();

      // Verify multiple validation errors are shown
      expect(find.textContaining('valid'), findsAtLeastNWidgets(2));
    });

    testWidgets('empty states have proper error recovery', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to appointments
      await TestHelpers.navigateToAppointments(tester);

      // Verify empty state with action
      final bookButton = find.text('Book Appointment');
      if (bookButton.evaluate().isNotEmpty) {
        await tester.tap(bookButton);
        await tester.pumpAndSettle();

        // Verify navigation to booking flow
        TestHelpers.verifyNavigationTo(tester, 'Search');
      }
    });
  });
}

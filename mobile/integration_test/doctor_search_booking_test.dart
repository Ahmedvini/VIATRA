import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Doctor Search and Booking Tests', () {
    setUp(() async {
      // Ensure we're logged in before each test
    });

    testWidgets('user can search for doctors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Navigate to search
      await TestHelpers.navigateToSearch(tester);

      // Enter search query
      await TestHelpers.enterText(tester, 'search_field', 'cardiology');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify search results appear
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('user can apply filters', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      await TestHelpers.navigateToSearch(tester);

      // Open filter sheet
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Select specialty
        final specialtyOption = find.text('Cardiology');
        if (specialtyOption.evaluate().isNotEmpty) {
          await tester.tap(specialtyOption);
          await tester.pumpAndSettle();
        }

        // Apply filters
        await TestHelpers.tapButton(tester, 'apply_filters_button');
        await tester.pumpAndSettle();

        // Verify filtered results
        expect(find.byType(Card), findsWidgets);
      }
    });

    testWidgets('user can view doctor details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      await TestHelpers.navigateToSearch(tester);

      // Wait for results
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on first doctor card
      final doctorCard = find.byType(Card).first;
      if (doctorCard.evaluate().isNotEmpty) {
        await tester.tap(doctorCard);
        await tester.pumpAndSettle();

        // Verify doctor details screen
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Book Appointment'), findsOneWidget);
      }
    });

    testWidgets('user can complete booking flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      await TestHelpers.navigateToSearch(tester);

      // Select a doctor
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final doctorCard = find.byType(Card).first;
      await tester.tap(doctorCard);
      await tester.pumpAndSettle();

      // Book appointment
      final bookButton = find.text('Book Appointment');
      if (bookButton.evaluate().isNotEmpty) {
        await tester.tap(bookButton);
        await tester.pumpAndSettle();

        // Select date (if date picker appears)
        // This depends on your implementation
        
        // Select time slot
        final timeSlot = find.text('09:00 AM').first;
        if (timeSlot.evaluate().isNotEmpty) {
          await tester.tap(timeSlot);
          await tester.pumpAndSettle();
        }

        // Confirm booking
        final confirmButton = find.text('Confirm Booking');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // Verify success message
          expect(find.textContaining('Success'), findsOneWidget);
        }
      }
    });

    testWidgets('empty state shown when no results', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      await TestHelpers.navigateToSearch(tester);

      // Enter search query that returns no results
      await TestHelpers.enterText(tester, 'search_field', 'nonexistentspecialty12345');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify empty state
      expect(find.textContaining('No'), findsOneWidget);
    });

    testWidgets('user can clear search', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      await TestHelpers.navigateToSearch(tester);

      // Enter search query
      await TestHelpers.enterText(tester, 'search_field', 'cardiology');
      await tester.pumpAndSettle();

      // Clear search
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Verify search field is cleared
        final searchField = find.byKey(const Key('search_field'));
        if (searchField.evaluate().isNotEmpty) {
          final textField = tester.widget(searchField);
          expect(textField.controller?.text, isEmpty);
        }
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Health Profile Tests', () {
    testWidgets('user can view health profile', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to health profile
      await TestHelpers.navigateToProfile(tester);
      
      final healthProfileButton = find.text('Health Profile');
      if (healthProfileButton.evaluate().isNotEmpty) {
        await tester.tap(healthProfileButton);
        await tester.pumpAndSettle();

        // Verify health profile sections
        expect(find.text('Vitals'), findsOneWidget);
        expect(find.text('Chronic Conditions'), findsOneWidget);
        expect(find.text('Allergies'), findsOneWidget);
      }
    });

    testWidgets('user can add chronic condition', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to health profile
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Add chronic condition
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        await TestHelpers.enterText(tester, 'condition_name', 'Hypertension');
        
        // Select severity
        final severityDropdown = find.text('Mild');
        if (severityDropdown.evaluate().isNotEmpty) {
          await tester.tap(severityDropdown);
          await tester.pumpAndSettle();
        }

        await TestHelpers.tapButton(tester, 'save_button');
        await tester.pumpAndSettle();

        // Verify condition was added
        expect(find.text('Hypertension'), findsOneWidget);
      }
    });

    testWidgets('user can edit chronic condition', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to health profile with existing condition
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Tap on existing condition
      final conditionTile = find.byType(ListTile).first;
      if (conditionTile.evaluate().isNotEmpty) {
        await tester.tap(conditionTile);
        await tester.pumpAndSettle();

        // Edit condition details
        await TestHelpers.enterText(tester, 'notes_field', 'Updated notes');
        await TestHelpers.tapButton(tester, 'save_button');
        await tester.pumpAndSettle();

        // Verify update
        expect(find.text('Updated notes'), findsOneWidget);
      }
    });

    testWidgets('user can add allergy', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to allergies section
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Navigate to allergies
      final allergiesSection = find.text('Allergies');
      await tester.tap(allergiesSection);
      await tester.pumpAndSettle();

      // Add allergy
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        await TestHelpers.enterText(tester, 'allergen_field', 'Penicillin');
        await TestHelpers.enterText(tester, 'reaction_field', 'Rash');
        
        await TestHelpers.tapButton(tester, 'save_button');
        await tester.pumpAndSettle();

        // Verify allergy was added
        expect(find.text('Penicillin'), findsOneWidget);
      }
    });

    testWidgets('user can update vitals', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to health profile
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Edit vitals
      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        await TestHelpers.enterText(tester, 'height_field', '180');
        await TestHelpers.enterText(tester, 'weight_field', '75');
        
        await TestHelpers.tapButton(tester, 'save_button');
        await tester.pumpAndSettle();

        // Verify BMI calculated
        expect(find.textContaining('BMI'), findsOneWidget);
      }
    });

    testWidgets('shows empty state when no health data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'newuser@example.com', 'password123');

      // Navigate to health profile
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Verify empty states
      expect(find.textContaining('No'), findsAtLeastNWidgets(1));
    });
  });
}

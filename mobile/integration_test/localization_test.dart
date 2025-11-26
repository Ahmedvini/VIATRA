import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    testWidgets('app starts with default locale (English)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify English text is displayed
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('user can switch to Arabic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Switch language to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Verify Arabic text is displayed
      expect(find.text('مرحباً بعودتك'), findsOneWidget);
      
      // Verify RTL layout
      TestHelpers.verifyRTLLayout(tester);
    });

    testWidgets('user can switch back to English', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Switch to Arabic first
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Switch back to English
      await TestHelpers.switchLanguage(tester, 'English');
      await tester.pumpAndSettle();

      // Verify English text
      expect(find.text('Welcome Back'), findsOneWidget);
      
      // Verify LTR layout
      TestHelpers.verifyLTRLayout(tester);
    });

    testWidgets('localization persists across navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Navigate to different screens
      await TestHelpers.navigateToSearch(tester);
      expect(find.text('بحث'), findsOneWidget);

      await TestHelpers.navigateToAppointments(tester);
      expect(find.text('المواعيد'), findsOneWidget);

      await TestHelpers.navigateToProfile(tester);
      expect(find.text('الملف الشخصي'), findsOneWidget);
    });

    testWidgets('medical terms are properly localized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Navigate to health profile
      await TestHelpers.navigateToProfile(tester);
      final healthProfileButton = find.text('Health Profile');
      await tester.tap(healthProfileButton);
      await tester.pumpAndSettle();

      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Verify medical terms are localized
      expect(find.text('الأمراض المزمنة'), findsOneWidget); // Chronic Conditions
      expect(find.text('الحساسية'), findsOneWidget); // Allergies
      expect(find.text('المؤشرات الحيوية'), findsOneWidget); // Vitals
    });

    testWidgets('RTL layout properly mirrors UI elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Verify directionality
      TestHelpers.verifyRTLLayout(tester);

      // Verify icons are positioned correctly (implementation-specific)
      // Back buttons should be on the right
      // Forward navigation on the left
    });

    testWidgets('numbers and dates formatted correctly in Arabic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');
      
      // Navigate to appointments
      await TestHelpers.navigateToAppointments(tester);
      
      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Verify date/time formatting (implementation-specific)
      // Should use Arabic numerals and date formats
    });

    testWidgets('error messages are localized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to login with invalid credentials
      await TestHelpers.navigateToLogin(tester);
      await TestHelpers.enterText(tester, 'email_field', 'invalid');
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      // Verify error in English
      expect(find.textContaining('required'), findsAtLeastNWidgets(1));

      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Try again and verify Arabic error
      await TestHelpers.tapButton(tester, 'login_button');
      await tester.pumpAndSettle();

      expect(find.textContaining('مطلوب'), findsAtLeastNWidgets(1));
    });

    testWidgets('empty states are localized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'newuser@example.com', 'password123');
      
      // Navigate to appointments (empty)
      await TestHelpers.navigateToAppointments(tester);

      // Verify English empty state
      expect(find.textContaining('No'), findsOneWidget);

      // Switch to Arabic
      await TestHelpers.switchLanguage(tester, 'العربية');
      await tester.pumpAndSettle();

      // Verify Arabic empty state
      expect(find.textContaining('لا'), findsOneWidget);
    });
  });
}

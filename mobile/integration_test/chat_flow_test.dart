import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viatra_mobile/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Flow Tests', () {
    testWidgets('user can send and receive messages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to chat (implementation-specific)
      // For this test, we assume there's a way to access chat

      // Send a message
      await TestHelpers.enterText(tester, 'message_field', 'Hello, Doctor!');
      await TestHelpers.tapButton(tester, 'send_button');
      await tester.pumpAndSettle();

      // Verify message appears in chat
      expect(find.text('Hello, Doctor!'), findsOneWidget);
    });

    testWidgets('chat shows loading state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Open chat
      // Verify loading indicator shows while messages load
      TestHelpers.verifyLoadingDisplayed(tester);
    });

    testWidgets('empty state shown when no messages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await TestHelpers.performLogin(tester, 'test@example.com', 'password123');

      // Navigate to new chat
      // Verify empty state message
      expect(find.textContaining('No messages'), findsOneWidget);
    });
  });
}

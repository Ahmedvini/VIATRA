import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper utilities for integration tests
class TestHelpers {
  /// Waits for a specific duration
  static Future<void> wait(WidgetTester tester, {Duration duration = const Duration(seconds: 1)}) async {
    await tester.pumpAndSettle(duration);
  }

  /// Enters text into a text field by key
  static Future<void> enterText(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(Key(key));
    if (finder.evaluate().isEmpty) {
      // Try finding by type and entering text into first field
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, text);
      }
    } else {
      await tester.enterText(finder, text);
    }
    await tester.pumpAndSettle();
  }

  /// Taps a button by key or text
  static Future<void> tapButton(WidgetTester tester, String identifier) async {
    // Try by key first
    var finder = find.byKey(Key(identifier));
    
    if (finder.evaluate().isEmpty) {
      // Try by text
      finder = find.text(identifier);
    }
    
    if (finder.evaluate().isEmpty) {
      // Try finding button with text containing identifier
      finder = find.widgetWithText(ElevatedButton, identifier);
    }
    
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
  }

  /// Navigates to login screen
  static Future<void> navigateToLogin(WidgetTester tester) async {
    // Implementation depends on your navigation structure
    await tester.pumpAndSettle();
  }

  /// Navigates to registration screen
  static Future<void> navigateToRegistration(WidgetTester tester) async {
    await navigateToLogin(tester);
    final signUpButton = find.text('Sign Up');
    if (signUpButton.evaluate().isNotEmpty) {
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
    }
  }

  /// Performs login with credentials
  static Future<void> performLogin(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await navigateToLogin(tester);
    await enterText(tester, 'email_field', email);
    await enterText(tester, 'password_field', password);
    await tapButton(tester, 'login_button');
    await tester.pumpAndSettle();
  }

  /// Navigates to profile screen
  static Future<void> navigateToProfile(WidgetTester tester) async {
    final profileTab = find.byIcon(Icons.person);
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
    }
  }

  /// Navigates to search screen
  static Future<void> navigateToSearch(WidgetTester tester) async {
    final searchTab = find.byIcon(Icons.search);
    if (searchTab.evaluate().isNotEmpty) {
      await tester.tap(searchTab);
      await tester.pumpAndSettle();
    }
  }

  /// Navigates to appointments screen
  static Future<void> navigateToAppointments(WidgetTester tester) async {
    final appointmentsTab = find.byIcon(Icons.calendar_today);
    if (appointmentsTab.evaluate().isNotEmpty) {
      await tester.tap(appointmentsTab);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies error message is displayed
  static void verifyErrorDisplayed(WidgetTester tester) {
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.toLowerCase().contains('error') ?? false),
      ),
      findsAtLeastNWidgets(1),
    );
  }

  /// Verifies loading indicator is displayed
  static void verifyLoadingDisplayed(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies no loading indicator is displayed
  static void verifyNotLoading(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  /// Scrolls to find a widget
  static Future<void> scrollToFind(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
  }) async {
    if (finder.evaluate().isEmpty) {
      final scroll = scrollable ?? find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        finder,
        100,
        scrollable: scroll,
      );
    }
  }

  /// Takes a screenshot (for debugging)
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    // Screenshot functionality
    await tester.pumpAndSettle();
    // Implementation depends on your screenshot setup
  }

  /// Verifies navigation occurred by checking for specific widget
  static void verifyNavigationTo(WidgetTester tester, String screenTitle) {
    expect(find.text(screenTitle), findsOneWidget);
  }

  /// Dismisses keyboard
  static Future<void> dismissKeyboard(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  /// Waits for specific widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    throw Exception('Widget not found within timeout: $finder');
  }

  /// Verifies snackbar with message
  static void verifySnackBar(WidgetTester tester, String message) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  /// Verifies dialog is shown
  static void verifyDialogShown(WidgetTester tester) {
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  /// Dismisses dialog
  static Future<void> dismissDialog(WidgetTester tester) async {
    final okButton = find.text('OK');
    final cancelButton = find.text('Cancel');
    
    if (okButton.evaluate().isNotEmpty) {
      await tester.tap(okButton);
    } else if (cancelButton.evaluate().isNotEmpty) {
      await tester.tap(cancelButton);
    }
    
    await tester.pumpAndSettle();
  }

  /// Switches language in app
  static Future<void> switchLanguage(WidgetTester tester, String language) async {
    await navigateToProfile(tester);
    
    final languageButton = find.text('Language');
    if (languageButton.evaluate().isNotEmpty) {
      await tester.tap(languageButton);
      await tester.pumpAndSettle();
      
      final languageOption = find.text(language);
      if (languageOption.evaluate().isNotEmpty) {
        await tester.tap(languageOption);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Verifies RTL layout
  static void verifyRTLLayout(WidgetTester tester) {
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  }

  /// Verifies LTR layout
  static void verifyLTRLayout(WidgetTester tester) {
    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.ltr);
  }
}

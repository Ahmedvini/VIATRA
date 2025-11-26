# Integration Tests

This directory contains integration tests for the VIATRA Health mobile application. These tests verify critical user journeys and ensure that the app functions correctly as a whole.

## Overview

Integration tests simulate real user interactions and test the complete flow of the application, including UI, business logic, and state management.

## Test Structure

### Test Files

- **`app_test.dart`**: Basic smoke tests to ensure the app launches successfully
- **`auth_flow_test.dart`**: Authentication flows (login, registration, logout)
- **`doctor_search_booking_test.dart`**: Doctor search, filtering, and appointment booking
- **`chat_flow_test.dart`**: Chat/messaging functionality
- **`health_profile_test.dart`**: Health profile management (vitals, conditions, allergies)
- **`role_switching_test.dart`**: Role switching between patient and doctor
- **`localization_test.dart`**: Language switching and RTL support
- **`error_handling_test.dart`**: Error handling, validation, and recovery

### Test Helpers

The `test_helpers.dart` file provides reusable utilities for common test operations:

- **Navigation**: `navigateToLogin()`, `navigateToSearch()`, `navigateToProfile()`, etc.
- **Input**: `enterText()`, `tapButton()`, etc.
- **Verification**: `verifyErrorDisplayed()`, `verifyLoadingDisplayed()`, etc.
- **Localization**: `switchLanguage()`, `verifyRTLLayout()`, etc.

## Running Integration Tests

### Prerequisites

1. Ensure Flutter is installed and configured
2. Have an emulator/simulator running or a physical device connected
3. Install integration test dependencies:

```bash
cd mobile
flutter pub get
```

### Run All Integration Tests

```bash
# Run all integration tests
flutter test integration_test

# Run with verbose output
flutter test integration_test --verbose
```

### Run Specific Test Suite

```bash
# Run only auth flow tests
flutter test integration_test/auth_flow_test.dart

# Run only localization tests
flutter test integration_test/localization_test.dart
```

### Run on Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter test integration_test --device-id=<device-id>
```

### Generate Test Reports

```bash
# Run with test reporter
flutter test integration_test --reporter=expanded

# Generate coverage report
flutter test integration_test --coverage
```

## Test Coverage

The integration tests cover the following critical user journeys:

### 1. Authentication Flows
- ✅ User login with valid credentials
- ✅ Validation errors for invalid input
- ✅ Patient registration flow
- ✅ Doctor registration flow
- ✅ Logout functionality

### 2. Doctor Search and Booking
- ✅ Search for doctors by name/specialty
- ✅ Apply filters (specialty, location, availability)
- ✅ View doctor details
- ✅ Select time slots
- ✅ Complete booking flow
- ✅ Empty state handling

### 3. Health Profile Management
- ✅ View health profile
- ✅ Add/edit chronic conditions
- ✅ Add/edit allergies
- ✅ Update vitals (height, weight, blood pressure)
- ✅ BMI calculation
- ✅ Empty state handling

### 4. Appointments
- ✅ View upcoming appointments
- ✅ View past appointments
- ✅ Cancel appointments
- ✅ Reschedule appointments
- ✅ Filter appointments by status

### 5. Role Switching
- ✅ Switch from patient to doctor role
- ✅ Switch from doctor to patient role
- ✅ Role-specific navigation persistence
- ✅ Role permissions validation

### 6. Localization
- ✅ Switch between English and Arabic
- ✅ RTL layout for Arabic
- ✅ Medical term localization
- ✅ Number and date formatting
- ✅ Error message localization
- ✅ Empty state localization

### 7. Error Handling
- ✅ Network error handling
- ✅ Validation error display
- ✅ Auth error handling
- ✅ Server error with retry
- ✅ Loading states
- ✅ Form validation
- ✅ Multiple error handling
- ✅ Error recovery flows

## Writing New Tests

### Test Structure Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Name Tests', () {
    testWidgets('description of what test does', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Perform test actions
      await TestHelpers.navigateToLogin(tester);
      await TestHelpers.enterText(tester, 'field_key', 'value');
      await TestHelpers.tapButton(tester, 'button_key');

      // Verify results
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

### Best Practices

1. **Use Test Helpers**: Leverage existing helper functions for common operations
2. **Wait for Animations**: Always use `await tester.pumpAndSettle()` after actions
3. **Descriptive Names**: Use clear, descriptive test names
4. **Cleanup**: Ensure tests don't affect each other (use setUp/tearDown if needed)
5. **Error Handling**: Test both happy path and error scenarios
6. **Assertions**: Verify both what should be present and what shouldn't be
7. **Keys**: Use Keys for widgets that need to be found reliably in tests

### Adding Test Helpers

When adding a new reusable function to `test_helpers.dart`:

```dart
/// Brief description of what the helper does
static Future<void> helperFunctionName(
  WidgetTester tester,
  // parameters
) async {
  // Implementation
  await tester.pumpAndSettle();
}
```

## CI/CD Integration

Integration tests are run automatically on:
- Pull requests to main/develop branches
- Nightly builds
- Pre-release builds

See `.github/workflows/ci.yml` for CI configuration.

## Troubleshooting

### Tests Failing Intermittently

- Increase wait times: `await tester.pumpAndSettle(Duration(seconds: 3));`
- Use `waitForWidget()` helper for elements that load asynchronously
- Check for race conditions in async operations

### Widget Not Found

- Verify the widget key or text matches exactly
- Check if the widget is scrolled out of view (use `scrollToFind()`)
- Ensure animations have completed with `pumpAndSettle()`
- Check widget tree with `debugDumpApp()` in tests

### Timeout Errors

- Increase timeout in test configuration
- Break down long tests into smaller ones
- Optimize app initialization for tests

### Platform-Specific Issues

- Test on multiple platforms (iOS/Android)
- Check for platform-specific widgets or behaviors
- Use platform checks where necessary

## Performance Considerations

- **Parallel Execution**: Tests run sequentially by default
- **Test Duration**: Keep individual tests under 30 seconds when possible
- **Resource Cleanup**: Properly dispose of resources after tests
- **Mock Services**: Consider mocking external services for faster tests

## Debugging Tests

### Enable Verbose Logging

```bash
flutter test integration_test --verbose
```

### Take Screenshots

Use the `takeScreenshot()` helper function:

```dart
await TestHelpers.takeScreenshot(tester, 'test_screenshot');
```

### Debug Specific Test

```dart
testWidgets('test name', (WidgetTester tester) async {
  debugDumpApp(); // Prints widget tree
  debugPrint('Current state: $someVariable');
  // ... test code
});
```

## Maintenance

- Review and update tests when features change
- Remove obsolete tests
- Keep test helpers up to date
- Document any test-specific configurations or requirements

## Resources

- [Flutter Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [WidgetTester Documentation](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)

## Contact

For questions or issues with integration tests, contact the mobile development team.

# Testing Guide

This guide provides comprehensive information about testing the VIATRA Health mobile application.

## Table of Contents

1. [Overview](#overview)
2. [Test Types](#test-types)
3. [Running Tests](#running-tests)
4. [Writing Tests](#writing-tests)
5. [Integration Tests](#integration-tests)
6. [Widget Tests](#widget-tests)
7. [Unit Tests](#unit-tests)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [CI/CD](#cicd)

## Overview

The VIATRA Health mobile app uses a comprehensive testing strategy to ensure reliability and quality:

- **Unit Tests**: Test individual functions and classes in isolation
- **Widget Tests**: Test individual widgets and their interactions
- **Integration Tests**: Test complete user journeys and flows

## Test Types

### Unit Tests

Located in `test/` directory. Test business logic, utilities, and services.

**Example**: Testing a validation function

```dart
test('validateEmail returns error for invalid email', () {
  final result = Validators.validateEmail('invalid-email');
  expect(result, isNotNull);
});
```

### Widget Tests

Located in `test/` directory. Test widget rendering and user interactions.

**Example**: Testing a custom button

```dart
testWidgets('CustomButton calls onPressed when tapped', (WidgetTester tester) async {
  bool pressed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        label: 'Test',
        onPressed: () => pressed = true,
      ),
    ),
  );

  await tester.tap(find.text('Test'));
  expect(pressed, true);
});
```

### Integration Tests

Located in `integration_test/` directory. Test complete user flows.

See [Integration Test README](../integration_test/README.md) for details.

## Running Tests

### Run All Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test
```

### Run Specific Test File

```bash
# Unit/widget test
flutter test test/utils/validators_test.dart

# Integration test
flutter test integration_test/auth_flow_test.dart
```

### Run Tests with Coverage

```bash
# Generate coverage report
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Tests on Specific Device

```bash
# List devices
flutter devices

# Run on specific device
flutter test integration_test --device-id=<device-id>
```

## Writing Tests

### Unit Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
      });
    });
  });
}
```

### Widget Test Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/common/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('displays loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays custom message when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });
  });
}
```

### Integration Test Structure

See [Integration Test README](../integration_test/README.md) for detailed examples.

## Best Practices

### General Best Practices

1. **Follow AAA Pattern**: Arrange, Act, Assert
   ```dart
   test('description', () {
     // Arrange
     final input = 'test';
     
     // Act
     final result = function(input);
     
     // Assert
     expect(result, expected);
   });
   ```

2. **Use Descriptive Names**: Test names should clearly describe what they test
   ```dart
   // Good
   test('returns error when email is invalid')
   
   // Bad
   test('email validation')
   ```

3. **Test One Thing**: Each test should verify one specific behavior

4. **Avoid Test Interdependence**: Tests should not depend on other tests

5. **Use setUp and tearDown**: For common setup/cleanup
   ```dart
   group('MyClass', () {
     late MyClass myClass;
     
     setUp(() {
       myClass = MyClass();
     });
     
     test('test 1', () {
       // Use myClass
     });
   });
   ```

### Widget Testing Best Practices

1. **Use Keys for Important Widgets**
   ```dart
   TextField(key: Key('email_field'))
   
   // In test
   await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
   ```

2. **Wait for Animations**
   ```dart
   await tester.pumpAndSettle();
   ```

3. **Test Different States**
   - Initial state
   - Loading state
   - Success state
   - Error state
   - Empty state

4. **Test Accessibility**
   ```dart
   expect(tester.getSemantics(find.byType(MyWidget)), matchesSemantics());
   ```

### Integration Testing Best Practices

1. **Use Test Helpers**: Reuse common operations
2. **Test Critical Paths**: Focus on high-value user journeys
3. **Mock External Services**: For consistent and fast tests
4. **Clean Up After Tests**: Reset app state if needed
5. **Test on Multiple Platforms**: iOS and Android may behave differently

### Mocking Best Practices

1. **Use Mockito for Mocking**
   ```dart
   import 'package:mockito/mockito.dart';
   import 'package:mockito/annotations.dart';
   
   @GenerateMocks([ApiService])
   void main() {
     test('description', () {
       final mockApi = MockApiService();
       when(mockApi.getData()).thenAnswer((_) async => mockData);
       
       // Test with mock
     });
   }
   ```

2. **Mock at Appropriate Level**: Mock services, not widgets

3. **Verify Interactions**
   ```dart
   verify(mockApi.getData()).called(1);
   verifyNever(mockApi.deleteData());
   ```

## Troubleshooting

### Common Issues

#### Tests Failing Intermittently

**Problem**: Tests pass sometimes and fail other times.

**Solutions**:
- Add appropriate waits: `await tester.pumpAndSettle()`
- Increase timeout for slow operations
- Check for race conditions in async code
- Use `waitForWidget()` helper for dynamically loaded content

#### Widget Not Found

**Problem**: `expect(find.something(), findsOneWidget)` fails.

**Solutions**:
- Check widget is actually rendered
- Verify key/text matches exactly (case-sensitive)
- Check if widget is scrolled out of view
- Use `debugDumpApp()` to see widget tree

#### Timeout Errors

**Problem**: Tests timeout before completing.

**Solutions**:
- Optimize app initialization
- Mock slow services
- Break down long tests
- Increase timeout in test configuration

#### Platform-Specific Failures

**Problem**: Tests pass on one platform but fail on another.

**Solutions**:
- Check for platform-specific widgets/behaviors
- Test on both iOS and Android
- Use platform checks where necessary
- Be aware of platform-specific animations/transitions

### Debugging Tests

#### Enable Verbose Output

```bash
flutter test --verbose
```

#### Print Widget Tree

```dart
debugDumpApp();
```

#### Take Screenshots

```dart
await TestHelpers.takeScreenshot(tester, 'debug_screenshot');
```

#### Add Breakpoints

Use your IDE's debugger to set breakpoints in test code.

## CI/CD

### Automated Test Runs

Tests run automatically on:
- Every commit to feature branches
- Pull requests to main/develop
- Nightly builds
- Pre-release tags

### CI Configuration

See `.github/workflows/ci.yml` for full CI configuration.

**Key CI Steps**:
1. Install Flutter
2. Install dependencies (`flutter pub get`)
3. Run unit/widget tests (`flutter test`)
4. Run integration tests (`flutter test integration_test`)
5. Generate and upload coverage report
6. Archive test results

### Coverage Requirements

- **Target**: 80% code coverage
- **Minimum**: 70% code coverage for PR approval

### Viewing CI Test Results

1. Go to GitHub Actions tab
2. Select the workflow run
3. View test results and coverage report
4. Download artifacts if needed

## Test Organization

```
mobile/
├── test/                           # Unit and widget tests
│   ├── utils/                      # Utility tests
│   │   ├── validators_test.dart
│   │   └── error_handler_test.dart
│   ├── widgets/                    # Widget tests
│   │   ├── common/
│   │   │   ├── loading_widget_test.dart
│   │   │   └── error_widget_test.dart
│   │   └── appointments/
│   │       └── appointment_card_test.dart
│   ├── services/                   # Service tests
│   │   ├── auth_service_test.dart
│   │   └── api_service_test.dart
│   └── providers/                  # Provider tests
│       └── auth_provider_test.dart
└── integration_test/               # Integration tests
    ├── app_test.dart
    ├── auth_flow_test.dart
    ├── doctor_search_booking_test.dart
    ├── health_profile_test.dart
    ├── role_switching_test.dart
    ├── localization_test.dart
    ├── error_handling_test.dart
    ├── test_helpers.dart
    └── README.md
```

## Code Coverage

### Viewing Coverage

```bash
# Generate coverage
flutter test --coverage

# View in terminal (requires lcov-tools)
lcov --list coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage Goals

- **Overall**: 80%+
- **Critical Paths**: 95%+
- **Utils/Services**: 90%+
- **Widgets**: 80%+

### Excluding Files from Coverage

Add to file:
```dart
// coverage:ignore-file
```

Exclude specific lines:
```dart
// coverage:ignore-start
// code to ignore
// coverage:ignore-end
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Flutter Test Package](https://pub.dev/packages/flutter_test)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)

## Getting Help

For questions or issues:
1. Check this documentation
2. Review existing tests for examples
3. Consult team documentation
4. Ask in team chat
5. Create an issue on GitHub

## Maintenance

- Review and update tests regularly
- Remove obsolete tests
- Add tests for new features
- Keep test helpers and utilities up to date
- Update documentation as testing practices evolve

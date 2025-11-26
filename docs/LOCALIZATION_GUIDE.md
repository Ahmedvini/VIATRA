# Localization Guide

This guide explains how to implement and maintain localization in the VIATRA Health mobile application.

## Table of Contents

1. [Overview](#overview)
2. [Supported Languages](#supported-languages)
3. [Architecture](#architecture)
4. [Adding New Translations](#adding-new-translations)
5. [Using Translations in Code](#using-translations-in-code)
6. [RTL Support](#rtl-support)
7. [Formatting](#formatting)
8. [Testing](#testing)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

VIATRA Health uses Flutter's official localization system (`flutter_localizations`) with ARB (Application Resource Bundle) files for translation management.

### Key Features

- ✅ Multiple language support (English, Arabic)
- ✅ RTL (Right-to-Left) layout support
- ✅ Type-safe translations with code generation
- ✅ Context-aware translations with placeholders
- ✅ Medical terminology localization
- ✅ Date/time formatting per locale

## Supported Languages

| Language | Code | Direction | Status |
|----------|------|-----------|--------|
| English  | `en` | LTR       | ✅ Complete |
| Arabic   | `ar` | RTL       | ✅ Complete |

## Architecture

### Directory Structure

```
mobile/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb          # English translations
│   │   └── app_ar.arb          # Arabic translations
│   ├── utils/
│   │   └── localization_helper.dart  # Helper utilities
│   └── main.dart               # Localization configuration
├── l10n.yaml                   # Localization configuration
└── .dart_tool/
    └── flutter_gen/
        └── gen_l10n/
            └── app_localizations*.dart  # Generated files
```

### Configuration

**`l10n.yaml`**:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

**`main.dart`**:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'),
    Locale('ar'),
  ],
  // ...
)
```

## Adding New Translations

### Step 1: Add to English ARB File

Add new keys to `lib/l10n/app_en.arb`:

```json
{
  "myNewKey": "My New Text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

### Step 2: Add Translations for Other Languages

Add corresponding translations to `lib/l10n/app_ar.arb`:

```json
{
  "myNewKey": "النص الجديد"
}
```

### Step 3: Regenerate Localizations

```bash
flutter pub get
# This automatically generates the localization classes
```

### Step 4: Use in Code

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.myNewKey)
```

## Using Translations in Code

### Basic Usage

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.loginButton);
  }
}
```

### With Placeholders

**ARB File**:
```json
{
  "welcomeUser": "Welcome, {username}!",
  "@welcomeUser": {
    "description": "Welcome message with username",
    "placeholders": {
      "username": {
        "type": "String"
      }
    }
  }
}
```

**Code**:
```dart
Text(l10n.welcomeUser('John'))
```

### With Multiple Placeholders

**ARB File**:
```json
{
  "appointmentDetails": "Appointment with {doctorName} on {date} at {time}",
  "@appointmentDetails": {
    "placeholders": {
      "doctorName": {"type": "String"},
      "date": {"type": "String"},
      "time": {"type": "String"}
    }
  }
}
```

**Code**:
```dart
Text(l10n.appointmentDetails('Dr. Smith', '2024-01-15', '10:00 AM'))
```

### With Numbers

**ARB File**:
```json
{
  "yearsExperience": "{years} years",
  "@yearsExperience": {
    "placeholders": {
      "years": {"type": "int"}
    }
  }
}
```

**Code**:
```dart
Text(l10n.yearsExperience(5))
```

### Using Localization Helper

```dart
import 'package:mobile/utils/localization_helper.dart';

// Get greeting based on time of day
Text(LocalizationHelper.getLocalizedGreeting(context))

// Get localized role
Text(LocalizationHelper.getLocalizedRole(context, 'doctor'))

// Get localized appointment status
Text(LocalizationHelper.getLocalizedAppointmentStatus(context, 'scheduled'))

// Check if RTL
bool isRTL = LocalizationHelper.isRTL(context);
```

## RTL Support

### Automatic RTL Layout

Flutter automatically handles RTL layout when using:

- `Directionality` widget (set automatically by localization)
- `EdgeInsetsDirectional` instead of `EdgeInsets`
- `AlignmentDirectional` instead of `Alignment`
- `PositionedDirectional` instead of `Positioned`

### EdgeInsetsDirectional Example

```dart
// ❌ Don't use EdgeInsets for padding that should flip in RTL
Padding(
  padding: EdgeInsets.only(left: 16, right: 8),
  child: child,
)

// ✅ Use EdgeInsetsDirectional
Padding(
  padding: EdgeInsetsDirectional.only(start: 16, end: 8),
  child: child,
)
```

### AlignmentDirectional Example

```dart
// ❌ Don't use Alignment.centerLeft
Container(
  alignment: Alignment.centerLeft,
  child: child,
)

// ✅ Use AlignmentDirectional.centerStart
Container(
  alignment: AlignmentDirectional.centerStart,
  child: child,
)
```

### Checking Text Direction

```dart
bool isRTL = Directionality.of(context) == TextDirection.rtl;

// Or use helper
bool isRTL = LocalizationHelper.isRTL(context);
```

### Icons in RTL

Some icons need to be flipped in RTL:

```dart
Icon(
  Icons.arrow_forward,
  textDirection: TextDirection.ltr, // Force LTR for specific icons
)

// Or flip based on direction
Icon(
  isRTL ? Icons.arrow_back : Icons.arrow_forward,
)
```

### Testing RTL Layout

```dart
testWidgets('layout works in RTL', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      home: MyWidget(),
    ),
  );

  final directionality = tester.widget<Directionality>(
    find.byType(Directionality).first,
  );
  expect(directionality.textDirection, TextDirection.rtl);
});
```

## Formatting

### Date Formatting

```dart
import 'package:intl/intl.dart';

String formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = DateFormat.yMMMd(locale);
  return formatter.format(date);
}
```

### Time Formatting

```dart
String formatTime(BuildContext context, DateTime time) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = DateFormat.jm(locale);
  return formatter.format(time);
}
```

### Number Formatting

```dart
import 'package:intl/intl.dart';

String formatNumber(BuildContext context, num value) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = NumberFormat.decimalPattern(locale);
  return formatter.format(value);
}
```

### Currency Formatting

```dart
String formatCurrency(BuildContext context, double amount) {
  final locale = Localizations.localeOf(context).languageCode;
  final formatter = NumberFormat.currency(locale: locale, symbol: 'SAR');
  return formatter.format(amount);
}
```

## Testing

### Unit Testing Localizations

```dart
testWidgets('shows correct translation', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('ar')],
      home: MyWidget(),
    ),
  );

  expect(find.text('Welcome Back'), findsOneWidget);
});
```

### Testing Language Switch

```dart
testWidgets('changes language', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('en'),
      // ... setup
    ),
  );

  expect(find.text('Welcome Back'), findsOneWidget);

  // Change locale
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ar'),
      // ... setup
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('مرحباً بعودتك'), findsOneWidget);
});
```

### Integration Tests

See `integration_test/localization_test.dart` for complete examples.

## Best Practices

### 1. Use Semantic Keys

```json
{
  "loginButton": "Sign In",           // ✅ Semantic
  "button1": "Sign In"                // ❌ Generic
}
```

### 2. Add Descriptions

```json
{
  "loginButton": "Sign In",
  "@loginButton": {
    "description": "Button label for user login"  // ✅ Helpful context
  }
}
```

### 3. Use Placeholders for Dynamic Content

```json
{
  "greeting": "Hello, {name}!",      // ✅ Flexible
  "greetingJohn": "Hello, John!"     // ❌ Hard-coded
}
```

### 4. Keep Translations Consistent

Maintain consistent terminology across the app:
- "Sign In" vs "Login"
- "Appointment" vs "Booking"
- "Doctor" vs "Physician"

### 5. Consider Context

```json
{
  "saveButton": "Save",              // Generic
  "saveProfileButton": "Save Profile", // ✅ Context-specific
  "saveSettingsButton": "Save Settings"
}
```

### 6. Handle Plurals

```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "placeholders": {
      "count": {"type": "int"}
    }
  }
}
```

### 7. RTL-Aware Development

- Always use `EdgeInsetsDirectional`
- Use `AlignmentDirectional`
- Test in both LTR and RTL
- Consider icon directionality

### 8. Medical Terminology

For medical terms, ensure:
- Accurate translations
- Consistent usage
- Professional terminology
- Review by medical professionals when possible

### 9. Accessibility

- Provide semantic labels
- Ensure screen readers work with translations
- Test with different text sizes

### 10. Performance

- Avoid creating `AppLocalizations.of(context)` repeatedly
- Cache localized strings when appropriate
- Use const where possible

## Troubleshooting

### Issue: Translations Not Updating

**Solution**:
```bash
# Clean and regenerate
flutter clean
flutter pub get
```

### Issue: "AppLocalizations not found"

**Solution**:
```bash
# Ensure l10n.yaml is configured correctly
# Run code generation
flutter pub get
# Import generated file
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Issue: RTL Layout Not Working

**Solution**:
- Verify `Directionality` widget is in tree
- Check locale is set correctly
- Use `EdgeInsetsDirectional` instead of `EdgeInsets`
- Ensure `supportedLocales` includes RTL language

### Issue: Placeholder Not Working

**Solution**:
- Verify placeholder type matches usage
- Check ARB syntax is correct
- Ensure placeholder name matches between ARB and code

### Issue: Missing Translation

**Solution**:
- Check translation exists in ARB file
- Verify ARB file syntax (valid JSON)
- Run `flutter pub get` to regenerate
- Clear build cache if needed

## Adding a New Language

### Step 1: Create ARB File

Create `lib/l10n/app_<locale>.arb`:

```json
{
  "@@locale": "es",
  "loginWelcome": "Bienvenido",
  ...
}
```

### Step 2: Update Supported Locales

In `main.dart`:

```dart
supportedLocales: [
  Locale('en'),
  Locale('ar'),
  Locale('es'), // Add new locale
],
```

### Step 3: Update Locale Provider

Add language option to settings:

```dart
supportedLanguages = [
  {'code': 'en', 'name': 'English'},
  {'code': 'ar', 'name': 'العربية'},
  {'code': 'es', 'name': 'Español'},
];
```

### Step 4: Test

- Test language switch
- Test RTL if applicable
- Verify all screens
- Check formatting (dates, numbers)

## Resources

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle)
- [Intl Package](https://pub.dev/packages/intl)
- [RTL Support in Flutter](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#supporting-rtl-languages)

## Maintenance

### Regular Tasks

1. **Review Translations**: Periodically review for consistency
2. **Add New Strings**: Follow process for new features
3. **Update Documentation**: Keep this guide up to date
4. **Test Both Languages**: Always test in English and Arabic
5. **Monitor Issues**: Watch for localization bugs

### Translation Updates

When updating existing translations:
1. Update source (English) ARB file
2. Update all other language ARB files
3. Test changes in app
4. Update any documentation references

## Contact

For localization questions or to request new translations, contact:
- Mobile Development Team
- Localization Lead
- Medical Terminology Consultant (for medical terms)

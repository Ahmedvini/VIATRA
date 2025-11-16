# Viatra Mobile

The Flutter mobile application for the Viatra Health Platform, supporting both iOS and Android.

## Overview

Viatra Mobile is a cross-platform healthcare application that provides:
- User authentication and profile management
- Healthcare provider discovery and booking
- Secure document upload and management
- Real-time messaging and notifications
- Appointment scheduling and management
- Health records and analytics

## Technology Stack

- **Framework**: Flutter 3.x+
- **Language**: Dart 3.x+
- **State Management**: Provider (with Riverpod as alternative)
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: SharedPreferences + Flutter Secure Storage
- **UI**: Material Design 3
- **Localization**: Flutter Intl (English & Arabic with RTL support)

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (macOS only)
- Android development: Android SDK

## Project Structure

```
mobile/
├── lib/
│   ├── config/           # App configuration
│   │   ├── app_config.dart
│   │   ├── theme.dart
│   │   └── routes.dart
│   ├── models/          # Data models
│   ├── services/        # API and external services
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── navigation_service.dart
│   ├── providers/       # State management
│   │   ├── auth_provider.dart
│   │   ├── theme_provider.dart
│   │   └── locale_provider.dart
│   ├── screens/         # UI screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── profile/
│   │   └── settings/
│   ├── widgets/         # Reusable UI components
│   │   ├── common/
│   │   ├── forms/
│   │   └── cards/
│   ├── utils/           # Helper functions
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── error_handler.dart
│   ├── l10n/           # Localization files
│   └── main.dart       # App entry point
├── assets/             # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/              # Unit and widget tests
├── integration_test/  # Integration tests
├── android/           # Android-specific configuration
├── ios/              # iOS-specific configuration
└── pubspec.yaml      # Dependencies and configuration
```

## Getting Started

### 1. Environment Setup

Install Flutter and set up your development environment:

```bash
# Verify Flutter installation
flutter doctor

# Check for any issues
flutter doctor --verbose
```

### 2. Clone and Setup

```bash
# Navigate to mobile directory
cd mobile

# Copy environment configuration
cp .env.example .env

# Install dependencies
flutter pub get

# Generate code (if needed)
flutter packages pub run build_runner build
```

### 3. Environment Configuration

Edit `.env` file with your configuration:

```env
API_BASE_URL=http://localhost:8080/api/v1
ENVIRONMENT=development
GOOGLE_MAPS_API_KEY=your_api_key
# ... other configuration
```

### 4. Running the App

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

## Available Commands

### Development
```bash
# Run the app
flutter run

# Hot reload (r in terminal while running)
# Hot restart (R in terminal while running)

# Run with specific flavor/environment
flutter run --flavor dev
flutter run --flavor staging
flutter run --flavor prod
```

### Testing
```bash
# Run unit and widget tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/unit/auth_test.dart
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Check for dependency issues
flutter pub deps
```

### Build
```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android - recommended for Play Store)
flutter build appbundle

# Build iOS (macOS only)
flutter build ios

# Build for web
flutter build web
```

## State Management

The app uses Provider for state management:

```dart
// Provider setup
ChangeNotifierProvider<AuthProvider>(
  create: (_) => AuthProvider(),
  child: MyWidget(),
)

// Consuming state
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?.name ?? 'Not logged in');
  },
)

// Reading state
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final user = context.read<AuthProvider>().user;
```

## Navigation

Using GoRouter for type-safe navigation:

```dart
// Navigate to a route
context.go('/profile');
context.push('/settings');

// Navigate with parameters
context.pushNamed('user-profile', params: {'id': '123'});

// Navigate and replace
context.pushReplacement('/home');
```

## API Integration

HTTP requests using Dio:

```dart
// GET request
final response = await apiService.get('/users/profile');

// POST request
final response = await apiService.post('/auth/login', data: {
  'email': email,
  'password': password,
});

// File upload
final response = await apiService.uploadFile('/upload', file);
```

## Localization

Supporting English and Arabic with RTL:

```dart
// In widget
Text(AppLocalizations.of(context)!.welcome)

// Using extension
context.l10n.welcome

// RTL support is automatic based on locale
```

## Theming

Material Design 3 theming:

```dart
// Access theme
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Custom colors
final primaryColor = colorScheme.primary;
final surfaceColor = colorScheme.surface;

// Typography
final headlineStyle = theme.textTheme.headlineLarge;
```

## Local Storage

Different storage options for different needs:

```dart
// Secure storage (tokens, sensitive data)
await secureStorage.write(key: 'token', value: token);
final token = await secureStorage.read(key: 'token');

// SharedPreferences (app settings, cache)
final prefs = await SharedPreferences.getInstance();
await prefs.setString('theme', 'dark');
final theme = prefs.getString('theme');
```

## Error Handling

Centralized error handling:

```dart
try {
  await apiService.login(email, password);
} catch (e) {
  ErrorHandler.handleError(e);
  // Show user-friendly message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(ErrorHandler.getDisplayMessage(e))),
  );
}
```

## Testing

### Unit Tests
```dart
// test/unit/auth_provider_test.dart
testWidgets('Login with valid credentials', (tester) async {
  final authProvider = AuthProvider();
  await authProvider.login('test@example.com', 'password');
  expect(authProvider.isLoggedIn, true);
});
```

### Widget Tests
```dart
// test/widget/login_screen_test.dart
testWidgets('Login screen UI test', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Login'), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(2));
});
```

### Integration Tests
```dart
// integration_test/app_test.dart
testWidgets('Complete user flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // Test complete user journey
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
});
```

## Build Configuration

### Android

Configure in `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS

Configure in `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Viatra Health</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```

## Performance Optimization

### Best Practices

1. **Widget Rebuilds**: Use `const` constructors where possible
2. **Images**: Use appropriate formats and sizes
3. **Lists**: Use `ListView.builder` for large lists
4. **State**: Keep state as local as possible
5. **Network**: Implement proper caching and error handling

### Performance Monitoring

```dart
// Performance logging
final stopwatch = Stopwatch()..start();
await expensiveOperation();
Logger.performance('Operation took ${stopwatch.elapsedMilliseconds}ms');
```

## Security

### Best Practices

1. **Token Storage**: Use FlutterSecureStorage for sensitive data
2. **API Communication**: Always use HTTPS in production
3. **Input Validation**: Validate all user inputs
4. **Error Messages**: Don't expose sensitive information
5. **Code Obfuscation**: Build with `--obfuscate` for release

### Certificate Pinning

```dart
// Implement certificate pinning for production
final dio = Dio();
dio.interceptors.add(CertificatePinningInterceptor());
```

## Deployment

### Android (Google Play Store)

```bash
# Build app bundle
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

# Upload to Play Console
# Follow Google Play Console upload process
```

### iOS (App Store)

```bash
# Build for iOS
flutter build ios --release --obfuscate --split-debug-info=build/symbols

# Archive in Xcode and upload to App Store Connect
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. **Hot Reload Not Working**
   ```bash
   flutter run --hot
   # Or restart app (R in terminal)
   ```

3. **Dependency Conflicts**
   ```bash
   flutter pub deps
   flutter pub upgrade --major-versions
   ```

4. **iOS Build Issues**
   ```bash
   cd ios
   pod install --clean-install
   cd ..
   flutter build ios
   ```

### Performance Issues

- Use Flutter Inspector for widget debugging
- Enable performance overlay: `flutter run --enable-software-rendering`
- Profile memory usage: `flutter run --profile`

## Development Workflow

1. **Feature Development**
   - Create feature branch
   - Implement feature with tests
   - Run `flutter analyze` and `flutter test`
   - Submit pull request

2. **Code Review**
   - Ensure code follows style guide
   - Verify tests are included
   - Check performance implications

3. **Deployment**
   - Test on multiple devices
   - Build release version
   - Deploy to app stores

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

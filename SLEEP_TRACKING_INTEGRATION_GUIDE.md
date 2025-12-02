# Sleep Tracking - Mobile Integration Guide

## 🎯 Overview

This guide provides instructions for integrating the sleep tracking screens into your main mobile app navigation.

## 📱 Completed Screens

All four sleep tracking screens are now complete:

1. **Sleep Dashboard** (`sleep_dashboard_screen.dart`)
   - Overview of sleep statistics
   - Quick access to start new sleep session
   - Recent sleep history

2. **Active Sleep** (`active_sleep_screen.dart`)
   - Real-time sleep tracking
   - Pause/resume/end controls
   - Wake-up tracking

3. **Sleep History** (`sleep_history_screen.dart`)
   - List of past sleep sessions
   - Filter and search functionality
   - Quick navigation to details

4. **Sleep Details** (`sleep_details_screen.dart`)
   - Detailed session information
   - Interruption timeline
   - Sleep quality and efficiency metrics
   - Session deletion

## 🔧 Integration Steps

### Step 1: Generate Model Code

Before running the app, generate the required `.g.dart` files:

```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Add Route Definitions

Add these routes to your `lib/routes/app_routes.dart` (or wherever you define routes):

```dart
import '../screens/sleep_tracking/sleep_dashboard_screen.dart';
import '../screens/sleep_tracking/active_sleep_screen.dart';
import '../screens/sleep_tracking/sleep_history_screen.dart';
import '../screens/sleep_tracking/sleep_details_screen.dart';

class AppRoutes {
  // Sleep Tracking Routes
  static const String sleepDashboard = '/sleep-dashboard';
  static const String activeSleep = '/active-sleep';
  static const String sleepHistory = '/sleep-history';
  static const String sleepDetails = '/sleep-details';
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ... existing routes ...
      
      case sleepDashboard:
        return MaterialPageRoute(
          builder: (_) => const SleepDashboardScreen(),
        );
        
      case activeSleep:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ActiveSleepScreen(sessionId: sessionId),
        );
        
      case sleepHistory:
        return MaterialPageRoute(
          builder: (_) => const SleepHistoryScreen(),
        );
        
      case sleepDetails:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SleepDetailsScreen(sessionId: sessionId),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

### Step 3: Add Navigation Button in Main App

#### Option A: Add to Bottom Navigation Bar

If you have a bottom navigation bar, add a sleep tracking tab:

```dart
BottomNavigationBar(
  items: const [
    // ... existing items ...
    BottomNavigationBarItem(
      icon: Icon(Icons.bedtime),
      label: 'Sleep',
    ),
  ],
  onTap: (index) {
    // Handle navigation
    if (index == sleepTabIndex) {
      Navigator.pushNamed(context, AppRoutes.sleepDashboard);
    }
  },
)
```

#### Option B: Add to Drawer Menu

If you have a drawer menu:

```dart
Drawer(
  child: ListView(
    children: [
      // ... existing items ...
      ListTile(
        leading: const Icon(Icons.bedtime),
        title: const Text('Sleep Tracking'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushNamed(context, AppRoutes.sleepDashboard);
        },
      ),
    ],
  ),
)
```

#### Option C: Add to Home Screen Cards

Add a card on your home screen:

```dart
Card(
  child: InkWell(
    onTap: () {
      Navigator.pushNamed(context, AppRoutes.sleepDashboard);
    },
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.bedtime, size: 48, color: Colors.indigo),
          const SizedBox(height: 8),
          Text('Sleep Tracking', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Track your sleep patterns', 
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    ),
  ),
)
```

### Step 4: Update main.dart

Make sure your main.dart uses the route generator:

```dart
MaterialApp(
  title: 'VIATRA',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  onGenerateRoute: AppRoutes.generateRoute,
  initialRoute: '/',
)
```

## 🔄 Navigation Flow

```
Dashboard → Start Session → Active Sleep → End Session → Details
    ↓                            ↓
  History → Select Session → Details
                               ↓
                           Delete Session
```

### Programmatic Navigation Examples

**Start a new sleep session:**
```dart
// From dashboard or any screen
final session = await _sleepService.startSleepSession();
Navigator.pushNamed(
  context, 
  AppRoutes.activeSleep,
  arguments: session.id,
);
```

**View sleep history:**
```dart
Navigator.pushNamed(context, AppRoutes.sleepHistory);
```

**View session details:**
```dart
Navigator.pushNamed(
  context,
  AppRoutes.sleepDetails,
  arguments: sessionId,
);
```

**Handle navigation results:**
```dart
final result = await Navigator.pushNamed(
  context,
  AppRoutes.sleepDetails,
  arguments: sessionId,
);

// If session was deleted, refresh list
if (result == true) {
  _loadSessions();
}
```

## 🎨 UI Customization

### Theme Colors

The screens use theme colors by default. Customize in your theme:

```dart
ThemeData(
  primaryColor: Colors.indigo,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Custom Icons

Replace default icons if needed:

```dart
// In sleep_dashboard_screen.dart
Icon(Icons.bedtime) // Change to your custom icon
```

## 🔐 Authentication

Ensure API authentication is configured:

```dart
// In api_service.dart
class ApiService {
  Future<void> setAuthToken(String token) async {
    _token = token;
    // Store token securely
  }
}
```

## 📊 Required Permissions

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
```

Add to `Info.plist` (iOS):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🧪 Testing the Integration

### Manual Testing Checklist

- [ ] Dashboard loads with empty state
- [ ] Start sleep session creates active session
- [ ] Active sleep screen shows real-time duration
- [ ] Pause/resume functionality works
- [ ] End session saves data
- [ ] Sleep history displays sessions
- [ ] Sleep details shows full information
- [ ] Delete session removes from list
- [ ] Navigation back buttons work correctly
- [ ] Pull-to-refresh updates data

### Test User Flow

1. Open app and navigate to sleep tracking
2. Start a new sleep session
3. Wait a few seconds, observe duration updating
4. Pause the session (record interruption)
5. Resume the session
6. End the session with quality rating
7. View the session in history
8. Open session details
9. Review all metrics
10. Delete the session

## 🐛 Troubleshooting

### Common Issues

**1. Models not found**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**2. API connection failed**
- Check backend is running
- Verify API_BASE_URL in environment
- Check network permissions

**3. Navigation not working**
- Verify routes are registered
- Check route names match exactly
- Ensure MaterialApp uses onGenerateRoute

**4. Data not refreshing**
- Check pull-to-refresh implementation
- Verify API endpoints
- Check authentication token

## 📝 Next Steps

After integration:

1. **Add notifications**
   - Remind users to track sleep
   - Alert on poor sleep patterns

2. **Add analytics**
   - Track feature usage
   - Monitor app performance

3. **Add export functionality**
   - Generate sleep reports
   - Export data to PDF

4. **Add health integrations**
   - Apple Health (iOS)
   - Google Fit (Android)

5. **Add more visualizations**
   - Sleep cycle graphs
   - Weekly/monthly trends
   - Comparison charts

## 🔗 Related Files

- Models: `/mobile/lib/models/sleep_tracking/`
- Service: `/mobile/lib/services/sleep_tracking_service.dart`
- Screens: `/mobile/lib/screens/sleep_tracking/`
- Backend: `/backend/src/controllers/sleepTrackingController.js`

## 📚 Documentation

- [Sleep Tracking Setup Guide](SLEEP_TRACKING_SETUP_GUIDE.md)
- [Sleep Tracking Implementation](SLEEP_TRACKING_IMPLEMENTATION.md)
- [Sleep Mobile Implementation Status](SLEEP_MOBILE_IMPLEMENTATION_STATUS.md)
- [Backend API Documentation](docs/api/CHAT_API.md)

---

**Status:** ✅ All screens complete and ready for integration  
**Last Updated:** December 2024

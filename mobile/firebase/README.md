# Firebase Configuration for VIATRA Mobile App

## Overview
This directory should contain your Firebase configuration files for Android and iOS platforms.

## Required Files

### Android
Place your Firebase configuration file here:
- **File**: `android/app/google-services.json`
- **Location**: `/mobile/android/app/google-services.json`

### iOS
Place your Firebase configuration file here:
- **File**: `ios/Runner/GoogleService-Info.plist`
- **Location**: `/mobile/ios/Runner/GoogleService-Info.plist`

## How to Get Configuration Files

1. **Go to Firebase Console**:
   - Visit https://console.firebase.google.com
   - Select your project (or create a new one)

2. **Add Android App**:
   - Click "Add app" and select Android
   - Enter package name: `com.viatra.health` (or your package name)
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Add iOS App**:
   - Click "Add app" and select iOS
   - Enter bundle ID: `com.viatra.health` (or your bundle ID)
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/` directory

4. **Enable Cloud Messaging**:
   - In Firebase Console, go to Project Settings
   - Navigate to "Cloud Messaging" tab
   - Enable Cloud Messaging API if not enabled

## .gitignore

These files are already excluded from version control for security.
Never commit these files to your repository!

```
# Firebase
google-services.json
GoogleService-Info.plist
firebase-adminsdk-*.json
```

## Testing Configuration

To verify your Firebase setup:

```bash
# Run the app
flutter run

# Check Firebase initialization logs
# You should see: [Firebase] Successfully initialized Firebase
```

## Troubleshooting

### Android Issues
- Ensure `google-services.json` is in `android/app/` directory
- Check that the package name matches your app's package name
- Rebuild the app after adding the file: `flutter clean && flutter run`

### iOS Issues
- Ensure `GoogleService-Info.plist` is in `ios/Runner/` directory
- Check that the bundle ID matches your app's bundle ID
- Open Xcode and verify the file is added to the Runner target
- Rebuild the app after adding the file

### Firebase Initialization Errors
- Verify both configuration files are present
- Check that your Firebase project has Cloud Messaging enabled
- Ensure you've run `flutter pub get` after adding firebase dependencies
- Check Firebase Console for any configuration errors

## Environment Variables

Also ensure your `.env` file contains:

```env
FIREBASE_PROJECT_ID=your-firebase-project-id
```

## Next Steps

After adding configuration files:
1. Request notification permissions on app startup
2. Test push notifications from Firebase Console
3. Verify FCM token registration in backend
4. Test real-time messaging

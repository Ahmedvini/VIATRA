# Building APK for Real Phone Testing

## Quick Start (Debug APK)

For immediate testing on your phone:

```bash
cd /home/ahmedvini/Music/VIATRA/mobile
flutter build apk --debug
```

**APK Location:** `build/app/outputs/flutter-apk/app-debug.apk`

## Installation Methods

### Method 1: Using ADB (USB)

1. **Enable Developer Options on your phone:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect phone via USB and install:**
   ```bash
   cd /home/ahmedvini/Music/VIATRA/mobile
   flutter build apk --debug
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

3. **Or use Flutter to install directly:**
   ```bash
   flutter install
   ```

### Method 2: Manual Transfer

1. **Copy APK to phone:**
   ```bash
   # Via USB cable - copy the APK to your phone's Download folder
   cp build/app/outputs/flutter-apk/app-debug.apk ~/Downloads/viatra-debug.apk
   ```

2. **On your phone:**
   - Open File Manager
   - Go to Downloads folder
   - Tap on `viatra-debug.apk`
   - Allow "Install from Unknown Sources" if prompted
   - Tap "Install"

### Method 3: Share via Internet

```bash
# Upload to a file sharing service
# Or share via messaging apps
```

## Build Variants

### 1. Debug APK (For Testing)
```bash
flutter build apk --debug
```
- **Size:** ~50-60 MB
- **Performance:** Slower (includes debug info)
- **Use case:** Development, testing
- **Location:** `build/app/outputs/flutter-apk/app-debug.apk`

### 2. Release APK (For Distribution)
```bash
flutter build apk --release
```
- **Size:** ~20-30 MB
- **Performance:** Optimized
- **Use case:** Production, sharing with users
- **Location:** `build/app/outputs/flutter-apk/app-release.apk`

### 3. Split APKs (Smallest Size)
```bash
flutter build apk --split-per-abi --release
```
- **Creates 3 APKs:**
  - `app-armeabi-v7a-release.apk` (~15 MB) - Old 32-bit phones
  - `app-arm64-v8a-release.apk` (~18 MB) - Modern 64-bit phones ⭐
  - `app-x86_64-release.apk` (~20 MB) - Intel-based devices
- **Most phones use:** arm64-v8a

### 4. Fat APK (All architectures in one)
```bash
flutter build apk --release
```
This is the default - includes all architectures in one APK.

## Pre-Build Checklist

Before building, make sure:

### 1. ✅ Environment Variables Configured
```bash
cat /home/ahmedvini/Music/VIATRA/mobile/.env
```
Should show your Railway backend URL.

### 2. ✅ App Version and Name
Check `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+buildNumber
name: viatra_app
```

### 3. ✅ App Display Name
Check `mobile/android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Viatra"  <!-- This is what appears on phone -->
```

### 4. ✅ Permissions
The app already has necessary permissions in AndroidManifest.xml:
- Internet access
- Camera (for document upload)
- External storage

## Release Signing (For Production)

For production releases, you need proper signing:

### 1. Generate a keystore (one-time setup)
```bash
cd /home/ahmedvini/Music/VIATRA/mobile/android
keytool -genkey -v -keystore viatra-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias viatra-key
```

You'll be asked for:
- Keystore password
- Key password
- Your name and organization details

**⚠️ IMPORTANT:** Save these passwords securely!

### 2. Create key.properties
```bash
cat > /home/ahmedvini/Music/VIATRA/mobile/android/key.properties << 'EOF'
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=viatra-key
storeFile=viatra-release-key.jks
EOF
```

### 3. Update build.gradle
The `android/app/build.gradle` needs to reference the keystore.
(Let me know if you want to set this up now)

## Common Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build split APKs (smaller files)
flutter build apk --split-per-abi --release

# Install directly to connected phone
flutter install

# Check APK size
ls -lh build/app/outputs/flutter-apk/

# Find your phone via ADB
adb devices

# Install specific APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Troubleshooting

### "Installation blocked" on phone
- Go to Settings → Security
- Enable "Install from Unknown Sources" or "Allow from this source"

### "App not installed" error
- Uninstall any previous version first
- Make sure you have enough storage space
- Try: `adb uninstall com.viatra.mobile` then install again

### APK is too large
- Use `--split-per-abi` flag
- Remove unused resources
- Check asset sizes

### Phone not detected by ADB
```bash
# Check if phone is connected
adb devices

# Restart ADB server
adb kill-server
adb start-server

# Make sure USB debugging is enabled on phone
```

## Current Build Status

Your app is currently configured to:
- ✅ Use Railway backend URL from .env file
- ✅ Use debug signing for release builds (fine for testing)
- ✅ Include all necessary permissions
- ⚠️ No production signing key yet (needed for Play Store)

## Recommended Workflow

### For Testing (Now):
```bash
cd /home/ahmedvini/Music/VIATRA/mobile
flutter build apk --debug
# Then copy app-debug.apk to your phone
```

### For Sharing with Others:
```bash
cd /home/ahmedvini/Music/VIATRA/mobile
flutter build apk --release
# Share app-release.apk
```

### For Play Store (Later):
1. Set up proper signing (keystore)
2. Build an App Bundle: `flutter build appbundle`
3. Upload to Google Play Console

## APK File Locations

After build, find your APK at:
```
/home/ahmedvini/Music/VIATRA/mobile/build/app/outputs/flutter-apk/

├── app-debug.apk                    (debug build)
├── app-release.apk                  (release build)
├── app-armeabi-v7a-release.apk     (split build - 32-bit ARM)
├── app-arm64-v8a-release.apk       (split build - 64-bit ARM) ⭐
└── app-x86_64-release.apk          (split build - Intel)
```

**For most modern phones, use: `app-arm64-v8a-release.apk`**

## Next Steps

1. **Build debug APK** (already running)
2. **Copy to phone** and install
3. **Test registration** with Railway backend
4. **If everything works**, build release APK
5. **Share with testers** or deploy to Play Store

## Questions?

- Want to set up production signing now? Let me know!
- Need help with Play Store deployment? I can guide you!
- Having installation issues? Share the error message!

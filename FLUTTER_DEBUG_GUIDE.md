# 🚀 Flutter Debugging & Hot Reload Setup Guide for VS Code

## ✅ Prerequisites (Already Installed)
- ✅ Flutter SDK
- ✅ Dart Extension for VS Code
- ✅ Flutter Extension for VS Code
- ✅ Android SDK & Emulator

---

## 📱 How to Start Debugging with Hot Reload

### **Method 1: Using VS Code Debug Panel (Recommended)**

1. **Start an Android Emulator or Connect a Device:**
   ```bash
   # Check available devices
   flutter devices
   
   # Start an emulator (if not running)
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```

2. **Open the Debug Panel:**
   - Press `Ctrl+Shift+D` (or `Cmd+Shift+D` on Mac)
   - Or click the "Run and Debug" icon in the left sidebar

3. **Select Configuration:**
   - Choose "Flutter: Debug (mobile)" from the dropdown
   - Click the green "Play" button (or press `F5`)

4. **Your app will launch with Hot Reload enabled! 🎉**

---

### **Method 2: Using Command Palette**

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Flutter: Launch Emulator"
3. Select your emulator
4. Press `F5` to start debugging

---

### **Method 3: Using Terminal in VS Code**

1. Open terminal in VS Code: `` Ctrl+` ``
2. Navigate to mobile folder:
   ```bash
   cd /home/ahmedvini/Documents/VIATRA/mobile
   ```
3. Run Flutter:
   ```bash
   flutter run
   ```

---

## 🔥 Hot Reload Commands

Once your app is running, you can use these commands:

### **In VS Code Debug Console:**
- `r` - Hot Reload (faster, preserves state)
- `R` - Hot Restart (full restart, resets state)
- `q` - Quit
- `s` - Save screenshot
- `w` - Dump widget hierarchy
- `t` - Dump rendering tree

### **Using Keyboard Shortcuts:**
While debugging is active:
- `Ctrl+F5` - Run without debugging
- `Shift+F5` - Stop debugging
- `Ctrl+Shift+F5` - Hot Restart

### **Auto Hot Reload on Save:**
Your current settings enable **auto hot reload** when you save a file!
- Just save any `.dart` file (`Ctrl+S`)
- The app will automatically hot reload 🔄

---

## 🎯 Quick Start Steps

### **1. Start Android Emulator**
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch Pixel_3a_API_30
```

### **2. Verify Device is Connected**
```bash
flutter devices
```

You should see something like:
```
Android SDK built for x86 (emulator) • emulator-5554 • android-x86 • Android 11 (API 30)
```

### **3. Start Debugging in VS Code**
- Press `F5`
- Or click the green play button in the Debug panel
- Select "Flutter: Debug (mobile)"

### **4. Make Changes & See Hot Reload in Action**
1. Open any `.dart` file in `mobile/lib/`
2. Make a change (e.g., change a text string)
3. Save the file (`Ctrl+S`)
4. Watch your changes appear instantly in the emulator! ⚡

---

## 🛠️ Useful Flutter Commands

```bash
# Check Flutter setup
flutter doctor -v

# List all devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release

# Hot reload manually (when app is running)
# Type 'r' in the terminal

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Build APK
flutter build apk --debug
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle
```

---

## 🐛 Debugging Features in VS Code

### **Breakpoints:**
- Click in the left margin of any line to add a breakpoint (red dot)
- Debug execution will pause at breakpoints
- Inspect variables in the Debug panel

### **Debug Console:**
- View print statements
- Execute Dart expressions
- Inspect widget tree

### **Hot Reload vs Hot Restart:**

**Hot Reload (r):**
- ⚡ Fast (1-2 seconds)
- Preserves app state
- Use for UI changes, fixing bugs
- Best for iterative development

**Hot Restart (R):**
- 🔄 Slower (5-10 seconds)
- Resets all state
- Use when changing app initialization, adding assets, or changing dependencies
- Reloads the entire app

---

## 📊 Monitoring Performance

### **DevTools:**
1. While debugging, open DevTools:
   - Press `Ctrl+Shift+P`
   - Type "Dart: Open DevTools"
   - Or click the link in Debug Console

2. **DevTools Features:**
   - Widget Inspector (view widget tree)
   - Performance profiling
   - Network monitoring
   - Memory usage
   - Logging

---

## 🎨 Tips for Effective Development

1. **Use Hot Reload Frequently:**
   - Save often to see changes instantly
   - No need to rebuild the entire app

2. **Watch the Debug Console:**
   - See print() statements
   - Monitor errors and warnings

3. **Use Breakpoints for Complex Issues:**
   - Pause execution at specific points
   - Inspect variable values

4. **Keep DevTools Open:**
   - Monitor performance in real-time
   - Identify widget rebuild issues

5. **Use Flutter Outline View:**
   - In VS Code, open "Flutter Outline" panel
   - Navigate widget tree easily

---

## 🚨 Troubleshooting

### **App doesn't hot reload:**
```bash
# Try hot restart instead (press 'R')
# Or restart debugging (Shift+F5, then F5)
```

### **"No devices found":**
```bash
# Check if emulator is running
flutter devices

# Start an emulator
flutter emulators --launch <emulator_id>
```

### **Build errors:**
```bash
# Clean and rebuild
cd /home/ahmedvini/Documents/VIATRA/mobile
flutter clean
flutter pub get
flutter run
```

### **Emulator is slow:**
- Use a newer emulator with more RAM
- Enable hardware acceleration
- Or use a physical device instead

---

## 🎯 Your Project Structure

```
/home/ahmedvini/Documents/VIATRA/
├── mobile/              # Main mobile app (ready for debugging!)
│   ├── lib/
│   │   └── main.dart   # Entry point
│   └── android/
└── viatra_app/         # Alternative app version
    └── lib/
        └── main.dart
```

---

## ▶️ Ready to Start!

**Quick Start Command:**
1. Open VS Code in VIATRA folder
2. Press `F5`
3. Select "Flutter: Debug (mobile)"
4. Start coding with hot reload! 🎉

**Happy coding!** 🚀

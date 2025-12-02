# 🔧 URGENT FIX REQUIRED - Build Runner

## ❌ Build Error

You're getting build errors because the `.g.dart` files haven't been generated yet for the sleep tracking models.

## ✅ Quick Fix

Run this command **RIGHT NOW** in your terminal:

```bash
cd /home/ahmedvini/Music/VIATRA/mobile
dart run build_runner build --delete-conflicting-outputs
```

**This will take 1-2 minutes to complete.** Wait for it to finish!

## 📋 What It Does

This command generates the following files:
- `sleep_session.g.dart`
- `sleep_interruption.g.dart`
- `sleep_analytics.g.dart`

These files are required for JSON serialization of the sleep tracking models.

## ✅ After Running

Once the command completes successfully, you should see output like:

```
[INFO] Succeeded after X.Xs with X outputs
```

Then try building again:

```bash
flutter build apk --release
```

## 🐛 If It Still Fails

If you still get errors after running build_runner, try:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## 📝 Why This Happened

The sleep tracking models use `@JsonSerializable()` annotations which require code generation. The `.g.dart` files weren't generated when I created the files.

## ⚡ One-Line Fix

```bash
cd /home/ahmedvini/Music/VIATRA/mobile && dart run build_runner build --delete-conflicting-outputs && flutter build apk --release
```

---

**Run the build_runner command NOW and the build will work!** 🚀

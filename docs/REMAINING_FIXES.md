# FINAL BUILD FIX INSTRUCTIONS

## Remaining Compilation Errors: 36 errors

All errors are straightforward text replacements. Due to terminal command limitations, these need to be applied manually or with a proper IDE find-replace.

---

## 1. health_profile_service.dart (16 errors)

**File:** `lib/services/health_profile_service.dart`

**Find:** `json.decode(response.body)`  
**Replace with:** `response.data`

**Remove these imports:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

---

## 2. health_profile_provider.dart (3 errors)

**File:** `lib/providers/health_profile_provider.dart`

**Lines 92-95, 120-123, 152-155:**

**Find:**
```dart
        await _storageService.setCacheData(
          _cacheKey,
          _healthProfile!.toJson(),
          _cacheDuration,
        );
```

**Replace with:**
```dart
        await _storageService.setCacheData(
          _cacheKey,
          _healthProfile!.toJson(),
          ttl: _cacheDuration,
        );
```

---

## 3. appointment_detail_screen.dart (2 errors)

**File:** `lib/screens/appointments/appointment_detail_screen.dart`

**Line 213:**  
**Find:** `final canCancel = appointment.canBeCancelled();`  
**Replace with:** `final canCancel = appointment.canBeCancelled;`

**Line 214:**  
**Find:** `final canReschedule = appointment.canBeRescheduled();`  
**Replace with:** `final canReschedule = appointment.canBeRescheduled;`

---

## 4. appointment_card.dart (6 errors)

**File:** `lib/widgets/appointments/appointment_card.dart`

**Find all instances of:**
- `.canBeCancelled()` → Replace with `.canBeCancelled`
- `.canBeRescheduled()` → Replace with `.canBeRescheduled`

**Lines affected:** 236 (x2), 240, 251 (x2), 253

---

## 5. health_profile_view_screen.dart (CORRUPTED - needs restore)

**File:** `lib/screens/health_profile/health_profile_view_screen.dart`

### Step 1: Restore from git
```bash
cd /home/ahmedvini/Documents/VIATRA/viatra_app
git checkout lib/screens/health_profile/health_profile_view_screen.dart
```

### Step 2: Fix medications property

**Find (around line 178):**
```dart
                  if (profile.medications != null && profile.medications!.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Current Medications', Icons.medication),
                    const SizedBox(height: 8),
                    ...profile.medications!.map((med) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(med),
                          ),
                        )),
```

**Replace with:**
```dart
                  if (profile.currentMedications.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Current Medications', Icons.medication),
                    const SizedBox(height: 8),
                    ...profile.currentMedications.map((med) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(med.name),
                            subtitle: med.dosage != null ? Text(med.dosage!) : null,
                          ),
                        )),
```

---

## Quick Fix Commands (if terminal works properly):

```bash
cd /home/ahmedvini/Documents/VIATRA/viatra_app

# Fix health_profile_service.dart
sed -i 's/json\.decode(response\.body)/response.data/g' lib/services/health_profile_service.dart
sed -i "/import 'dart:convert';/d" lib/services/health_profile_service.dart
sed -i "/import 'package:http\/http.dart' as http;/d" lib/services/health_profile_service.dart

# Fix health_profile_provider.dart  
sed -i 's/          _cacheDuration,/          ttl: _cacheDuration,/g' lib/providers/health_profile_provider.dart

# Fix appointment files
sed -i 's/\.canBeCancelled()/\.canBeCancelled/g' lib/screens/appointments/appointment_detail_screen.dart
sed -i 's/\.canBeRescheduled()/\.canBeRescheduled/g' lib/screens/appointments/appointment_detail_screen.dart
sed -i 's/\.canBeCancelled()/\.canBeCancelled/g' lib/widgets/appointments/appointment_card.dart
sed -i 's/\.canBeRescheduled()/\.canBeRescheduled/g' lib/widgets/appointments/appointment_card.dart

# Restore and fix health_profile_view_screen.dart
git checkout lib/screens/health_profile/health_profile_view_screen.dart
# Then manually fix the medications section as described above
```

---

## After Fixes, Run:

```bash
cd /home/ahmedvini/Documents/VIATRA/viatra_app
flutter build apk --debug
```

Expected result: **0 compilation errors**, successful APK build.

---

## Notes:

- All these errors are simple find-replace operations
- The core issues are:
  1. `ApiResponse` uses `.data`, not `.body`
  2. `setCacheData` requires named parameter `ttl:`
  3. `canBeCancelled` and `canBeRescheduled` are properties, not methods
  4. `HealthProfile.medications` is actually `currentMedications` of type `List<Medication>`

- Once these are fixed, the app should compile successfully
- The doctor_service.dart file has already been fixed successfully

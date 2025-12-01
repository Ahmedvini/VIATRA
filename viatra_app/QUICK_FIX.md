# Quick Fix Commands - VIATRA Build Errors

## Run these commands in order:

```bash
cd /home/ahmedvini/Documents/VIATRA/viatra_app

# 1. Fix patient.user map access (doctor screens)
find lib/widgets/doctor lib/screens/doctor -name "*.dart" -exec sed -i "s/patient\\.user?\\./patient['user']?./g" {} \;

# 2. Fix appointment boolean properties
find lib/screens/appointments lib/widgets/appointments -name "*.dart" -exec sed -i 's/\\.canBeCancelled()/\.canBeCancelled/g' {} \;
find lib/screens/appointments lib/widgets/appointments -name "*.dart" -exec sed -i 's/\\.canBeRescheduled()/\.canBeRescheduled/g' {} \;

# 3. Fix medications property name
find lib/screens/health_profile -name "*.dart" -exec sed -i 's/\\.medications/\.currentMedications/g' {} \;

# 4. Try build again
flutter build apk --debug 2>&1 | tee build_log.txt | tail -50
```

## Remaining manual fixes needed:
- EmergencyContact/ChronicCondition/Allergy property access (use . not [])
- Provider method calls (createProfile, updateProfile)
- Form type conversions (Map → Model objects)

See BUILD_FIX_PROGRESS.md for details.

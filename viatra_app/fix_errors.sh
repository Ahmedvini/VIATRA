#!/bin/sh

# Fix response.body to response.data in service files
echo "Fixing response.body to response.data..."
sed -i 's/response\.body/response.data/g' lib/services/doctor_service.dart
sed -i 's/response\.body/response.data/g' lib/services/health_profile_service.dart

# Fix setCacheData calls to use named parameter ttl:
echo "Fixing setCacheData calls..."
sed -i 's/setCacheData(\([^,]*\), \([^,]*\), _cacheDuration)/setCacheData(\1, \2, ttl: _cacheDuration)/g' lib/providers/health_profile_provider.dart

# Fix canBeCancelled and canBeRescheduled from methods to properties
echo "Fixing appointment methods to properties..."
sed -i 's/\.canBeCancelled()/.canBeCancelled/g' lib/screens/appointments/appointment_detail_screen.dart
sed -i 's/\.canBeRescheduled()/.canBeRescheduled/g' lib/screens/appointments/appointment_detail_screen.dart
sed -i 's/\.canBeCancelled()/.canBeCancelled/g' lib/widgets/appointments/appointment_card.dart
sed -i 's/\.canBeRescheduled()/.canBeRescheduled/g' lib/widgets/appointments/appointment_card.dart

# Fix medications to currentMedications in health profile edit screen
echo "Fixing medications property..."
sed -i 's/widget\.profile!\.medications?\.join/widget.profile!.currentMedications.map((m) => m.name).join/g' lib/screens/health_profile/health_profile_edit_screen.dart
sed -i 's/join(.*) ?? .*$/join(\x27, \x27);/g' lib/screens/health_profile/health_profile_edit_screen.dart

# Fix medications in health profile view screen
echo "Fixing medications in view screen..."
sed -i 's/profile\.medications != null && profile\.medications!\.isNotEmpty/profile.currentMedications.isNotEmpty/g' lib/screens/health_profile/health_profile_view_screen.dart
sed -i 's/profile\.medications!\.map((med)/profile.currentMedications.map((med)/g' lib/screens/health_profile/health_profile_view_screen.dart
sed -i 's/title: Text(med),/title: Text(med.name),\n                            subtitle: med.dosage != null ? Text(med.dosage!) : null,/g' lib/screens/health_profile/health_profile_view_screen.dart

echo "Fixes applied!"

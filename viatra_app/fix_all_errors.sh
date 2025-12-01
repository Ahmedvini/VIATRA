#!/bin/sh

echo "=== VIATRA Health Platform - Comprehensive Error Fix Script ==="
echo ""

cd /home/ahmedvini/Documents/VIATRA/viatra_app

# 1. Fix navigation service queryParameters
echo "1. Fixing navigation_service.dart queryParameters..."
sed -i 's/queryParameters: queryParameters)/queryParameters: queryParameters ?? {})/g' lib/services/navigation_service.dart

# 2. Fix response.body -> response.data in all services
echo "2. Fixing response.body -> response.data..."
find lib/services -name "*.dart" -exec sed -i 's/response\.body/response.data/g' {} \;

# 3. Fix verification service uploadFile additionalData parameter
echo "3. Fixing verification_service.dart uploadFile parameter..."
sed -i 's/additionalData: formData/data: formData/g' lib/services/verification_service.dart

# 4. Fix health_profile_provider.dart - setCacheData parameter
echo "4. Fixing health_profile_provider.dart..."
sed -i 's/setCacheData(/saveCacheData(/g' lib/providers/health_profile_provider.dart

# 5. Fix patient.user map access patterns
echo "5. Fixing patient.user map access..."
find lib/screens/doctor lib/widgets/doctor -name "*.dart" -exec sed -i "s/patient\.user\['\([^']*\)'\]/patient.user?['\1']/g" {} \;

# 6. Fix appointment.canBeCancelled() -> .canBeCancelled
echo "6. Fixing appointment canBeCancelled/canBeRescheduled..."
find lib/screens/appointments lib/widgets/appointments -name "*.dart" -exec sed -i 's/appointment\.canBeCancelled()/appointment.canBeCancelled/g' {} \;
find lib/screens/appointments lib/widgets/appointments -name "*.dart" -exec sed -i 's/appointment\.canBeRescheduled()/appointment.canBeRescheduled/g' {} \;

# 7. Fix health profile model - medications property
echo "7. Fixing health_profile_model.dart medications property..."
sed -i 's/healthProfile\.medications/healthProfile.currentMedications/g' lib/screens/health_profile/health_profile_view_screen.dart
sed -i 's/healthProfile\.medications/healthProfile.currentMedications/g' lib/screens/health_profile/health_profile_edit_screen.dart

# 8. Fix EmergencyContact constructor calls
echo "8. Fixing EmergencyContact constructor calls..."
find lib/screens/health_profile -name "*_screen.dart" -exec sed -i 's/phone:/phoneNumber:/g' {} \;

# 9. Fix ChronicCondition constructor calls
echo "9. Fixing ChronicCondition constructor calls..."  
find lib/screens/health_profile -name "*_screen.dart" -exec sed -i 's/condition:/name:/g' {} \;
find lib/screens/health_profile -name "*_screen.dart" -exec sed -i 's/diagnosisDate:/diagnosedDate:/g' {} \;

# 10. Fix Allergy constructor - no changes needed, already correct

# 11. Fix constants.dart Map type issues
echo "11. Fixing constants.dart Map types..."
sed -i 's/const Map<String, dynamic>/const Map<String, String>/g' lib/utils/constants.dart

# 12. Fix registration_form_screen.dart parameter issues
echo "12. Fixing registration_form_screen.dart..."
sed -i 's/submittedAt: DateTime.now()/\/\/ submittedAt: DateTime.now()/g' lib/screens/auth/registration_form_screen.dart

# 13. Fix error_widget.dart parameter
echo "13. Fixing error_widget.dart..."
sed -i 's/required this.onRetry/this.onRetry/g' lib/widgets/common/error_widget.dart

echo ""
echo "=== Fix script completed ==="
echo "Running flutter analyze..."
flutter analyze 2>&1 | tee analyze_results.txt | head -50
echo ""
echo "Full results in analyze_results.txt"

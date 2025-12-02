# 🚀 Food Tracking Feature - Developer Quick Reference

## 📱 Navigation Routes

```dart
// Main hub
context.go('/food-tracking');

// View reports
context.go('/food-tracking/report');

// Track options (choose manual/AI)
context.push('/food-tracking/track-options');

// Manual entry form
context.push('/food-tracking/manual-entry');

// AI photo analysis
context.push('/food-tracking/ai-analysis');
```

---

## 🏗️ File Structure

```
mobile/lib/
├── models/food_tracking/
│   ├── food_log.dart              # FoodLog model with JSON serialization
│   └── nutrition_summary.dart     # NutritionSummary for aggregated data
│
├── screens/food_tracking/
│   ├── food_tracking_main_screen.dart     # Hub: Report/Track buttons
│   ├── track_options_screen.dart          # Choose Manual/AI
│   ├── manual_entry_screen.dart           # ✅ Manual nutrition input
│   ├── ai_photo_analysis_screen.dart      # ✅ AI photo analysis
│   └── food_report_screen.dart            # ⏳ Coming in Phase 3
│
├── services/food_tracking/
│   └── food_tracking_service.dart         # ⏳ API service (TODO)
│
├── providers/food_tracking/
│   └── food_tracking_provider.dart        # ⏳ State management (TODO)
│
└── widgets/food_tracking/
    └── (various widgets)                   # ⏳ Reusable components (TODO)
```

---

## 🔌 API Integration (TODO)

### Service Implementation

Create `/mobile/lib/services/food_tracking/food_tracking_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../../models/food_tracking/food_log.dart';

class FoodTrackingService {
  final Dio _dio;
  
  FoodTrackingService(this._dio);
  
  // Create food log
  Future<FoodLog> createFoodLog(Map<String, dynamic> data) async {
    final response = await _dio.post('/food-tracking', data: data);
    return FoodLog.fromJson(response.data);
  }
  
  // Upload image to storage
  Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await _dio.post('/food-tracking/upload-image', data: formData);
    return response.data['imageUrl'];
  }
  
  // Analyze food with AI (Gemini)
  Future<Map<String, dynamic>> analyzeFood({
    required File imageFile,
    String? context,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
      if (context != null) 'context': context,
    });
    final response = await _dio.post('/food-tracking/analyze', data: formData);
    return response.data;
  }
  
  // Get food logs for a date range
  Future<List<FoodLog>> getFoodLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get('/food-tracking', queryParameters: {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });
    return (response.data as List)
        .map((json) => FoodLog.fromJson(json))
        .toList();
  }
  
  // Get nutrition summary
  Future<NutritionSummary> getNutritionSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get('/food-tracking/summary', queryParameters: {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });
    return NutritionSummary.fromJson(response.data);
  }
}
```

### Update Manual Entry Screen

Replace the TODO section in `manual_entry_screen.dart`:

```dart
// Get patient ID from auth
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final patientId = authProvider.user?.id;

if (patientId == null) {
  throw Exception('Patient not authenticated');
}

// Create food log
final foodTrackingService = Provider.of<FoodTrackingService>(context, listen: false);
await foodTrackingService.createFoodLog({
  'patientId': patientId,
  'mealType': _selectedMealType.value,
  'foodName': _foodNameController.text.trim(),
  'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
  'calories': _parseDouble(_caloriesController.text),
  'proteinGrams': _parseDouble(_proteinController.text),
  'carbsGrams': _parseDouble(_carbsController.text),
  'fatGrams': _parseDouble(_fatController.text),
  'fiberGrams': _parseDouble(_fiberController.text),
  'sugarGrams': _parseDouble(_sugarController.text),
  'sodiumMg': _parseDouble(_sodiumController.text),
  'servingSize': _servingSizeController.text.trim().isEmpty ? null : _servingSizeController.text.trim(),
  'servingsCount': double.tryParse(_servingsCountController.text) ?? 1.0,
  'consumedAt': _consumedAt.toIso8601String(),
});
```

### Update AI Analysis Screen

Replace the TODO section in `ai_photo_analysis_screen.dart`:

```dart
// Analyze image
final foodTrackingService = Provider.of<FoodTrackingService>(context, listen: false);
final result = await foodTrackingService.analyzeFood(
  imageFile: _selectedImage!,
  context: _contextController.text.trim(),
);

// Update form with AI results
setState(() {
  _foodNameController.text = result['foodName'] ?? '';
  _caloriesController.text = result['calories']?.toString() ?? '';
  _proteinController.text = result['proteinGrams']?.toString() ?? '';
  _carbsController.text = result['carbsGrams']?.toString() ?? '';
  _fatController.text = result['fatGrams']?.toString() ?? '';
  _fiberController.text = result['fiberGrams']?.toString() ?? '';
  _sugarController.text = result['sugarGrams']?.toString() ?? '';
  _sodiumController.text = result['sodiumMg']?.toString() ?? '';
  _servingSizeController.text = result['servingSize'] ?? '';
  _servingsCountController.text = result['servingsCount']?.toString() ?? '1.0';
  _aiConfidence = result['confidence'];
  _aiRawResponse = result['rawResponse'];
  _isAnalyzed = true;
});
```

```dart
// Save food log with image
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final patientId = authProvider.user?.id;

if (patientId == null) {
  throw Exception('Patient not authenticated');
}

// Upload image first
final foodTrackingService = Provider.of<FoodTrackingService>(context, listen: false);
final imageUrl = await foodTrackingService.uploadImage(_selectedImage!);

// Create food log
await foodTrackingService.createFoodLog({
  'patientId': patientId,
  'mealType': _selectedMealType.value,
  'foodName': _foodNameController.text.trim(),
  'description': _contextController.text.trim().isEmpty ? null : _contextController.text.trim(),
  'imageUrl': imageUrl,
  'calories': _parseDouble(_caloriesController.text),
  'proteinGrams': _parseDouble(_proteinController.text),
  'carbsGrams': _parseDouble(_carbsController.text),
  'fatGrams': _parseDouble(_fatController.text),
  'fiberGrams': _parseDouble(_fiberController.text),
  'sugarGrams': _parseDouble(_sugarController.text),
  'sodiumMg': _parseDouble(_sodiumController.text),
  'servingSize': _servingSizeController.text.trim().isEmpty ? null : _servingSizeController.text.trim(),
  'servingsCount': double.tryParse(_servingsCountController.text) ?? 1.0,
  'consumedAt': _consumedAt.toIso8601String(),
  'aiConfidence': _aiConfidence,
  'aiAnalysis': _aiRawResponse != null ? {'rawResponse': _aiRawResponse} : null,
});
```

---

## 🎨 UI Components Reference

### Color Coding for Macros

```dart
// Calories - Orange
Icon(Icons.local_fire_department, color: Colors.orange)

// Protein - Red
Icon(Icons.fitness_center, color: Colors.red)

// Carbs - Amber
Icon(Icons.cake, color: Colors.amber)

// Fat - Deep Purple
Icon(Icons.opacity, color: Colors.deepPurple)

// Fiber - Brown
Icon(Icons.grain, color: Colors.brown)

// Sugar - Pink
Icon(Icons.cookie, color: Colors.pink)

// Sodium - Blue
Icon(Icons.water_drop, color: Colors.blue)
```

### Meal Type Chips

```dart
MealType.values.map((type) {
  return ChoiceChip(
    label: Text(type.displayName),
    selected: _selectedMealType == type,
    onSelected: (selected) {
      if (selected) setState(() => _selectedMealType = type);
    },
    selectedColor: Colors.blue.withOpacity(0.3),
    avatar: Text(type.emoji),
  );
}).toList()
```

### Date/Time Picker

```dart
Future<void> _selectDateTime() async {
  final date = await showDatePicker(
    context: context,
    initialDate: _consumedAt,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now(),
  );

  if (date != null && mounted) {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_consumedAt),
    );

    if (time != null && mounted) {
      setState(() {
        _consumedAt = DateTime(
          date.year, date.month, date.day,
          time.hour, time.minute,
        );
      });
    }
  }
}
```

---

## 🧪 Testing

### Manual Entry Screen

```dart
// Test navigation
await tester.pumpWidget(MyApp());
await tester.tap(find.text('Food Tracking'));
await tester.pumpAndSettle();
await tester.tap(find.text('Track'));
await tester.pumpAndSettle();
await tester.tap(find.text('Manual Entry'));
await tester.pumpAndSettle();

// Test form validation
await tester.tap(find.text('Save Food Log'));
await tester.pumpAndSettle();
expect(find.text('Please enter Food Name'), findsOneWidget);

// Test filling form
await tester.enterText(find.byType(TextFormField).first, 'Chicken Breast');
await tester.enterText(find.widgetWithText(TextFormField, 'Calories'), '250');
await tester.tap(find.text('Save Food Log'));
await tester.pumpAndSettle();
expect(find.text('Food log saved successfully!'), findsOneWidget);
```

### AI Analysis Screen

```dart
// Test image selection
await tester.tap(find.text('AI Analysis'));
await tester.pumpAndSettle();
await tester.tap(find.byIcon(Icons.add_photo_alternate));
await tester.pumpAndSettle();
await tester.tap(find.text('Camera'));
// Mock image picker...

// Test AI analysis
await tester.tap(find.text('Analyze with AI'));
await tester.pumpAndSettle();
expect(find.text('Analyzing with AI...'), findsOneWidget);
await tester.pumpAndSettle(Duration(seconds: 4));
expect(find.text('AI Confidence:'), findsOneWidget);
```

---

## 📊 Backend API Endpoints

### Required Endpoints:

```
POST   /api/food-tracking              # Create food log
GET    /api/food-tracking              # Get food logs (with date range)
GET    /api/food-tracking/:id          # Get single food log
PUT    /api/food-tracking/:id          # Update food log
DELETE /api/food-tracking/:id          # Delete food log
GET    /api/food-tracking/summary      # Get nutrition summary
POST   /api/food-tracking/analyze      # AI food analysis (Gemini)
POST   /api/food-tracking/upload-image # Upload food image
```

### Expected Response Format:

```json
{
  "id": "uuid",
  "patientId": "uuid",
  "mealType": "lunch",
  "foodName": "Grilled Chicken Salad",
  "description": "With olive oil dressing",
  "imageUrl": "https://storage.googleapis.com/...",
  "calories": 350,
  "proteinGrams": 35,
  "carbsGrams": 15,
  "fatGrams": 18,
  "fiberGrams": 5,
  "sugarGrams": 3,
  "sodiumMg": 450,
  "servingSize": "1 bowl",
  "servingsCount": 1.0,
  "consumedAt": "2024-01-15T12:30:00Z",
  "aiConfidence": 0.87,
  "aiAnalysis": {
    "rawResponse": "AI detected: Grilled chicken breast..."
  },
  "createdAt": "2024-01-15T12:35:00Z",
  "updatedAt": "2024-01-15T12:35:00Z"
}
```

---

## 🔑 Environment Variables

Add to `.env`:

```bash
# Google Cloud
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_CLOUD_STORAGE_BUCKET=your-bucket-name
GEMINI_API_KEY=your-gemini-api-key

# Storage paths
FOOD_IMAGE_STORAGE_PATH=food-images/
```

---

## 🎯 Quick Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Generate code (if using codegen)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Common Issues & Solutions

### Issue: Image picker not working
**Solution:** Add permissions to AndroidManifest.xml and Info.plist

### Issue: Date picker not showing
**Solution:** Ensure Material app is wrapped around the widget

### Issue: Form not validating
**Solution:** Check that _formKey.currentState!.validate() is called

### Issue: Navigation not working
**Solution:** Verify routes are registered in routes.dart

---

**Last Updated:** Phase 2 Complete  
**Next Update:** Phase 3 (Report Screen)

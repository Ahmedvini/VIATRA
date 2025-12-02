# Food Tracking Phase 4 - Quick Developer Guide

## Quick Start

### Mobile: Create Food Log (Manual)
```dart
// Get service
final apiService = context.read<ApiService>();
final foodService = FoodTrackingService(apiService);

// Create log
final foodLog = await foodService.createFoodLog(
  mealType: 'lunch',
  foodName: 'Chicken Salad',
  calories: 350.0,
  proteinGrams: 35.0,
  carbsGrams: 15.0,
  fatGrams: 18.0,
  consumedAt: DateTime.now(),
);
```

### Mobile: Analyze Food Image with AI
```dart
// Get service
final apiService = context.read<ApiService>();
final foodService = FoodTrackingService(apiService);

// Analyze image (auto-saves to database)
final foodLog = await foodService.analyzeFoodImage(
  imageFile: File('/path/to/image.jpg'),
  mealType: 'dinner',
  servingsCount: 1.0,
  consumedAt: DateTime.now(),
);

// Result includes AI-analyzed nutrition data
print('Food: ${foodLog?.foodName}');
print('Calories: ${foodLog?.calories}');
print('Confidence: ${foodLog?.aiConfidence}');
```

### Mobile: Get Food Logs
```dart
// Today's logs
final todayLogs = await foodService.getTodayLogs();

// Last 7 days
final weekLogs = await foodService.getLogsForLastDays(7);

// Custom date range
final logs = await foodService.getFoodLogs(
  startDate: DateTime(2025, 12, 1),
  endDate: DateTime(2025, 12, 7),
  mealType: 'breakfast', // optional filter
  limit: 50,
  offset: 0,
);
```

### Mobile: Get Nutrition Summary
```dart
// Today's summary
final summary = await foodService.getTodaySummary();

// Last 7 days summary
final weekSummary = await foodService.getSummaryForLastDays(7);

// Access summary data
print('Total Calories: ${summary?.totalCalories}');
print('Average Daily: ${summary?.averageDailyCalories}');
print('Protein: ${summary?.totalProtein}g');
```

## Backend API Routes

### All routes require authentication (Bearer token)

```javascript
// Manual Entry
POST /api/health/food
Body: { meal_type, food_name, calories, protein_grams, ... }

// AI Analysis (multipart/form-data)
POST /api/health/food/analyze
Body: { image: File, meal_type, servings_count, consumed_at }

// Get Logs
GET /api/health/food?start_date=<>&end_date=<>&meal_type=<>&limit=50&offset=0

// Get Single Log
GET /api/health/food/:id

// Update Log
PUT /api/health/food/:id
Body: { meal_type, food_name, calories, ... } (any fields)

// Delete Log
DELETE /api/health/food/:id

// Get Summary
GET /api/health/food/summary?start_date=<>&end_date=<>
```

## Gemini AI Prompt

### What Gemini Analyzes
1. All visible food items
2. Estimated portion sizes
3. Complete nutrition breakdown
4. Confidence score (0-1)

### Response Format
```json
{
  "foodName": "Meal name",
  "description": "Detailed description",
  "servingSize": "1 bowl, 350g",
  "nutrition": {
    "calories": 450,
    "protein": 35.5,
    "carbs": 42.0,
    "fat": 18.5,
    "fiber": 6.0,
    "sugar": 5.0,
    "sodium": 450
  },
  "confidence": 0.85,
  "foodItems": [...]
}
```

### Database Mapping
```
Gemini Field          → Database Column
-------------------------------------------
foodName             → food_name
description          → description
servingSize          → serving_size
nutrition.calories   → calories
nutrition.protein    → protein_grams
nutrition.carbs      → carbs_grams
nutrition.fat        → fat_grams
nutrition.fiber      → fiber_grams
nutrition.sugar      → sugar_grams
nutrition.sodium     → sodium_mg
confidence           → ai_confidence
[entire object]      → ai_analysis (JSONB)
```

## Authentication Flow

```
1. User logs in
2. AuthProvider stores token
3. ApiService reads token from AuthProvider
4. ApiService adds "Authorization: Bearer <token>" to all requests
5. Backend auth middleware validates token
6. Backend extracts user ID from token
7. Controller uses req.user.id for patient_id
8. All queries filtered by patient_id automatically
```

## User-Specific Operations

Every CRUD operation is scoped to the authenticated user:

```javascript
// Backend automatically filters by patient_id
const foodLog = await FoodLog.create({
  patient_id: req.user.id,  // From JWT token
  // ... other fields
});

const logs = await FoodLog.findAll({
  where: { patient_id: req.user.id }
});

const log = await FoodLog.findOne({
  where: { id, patient_id: req.user.id }
});
```

**Users CANNOT access other users' data.**

## No Validation

As per requirements:
- No field validation on backend
- No form validation on mobile (except required fields)
- All nutrition fields optional
- Can save with any values or 0s

## Error Handling

### Mobile
```dart
final foodLog = await foodService.createFoodLog(...);

if (foodLog != null) {
  // Success
  print('Food log created: ${foodLog.id}');
} else {
  // Failed
  print('Failed to create food log');
}
```

### Backend
```javascript
// Success
res.status(201).json({
  success: true,
  message: 'Food log created',
  data: foodLog
});

// Error
res.status(500).json({
  success: false,
  message: 'Failed to create food log',
  error: error.message
});
```

## Common Code Snippets

### Initialize Service (Mobile)
```dart
// In a widget with Provider context
final apiService = context.read<ApiService>();
final foodService = FoodTrackingService(apiService);
```

### Update Food Log
```dart
final updated = await foodService.updateFoodLog(
  id: 'log-id',
  calories: 400.0,  // Only update calories
);
```

### Delete Food Log
```dart
final success = await foodService.deleteFoodLog('log-id');
if (success) {
  print('Deleted successfully');
}
```

### Get Specific Date Logs
```dart
final date = DateTime(2025, 12, 1);
final logs = await foodService.getLogsForDate(date);
```

## File Locations

### Backend
- Controller: `/backend/src/controllers/foodTrackingController.js`
- Gemini Service: `/backend/src/services/gemini/geminiService.js`
- Routes: `/backend/src/routes/foodTracking.js`
- Model: `/backend/src/models/FoodLog.js`

### Mobile
- Service: `/mobile/lib/services/food_tracking_service.dart`
- FoodLog Model: `/mobile/lib/models/food_tracking/food_log.dart`
- NutritionSummary Model: `/mobile/lib/models/food_tracking/nutrition_summary.dart`
- Manual Entry: `/mobile/lib/screens/food_tracking/manual_entry_screen.dart`
- AI Analysis: `/mobile/lib/screens/food_tracking/ai_photo_analysis_screen.dart`
- Report: `/mobile/lib/screens/food_tracking/food_report_screen.dart`

## Environment Variables (Backend)

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

Required for AI food analysis to work.

## Testing Checklist

- [ ] Manual entry creates log
- [ ] AI analysis creates log with image
- [ ] Get logs returns user-specific data
- [ ] Summary calculates correctly
- [ ] Update modifies existing log
- [ ] Delete removes log
- [ ] User A cannot see User B's logs
- [ ] Invalid token returns 401
- [ ] Gemini returns valid nutrition data

## Troubleshooting

**"Token expired"**
→ User needs to re-authenticate

**"AI analysis returns 0 calories"**
→ Image unclear or Gemini couldn't identify food, retry with better image

**"Cannot read user ID"**
→ Auth middleware not working, check token in request headers

**"CORS error"**
→ Backend CORS configuration, add mobile app origin to allowed origins

## Performance Tips

1. Use pagination for large date ranges
2. Cache today's summary
3. Compress images before upload
4. Add database indexes on `consumed_at` and `patient_id`
5. Consider CDN for image storage

## Next Steps

1. Test all endpoints with Postman/Thunder Client
2. Test mobile app end-to-end
3. Monitor Gemini accuracy and adjust prompt
4. Add more nutrition fields if needed
5. Implement offline support (future)

---

**Phase 4 Complete**: Full API integration with authenticated CRUD operations and Gemini AI analysis.

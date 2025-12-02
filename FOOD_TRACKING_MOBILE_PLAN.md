# 🍎 Food Tracking Feature - Mobile App Implementation Plan

## 📱 App Structure

```
Patient Home
    ↓
Food Tracking (Main)
    ↓
    ├── 📊 Report (Detailed nutrition report)
    │   ├── Daily summary
    │   ├── Weekly/Monthly charts
    │   ├── Meal breakdown
    │   ├── Nutrition trends
    │   └── Export PDF option
    │
    └── 📝 Track (Log food)
        ├── ✍️ Manual Entry
        │   ├── Meal type selection
        │   ├── Food name input
        │   ├── Manual macro input (calories, protein, carbs, fat, etc.)
        │   ├── Serving size input
        │   └── Time/date picker
        │
        └── 🤖 AI Analysis (Photo)
            ├── Camera/Gallery picker
            ├── Take/select food photo
            ├── Optional context text input
            ├── AI analysis (Gemini)
            ├── Review & edit results
            └── Save to database
```

---

## 🎨 Screen Designs

### 1. **Food Tracking Main Screen**
- Two large card buttons:
  - 📊 **Report** - View nutrition reports
  - 📝 **Track** - Log new food

### 2. **Track Options Screen**
- Two options:
  - ✍️ **Manual Entry** - Type macros manually
  - 🤖 **AI Analysis** - Take photo for AI analysis

### 3. **Manual Entry Screen**
- Form with fields:
  - Meal type (breakfast/lunch/dinner/snack)
  - Food name
  - Calories
  - Protein (g)
  - Carbs (g)
  - Fat (g)
  - Fiber (g)
  - Sugar (g)
  - Sodium (mg)
  - Serving size
  - Servings count
  - Date/time consumed

### 4. **AI Photo Analysis Screen**
- Camera/Gallery button
- Image preview
- Optional context text field
- "Analyze" button
- Loading indicator during AI analysis
- Results preview with editable fields
- "Save" button

### 5. **Report Screen**
- Date range selector
- Summary cards:
  - Total calories
  - Total protein/carbs/fat
  - Average daily intake
- Charts:
  - Daily calorie trend
  - Macro distribution pie chart
  - Meal breakdown bar chart
- Meal history list
- Export PDF button

---

## 📂 File Structure

```
mobile/lib/
├── features/
│   └── food_tracking/
│       ├── screens/
│       │   ├── food_tracking_main_screen.dart          # Main hub (Report/Track)
│       │   ├── track_options_screen.dart               # Manual/AI options
│       │   ├── manual_entry_screen.dart                # Manual macro input
│       │   ├── ai_photo_analysis_screen.dart           # AI photo analysis
│       │   ├── food_report_screen.dart                 # Detailed reports
│       │   └── food_log_detail_screen.dart             # View/edit single log
│       ├── widgets/
│       │   ├── meal_type_selector.dart
│       │   ├── nutrition_input_field.dart
│       │   ├── food_log_card.dart
│       │   ├── nutrition_summary_card.dart
│       │   ├── calorie_chart.dart
│       │   ├── macro_pie_chart.dart
│       │   └── meal_breakdown_chart.dart
│       ├── models/
│       │   └── food_log.dart
│       ├── services/
│       │   ├── food_tracking_service.dart              # API calls
│       │   └── gemini_service.dart                     # AI analysis
│       └── providers/
│           └── food_tracking_provider.dart             # State management
```

---

## 🔌 API Endpoints to Use

### From Backend:

```dart
// Analyze food with AI
POST /api/food-tracking/analyze
  - image: File
  - meal_type: String
  - consumed_at: DateTime
  - context: String (optional)

// Get all food logs
GET /api/food-tracking
  - start_date: DateTime
  - end_date: DateTime
  - meal_type: String (optional)

// Get single food log
GET /api/food-tracking/:id

// Create food log manually
POST /api/food-tracking/manual
  - meal_type: String
  - food_name: String
  - calories: double
  - protein_grams: double
  - carbs_grams: double
  - fat_grams: double
  - fiber_grams: double
  - sugar_grams: double
  - sodium_mg: double
  - serving_size: String
  - servings_count: double
  - consumed_at: DateTime

// Update food log
PUT /api/food-tracking/:id

// Delete food log
DELETE /api/food-tracking/:id

// Get nutrition summary
GET /api/food-tracking/summary
  - start_date: DateTime
  - end_date: DateTime
```

---

## 📦 Required Packages

Add to `mobile/pubspec.yaml`:

```yaml
dependencies:
  # Image handling
  image_picker: ^1.0.4
  camera: ^0.10.5+5
  image_cropper: ^5.0.1
  
  # Charts
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.7
  
  # Date/Time
  intl: ^0.18.1
  table_calendar: ^3.0.9
  
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # PDF Generation
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # File handling
  path_provider: ^2.1.1
  
  # UI Enhancements
  shimmer: ^3.0.0
  lottie: ^2.7.0
  flutter_animate: ^4.3.0
```

---

## 🎯 Implementation Steps

### Phase 1: Setup & Models ✅
1. Create food_log model
2. Set up API service
3. Configure image picker

### Phase 2: Manual Entry 📝
1. Create manual entry screen
2. Form validation
3. API integration
4. Success feedback

### Phase 3: AI Photo Analysis 🤖
1. Camera/gallery integration
2. Image preview & cropping
3. Gemini API integration
4. Results preview & editing
5. Save to database

### Phase 4: Reports & Analytics 📊
1. Fetch food logs from API
2. Calculate summaries
3. Create charts (calories, macros)
4. Date range filtering
5. PDF export

### Phase 5: UI/UX Polish ✨
1. Loading states
2. Error handling
3. Offline support
4. Animations
5. Dark mode support

---

## 🎨 Design Specifications

### Colors:
```dart
// Food Tracking Theme
const Color primaryGreen = Color(0xFF4CAF50);
const Color accentOrange = Color(0xFFFF9800);
const Color lightGreen = Color(0xFFE8F5E9);
const Color darkGreen = Color(0xFF388E3C);
const Color caloriesColor = Color(0xFFFF6B6B);
const Color proteinColor = Color(0xFF4ECDC4);
const Color carbsColor = Color(0xFFFFA07A);
const Color fatColor = Color(0xFF95E1D3);
```

### Typography:
```dart
// Headings
TextStyle heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

// Body
TextStyle bodyText = TextStyle(fontSize: 16);
TextStyle captionText = TextStyle(fontSize: 14, color: Colors.grey);
```

---

## 🔐 Security Considerations

1. **Authentication**: All API calls include JWT token
2. **Data Privacy**: Only show user's own food logs
3. **Image Storage**: Upload to Google Cloud Storage securely
4. **Input Validation**: Validate all user inputs
5. **Error Handling**: Handle API errors gracefully

---

## 📊 Sample Data Flow

### Manual Entry:
```
User fills form → Validate inputs → POST to API → Success → Show confirmation → Navigate back
```

### AI Photo:
```
User takes photo → Upload image → POST to /analyze → Gemini processes → Return nutrition data → User reviews → Edit if needed → Save → Success
```

### Reports:
```
User opens reports → Select date range → GET /food-tracking → Process data → Calculate summaries → Render charts → Display
```

---

## 🎯 Next Steps

I'll now create:
1. ✅ Food tracking models
2. ✅ API service layer
3. ✅ Main food tracking screen
4. ✅ Manual entry screen
5. ✅ AI photo analysis screen
6. ✅ Report screen with charts
7. ✅ All supporting widgets

Ready to implement? Let me know and I'll start creating the Flutter code! 🚀

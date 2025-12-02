# AI Health Tracking System Implementation Plan

**Feature:** AI-Powered Patient Health Tracking with Gemini Integration  
**Date:** December 2, 2025  
**AI Model:** Google Gemini Pro Vision

## 🎯 Feature Requirements

### 1. Food Tracking (AI-Powered)
- **Photo Upload:** Take/upload food photo
- **AI Analysis (Gemini Vision):**
  - Identify food types
  - Estimate calories per item
  - Calculate macronutrients:
    - Carbohydrates (g + %)
    - Fats (g + %)
    - Proteins (g + %)
    - Fruits (g + %)
    - Vegetables (g + %)
- **Database:** Store meals with:
  - Photo URL
  - Food items detected
  - Nutritional breakdown
  - Timestamp
  - Meal type (breakfast/lunch/dinner/snack)

### 2. Sleep Tracking
- **Recorder Features:**
  - Start sleep session
  - Pause (temporary interruption)
  - Resume (continue sleep)
  - End (complete session)
- **Manual Logging:**
  - Wake-up events during sleep
  - Sleep quality rating
  - Dreams/notes
- **Database:** Store:
  - Sleep start/end times
  - Total duration
  - Interruptions (wake-ups)
  - Sleep cycles estimation
  - Quality metrics

### 3. Health Metrics
- **Weight Tracker:**
  - Manual weight entry
  - Date/time stamped
  - BMI calculation
  - Weight trend graphs

- **Water Intake:**
  - Quick add buttons (glass/bottle sizes)
  - Manual ml/oz entry
  - Daily goal tracking
  - Hydration reminders

- **Allergies:**
  - Add/edit/delete allergies
  - Severity levels
  - Reaction notes

- **Chronic Diseases:**
  - Add/edit/delete conditions
  - Medication tracking
  - Symptom logging

### 4. Dashboard & Reports
- **Time Periods:**
  - Daily view
  - Weekly summary
  - Monthly overview

- **Visualizations:**
  - Food: Pie charts (macro %), line graphs (calories over time)
  - Sleep: Bar charts (duration), line graphs (quality trend)
  - Weight: Line graph with trend
  - Water: Progress bar, daily achievement

- **Insights:**
  - AI-generated health insights
  - Pattern detection
  - Recommendations

## 🏗️ Implementation Structure

### Backend (`/backend/src/`)

```
services/
  ├── gemini/
  │   ├── geminiService.js         # Gemini API integration
  │   └── foodAnalysisService.js   # Food analysis logic
  
models/
  ├── FoodLog.js                   # Food entries
  ├── SleepLog.js                  # Sleep sessions
  ├── WeightLog.js                 # Weight entries
  ├── WaterLog.js                  # Water intake
  ├── Allergy.js                   # Patient allergies
  ├── ChronicDisease.js            # Chronic conditions
  
controllers/
  ├── healthTracking/
  │   ├── foodController.js        # Food tracking endpoints
  │   ├── sleepController.js       # Sleep tracking endpoints
  │   ├── metricsController.js     # Weight, water, etc.
  │   ├── dashboardController.js   # Analytics & reports
  
routes/
  └── healthTracking.js            # All health tracking routes
```

### Mobile (`/mobile/lib/`)

```
services/
  ├── gemini_service.dart          # Gemini API client
  ├── food_tracking_service.dart   # Food API calls
  ├── sleep_tracking_service.dart  # Sleep API calls
  ├── health_metrics_service.dart  # Metrics API calls

models/
  ├── food_log_model.dart
  ├── sleep_log_model.dart
  ├── weight_log_model.dart
  ├── water_log_model.dart
  ├── allergy_model.dart
  ├── chronic_disease_model.dart
  ├── nutrition_info_model.dart

providers/
  ├── food_tracking_provider.dart
  ├── sleep_tracking_provider.dart
  ├── health_metrics_provider.dart
  ├── dashboard_provider.dart

screens/
  └── health_tracking/
      ├── dashboard_screen.dart           # Main dashboard
      ├── food/
      │   ├── food_camera_screen.dart     # Take photo
      │   ├── food_analysis_screen.dart   # Show AI results
      │   ├── food_log_screen.dart        # Food history
      │   └── food_detail_screen.dart     # Single meal detail
      ├── sleep/
      │   ├── sleep_recorder_screen.dart  # Active recording
      │   ├── sleep_log_screen.dart       # Sleep history
      │   └── sleep_detail_screen.dart    # Single session detail
      ├── metrics/
      │   ├── weight_tracker_screen.dart
      │   ├── water_tracker_screen.dart
      │   ├── allergies_screen.dart
      │   └── chronic_diseases_screen.dart
      └── reports/
          ├── daily_report_screen.dart
          ├── weekly_report_screen.dart
          └── monthly_report_screen.dart

widgets/
  └── health_tracking/
      ├── nutrition_pie_chart.dart
      ├── sleep_chart.dart
      ├── weight_line_chart.dart
      ├── water_progress_widget.dart
      └── meal_card_widget.dart
```

## 📦 Required Dependencies

### Backend
```json
{
  "@google/generative-ai": "^0.1.3",  // Gemini SDK
  "sharp": "^0.33.0",                  // Image processing
  "multer": "^1.4.5-lts.1"            // File upload
}
```

### Mobile
```yaml
dependencies:
  google_generative_ai: ^0.2.0  # Gemini SDK
  camera: ^0.10.5                # Camera access
  image_picker: ^1.0.5           # Photo picker
  fl_chart: ^0.66.0              # Charts
  syncfusion_flutter_charts: ^24.1.41  # Advanced charts
  intl: ^0.18.0                  # Date formatting
```

## 🔐 API Keys Required

1. **Google Gemini API Key**
   - Get from: https://makersuite.google.com/app/apikey
   - Add to `.env`: `GEMINI_API_KEY=your_key_here`

2. **Google Cloud Storage** (for food photos)
   - Already configured for document uploads

## 📊 Database Schema

### Food Log
```sql
CREATE TABLE food_logs (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES users(id),
  photo_url VARCHAR(500),
  meal_type VARCHAR(50), -- breakfast, lunch, dinner, snack
  total_calories DECIMAL(10,2),
  carbs_grams DECIMAL(10,2),
  carbs_percentage DECIMAL(5,2),
  fats_grams DECIMAL(10,2),
  fats_percentage DECIMAL(5,2),
  proteins_grams DECIMAL(10,2),
  proteins_percentage DECIMAL(5,2),
  fruits_grams DECIMAL(10,2),
  fruits_percentage DECIMAL(5,2),
  vegetables_grams DECIMAL(10,2),
  vegetables_percentage DECIMAL(5,2),
  food_items JSONB, -- Array of detected items
  ai_analysis_raw JSONB, -- Full Gemini response
  notes TEXT,
  logged_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Sleep Log
```sql
CREATE TABLE sleep_logs (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES users(id),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  total_duration_minutes INTEGER,
  status VARCHAR(20), -- active, paused, completed
  quality_rating INTEGER, -- 1-5
  interruptions JSONB, -- Array of wake-up events
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Weight Log
```sql
CREATE TABLE weight_logs (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES users(id),
  weight_kg DECIMAL(5,2),
  bmi DECIMAL(4,2),
  notes TEXT,
  logged_at TIMESTAMP DEFAULT NOW()
);
```

### Water Log
```sql
CREATE TABLE water_logs (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES users(id),
  amount_ml INTEGER,
  logged_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 Implementation Phases

### Phase 1: Backend Setup (Day 1-2)
- [ ] Install Gemini SDK
- [ ] Create database migrations
- [ ] Implement Gemini service
- [ ] Create models and controllers
- [ ] Set up routes and middleware

### Phase 2: Food Tracking (Day 3-4)
- [ ] Backend food analysis endpoint
- [ ] Mobile camera integration
- [ ] AI analysis screen
- [ ] Food log list and details

### Phase 3: Sleep Tracking (Day 5-6)
- [ ] Backend sleep endpoints
- [ ] Mobile recorder UI
- [ ] Sleep timer logic
- [ ] Sleep log and history

### Phase 4: Health Metrics (Day 7-8)
- [ ] Weight tracker
- [ ] Water tracker
- [ ] Allergies management
- [ ] Chronic diseases management

### Phase 5: Dashboard & Reports (Day 9-10)
- [ ] Dashboard UI with all widgets
- [ ] Chart implementations
- [ ] Daily/Weekly/Monthly reports
- [ ] AI insights generation

### Phase 6: Testing & Polish (Day 11-12)
- [ ] End-to-end testing
- [ ] UI/UX refinements
- [ ] Performance optimization
- [ ] Documentation

## 💡 AI Prompt Examples

### Food Analysis Prompt
```
Analyze this food image and provide:
1. List of food items identified
2. Estimated portion sizes in grams
3. Estimated calories per item and total
4. Nutritional breakdown:
   - Carbohydrates (grams and percentage)
   - Fats (grams and percentage)
   - Proteins (grams and percentage)
   - Fruits (grams and percentage)
   - Vegetables (grams and percentage)

Format response as JSON.
```

### Sleep Quality Insights Prompt
```
Based on sleep data:
- Duration: X hours
- Interruptions: Y times
- Pattern: [daily data]

Provide insights on sleep quality and recommendations.
```

## 📈 Success Metrics

1. **Food Tracking:**
   - AI accuracy > 80% for common foods
   - Photo-to-analysis < 5 seconds
   - User satisfaction with calorie estimates

2. **Sleep Tracking:**
   - Easy start/stop/pause UX
   - Accurate duration tracking
   - Useful insights generation

3. **Overall:**
   - Daily active users tracking
   - Feature adoption rate
   - User retention

## 🔄 Future Enhancements

1. Barcode scanning for packaged foods
2. Recipe suggestions based on nutritional goals
3. Integration with fitness trackers
4. Social features (share progress)
5. Gamification (achievements, streaks)
6. Voice input for quick logging
7. Medication reminders linked to chronic diseases
8. Export health data (PDF reports)

---

**Status:** Ready to implement  
**Estimated Timeline:** 12 days for full implementation  
**Priority:** High (Patient-facing feature)

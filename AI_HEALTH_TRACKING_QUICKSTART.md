# 🚀 AI Health Tracking - Quick Start Guide

**Status:** Foundation Ready, Implementation in Progress  
**Estimated Time:** 12-14 days for full implementation  
**AI Model:** Google Gemini Pro Vision

## ✅ What's Done

1. ✅ **Complete Implementation Plan** (`AI_HEALTH_TRACKING_PLAN.md`)
   - Feature requirements documented
   - Database schema designed
   - File structure planned
   - Dependencies identified

2. ✅ **Gemini Service** (`backend/src/services/gemini/geminiService.js`)
   - Food image analysis
   - Sleep insights generation
   - Dashboard insights generation
   - Error handling

3. ✅ **Dependencies Added** (`backend/package.json`)
   - `@google/generative-ai` - Gemini SDK
   - `sharp` - Image processing

## 🎯 Next Steps to Implement

### Step 1: Get Gemini API Key (5 minutes)

1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google account
3. Click "Get API Key" → "Create API key in new project"
4. Copy the key

5. Add to `/backend/.env`:
```env
GEMINI_API_KEY=your_api_key_here
```

### Step 2: Install Backend Dependencies

```bash
cd /home/ahmedvini/Music/VIATRA/backend
npm install
# This will install @google/generative-ai and sharp
```

### Step 3: Create Database Migrations

Create these migration files in `/backend/src/migrations/`:

**1. `XXXXXX-create-food-logs.js`** - Food tracking table
**2. `XXXXXX-create-sleep-logs.js`** - Sleep tracking table  
**3. `XXXXXX-create-weight-logs.js`** - Weight tracking table
**4. `XXXXXX-create-water-logs.js`** - Water intake table
**5. `XXXXXX-create-allergies.js`** - Allergies table
**6. `XXXXXX-create-chronic-diseases.js`** - Chronic diseases table

Example migration (food_logs):

```javascript
export const up = async (queryInterface, Sequelize) => {
  await queryInterface.createTable('food_logs', {
    id: {
      type: Sequelize.UUID,
      defaultValue: Sequelize.UUIDV4,
      primaryKey: true,
    },
    patient_id: {
      type: Sequelize.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    photo_url: {
      type: Sequelize.STRING(500),
    },
    meal_type: {
      type: Sequelize.ENUM('breakfast', 'lunch', 'dinner', 'snack'),
      allowNull: false,
    },
    total_calories: {
      type: Sequelize.DECIMAL(10, 2),
    },
    carbs_grams: Sequelize.DECIMAL(10, 2),
    carbs_percentage: Sequelize.DECIMAL(5, 2),
    fats_grams: Sequelize.DECIMAL(10, 2),
    fats_percentage: Sequelize.DECIMAL(5, 2),
    proteins_grams: Sequelize.DECIMAL(10, 2),
    proteins_percentage: Sequelize.DECIMAL(5, 2),
    fruits_grams: Sequelize.DECIMAL(10, 2),
    fruits_percentage: Sequelize.DECIMAL(5, 2),
    vegetables_grams: Sequelize.DECIMAL(10, 2),
    vegetables_percentage: Sequelize.DECIMAL(5, 2),
    food_items: {
      type: Sequelize.JSONB,
    },
    ai_analysis_raw: {
      type: Sequelize.JSONB,
    },
    notes: Sequelize.TEXT,
    logged_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
    created_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
    updated_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
  });

  await queryInterface.addIndex('food_logs', ['patient_id']);
  await queryInterface.addIndex('food_logs', ['logged_at']);
};

export const down = async (queryInterface) => {
  await queryInterface.dropTable('food_logs');
};
```

Run migrations:
```bash
cd /home/ahmedvini/Music/VIATRA/backend
npm run db:migrate
```

### Step 4: Create Models

Create Sequelize models in `/backend/src/models/`:

- `FoodLog.js`
- `SleepLog.js`
- `WeightLog.js`
- `WaterLog.js`
- `Allergy.js`
- `ChronicDisease.js`

### Step 5: Create Controllers

Create controllers in `/backend/src/controllers/healthTracking/`:

- `foodController.js` - Food tracking endpoints
- `sleepController.js` - Sleep tracking endpoints
- `metricsController.js` - Weight, water, allergies, chronic diseases
- `dashboardController.js` - Analytics and reports

### Step 6: Create Routes

Create `/backend/src/routes/healthTracking.js`:

```javascript
import express from 'express';
import foodController from '../controllers/healthTracking/foodController.js';
import sleepController from '../controllers/healthTracking/sleepController.js';
import metricsController from '../controllers/healthTracking/metricsController.js';
import dashboardController from '../controllers/healthTracking/dashboardController.js';
import { authenticate } from '../middleware/auth.js';
import upload from '../middleware/upload.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Food Tracking
router.post('/food/analyze', upload.single('photo'), foodController.analyzeFood);
router.get('/food', foodController.getFoodLogs);
router.get('/food/:id', foodController.getFoodLog);
router.put('/food/:id', foodController.updateFoodLog);
router.delete('/food/:id', foodController.deleteFoodLog);

// Sleep Tracking
router.post('/sleep/start', sleepController.startSleep);
router.post('/sleep/:id/pause', sleepController.pauseSleep);
router.post('/sleep/:id/resume', sleepController.resumeSleep);
router.post('/sleep/:id/end', sleepController.endSleep);
router.post('/sleep/:id/wake-up', sleepController.logWakeUp);
router.get('/sleep', sleepController.getSleepLogs);
router.get('/sleep/:id', sleepController.getSleepLog);

// Health Metrics
router.post('/weight', metricsController.logWeight);
router.get('/weight', metricsController.getWeightLogs);
router.post('/water', metricsController.logWater);
router.get('/water', metricsController.getWaterLogs);
router.post('/allergies', metricsController.addAllergy);
router.get('/allergies', metricsController.getAllergies);
router.delete('/allergies/:id', metricsController.deleteAllergy);
router.post('/chronic-diseases', metricsController.addChronicDisease);
router.get('/chronic-diseases', metricsController.getChronicDiseases);
router.delete('/chronic-diseases/:id', metricsController.deleteChronicDisease);

// Dashboard & Reports
router.get('/dashboard', dashboardController.getDashboard);
router.get('/reports/daily', dashboardController.getDailyReport);
router.get('/reports/weekly', dashboardController.getWeeklyReport);
router.get('/reports/monthly', dashboardController.getMonthlyReport);

export default router;
```

Register in `/backend/src/routes/index.js`:
```javascript
import healthTrackingRoutes from './healthTracking.js';
// ...
app.use('/api/health-tracking', healthTrackingRoutes);
```

### Step 7: Mobile App Dependencies

Add to `/mobile/pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # AI Health Tracking
  google_generative_ai: ^0.2.0
  camera: ^0.10.5
  fl_chart: ^0.66.0
  syncfusion_flutter_charts: ^24.1.41
```

Run:
```bash
cd /home/ahmedvini/Music/VIATRA/mobile
flutter pub get
```

### Step 8: Create Mobile Services

Create services in `/mobile/lib/services/`:

- `gemini_service.dart` - Gemini API client (optional, backend handles this)
- `food_tracking_service.dart` - Food API calls
- `sleep_tracking_service.dart` - Sleep API calls
- `health_metrics_service.dart` - Metrics API calls

### Step 9: Create Mobile Models

Create models in `/mobile/lib/models/`:

- `food_log_model.dart`
- `sleep_log_model.dart`
- `weight_log_model.dart`
- `water_log_model.dart`
- `allergy_model.dart`
- `chronic_disease_model.dart`
- `nutrition_info_model.dart`

### Step 10: Create Mobile Providers

Create providers in `/mobile/lib/providers/`:

- `food_tracking_provider.dart`
- `sleep_tracking_provider.dart`
- `health_metrics_provider.dart`
- `dashboard_provider.dart`

### Step 11: Create Mobile Screens

Create screens in `/mobile/lib/screens/health_tracking/`:

**Dashboard:**
- `dashboard_screen.dart` - Main dashboard with all metrics

**Food Tracking:**
- `food/food_camera_screen.dart` - Take/select photo
- `food/food_analysis_screen.dart` - Show AI analysis results
- `food/food_log_screen.dart` - Food history
- `food/food_detail_screen.dart` - Single meal detail

**Sleep Tracking:**
- `sleep/sleep_recorder_screen.dart` - Active recording UI
- `sleep/sleep_log_screen.dart` - Sleep history
- `sleep/sleep_detail_screen.dart` - Single session detail

**Metrics:**
- `metrics/weight_tracker_screen.dart`
- `metrics/water_tracker_screen.dart`
- `metrics/allergies_screen.dart`
- `metrics/chronic_diseases_screen.dart`

**Reports:**
- `reports/daily_report_screen.dart`
- `reports/weekly_report_screen.dart`
- `reports/monthly_report_screen.dart`

### Step 12: Create Mobile Widgets

Create reusable widgets in `/mobile/lib/widgets/health_tracking/`:

- `nutrition_pie_chart.dart` - Macro breakdown pie chart
- `sleep_chart.dart` - Sleep duration bar chart
- `weight_line_chart.dart` - Weight trend line chart
- `water_progress_widget.dart` - Water intake progress
- `meal_card_widget.dart` - Food log card
- `sleep_session_card.dart` - Sleep session card

## 📝 Implementation Priority

### Phase 1: Foundation (Days 1-2)
- ✅ Implementation plan
- ✅ Gemini service
- [ ] Database migrations
- [ ] Models
- [ ] Basic routes

### Phase 2: Food Tracking (Days 3-5)
- [ ] Backend food controller
- [ ] Mobile camera integration
- [ ] Food analysis screen
- [ ] Food log list

### Phase 3: Sleep Tracking (Days 6-7)
- [ ] Backend sleep controller
- [ ] Mobile recorder UI
- [ ] Sleep timer logic
- [ ] Sleep history

### Phase 4: Health Metrics (Days 8-9)
- [ ] Weight tracker
- [ ] Water tracker
- [ ] Allergies/diseases management

### Phase 5: Dashboard (Days 10-11)
- [ ] Dashboard UI
- [ ] Charts implementation
- [ ] Reports

### Phase 6: Polish (Days 12-14)
- [ ] Testing
- [ ] Bug fixes
- [ ] UI/UX improvements
- [ ] Documentation

## 🧪 Testing the Gemini Service

Create a test script `/backend/test-gemini.js`:

```javascript
import geminiService from './src/services/gemini/geminiService.js';
import fs from 'fs';
import path from 'path';

async function testFoodAnalysis() {
  try {
    // Load a test image
    const imagePath = path.join(process.cwd(), 'test-food.jpg');
    const imageBuffer = fs.readFileSync(imagePath);
    
    console.log('Analyzing food image...');
    const result = await geminiService.analyzeFoodImage(imageBuffer, 'image/jpeg');
    
    console.log('Analysis Result:');
    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error('Error:', error.message);
  }
}

testFoodAnalysis();
```

Run:
```bash
cd /home/ahmedvini/Music/VIATRA/backend
node test-gemini.js
```

## 📚 Resources

### Documentation
- Gemini API: https://ai.google.dev/docs
- Google Generative AI SDK: https://www.npmjs.com/package/@google/generative-ai
- FL Chart (Flutter): https://pub.dev/packages/fl_chart
- Camera Plugin: https://pub.dev/packages/camera

### Example Prompts

**Food Analysis:**
```
Analyze this plate: 
- 200g grilled chicken breast
- 150g steamed broccoli
- 100g brown rice

Expected response:
- Total calories: ~450 kcal
- Protein: 45g (40%)
- Carbs: 40g (35%)
- Fats: 12g (25%)
```

**Sleep Insights:**
```
Sleep: 7.5 hours
Interruptions: 2
Pattern: Consistent 7-8 hours

Expected insights:
- Quality: Good
- Recommendations: Maintain schedule
- Score: 80/100
```

## ⚠️ Important Notes

1. **API Costs:** Gemini has usage limits. Monitor at https://makersuite.google.com/
2. **Image Size:** Compress images before sending to API (use Sharp)
3. **Rate Limiting:** Implement rate limits to prevent abuse
4. **Privacy:** Food photos may contain personal data - handle securely
5. **Accuracy:** AI estimates are approximate - add disclaimers

## 🎨 UI/UX Recommendations

1. **Onboarding:** Explain what each tracker does
2. **Quick Actions:** FABs for common actions (log water, start sleep)
3. **Visual Feedback:** Show AI analyzing with loading animations
4. **Gamification:** Streaks, achievements for consistent tracking
5. **Notifications:** Reminders to log meals, drink water, go to sleep

## ✅ Success Criteria

- [ ] Food photo → AI analysis → Saved to DB < 10 seconds
- [ ] Sleep recorder works reliably (no crashes)
- [ ] Dashboard loads < 2 seconds
- [ ] Charts render smoothly
- [ ] AI analysis accuracy > 70% for common foods
- [ ] User can complete full day of tracking easily

---

**Current Status:** Foundation ready, begin Phase 1 implementation  
**Next Action:** Get Gemini API key and create database migrations  
**Questions?** Review `AI_HEALTH_TRACKING_PLAN.md` for details

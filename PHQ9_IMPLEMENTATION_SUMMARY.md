# PHQ-9 Psychological Assessment Feature - Implementation Summary

**Date:** December 2, 2025  
**Status:** ✅ Backend Complete | 🔄 Mobile In Progress

## Overview

Implemented a comprehensive PHQ-9 (Patient Health Questionnaire-9) psychological assessment feature for depression screening in the VIATRA health platform. This feature mirrors the sleep and food tracking implementations with bilingual support (English/Arabic).

---

## Backend Implementation ✅ COMPLETE

### 1. Database Schema
**File:** `/backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`

**Features:**
- Full PHQ-9 questionnaire storage (9 questions, 0-3 scoring each)
- Automatic total score calculation (0-27)
- Auto-generated severity levels (minimal, mild, moderate, moderately_severe, severe)
- Trend analytics view for tracking progress over time
- Database triggers for automatic calculations
- High-risk flagging for self-harm indicators (q9)

**Severity Levels:**
- 0-4: Minimal depression
- 5-9: Mild depression
- 10-14: Moderate depression
- 15-19: Moderately severe depression
- 20-27: Severe depression

### 2. Backend Model
**File:** `/backend/src/models/PsychologicalAssessment.js`

**Features:**
- Sequelize model with all PHQ-9 questions
- Automatic score calculation before save
- Static methods for severity interpretation
- Bilingual severity displays (English/Arabic)
- Clinical recommendations based on score
- Validation rules (0-3 per question)

### 3. Backend Controller
**File:** `/backend/src/controllers/psychologicalAssessmentController.js`

**Endpoints:**
| Method | Route | Description |
|--------|-------|-------------|
| POST | `/submit` | Submit new PHQ-9 assessment |
| GET | `/history` | Get assessment history with filters |
| GET | `/:assessmentId` | Get specific assessment details |
| GET | `/analytics` | Get trends and analytics |
| DELETE | `/:assessmentId` | Delete an assessment |
| GET | `/questions` | Get PHQ-9 questions (bilingual) |

**Features:**
- Validation (all 9 questions required)
- High-risk logging for self-harm indicators
- Bilingual recommendations
- Score trends and patterns analysis
- Symptom distribution tracking

### 4. Backend Routes
**File:** `/backend/src/routes/psychologicalAssessment.js`

**Registered at:** `/api/psychological-assessment`

All routes require authentication

---

## Mobile Implementation 🔄 IN PROGRESS

### 1. Data Models
**File:** `/mobile/lib/models/psychological/psychological_assessment.dart`

**Features:**
- `PsychologicalAssessment` model with all fields
- `PHQ9Question` model for questions
- `ScoreLabel` model for answer options
- Static question data with bilingual text
- Score labels (0-3) in English/Arabic
- Severity display methods (bilingual)
- JSON serialization ready

**Needs:** Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `.g.dart` files

### 2. Service Layer
**File:** `/mobile/lib/services/psychological_assessment_service.dart`

**Methods:**
- `submitAssessment()` - Submit new PHQ-9
- `getAssessmentHistory()` - Get past assessments
- `getAssessmentById()` - Get specific assessment
- `getAnalytics()` - Get trends and stats
- `deleteAssessment()` - Delete assessment

### 3. Assessment Screen
**File:** `/mobile/lib/screens/psychological/phq9_assessment_screen.dart`

**Features:**
- ✅ Page-by-page questionnaire (9 pages)
- ✅ Progress indicator
- ✅ Bilingual questions (English + Arabic)
- ✅ Scrollable slider (0-3) with visual feedback
- ✅ Tap-able answer cards
- ✅ Previous/Next navigation
- ✅ Real-time answer tracking
- ✅ Submit validation (all questions required)

**UI Components:**
1. **Progress Bar** - Shows current question (e.g., "3/9")
2. **Instructions Banner** - Bilingual context
3. **Question Card:**
   - Question number
   - English text (large, bold)
   - Arabic text (gray, italic, RTL)
4. **Score Selector:**
   - Slider (0-3) with divisions
   - Visual score indicators
   - Tap-able answer cards with:
     - Score badge (0-3)
     - English label
     - Arabic label (RTL)
     - Check icon when selected
5. **Navigation:**
   - Previous button (except first page)
   - Next button (changes to "Submit" on last page)

### 4. Result Screen
**File:** `/mobile/lib/screens/psychological/assessment_result_screen.dart`

**Features:**
- ✅ Large score display with gradient card
- ✅ Severity level badge (bilingual)
- ✅ Score interpretation (bilingual)
- ✅ Clinical recommendations (bilingual)
- ✅ Crisis warning for high self-harm scores (q9 >= 2)
- ✅ Action buttons (View History, Go Home)
- ✅ Disclaimer notice

**Color-coded severity:**
- Minimal: Green
- Mild: Light Green
- Moderate: Orange
- Moderately Severe: Deep Orange
- Severe: Red

---

## 📋 TO-DO: Remaining Mobile Screens

### 1. Assessment History Screen
**File:** `/mobile/lib/screens/psychological/assessment_history_screen.dart`

**Features Needed:**
- List all past assessments
- Date filtering
- Sort by date/score
- Score trend graph
- Tap to view details
- Pull-to-refresh
- Delete functionality

### 2. Assessment Details Screen  
**File:** `/mobile/lib/screens/psychological/assessment_details_screen.dart`

**Features Needed:**
- Full assessment details
- All 9 answers displayed
- Score breakdown
- Recommendations
- Share/export options
- Delete option

### 3. Assessment Dashboard
**File:** `/mobile/lib/screens/psychological/assessment_dashboard_screen.dart`

**Features Needed:**
- Quick start new assessment button
- Recent assessments list (last 5)
- Score trend chart (line/bar graph)
- Average score
- Latest severity level
- Improvement/worsening indicator
- Link to full history

---

## Integration Steps

### Backend Integration
1. ✅ Database migration created
2. ✅ Model created
3. ✅ Controller created
4. ✅ Routes created
5. ✅ Routes registered in `/backend/src/routes/index.js`

**To Deploy:**
```bash
# Run SQL migration
psql -U viatra_user -d viatra_db -f backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql

# Restart backend
cd backend
npm install
npm start
```

### Mobile Integration
1. ✅ Models created
2. ✅ Service created
3. ✅ Assessment screen created
4. ✅ Result screen created
5. ⏳ History screen needed
6. ⏳ Details screen needed
7. ⏳ Dashboard screen needed
8. ⏳ Add to patient home screen
9. ⏳ Add to routes

**To Complete:**
```bash
# Generate model files
cd mobile
flutter pub run build_runner build --delete-conflicting-outputs

# Add to pubspec.yaml if needed
# (intl, provider, charts_flutter for graphs)

# Create remaining screens
# Add routes in lib/config/routes.dart
# Add card to patient home screen
```

---

## User Flow

```
Patient Home Screen
  ↓
[Mental Health] Card
  ↓
Assessment Dashboard
  ├─→ [Start New Assessment]
  │     ↓
  │   PHQ-9 Assessment Screen (9 pages)
  │     ↓
  │   Submit
  │     ↓
  │   Assessment Result Screen
  │     ├─→ [View History]
  │     └─→ [Go Home]
  │
  ├─→ [View History]
  │     ↓
  │   Assessment History Screen
  │     ↓
  │   [Tap Assessment]
  │     ↓
  │   Assessment Details Screen
  │
  └─→ Score Trend Chart
```

---

## API Endpoints Reference

### Submit Assessment
```http
POST /api/psychological-assessment/submit
Authorization: Bearer <token>

{
  "q1_interest": 1,
  "q2_feeling_down": 2,
  "q3_sleep": 1,
  "q4_energy": 2,
  "q5_appetite": 0,
  "q6_self_worth": 1,
  "q7_concentration": 1,
  "q8_movement": 0,
  "q9_self_harm": 0,
  "notes": "Feeling better this week",
  "difficulty_level": "somewhat_difficult"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Assessment submitted successfully",
  "data": {
    "assessment": { ... },
    "recommendations": {
      "en": "Watchful waiting...",
      "ar": "المراقبة والانتظار..."
    },
    "severity_display": {
      "en": "Mild Depression",
      "ar": "اكتئاب خفيف"
    }
  }
}
```

### Get History
```http
GET /api/psychological-assessment/history?limit=50
Authorization: Bearer <token>
```

### Get Analytics
```http
GET /api/psychological-assessment/analytics?days=90
Authorization: Bearer <token>
```

---

## Clinical Notes

### PHQ-9 Scoring Guide
- **0-4**: Minimal depression - No treatment needed
- **5-9**: Mild depression - Watchful waiting, therapy consideration
- **10-14**: Moderate depression - Treatment plan (therapy/medication)
- **15-19**: Moderately severe - Active treatment required
- **20-27**: Severe - Immediate treatment, possible hospitalization

### Critical Question
**Question 9** (Self-harm thoughts):
- Score ≥ 2: HIGH RISK - Immediate intervention needed
- Backend logs warning
- Mobile shows crisis support card
- Recommend immediate clinical evaluation

---

## Testing Checklist

### Backend
- [ ] Create assessment with all questions
- [ ] Validate score calculation
- [ ] Verify severity level assignment
- [ ] Test high-risk flagging (q9 >= 2)
- [ ] Test analytics endpoints
- [ ] Test date filtering
- [ ] Test bilingual responses

### Mobile
- [ ] Complete PHQ-9 assessment
- [ ] Navigate between questions
- [ ] Slider interaction (0-3)
- [ ] Tap answer cards
- [ ] Submit validation
- [ ] View results
- [ ] Check bilingual display
- [ ] Test crisis warning (q9 >= 2)
- [ ] View history
- [ ] View trends

---

## Next Steps

1. **Generate Dart Models**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Create Remaining Screens:**
   - Assessment History Screen
   - Assessment Details Screen
   - Assessment Dashboard Screen

3. **Add to Patient Home:**
   - Create "Mental Health" card
   - Link to Assessment Dashboard

4. **Add Routes:**
   - Register all screens in `routes.dart`

5. **Deploy Backend:**
   - Run SQL migration
   - Restart backend server

6. **Test End-to-End:**
   - Complete assessment flow
   - Verify data persistence
   - Test all screens

---

## Summary

✅ **Completed:**
- Full backend implementation (database, model, controller, routes)
- Mobile models and service
- PHQ-9 assessment screen (interactive, bilingual, scrollable 0-3 slider)
- Results screen (score display, recommendations, crisis warning)

⏳ **Remaining:**
- 3 mobile screens (History, Details, Dashboard)
- Integration with patient home screen
- Route registration
- Testing and deployment

**Estimated Time to Complete:** 2-3 hours for remaining mobile screens

🎉 The core PHQ-9 assessment feature is functional and ready for testing!

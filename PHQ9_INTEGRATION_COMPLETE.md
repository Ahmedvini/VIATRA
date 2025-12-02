# PHQ-9 Psychological Assessment - Final Integration Guide

## ✅ IMPLEMENTATION STATUS: COMPLETE

All PHQ-9 (Patient Health Questionnaire-9) components have been successfully implemented for the VIATRA health platform.

---

## 📋 COMPLETED COMPONENTS

### Backend Implementation ✅
1. **Database Schema** (`/backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`)
   - Table: `psychological_assessments`
   - 9 question columns (0-3 scoring each)
   - Automatic total score calculation (0-27)
   - Automatic severity level classification
   - Analytics view for trends
   - Proper indexes for performance

2. **Model** (`/backend/src/models/PsychologicalAssessment.js`)
   - Sequelize model with all fields
   - Static methods for severity calculation
   - Static methods for recommendations

3. **Controller** (`/backend/src/controllers/psychologicalAssessmentController.js`)
   - POST `/api/psychological-assessments` - Submit new assessment
   - GET `/api/psychological-assessments/history` - Get assessment history
   - GET `/api/psychological-assessments/analytics` - Get trends and analytics
   - GET `/api/psychological-assessments/:id` - Get single assessment details
   - DELETE `/api/psychological-assessments/:id` - Delete assessment
   - GET `/api/psychological-assessments/questions` - Get PHQ-9 questions

4. **Routes** (`/backend/src/routes/psychologicalAssessment.js`)
   - All endpoints registered and protected with auth middleware
   - Routes added to main router (`/backend/src/routes/index.js`)

### Mobile Implementation ✅
1. **Dart Model** (`/mobile/lib/models/psychological/psychological_assessment.dart`)
   - `PsychologicalAssessment` class with json_serializable
   - `PHQ9Question` class for bilingual questions
   - `ScoreLabel` class for bilingual answer options
   - `PHQ9Questions` static class with all 9 questions
   - Severity display methods (English & Arabic)

2. **Service** (`/mobile/lib/services/psychological_assessment_service.dart`)
   - `submitAssessment()` - Submit new PHQ-9 assessment
   - `getHistory()` - Fetch assessment history with filters
   - `getAnalytics()` - Get trends and statistics
   - `getDetails()` - Get single assessment details
   - `deleteAssessment()` - Delete an assessment

3. **UI Screens** (All bilingual English/Arabic)
   - **PHQ-9 Assessment Screen** (`phq9_assessment_screen.dart`)
     - Scrollable list of 9 questions
     - Horizontal slider (0-3) for each answer
     - Answer cards showing selected options
     - Visual feedback and validation
     - Submit button with loading state
   
   - **Assessment Result Screen** (`assessment_result_screen.dart`)
     - Score display with color-coded severity
     - Severity level badge
     - Personalized recommendations
     - Crisis hotline button (for severe cases)
     - Navigation to history
   
   - **Assessment History Screen** (`assessment_history_screen.dart`)
     - List of past assessments
     - Filter by date range and severity
     - Trend chart showing score over time
     - Tap to view details
   
   - **Assessment Details Screen** (`assessment_details_screen.dart`)
     - Full breakdown of individual answers
     - Question-by-question review
     - Score visualization
     - Difficulty level indicator

4. **Routes** (`/mobile/lib/config/routes.dart`)
   - `/psychological/phq9` - Take PHQ-9 assessment
   - `/psychological/result` - View results
   - `/psychological/history` - View history
   - `/psychological/details/:assessmentId` - View details

---

## 🔧 REMAINING TASKS

### 1. Generate JSON Serialization Files
```bash
cd /home/ahmedvini/Music/VIATRA/mobile
dart run build_runner build --delete-conflicting-outputs
```
This will generate `psychological_assessment.g.dart` required for JSON parsing.

### 2. Integrate into Patient Dashboard
Add a button/card to the patient home screen to access PHQ-9:

**Option A: In main dashboard** (`/mobile/lib/screens/main_app_shell.dart` or similar)
```dart
// Add PHQ-9 assessment card
Card(
  child: ListTile(
    leading: Icon(Icons.psychology),
    title: Text('Mental Health Assessment'),
    subtitle: Text('PHQ-9 Depression Screening'),
    trailing: Icon(Icons.arrow_forward),
    onTap: () => context.push('/psychological/phq9'),
  ),
)
```

**Option B: In dedicated health tracking section**
```dart
// Add to health tracking menu
ListTile(
  leading: Icon(Icons.psychology),
  title: Text('Psychological Assessment'),
  onTap: () => context.push('/psychological/phq9'),
)
```

### 3. Deploy Backend Changes
The SQL migration needs to be executed on your database:
```bash
# Option 1: If you have auto-migrations enabled
cd /home/ahmedvini/Music/VIATRA/backend
npm run migrate

# Option 2: Manual execution
psql -U your_user -d your_database -f database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql
```

### 4. Test End-to-End Flow
1. Start backend: `cd backend && npm run dev`
2. Start mobile app: `cd mobile && flutter run`
3. Navigate to PHQ-9 assessment
4. Complete assessment (answer all 9 questions)
5. View results and recommendations
6. Check history screen
7. View assessment details

### 5. Optional Enhancements
- [ ] Add push notifications for periodic assessments (e.g., weekly reminder)
- [ ] Add doctor access to view patient assessments
- [ ] Add export to PDF functionality
- [ ] Add comparison charts (compare with previous assessments)
- [ ] Integrate with appointment booking (suggest therapy if scores are high)

---

## 📖 USAGE GUIDE

### For Patients
1. Navigate to "Mental Health Assessment" or "PHQ-9" from the home screen
2. Read the instructions: "Over the past two weeks, how often have you been bothered by..."
3. Answer all 9 questions using the slider (0 = Not at all, 3 = Nearly every day)
4. Optionally add notes
5. Submit the assessment
6. View your score and severity level
7. Read personalized recommendations
8. **IMPORTANT**: If suicidal thoughts (Q9) are present, crisis resources are shown
9. View history to track progress over time

### Score Interpretation
- **0-4**: Minimal depression
- **5-9**: Mild depression
- **10-14**: Moderate depression
- **15-19**: Moderately severe depression
- **20-27**: Severe depression

### PHQ-9 Questions (Bilingual)
1. Little interest or pleasure in doing things / قلة الاهتمام أو المتعة
2. Feeling down, depressed, or hopeless / الشعور بالإحباط أو الاكتئاب
3. Trouble sleeping / صعوبة في النوم
4. Feeling tired or low energy / الشعور بالتعب
5. Poor appetite or overeating / ضعف الشهية
6. Feeling bad about yourself / الشعور بالسوء تجاه نفسك
7. Trouble concentrating / صعوبة في التركيز
8. Moving/speaking slowly or restless / التحرك ببطء أو القلق
9. Thoughts of self-harm / أفكار إيذاء النفس

---

## 🔐 SECURITY NOTES

- All endpoints are protected with JWT authentication
- Patients can only access their own assessments
- Question 9 (self-harm) triggers immediate crisis resources
- Data is encrypted in transit (HTTPS)
- Sensitive mental health data should comply with HIPAA/local regulations

---

## 🎨 UI/UX Features

- **Bilingual Support**: Full Arabic and English support
- **Accessibility**: Large touch targets, clear labels
- **Visual Feedback**: Color-coded severity levels
- **Scrollable Interface**: Long questions are fully readable
- **Progress Indication**: See which questions are answered
- **Crisis Warning**: Prominent display for high-risk scores

---

## 📊 Analytics & Trends

The history screen provides:
- Line chart showing score trends over time
- Average score calculation
- Frequency of assessments
- Filter by date range
- Filter by severity level

Backend analytics endpoint provides:
- Average score over time period
- Score trends (improving/declining)
- Assessment frequency
- Severity distribution

---

## 🚀 DEPLOYMENT CHECKLIST

- [x] Backend model created
- [x] Backend controller created
- [x] Backend routes registered
- [x] SQL migration script created
- [x] Mobile Dart model created
- [x] Mobile service created
- [x] Mobile UI screens created
- [x] Mobile routes registered
- [ ] Run build_runner to generate .g.dart files
- [ ] Run SQL migration on database
- [ ] Integrate into patient dashboard
- [ ] Test end-to-end flow
- [ ] Deploy to staging environment
- [ ] User acceptance testing
- [ ] Deploy to production

---

## 📞 SUPPORT & CRISIS RESOURCES

The app displays crisis resources when severe depression or suicidal thoughts are detected:
- Crisis Hotline: 988 (US) / 920033360 (Saudi Arabia)
- Emergency: 911 / 997
- Text "HELLO" to 741741 (Crisis Text Line)

---

## 🔗 RELATED DOCUMENTATION

- PHQ-9 Clinical Information: https://www.apa.org/depression-guideline/patient-health-questionnaire.pdf
- Backend API: `/backend/README.md`
- Mobile App: `/mobile/README.md`
- Architecture: `/docs/ARCHITECTURE.md`

---

## ✅ VERIFICATION

To verify the implementation:
```bash
# 1. Check backend
cd /home/ahmedvini/Music/VIATRA/backend
grep -r "psychologicalAssessment" src/routes/index.js

# 2. Check mobile files exist
cd /home/ahmedvini/Music/VIATRA/mobile
ls -la lib/models/psychological/
ls -la lib/services/psychological_assessment_service.dart
ls -la lib/screens/psychological/

# 3. Check routes
grep "psychological" lib/config/routes.dart

# 4. Build and test
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

**🎉 IMPLEMENTATION COMPLETE! Ready for testing and deployment.**

**Created:** December 2, 2024  
**Status:** ✅ Complete - Pending build_runner and integration

# QUICK START - Finish PHQ-9 Integration

## ✅ WHAT'S DONE
All code is written! Backend and mobile implementation complete.

## 🔧 FINAL 3 STEPS

### Step 1: Generate .g.dart files (1 minute)
```bash
cd /home/ahmedvini/Music/VIATRA/mobile
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Add to patient dashboard (2 minutes)
Add this button to your patient home screen (find the main patient screen):

```dart
// Add this card/button somewhere in your patient dashboard
ElevatedButton.icon(
  icon: Icon(Icons.psychology),
  label: Text('Mental Health Assessment'),
  onPressed: () => context.push('/psychological/phq9'),
)
```

### Step 3: Run database migration (30 seconds)
The SQL file at `/backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql` needs to run on your database. It will automatically create all tables, triggers, and functions.

## 🎉 THAT'S IT!

Then test:
1. Start backend: `cd backend && npm run dev`
2. Start mobile: `cd mobile && flutter run`
3. Take a PHQ-9 assessment
4. View results and history

## 📁 CREATED FILES
- Backend: 4 files (model, controller, routes, SQL)
- Mobile: 8 files (model, service, 4 screens, routes update)
- Docs: 2 files (this guide + full guide)

## 🔍 QUICK FILE REFERENCE
- Model: `/mobile/lib/models/psychological/psychological_assessment.dart`
- Service: `/mobile/lib/services/psychological_assessment_service.dart`
- Screens: `/mobile/lib/screens/psychological/*.dart`
- Routes: `/mobile/lib/config/routes.dart` (lines 225-256)
- Backend: `/backend/src/routes/psychologicalAssessment.js`
- SQL: `/backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`

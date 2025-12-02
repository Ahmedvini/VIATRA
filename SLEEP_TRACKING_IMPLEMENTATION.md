# Sleep Tracking Implementation - Complete Guide

## 🎯 Overview
This guide covers the complete sleep tracking system implementation, similar to the food tracking feature. Patients can track their sleep cycles, record wake-ups, and view sleep analytics through a dashboard.

---

## 📁 Files Created/Modified

### Backend Files
✅ `/backend/src/controllers/sleepTrackingController.js` - Sleep tracking business logic
✅ `/backend/src/routes/sleepTracking.js` - API routes
✅ `/backend/src/routes/index.js` - Added sleep routes mounting
✅ `/backend/src/models/SleepSession.js` - Sleep session model
✅ `/backend/src/models/SleepInterruption.js` - Wake-up interruption model
✅ `/backend/src/models/index.js` - Added sleep models exports
✅ `/backend/src/migrations/20251202-create-sleep-tracking.cjs` - Database migration

### Database Files
✅ `/CREATE_SLEEP_TRACKING_TABLES.sql` - Manual SQL script for Supabase
✅ `/SLEEP_TRACKING_SETUP_GUIDE.md` - Setup instructions

---

## 🗄️ Database Schema

### Table: `sleep_sessions`
```sql
CREATE TABLE sleep_sessions (
  id UUID PRIMARY KEY,
  patient_id UUID REFERENCES users(id),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  quality_rating INTEGER (1-5),
  total_duration_minutes INTEGER,
  wake_up_count INTEGER DEFAULT 0,
  notes TEXT,
  environment_factors JSONB,
  status VARCHAR(20) DEFAULT 'active', -- 'active', 'paused', 'completed'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Table: `sleep_interruptions`
```sql
CREATE TABLE sleep_interruptions (
  id UUID PRIMARY KEY,
  sleep_session_id UUID REFERENCES sleep_sessions(id),
  pause_time TIMESTAMP NOT NULL,
  resume_time TIMESTAMP,
  duration_minutes INTEGER,
  reason VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🔌 API Endpoints

Base URL: `/api/v1/sleep-tracking`

### 1. Start Sleep Session
```http
POST /start
Authorization: Bearer {token}

Request Body:
{
  "start_time": "2024-12-02T22:00:00Z",
  "notes": "Going to bed early",
  "environment_factors": {
    "room_temperature": "68F",
    "noise_level": "quiet"
  }
}

Response:
{
  "success": true,
  "message": "Sleep session started successfully",
  "data": {
    "id": "uuid",
    "patient_id": "uuid",
    "start_time": "2024-12-02T22:00:00Z",
    "status": "active",
    "wake_up_count": 0,
    ...
  }
}
```

### 2. Pause Sleep Session (Wake Up)
```http
PUT /:sessionId/pause
Authorization: Bearer {token}

Request Body:
{
  "reason": "bathroom",
  "notes": "Woke up to use the bathroom"
}

Response:
{
  "success": true,
  "message": "Sleep session paused",
  "data": {
    "session": {...},
    "interruption": {
      "id": "uuid",
      "pause_time": "2024-12-03T03:00:00Z",
      "reason": "bathroom"
    }
  }
}
```

### 3. Resume Sleep Session
```http
PUT /:sessionId/resume
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Sleep session resumed",
  "data": {...}
}
```

### 4. End Sleep Session
```http
PUT /:sessionId/end
Authorization: Bearer {token}

Request Body:
{
  "quality_rating": 4,
  "notes": "Slept well overall"
}

Response:
{
  "success": true,
  "message": "Sleep session completed successfully",
  "data": {
    "id": "uuid",
    "status": "completed",
    "total_duration_minutes": 480,
    "quality_rating": 4,
    "wake_up_count": 2,
    ...
  }
}
```

### 5. Get Sleep Sessions
```http
GET /
Authorization: Bearer {token}
Query Parameters:
  - start_date: ISO date string
  - end_date: ISO date string
  - status: 'active', 'paused', or 'completed'
  - limit: number (default 50)
  - offset: number (default 0)

Response:
{
  "success": true,
  "data": [...sessions with interruptions...],
  "pagination": {
    "limit": 50,
    "offset": 0,
    "total": 10
  }
}
```

### 6. Get Sleep Session by ID
```http
GET /:sessionId
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "patient_id": "uuid",
    "start_time": "...",
    "end_time": "...",
    "interruptions": [
      {
        "id": "uuid",
        "pause_time": "...",
        "resume_time": "...",
        "duration_minutes": 15,
        "reason": "bathroom"
      }
    ],
    ...
  }
}
```

### 7. Get Sleep Analytics
```http
GET /analytics
Authorization: Bearer {token}
Query Parameters:
  - days: number (default 7)

Response:
{
  "success": true,
  "data": {
    "totalSessions": 7,
    "averageDuration": 450, // minutes
    "averageQuality": 4.2,
    "totalWakeUps": 14,
    "averageWakeUps": 2.0,
    "sleepEfficiency": 92 // percentage
  },
  "sessions": [...detailed session data...]
}
```

### 8. Record Interruption
```http
POST /:sessionId/interruption
Authorization: Bearer {token}

Request Body:
{
  "reason": "noise",
  "notes": "Loud sound outside"
}

Response:
{
  "success": true,
  "message": "Sleep interruption recorded",
  "data": {
    "id": "uuid",
    "sleep_session_id": "uuid",
    "pause_time": "...",
    "reason": "noise"
  }
}
```

### 9. Delete Sleep Session
```http
DELETE /:sessionId
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Sleep session deleted successfully"
}
```

---

## 🔄 Sleep Session Flow

### State Diagram
```
┌─────────┐
│  START  │
└────┬────┘
     │
     v
┌─────────┐     Wake Up      ┌─────────┐
│ ACTIVE  │ ───────────────> │ PAUSED  │
└────┬────┘                  └────┬────┘
     │                            │
     │ End Session               │ Resume
     │                            │
     v                            v
┌──────────┐                 ┌─────────┐
│COMPLETED │<────────────────│ ACTIVE  │
└──────────┘                 └─────────┘
```

### Example User Journey
1. **9:00 PM** - User taps "Start Sleep"
   - Status: `active`
   - `start_time` = 9:00 PM

2. **2:00 AM** - User wakes up (bathroom)
   - Status changes to: `paused`
   - Creates interruption with `pause_time` = 2:00 AM
   - `wake_up_count` increments to 1

3. **2:15 AM** - User resumes sleep
   - Status changes to: `active`
   - Updates interruption with `resume_time` = 2:15 AM
   - Calculates `duration_minutes` = 15

4. **4:00 AM** - User wakes up again (noise)
   - Status: `paused`
   - Creates another interruption
   - `wake_up_count` increments to 2

5. **4:10 AM** - User resumes sleep
   - Status: `active`
   - Updates second interruption

6. **6:00 AM** - User ends sleep
   - Status: `completed`
   - Sets `end_time` = 6:00 AM
   - Calculates `total_duration_minutes` = 540 (9 hours)
   - Records `quality_rating` = 4

---

## 📱 Mobile App Implementation (Next Step)

### Required Screens

1. **Sleep Dashboard** (`/mobile/lib/screens/sleep_tracking/sleep_dashboard_screen.dart`)
   - Weekly sleep chart
   - Average sleep duration
   - Average sleep quality
   - Wake-up statistics
   - Recent sleep sessions list

2. **Active Sleep Screen** (`/mobile/lib/screens/sleep_tracking/active_sleep_screen.dart`)
   - Large timer showing sleep duration
   - "Pause" button (for wake-ups)
   - "End Sleep" button
   - Current interruption count
   - Session start time

3. **Sleep History** (`/mobile/lib/screens/sleep_tracking/sleep_history_screen.dart`)
   - List of past sleep sessions
   - Filter by date range
   - View details button

4. **Sleep Details** (`/mobile/lib/screens/sleep_tracking/sleep_details_screen.dart`)
   - Full session details
   - List of interruptions
   - Sleep efficiency score
   - Sleep timeline visualization

### Required Models

1. **SleepSession** (`/mobile/lib/models/sleep_tracking/sleep_session.dart`)
```dart
class SleepSession {
  final String id;
  final String patientId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? qualityRating;
  final int? totalDurationMinutes;
  final int wakeUpCount;
  final String? notes;
  final Map<String, dynamic>? environmentFactors;
  final String status; // 'active', 'paused', 'completed'
  final List<SleepInterruption> interruptions;
  
  // Methods
  Duration get totalDuration;
  double? get sleepEfficiency;
  String get formattedDuration;
}
```

2. **SleepInterruption** (`/mobile/lib/models/sleep_tracking/sleep_interruption.dart`)
```dart
class SleepInterruption {
  final String id;
  final String sleepSessionId;
  final DateTime pauseTime;
  final DateTime? resumeTime;
  final int? durationMinutes;
  final String? reason;
  final String? notes;
  
  // Methods
  Duration? get duration;
  bool get isActive; // resume_time is null
}
```

### Required Service

**SleepTrackingService** (`/mobile/lib/services/sleep_tracking_service.dart`)
```dart
class SleepTrackingService {
  Future<SleepSession> startSleepSession({...});
  Future<SleepSession> pauseSleepSession(String sessionId, {...});
  Future<SleepSession> resumeSleepSession(String sessionId);
  Future<SleepSession> endSleepSession(String sessionId, {...});
  Future<List<SleepSession>> getSleepSessions({...});
  Future<SleepSession> getSleepSessionById(String sessionId);
  Future<SleepAnalytics> getSleepAnalytics({int days = 7});
  Future<void> deleteSleepSession(String sessionId);
}
```

---

## 🧪 Testing Checklist

### Backend Testing
- [ ] Run `CREATE_SLEEP_TRACKING_TABLES.sql` in Supabase
- [ ] Start backend: `cd backend && npm run dev`
- [ ] Test API endpoints with Postman/curl
- [ ] Verify data appears in Supabase tables

### Integration Testing
- [ ] Start sleep session → verify in database
- [ ] Pause session → verify interruption created
- [ ] Resume session → verify interruption updated
- [ ] End session → verify status and duration calculated
- [ ] Get analytics → verify calculations

### Mobile Testing (After UI Implementation)
- [ ] Login with test patient
- [ ] Navigate to sleep tracking
- [ ] Start a sleep session
- [ ] Record a wake-up (pause/resume)
- [ ] End sleep and rate quality
- [ ] View sleep history
- [ ] Check analytics dashboard

---

## 🚀 Quick Start

### Step 1: Database Setup
```bash
# 1. Open Supabase SQL Editor
# 2. Copy contents of CREATE_SLEEP_TRACKING_TABLES.sql
# 3. Run the script
# 4. Verify tables created
```

### Step 2: Backend Setup
```bash
cd backend
npm install  # if needed
npm run dev  # Start server
```

### Step 3: Test API
```bash
# Get your auth token first (login)
TOKEN="your-jwt-token"

# Start sleep
curl -X POST http://localhost:3000/api/v1/sleep-tracking/start \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"start_time":"2024-12-02T22:00:00Z","notes":"Test sleep"}'

# Get sessions
curl http://localhost:3000/api/v1/sleep-tracking \
  -H "Authorization: Bearer $TOKEN"
```

### Step 4: Mobile Implementation (Next)
1. Create model files
2. Create service file
3. Create UI screens
4. Test end-to-end

---

## 📊 Analytics Calculations

### Average Sleep Duration
```javascript
averageDuration = totalMinutes / numberOfSessions
```

### Average Sleep Quality
```javascript
averageQuality = sumOfQualityRatings / numberOfSessionsWithRating
```

### Sleep Efficiency
```javascript
actualSleep = totalDuration - totalInterruptionDuration
sleepEfficiency = (actualSleep / totalDuration) * 100
```

### Average Wake-ups
```javascript
averageWakeUps = totalWakeUpCount / numberOfSessions
```

---

## 🎨 UI Design Suggestions

### Dashboard
- Line chart showing sleep duration over 7/30 days
- Circular progress showing average sleep quality
- Cards displaying:
  - Average sleep time
  - Average wake-ups
  - Sleep efficiency
  - Last night's sleep

### Active Sleep Screen
- Large circular timer (like a stopwatch)
- Subtle animations
- Dark theme (night mode)
- Big buttons for easy tapping when sleepy

### Color Scheme
- Quality 5 stars: 🟢 Green
- Quality 4 stars: 🟡 Yellow-Green
- Quality 3 stars: 🟡 Yellow
- Quality 2 stars: 🟠 Orange
- Quality 1 star: 🔴 Red

---

## 🔐 Security Notes

- All endpoints require authentication
- Users can only access their own sleep data
- patient_id is taken from JWT token, not request body
- Proper validation on all inputs

---

## 📝 Next Steps

1. ✅ Database tables created
2. ✅ Backend routes and controllers
3. ✅ Models and associations
4. ⏳ Mobile models (Dart)
5. ⏳ Mobile service (Dart)
6. ⏳ Mobile UI screens
7. ⏳ End-to-end testing

---

## 💡 Future Enhancements

- Sleep goal setting
- Sleep reminders/notifications
- Sleep cycle detection (REM, deep sleep)
- Integration with wearable devices
- Sleep tips and recommendations
- Export sleep data as PDF report
- Share sleep data with doctor

---

## 🐛 Troubleshooting

### Backend won't start
- Check if sleep models are imported correctly
- Verify Sequelize initialization
- Check database connection

### Foreign key errors
- Ensure `users` table exists
- Verify patient_id is valid UUID
- Check CASCADE settings

### Analytics returning zeros
- Ensure sessions have status='completed'
- Check date range filters
- Verify session has end_time

---

## 📚 Related Documentation

- `SLEEP_TRACKING_SETUP_GUIDE.md` - Database setup
- `CREATE_SLEEP_TRACKING_TABLES.sql` - SQL script
- `FOOD_TRACKING_SETUP_GUIDE.md` - Similar feature reference
- Backend: `/backend/src/controllers/sleepTrackingController.js`
- Backend: `/backend/src/routes/sleepTracking.js`

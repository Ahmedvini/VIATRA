# Sleep Tracking Database Setup Guide

## Quick Setup Steps

### 1. Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### 2. Run the SQL Script
1. Copy the entire contents of `CREATE_SLEEP_TRACKING_TABLES.sql`
2. Paste it into the SQL editor
3. Click **Run** or press `Ctrl+Enter`

### 3. Verify Creation
The script will automatically verify:
- ✅ Table structure for `sleep_sessions`
- ✅ Table structure for `sleep_interruptions`
- ✅ Foreign key constraints
- ✅ Indexes for performance
- ✅ Row counts (should be 0 initially)

---

## Database Schema

### Table 1: `sleep_sessions`
Stores the main sleep tracking sessions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `patient_id` | UUID | Links to `users.id` (the patient) |
| `start_time` | TIMESTAMP | When sleep started |
| `end_time` | TIMESTAMP | When sleep ended (NULL if active) |
| `quality_rating` | INTEGER | Sleep quality 1-5 stars |
| `total_duration_minutes` | INTEGER | Total sleep duration |
| `wake_up_count` | INTEGER | Number of wake-ups |
| `notes` | TEXT | Patient notes about sleep |
| `environment_factors` | JSONB | Room temp, noise, etc. |
| `status` | VARCHAR | 'active', 'paused', or 'completed' |
| `created_at` | TIMESTAMP | Record creation time |
| `updated_at` | TIMESTAMP | Last update time (auto-updated) |

### Table 2: `sleep_interruptions`
Tracks each time the patient woke up during sleep.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `sleep_session_id` | UUID | Links to `sleep_sessions.id` |
| `pause_time` | TIMESTAMP | When they woke up |
| `resume_time` | TIMESTAMP | When they went back to sleep |
| `duration_minutes` | INTEGER | How long awake (calculated) |
| `reason` | VARCHAR | Why they woke up |
| `notes` | TEXT | Additional notes |
| `created_at` | TIMESTAMP | Record creation time |
| `updated_at` | TIMESTAMP | Last update time (auto-updated) |

---

## How Sleep Tracking Works

### User Flow:
1. **Start Sleep** → Creates a new `sleep_sessions` record with `status='active'`
2. **Wake Up (Pause)** → 
   - Changes session `status='paused'`
   - Creates a `sleep_interruptions` record with `pause_time`
   - Increments `wake_up_count`
3. **Resume Sleep** → 
   - Changes session `status='active'`
   - Updates the interruption with `resume_time` and calculates `duration_minutes`
4. **End Sleep** → 
   - Changes session `status='completed'`
   - Sets `end_time`
   - Calculates `total_duration_minutes`
   - Records `quality_rating` (optional)

### Status Flow:
```
active → paused → active → paused → active → completed
  ↓        ↓        ↓        ↓        ↓
sleep   wake up  sleep   wake up  sleep    end
```

---

## API Endpoints (Backend)

Once you run the backend, these endpoints will be available:

### Start Sleep
```http
POST /api/v1/sleep-tracking/start
Authorization: Bearer YOUR_TOKEN

{
  "start_time": "2024-12-02T22:00:00Z",
  "notes": "Going to bed early tonight",
  "environment_factors": {
    "room_temperature": "68F",
    "noise_level": "quiet"
  }
}
```

### Pause Sleep (Wake Up)
```http
PUT /api/v1/sleep-tracking/:sessionId/pause

{
  "reason": "bathroom",
  "notes": "Woke up to use the bathroom"
}
```

### Resume Sleep
```http
PUT /api/v1/sleep-tracking/:sessionId/resume
```

### End Sleep
```http
PUT /api/v1/sleep-tracking/:sessionId/end

{
  "quality_rating": 4,
  "notes": "Slept well overall"
}
```

### Get Sleep Sessions
```http
GET /api/v1/sleep-tracking?limit=30&status=completed
```

### Get Sleep Analytics
```http
GET /api/v1/sleep-tracking/analytics?days=7
```

Returns:
- Average sleep duration
- Average sleep quality
- Average wake-ups per night
- Sleep efficiency percentage
- Daily breakdown

---

## Testing After Setup

### 1. Check Tables Exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('sleep_sessions', 'sleep_interruptions');
```

### 2. Test Insert (use your actual patient_id)
```sql
-- Start a sleep session
INSERT INTO sleep_sessions (patient_id, start_time, status)
VALUES ('YOUR-PATIENT-UUID', NOW(), 'active')
RETURNING *;
```

### 3. Get All Sleep Sessions for Patient
```sql
SELECT * FROM sleep_sessions 
WHERE patient_id = 'YOUR-PATIENT-UUID' 
ORDER BY start_time DESC;
```

---

## Mobile App Usage

The mobile app will have:

1. **Sleep Dashboard** - Shows sleep analytics, charts, and history
2. **Start Sleep Button** - Begins tracking a new sleep session
3. **Pause/Resume Controls** - Records wake-ups during sleep
4. **End Sleep Button** - Completes the session and collects quality rating
5. **Sleep History** - View all past sleep sessions
6. **Analytics** - Weekly/monthly sleep patterns and insights

---

## Next Steps

1. ✅ Run `CREATE_SLEEP_TRACKING_TABLES.sql` in Supabase
2. ⏳ Start backend server (`cd backend && npm run dev`)
3. ⏳ Test API endpoints with Postman or curl
4. ⏳ Build mobile app sleep tracking UI
5. ⏳ Test end-to-end flow with your test patient

---

## Troubleshooting

### If you get "relation already exists" error:
The tables already exist. You can drop them first:
```sql
DROP TABLE IF EXISTS sleep_interruptions CASCADE;
DROP TABLE IF EXISTS sleep_sessions CASCADE;
```
Then re-run the create script.

### If foreign key constraint fails:
Make sure the `users` table exists and has the patient records.

### To check patient IDs:
```sql
SELECT id, email, role FROM users WHERE role = 'patient';
```

---

## Database Relationships

```
users (patient)
  ↓ (patient_id)
sleep_sessions
  ↓ (sleep_session_id)
sleep_interruptions
```

Each patient can have many sleep sessions.
Each sleep session can have many interruptions (wake-ups).

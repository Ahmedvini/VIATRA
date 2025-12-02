# PHQ-9 Backend Setup & Troubleshooting

## ❗ ERROR: "Post /api/v1/psychological-assessment 404 Not Found"

### Possible Causes & Solutions:

## 1. ✅ Database Table Not Created
**Most Likely Cause!**

The SQL migration hasn't been run, so the database doesn't have the `psychological_assessments` table.

### Solution:
```bash
cd /home/ahmedvini/Music/VIATRA/backend

# Check if database is running
psql -U your_username -d your_database_name -c "\dt psychological_assessments"

# If table doesn't exist, run the migration:
psql -U your_username -d your_database_name -f database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql
```

---

## 2. ✅ Backend Not Running or Not Restarted
If you added the routes but didn't restart the backend server.

### Solution:
```bash
cd /home/ahmedvini/Music/VIATRA/backend

# Stop the server (Ctrl+C) then:
npm run dev

# Or if using pm2:
pm2 restart backend
```

---

## 3. ✅ Route Not Registered
Check if the route is properly registered in the main router.

### Verify:
```bash
cd /home/ahmedvini/Music/VIATRA/backend
grep -n "psychological-assessment" src/routes/index.js
```

Should show:
```javascript
router.use('/psychological-assessment', psychologicalAssessmentRoutes);
```

---

## 4. ✅ Controller Import Error
Check if there are any import errors in the backend.

### Verify:
```bash
cd /home/ahmedvini/Music/VIATRA/backend
npm run dev
# Check console for any import errors
```

---

## 5. ✅ Database Connection Issue
The model can't connect to the database.

### Verify:
```bash
# Check backend logs when starting
cd /home/ahmedvini/Music/VIATRA/backend
npm run dev

# Should see:
# ✓ Database connected
# ✓ All models loaded
```

---

## 🔍 Quick Diagnostic Steps

### Step 1: Check Backend Logs
```bash
cd /home/ahmedvini/Music/VIATRA/backend
npm run dev
```
Look for errors when the server starts.

### Step 2: Test Backend Route Directly
```bash
# Get auth token first (login)
TOKEN="your_jwt_token_here"

# Test the endpoint
curl -X GET "http://localhost:8080/api/v1/psychological-assessment/questions" \
  -H "Authorization: Bearer $TOKEN"

# Should return the PHQ-9 questions
```

### Step 3: Check if Route Exists
```bash
cd /home/ahmedvini/Music/VIATRA/backend
node -e "
const routes = require('./src/routes/index.js');
console.log('Routes loaded');
"
```

### Step 4: Verify Database Table
```bash
# Connect to your database
psql -U your_username -d your_database_name

# Check if table exists
\dt psychological_assessments

# If exists, check structure
\d psychological_assessments
```

---

## 📋 Complete Setup Checklist

- [ ] SQL migration file created at `backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`
- [ ] **SQL migration executed on database** ← MOST IMPORTANT!
- [ ] Controller exists at `backend/src/controllers/psychologicalAssessmentController.js`
- [ ] Routes exist at `backend/src/routes/psychologicalAssessment.js`
- [ ] Routes registered in `backend/src/routes/index.js`
- [ ] Backend server restarted after adding routes
- [ ] Database connection working
- [ ] Auth middleware configured

---

## 🚀 Quick Fix Command

If the table doesn't exist, run this:

```bash
# Navigate to backend
cd /home/ahmedvini/Music/VIATRA/backend

# Run migration (adjust DB credentials)
psql -U postgres -d viatra_db -f database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql

# Restart backend
npm run dev
```

---

## 🧪 Test the Endpoint

After fixing, test with this:

```bash
# Login first to get token
curl -X POST "http://localhost:8080/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"your_email","password":"your_password"}'

# Copy the token, then test PHQ-9:
curl -X POST "http://localhost:8080/api/v1/psychological-assessment/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "q1_interest": 0,
    "q2_feeling_down": 1,
    "q3_sleep": 2,
    "q4_energy": 1,
    "q5_appetite": 0,
    "q6_self_worth": 1,
    "q7_concentration": 2,
    "q8_movement": 0,
    "q9_self_harm": 0
  }'
```

---

## ✅ Expected Response

If working correctly:
```json
{
  "success": true,
  "message": "Assessment submitted successfully",
  "data": {
    "assessment": {
      "id": "...",
      "total_score": 7,
      "severity_level": "mild",
      ...
    },
    "recommendations": [...],
    "severity_display": {...}
  }
}
```

---

## 💡 Most Common Issue

**90% of the time it's:** The SQL migration wasn't run!

**Solution:**
1. Find your database credentials
2. Run the SQL file: `psql -U username -d database_name -f database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`
3. Restart backend: `npm run dev`
4. Test again from mobile app

---

Created: December 2, 2024  
For: PHQ-9 Backend Troubleshooting

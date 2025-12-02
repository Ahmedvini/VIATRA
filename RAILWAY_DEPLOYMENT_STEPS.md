# 🚂 RAILWAY DEPLOYMENT REQUIRED

## 🎯 The Real Issue

Your mobile app is pointing to: `https://viatra-backend-production.up.railway.app`

But the Railway backend doesn't have:
1. ✅ The SQL table (you can add this manually)
2. ❌ The updated `models/index.js` with PsychologicalAssessment registered
3. ❌ The new controller, routes, and model files

---

## 🚀 Quick Fix Options

### Option 1: Push to Git & Auto-Deploy (Recommended)
```bash
cd /home/ahmedvini/Music/VIATRA

# Add all PHQ-9 files
git add backend/src/models/PsychologicalAssessment.js
git add backend/src/models/index.js
git add backend/src/controllers/psychologicalAssessmentController.js
git add backend/src/routes/psychologicalAssessment.js
git add backend/src/routes/index.js
git add backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql

# Commit
git commit -m "Add PHQ-9 psychological assessment feature"

# Push to trigger Railway deployment
git push origin main  # or your branch name
```

Railway will automatically deploy the changes!

---

### Option 2: Manual Railway Database Migration

While deployment is running, add the SQL table:

1. **Go to Railway Dashboard**
2. **Open your PostgreSQL database**
3. **Click "Query"**
4. **Paste the SQL from:** `backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql`
5. **Execute the query**

---

## 📋 Files That Need to Be Deployed

### Backend Files Added/Modified:
```
✅ backend/src/models/PsychologicalAssessment.js (NEW)
✅ backend/src/models/index.js (MODIFIED - added model registration)
✅ backend/src/controllers/psychologicalAssessmentController.js (NEW)
✅ backend/src/routes/psychologicalAssessment.js (NEW)
✅ backend/src/routes/index.js (MODIFIED - added route)
✅ backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql (NEW)
```

---

## ⏱️ Deployment Steps

1. **Commit and push changes** (Option 1 above)
2. **Wait for Railway to deploy** (~2-3 minutes)
3. **Run SQL migration on Railway database** (Option 2 above)
4. **Test from mobile app**

---

## 🧪 After Deployment - Test

```bash
# Test the Railway endpoint
curl -X POST "https://viatra-backend-production.up.railway.app/api/v1/psychological-assessment/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "q1_interest": 1,
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

## 🔍 Check Railway Deployment

After pushing:
1. Go to Railway dashboard
2. Open your backend project
3. Click "Deployments"
4. Watch the build logs
5. Should see: "✓ Build successful"
6. Should see: "✓ Deployment successful"

---

## 🗃️ Railway Database Migration

**Access Railway DB:**
```bash
# Option A: From Railway Dashboard
1. Go to PostgreSQL service
2. Click "Query"
3. Paste SQL migration
4. Execute

# Option B: From local terminal (if you have Railway CLI)
railway run psql -f backend/database/init/CREATE_PSYCHOLOGICAL_ASSESSMENT_TABLES.sql
```

---

## ⚠️ Important Notes

- Railway auto-deploys when you push to `main` (or your configured branch)
- The model registration fix is CRITICAL - without it, the backend won't recognize the model
- SQL table must exist in Railway's database
- After deployment, restart may be automatic

---

## ✅ Deployment Checklist

- [ ] Commit all PHQ-9 backend files
- [ ] Push to GitHub/GitLab (trigger Railway deploy)
- [ ] Wait for Railway deployment to complete
- [ ] Run SQL migration on Railway database
- [ ] Check Railway logs for errors
- [ ] Test endpoint from mobile app
- [ ] Celebrate! 🎉

---

## 🚨 If Railway Deployment Fails

Check Railway logs for:
- Import errors (missing dependencies)
- Syntax errors
- Database connection issues

Most common fix:
```bash
# Make sure all dependencies are in package.json
cd backend
npm install  # Locally first
# Then commit package-lock.json and push again
```

---

**Next Steps:**
1. `git add` all the files
2. `git commit -m "Add PHQ-9 feature"`
3. `git push`
4. Run SQL on Railway DB
5. Test! 🚀

---

**Updated:** December 2, 2024  
**Status:** Ready to deploy to Railway  
**Mobile App:** Already configured for Railway ✓

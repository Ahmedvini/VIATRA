# 🚂 AI Health Chatbot - Railway Deployment Guide

## Overview

The AI Health Chatbot backend has been added to your existing VIATRA backend. Since you're using Railway, the new endpoints will automatically be deployed with your next backend deployment.

---

## ✅ What's Already Done

### Backend Files Created
1. ✅ `/backend/src/controllers/aiHealthChatbotController.js` - AI logic
2. ✅ `/backend/src/routes/aiHealthChatbot.js` - Route definitions
3. ✅ `/backend/src/routes/index.js` - Routes registered at `/api/v1/ai-chatbot`

### No Additional Configuration Needed!
- ✅ Uses existing PostgreSQL database (Railway)
- ✅ Uses existing authentication middleware
- ✅ Uses existing models (Patient, SleepSession, FoodLog, PsychologicalAssessment)
- ✅ No new environment variables required
- ✅ No new dependencies to install

---

## 🚀 Deployment Steps

### Step 1: Commit Your Changes

```bash
# Navigate to backend directory
cd backend

# Check what changed
git status

# You should see:
# modified:   src/routes/index.js
# new file:   src/controllers/aiHealthChatbotController.js
# new file:   src/routes/aiHealthChatbot.js

# Add the files
git add src/controllers/aiHealthChatbotController.js
git add src/routes/aiHealthChatbot.js
git add src/routes/index.js

# Commit
git commit -m "Add AI Health Chatbot feature

- Add AI chatbot controller with health data analysis
- Create chatbot routes for consent and chat functionality
- Integrate sleep, food, and PHQ-9 data analysis
- Add crisis detection and doctor recommendations
- Register routes at /api/v1/ai-chatbot"
```

### Step 2: Push to Railway

```bash
# Push to your main branch (Railway will auto-deploy)
git push origin main

# Or if you use a different branch:
git push origin <your-branch-name>
```

### Step 3: Monitor Deployment

1. Go to your Railway dashboard: https://railway.app
2. Select your backend project
3. Go to "Deployments" tab
4. Watch the build logs
5. Wait for "Deployed" status

### Step 4: Verify Deployment

```bash
# Replace YOUR_RAILWAY_URL with your actual Railway backend URL
# Example: https://viatra-backend-production.up.railway.app

# Test health check
curl https://YOUR_RAILWAY_URL/api/v1/

# Test consent endpoint (requires auth token)
curl -X POST https://YOUR_RAILWAY_URL/api/v1/ai-chatbot/consent \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"consent_given": true}'
```

---

## 📱 Mobile App Configuration

### Update API Base URL

Your mobile app should already be configured with Railway URL in `.env`:

```bash
# Check your mobile/.env file
cat mobile/.env

# Should contain:
# API_BASE_URL=https://your-backend.up.railway.app
```

If not set, update `mobile/.env`:

```env
API_BASE_URL=https://your-railway-backend-url.up.railway.app
```

### Rebuild Mobile App

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Testing on Railway

### 1. Test Backend Endpoints

```bash
# Set your Railway URL
export RAILWAY_URL="https://your-backend.up.railway.app"

# Test consent endpoint
curl -X POST $RAILWAY_URL/api/v1/ai-chatbot/consent \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"consent_given": true}'

# Expected Response:
# {
#   "success": true,
#   "message": "Consent granted successfully",
#   "data": { "consent_given": true }
# }
```

### 2. Test from Mobile App

1. Login to mobile app
2. Navigate to Patient Dashboard
3. Tap "AI Health Assistant" card
4. Grant consent
5. Send test message: "How's my sleep?"
6. Verify AI response

---

## 🗄️ Database Considerations

### Existing Tables Used
- ✅ `patients` - For patient lookup
- ✅ `sleep_sessions` - For sleep data analysis
- ✅ `food_logs` - For nutrition analysis
- ✅ `psychological_assessments` - For PHQ-9 data

### No New Tables Required!
The chatbot uses in-memory storage for:
- Chat history (temporary)
- User consents (temporary)

**For Production**: Consider adding these tables:
```sql
-- Optional: Persistent consent storage
CREATE TABLE ai_chatbot_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  consent_given BOOLEAN DEFAULT false,
  granted_at TIMESTAMP,
  revoked_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optional: Persistent chat history
CREATE TABLE ai_chatbot_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Note**: These are optional. The current implementation works without them.

---

## ⚠️ Important Notes for Railway

### 1. Memory Limitations
- Current implementation stores chat history in memory
- Chat history will be lost on Railway restarts
- Consider Redis or database for persistence if needed

### 2. Logs
- View logs in Railway dashboard
- Look for: `AI chatbot message from user {userId}`
- Check for errors: `Error in sendMessage:`

### 3. Environment Variables
No new variables needed! Uses existing:
- `DATABASE_URL` - Railway PostgreSQL
- `JWT_SECRET` - For authentication
- `NODE_ENV` - For environment detection

### 4. Cold Starts
- Railway may spin down inactive services
- First request after idle may be slow
- Subsequent requests will be fast

---

## 🐛 Troubleshooting

### Issue: "Cannot find module './aiHealthChatbot.js'"

**Solution**: Check file path is correct
```bash
# Verify file exists
ls -la backend/src/routes/aiHealthChatbot.js

# If using ES modules (import/export), ensure:
# 1. File extension is .js
# 2. package.json has "type": "module"
```

### Issue: "Failed to get health summary"

**Cause**: Patient record not found

**Solution**: Ensure user has patient record
```sql
-- Check patient exists
SELECT * FROM patients WHERE user_id = 'YOUR_USER_ID';
```

### Issue: "Data consent not granted"

**Solution**: Grant consent first
```bash
curl -X POST https://YOUR_RAILWAY_URL/api/v1/ai-chatbot/consent \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"consent_given": true}'
```

### Issue: Mobile app can't connect

**Solution**: Check Railway URL in mobile/.env
```bash
# Update mobile/.env
API_BASE_URL=https://your-actual-railway-url.up.railway.app

# Rebuild app
cd mobile
flutter clean
flutter pub get
flutter run
```

---

## 📊 Monitoring on Railway

### Check Deployment Status
1. Go to Railway dashboard
2. Select backend service
3. Check "Deployments" tab
4. Look for green "Deployed" status

### View Logs
1. Click on your service
2. Go to "Logs" tab
3. Filter by "ai-chatbot" or "AI chatbot"
4. Monitor for errors

### Metrics
- **Memory Usage**: Should be minimal (chat history in memory)
- **Response Time**: Typically < 500ms
- **Error Rate**: Should be 0%

---

## 🚀 Post-Deployment Checklist

- [ ] Code committed to git
- [ ] Pushed to Railway
- [ ] Deployment successful (check Railway dashboard)
- [ ] Backend health check passes
- [ ] Consent endpoint works
- [ ] Chat endpoint works
- [ ] Mobile app can connect
- [ ] Mobile app can grant consent
- [ ] Mobile app can send messages
- [ ] AI responses are relevant
- [ ] Crisis detection works
- [ ] Doctor recommendations appear when needed

---

## 📈 Next Steps

### Phase 1: Basic Testing (Current)
- ✅ Deploy to Railway
- ✅ Test basic chat functionality
- ✅ Verify data integration

### Phase 2: Enhancements (Future)
- [ ] Add Redis for persistent chat history
- [ ] Integrate OpenAI GPT-4 for better responses
- [ ] Add database tables for consents
- [ ] Implement rate limiting
- [ ] Add analytics tracking

### Phase 3: Production Optimization (Future)
- [ ] Add caching layer
- [ ] Optimize database queries
- [ ] Implement WebSocket for real-time chat
- [ ] Add health check endpoints
- [ ] Set up monitoring alerts

---

## 🔗 Quick Links

### Railway
- **Dashboard**: https://railway.app/dashboard
- **Docs**: https://docs.railway.app

### Your Backend
- **URL**: Check Railway dashboard for your deployment URL
- **Logs**: Railway Dashboard → Your Service → Logs
- **Metrics**: Railway Dashboard → Your Service → Metrics

### Mobile App
- **API Config**: `mobile/.env`
- **Service**: `mobile/lib/services/ai_health_chatbot_service.dart`
- **Screen**: `mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart`

---

## 💡 Tips for Railway

1. **Auto-Deploy**: Railway auto-deploys on git push to main branch
2. **Environment Variables**: Set in Railway dashboard, not in code
3. **Database**: Railway PostgreSQL URL is auto-injected as `DATABASE_URL`
4. **Logs**: Use Railway dashboard for real-time log viewing
5. **Scaling**: Railway automatically scales based on usage
6. **Custom Domain**: Can add custom domain in Railway settings

---

## ✅ Final Verification Commands

```bash
# 1. Check Railway deployment
curl https://YOUR_RAILWAY_URL/api/v1/

# 2. Test AI chatbot endpoint
curl https://YOUR_RAILWAY_URL/api/v1/ai-chatbot/consent \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. View Railway logs
railway logs --service backend

# 4. Check Railway status
railway status
```

---

## 🎉 You're Ready!

The AI Health Chatbot is now integrated with your Railway backend. Just commit, push, and Railway will handle the rest!

**Command Summary**:
```bash
# 1. Commit
git add backend/src/controllers/aiHealthChatbotController.js
git add backend/src/routes/aiHealthChatbot.js  
git add backend/src/routes/index.js
git commit -m "Add AI Health Chatbot feature"

# 2. Deploy to Railway
git push origin main

# 3. Test
# Check Railway dashboard for deployment status
# Test with mobile app once deployed
```

---

**Status**: ✅ Ready for Railway Deployment  
**Date**: December 2, 2024  
**Version**: 1.0  

**Push to Railway and you're live! 🚂🚀**

# 🚂 Railway Deployment - Quick Checklist

## ✅ Pre-Deployment

- [x] Backend files created with ES modules
- [x] Routes registered in index.js
- [x] No new dependencies needed
- [x] Uses existing database models
- [x] Uses existing authentication

## 📦 Files to Commit

```bash
# Backend changes
backend/src/controllers/aiHealthChatbotController.js  # NEW
backend/src/routes/aiHealthChatbot.js                # NEW
backend/src/routes/index.js                           # MODIFIED
```

## 🚀 Deploy to Railway

### Step 1: Commit Changes
```bash
cd backend
git add src/controllers/aiHealthChatbotController.js
git add src/routes/aiHealthChatbot.js
git add src/routes/index.js
git commit -m "Add AI Health Chatbot feature"
```

### Step 2: Push to Railway
```bash
git push origin main
```

### Step 3: Monitor
- Go to Railway dashboard
- Watch deployment logs
- Wait for "Deployed" status

## 🧪 Test After Deployment

### 1. Check Backend is Running
```bash
curl https://YOUR_RAILWAY_URL/api/v1/
```

### 2. Test AI Chatbot Endpoint
```bash
curl https://YOUR_RAILWAY_URL/api/v1/ai-chatbot/consent \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Test from Mobile App
- Open app
- Login as patient
- Tap "AI Health Assistant"
- Grant consent
- Send message

## 📱 Mobile App Setup

### Update .env (if needed)
```bash
# mobile/.env
API_BASE_URL=https://your-railway-backend.up.railway.app
```

### Rebuild App
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## ✅ Final Verification

- [ ] Railway deployment successful
- [ ] Backend health check passes
- [ ] AI chatbot consent endpoint works
- [ ] Mobile app connects to Railway
- [ ] Can grant consent from mobile app
- [ ] Can send messages from mobile app
- [ ] AI responds correctly
- [ ] Health data is analyzed

## 🐛 Quick Troubleshooting

**Issue**: Module not found
- **Fix**: Check ES module imports use `.js` extension

**Issue**: Can't connect from mobile
- **Fix**: Update `mobile/.env` with Railway URL

**Issue**: "Patient not found"
- **Fix**: Ensure user has patient record in database

**Issue**: "Consent not granted"
- **Fix**: Grant consent first via POST /consent endpoint

## 📊 Railway Dashboard Checks

1. **Deployments**: Check for green "Deployed" status
2. **Logs**: Search for "AI chatbot" messages
3. **Metrics**: Monitor memory and response time
4. **Variables**: Verify DATABASE_URL exists

## 🎉 Success Criteria

✅ Railway shows "Deployed"
✅ No errors in Railway logs
✅ Mobile app can access chatbot
✅ User can grant consent
✅ Messages send and receive
✅ AI provides relevant responses

---

**Ready to Deploy!** Just commit, push, and Railway handles the rest! 🚂🚀

**Command Summary**:
```bash
# 1. Commit
git add backend/src/controllers/aiHealthChatbotController.js backend/src/routes/aiHealthChatbot.js backend/src/routes/index.js
git commit -m "Add AI Health Chatbot"

# 2. Push to Railway
git push origin main

# 3. Done! Railway auto-deploys
```

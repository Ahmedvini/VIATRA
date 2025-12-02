# 🤖 AI Health Chatbot - Quick Start

## What It Does

An intelligent health assistant that:
- ✅ Analyzes your sleep, food, and mental health data
- ✅ Provides personalized recommendations
- ✅ Suggests doctor visits when necessary
- ✅ Respects your privacy with explicit consent

---

## 🚀 Quick Test

### Backend
```bash
cd backend
npm run dev
# Backend runs on http://localhost:8080
```

### Mobile
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### Access Chatbot
1. Open app
2. Login as patient
3. Tap **"AI Health Assistant"** on dashboard
4. Grant consent when prompted
5. Start chatting!

---

## 💬 Example Questions

Try asking:
- "How's my sleep?"
- "How am I doing with my diet?"
- "I'm feeling down lately"
- "Am I getting enough rest?"
- "What should I focus on?"

---

## 📁 Key Files

**Mobile:**
- `/mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart`
- `/mobile/lib/services/ai_health_chatbot_service.dart`

**Backend:**
- `/backend/src/controllers/aiHealthChatbotController.js`
- `/backend/src/routes/aiHealthChatbot.js`

---

## 🔧 API Endpoints

**Base**: `/api/v1/ai-chatbot`

- `POST /consent` - Grant consent
- `GET /consent` - Check consent
- `POST /chat` - Send message
- `GET /history` - View history
- `GET /insights` - Get insights

---

## ⚠️ Important

### Crisis Keywords
If user mentions: `suicide`, `kill myself`, `hurt myself`, `emergency`
→ AI provides immediate crisis resources

### Doctor Recommendations
AI suggests doctor visit if:
- Sleep < 5 hours consistently
- Calories < 1200 or > 3000
- PHQ-9 score ≥ 15 (moderately severe depression)

---

## 🎯 Features

- [x] Data consent management
- [x] Sleep analysis
- [x] Nutrition guidance  
- [x] Mental health support
- [x] Crisis detection
- [x] Chat history
- [x] Privacy controls

---

## 📖 Full Documentation

See `AI_HEALTH_CHATBOT_COMPLETE.md` for complete details.

---

**Status**: ✅ Ready for Testing  
**Version**: 1.0  
**Date**: Dec 2, 2024

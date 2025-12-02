# 🎯 QUICK ANSWER: Database Changes for Food Tracking

## ❓ Your Question:
> "What should I change in the database + how should I exactly change it? I want to link each patient to the food table. I want it to contain the things we agreed on."

---

## ✅ ANSWER:

### **What to Change:**
**NOTHING MANUALLY!** Just run one command:

```bash
cd backend
npm run db:migrate
```

---

## 📋 What the Migration Will Do Automatically:

### **1. Create New Table: `food_logs`**

```
┌─────────────────────────────────────────────────┐
│                   food_logs                     │
├─────────────────────────────────────────────────┤
│ id                 UUID PRIMARY KEY             │
│ patient_id         UUID → users.id (LINK!)      │ ← Links each log to a patient
│ meal_type          ENUM (breakfast/lunch/...)   │
│ food_name          VARCHAR                      │
│ description        TEXT                         │
│ image_url          VARCHAR                      │
│ calories           FLOAT                        │
│ protein_grams      FLOAT                        │
│ carbs_grams        FLOAT                        │
│ fat_grams          FLOAT                        │
│ fiber_grams        FLOAT                        │
│ sugar_grams        FLOAT                        │
│ sodium_mg          FLOAT                        │
│ ai_analysis        JSONB                        │
│ ai_confidence      FLOAT                        │
│ serving_size       VARCHAR                      │
│ servings_count     FLOAT                        │
│ consumed_at        TIMESTAMP                    │
│ created_at         TIMESTAMP                    │
│ updated_at         TIMESTAMP                    │
└─────────────────────────────────────────────────┘
          ↑
          │
          │ FOREIGN KEY
          │
          ▼
┌─────────────────────────────────────────────────┐
│                     users                       │
├─────────────────────────────────────────────────┤
│ id                 UUID PRIMARY KEY             │
│ email              VARCHAR                      │
│ role               ENUM (patient/doctor/admin)  │
│ ...                                             │
└─────────────────────────────────────────────────┘
```

---

## 🔗 Patient Linkage - How It Works:

### **The Connection:**
```
Each row in food_logs has patient_id
                ↓
        References users.id
                ↓
    This creates the link!
```

### **Example:**

**users table:**
| id | email | role |
|----|-------|------|
| user-123 | john@patient.com | patient |
| user-456 | jane@patient.com | patient |

**food_logs table (after patients log food):**
| id | patient_id | food_name | calories |
|----|------------|-----------|----------|
| log-1 | user-123 | Apple | 95 |
| log-2 | user-123 | Salad | 350 |
| log-3 | user-456 | Oatmeal | 150 |

**Result:**
- John (user-123) has 2 food logs
- Jane (user-456) has 1 food log
- Each log is **linked** to its patient via `patient_id`

---

## ✅ All Fields We Agreed On:

| Category | Fields | Status |
|----------|--------|--------|
| **Identity** | id, patient_id | ✅ |
| **Food Info** | meal_type, food_name, description, image_url | ✅ |
| **Nutrition** | calories, protein_grams, carbs_grams, fat_grams, fiber_grams, sugar_grams, sodium_mg | ✅ |
| **AI Analysis** | ai_analysis, ai_confidence | ✅ |
| **Serving Info** | serving_size, servings_count | ✅ |
| **Timestamps** | consumed_at, created_at, updated_at | ✅ |

**Total: 20 fields - ALL INCLUDED!** ✅

---

## 🚀 Exact Steps:

### **Step 1: Run Migration**
```bash
cd /home/ahmedvini/Music/VIATRA/backend
npm run db:migrate
```

### **Step 2: Verify (Optional)**
```bash
# Connect to your database
psql $DATABASE_URL

# Check if table was created
\dt food_logs

# Check table structure
\d food_logs
```

### **Step 3: Test API**
```bash
# Login as a patient to get token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"patient@example.com","password":"password"}'

# Upload food image
curl -X POST http://localhost:8080/api/food-tracking/analyze \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@food.jpg" \
  -F "meal_type=lunch"

# Get all food logs (only for authenticated patient)
curl -X GET http://localhost:8080/api/food-tracking \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔐 Security: How Patient Data Stays Private

### **Every API call filters by patient_id:**

```javascript
// When John logs in and requests his food logs:
const patientId = req.user.id; // John's ID from JWT token

// Query only returns John's data:
const foodLogs = await FoodLog.findAll({
  where: { patient_id: patientId }  // Only John's logs
});

// Jane's food logs are NEVER returned to John
// John's food logs are NEVER returned to Jane
```

---

## 📊 Summary Diagram:

```
PATIENT LOGS FOOD
        ↓
┌───────────────────┐
│ POST /analyze     │
│ with image        │
└────────┬──────────┘
         │
         ↓
┌────────────────────┐
│ AI Analyzes Image  │
│ (Gemini Vision)    │
└────────┬───────────┘
         │
         ↓
┌──────────────────────────────┐
│ Create Food Log:             │
│ - patient_id = req.user.id   │ ← LINK TO PATIENT
│ - food_name = "Apple"        │
│ - calories = 95              │
│ - protein_grams = 0.5        │
│ - ... (all other fields)     │
└──────────────────────────────┘
         │
         ↓
┌──────────────────────────────┐
│ Save to Database:            │
│ INSERT INTO food_logs        │
│ VALUES (...)                 │
└──────────────────────────────┘
         │
         ↓
┌──────────────────────────────┐
│ Return Data to Patient       │
└──────────────────────────────┘
```

---

## ✅ What's Ready:

- ✅ Migration file: `backend/src/migrations/20251202-create-food-logs.js`
- ✅ Model: `backend/src/models/FoodLog.js`
- ✅ Controller: `backend/src/controllers/foodTrackingController.js`
- ✅ Routes: `backend/src/routes/foodTracking.js`
- ✅ Associations: `backend/src/models/index.js`
- ✅ Patient Linkage: Every operation uses `patient_id`
- ✅ Security: All queries filter by authenticated patient
- ✅ All 20 fields we agreed on

---

## 🎯 Bottom Line:

**You don't need to manually change anything in the database!**

Just run:
```bash
cd backend && npm run db:migrate
```

This will:
1. ✅ Create the `food_logs` table
2. ✅ Add all 20 fields we agreed on
3. ✅ Set up the foreign key linking `patient_id` → `users.id`
4. ✅ Create indexes for fast queries
5. ✅ Configure cascade deletion

**Then you're done!** The food tracking feature is ready to use. 🎉

---

## 📚 Documentation:

For more details, see:
- `DATABASE_CHANGES_EXPLAINED.md` - Complete explanation
- `FOOD_TRACKING_SETUP_GUIDE.md` - Step-by-step guide
- `FOOD_TRACKING_STATUS.md` - Implementation status
- `FOOD_TRACKING_DATABASE.md` - API documentation

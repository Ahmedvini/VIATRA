# 🎯 Food Tracking Database Setup Guide

## What You Need to Do - EXACT STEPS

### ✅ Current Status
- ✅ Database migration file created: `backend/src/migrations/20251202-create-food-logs.js`
- ✅ Model properly configured: `backend/src/models/FoodLog.js`
- ✅ Controller ready: `backend/src/controllers/foodTrackingController.js`
- ✅ Routes registered: `backend/src/routes/foodTracking.js`
- ✅ **Patient linkage configured:** Every food log is linked to a patient via `patient_id`

---

## 📊 Database Changes Required

### **Step 1: Run the Migration**

The migration will create a new table called `food_logs` in your database.

**Command to run (in backend directory):**
```bash
cd backend
npm run db:migrate
```

This will execute the migration file and create the following table:

---

### **Step 2: What the Migration Creates**

#### Table Name: `food_logs`

```sql
CREATE TABLE food_logs (
  -- PRIMARY KEY
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- PATIENT LINK (This links each food log to a specific patient)
  patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- FOOD INFORMATION
  meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  food_name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  
  -- NUTRITION DATA (from AI analysis)
  calories FLOAT,
  protein_grams FLOAT,
  carbs_grams FLOAT,
  fat_grams FLOAT,
  fiber_grams FLOAT,
  sugar_grams FLOAT,
  sodium_mg FLOAT,
  
  -- AI ANALYSIS
  ai_analysis JSONB,
  ai_confidence FLOAT,
  
  -- SERVING INFO
  serving_size VARCHAR(255),
  servings_count FLOAT DEFAULT 1.0,
  
  -- TIMESTAMPS
  consumed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- INDEXES (for fast queries)
CREATE INDEX idx_patient_id ON food_logs(patient_id);
CREATE INDEX idx_consumed_at ON food_logs(consumed_at);
CREATE INDEX idx_patient_consumed ON food_logs(patient_id, consumed_at);
CREATE INDEX idx_meal_type ON food_logs(meal_type);
```

---

## 🔗 How Patient Linking Works

### **Foreign Key Relationship:**
```
users table (patients)
    ↓
    id (UUID)
    ↓
    ↓ ONE-TO-MANY
    ↓
food_logs table
    ↓
    patient_id (FOREIGN KEY → users.id)
```

### **What This Means:**
1. Every food log **MUST** have a `patient_id`
2. The `patient_id` **MUST** reference a valid `id` in the `users` table
3. If a user (patient) is deleted, all their food logs are automatically deleted (CASCADE)
4. Each patient can have unlimited food logs
5. Each food log belongs to exactly ONE patient

---

## 📋 Fields We Agreed On - ALL INCLUDED ✅

### **Identity & Linking:**
- ✅ `id` - Unique identifier for each food log
- ✅ `patient_id` - Links to the patient who logged this food

### **Food Information:**
- ✅ `meal_type` - breakfast, lunch, dinner, or snack
- ✅ `food_name` - Name of the food (AI-detected)
- ✅ `description` - Additional details
- ✅ `image_url` - Photo of the food (stored in Google Cloud Storage)

### **Nutritional Data (AI-Analyzed):**
- ✅ `calories` - Total energy
- ✅ `protein_grams` - Protein content
- ✅ `carbs_grams` - Carbohydrate content
- ✅ `fat_grams` - Fat content
- ✅ `fiber_grams` - Fiber content
- ✅ `sugar_grams` - Sugar content
- ✅ `sodium_mg` - Sodium content

### **AI Analysis:**
- ✅ `ai_analysis` - Full Gemini AI response (JSON format)
- ✅ `ai_confidence` - Confidence score (0-1)

### **Serving Information:**
- ✅ `serving_size` - e.g., "1 cup", "200g", "1 medium apple"
- ✅ `servings_count` - How many servings (e.g., 1.5)

### **Timestamps:**
- ✅ `consumed_at` - When the food was eaten
- ✅ `created_at` - When the log was created
- ✅ `updated_at` - When the log was last updated

---

## 🔐 How Patient Data Is Isolated

### **When a patient logs food:**
```javascript
// The controller extracts patient_id from the authenticated user's token
const patientId = req.user.id;

// Creates food log linked to this patient
await FoodLog.create({
  patient_id: patientId,  // ← Links to the user
  meal_type: 'lunch',
  food_name: 'Grilled Chicken Salad',
  // ... other fields
});
```

### **When a patient fetches their food logs:**
```javascript
// Only returns logs belonging to this patient
const foodLogs = await FoodLog.findAll({
  where: { patient_id: req.user.id }  // ← Security filter
});
```

### **When a patient updates/deletes a food log:**
```javascript
// Verifies ownership before allowing the action
const foodLog = await FoodLog.findOne({
  where: { 
    id: logId,
    patient_id: req.user.id  // ← Security check
  }
});
```

---

## 🚀 Running the Migration

### **Option 1: Local Development**
```bash
cd backend
npm run db:migrate
```

### **Option 2: Production (Railway)**
You have two options:

**A) Via Railway Dashboard:**
1. Go to your Railway project
2. Click on your backend service
3. Go to the "Deploy" tab
4. Add a one-time command: `npm run db:migrate`
5. Click "Deploy"

**B) Via Railway CLI:**
```bash
railway run npm run db:migrate
```

---

## ✅ Verification

After running the migration, verify it was successful:

### **Check if table exists:**
```sql
SELECT * FROM information_schema.tables WHERE table_name = 'food_logs';
```

### **Check table structure:**
```sql
\d food_logs;
```

### **Check foreign key:**
```sql
SELECT
  tc.constraint_name, 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'food_logs' AND tc.constraint_type = 'FOREIGN KEY';
```

Expected output:
```
constraint_name | table_name | column_name | foreign_table_name | foreign_column_name
----------------|------------|-------------|--------------------|--------------------- 
food_logs_patient_id_fkey | food_logs | patient_id | users | id
```

---

## 📝 Summary

### **What's being created:**
- A new table called `food_logs`

### **What it contains:**
- 20 fields (all the ones we agreed on)
- Foreign key linking each log to a patient
- 4 indexes for fast queries

### **How patient linking works:**
- `patient_id` column in `food_logs` → references `id` in `users` table
- Each food log belongs to exactly one patient
- Each patient can have many food logs
- Automatic deletion cascade (delete patient → delete their logs)

### **Security:**
- All queries filter by `patient_id = authenticated_user.id`
- No patient can see another patient's food logs
- No patient can modify another patient's food logs

---

## 🎯 Next Steps After Migration

1. ✅ Run migration: `npm run db:migrate`
2. ✅ Verify table was created
3. ✅ Test API endpoints:
   - POST `/api/food-tracking/analyze` - Log food with AI
   - GET `/api/food-tracking` - Get all my food logs
   - GET `/api/food-tracking/:id` - Get one food log
   - PUT `/api/food-tracking/:id` - Update food log
   - DELETE `/api/food-tracking/:id` - Delete food log
   - GET `/api/food-tracking/summary` - Get nutrition summary

4. ✅ Integrate with mobile app
5. ✅ Implement remaining health features (sleep, weight, water, etc.)

---

## 🔥 Ready to Go!

Everything is configured correctly. Just run the migration and you're good to go!

```bash
cd backend
npm run db:migrate
```

That's it! The food tracking feature is fully implemented with proper patient linkage. 🎉

# ❓ Your Question: What Should I Change in the Database?

## ✅ ANSWER: You don't need to change anything manually!

### 🎯 What You Need to Do:

Just run this ONE command in your backend directory:

```bash
cd backend
npm run db:migrate
```

That's it! The migration will automatically create the entire `food_logs` table with all the correct fields and patient linkage.

---

## 📊 What the Migration Will Create Automatically:

### **Table Structure:**
```
food_logs
├── id (UUID, PRIMARY KEY)
├── patient_id (UUID, FOREIGN KEY → users.id) ← PATIENT LINK
├── meal_type (breakfast/lunch/dinner/snack)
├── food_name
├── description
├── image_url
├── calories
├── protein_grams
├── carbs_grams
├── fat_grams
├── fiber_grams
├── sugar_grams
├── sodium_mg
├── ai_analysis (JSONB)
├── ai_confidence
├── serving_size
├── servings_count
├── consumed_at
├── created_at
└── updated_at
```

### **Foreign Key (Patient Link):**
```sql
ALTER TABLE food_logs
ADD CONSTRAINT food_logs_patient_id_fkey
FOREIGN KEY (patient_id) 
REFERENCES users(id)
ON DELETE CASCADE
ON UPDATE CASCADE;
```

### **Indexes (for fast queries):**
```sql
CREATE INDEX idx_patient_id ON food_logs(patient_id);
CREATE INDEX idx_consumed_at ON food_logs(consumed_at);
CREATE INDEX idx_patient_consumed ON food_logs(patient_id, consumed_at);
CREATE INDEX idx_meal_type ON food_logs(meal_type);
```

---

## 🔗 How Patient Linking Works - EXPLAINED

### **The Relationship:**
```
┌─────────────┐
│   users     │ ← This is where your patients are stored
│  (patients) │
└──────┬──────┘
       │
       │ ONE patient
       │
       │ can have
       │
       ▼ MANY food logs
┌─────────────┐
│  food_logs  │
│             │
│ patient_id ─┤ ← This field links back to users.id
└─────────────┘
```

### **In Simple Terms:**
1. Every time a patient logs food, a new row is added to `food_logs`
2. That row has a `patient_id` column that stores the patient's user ID
3. This creates the link: "This food log belongs to THIS patient"

### **Example Data:**

**users table:**
| id | email | role |
|----|-------|------|
| abc-123 | john@example.com | patient |
| def-456 | jane@example.com | patient |

**food_logs table:**
| id | patient_id | food_name | calories |
|----|------------|-----------|----------|
| log-1 | abc-123 | Apple | 95 |
| log-2 | abc-123 | Chicken Salad | 350 |
| log-3 | def-456 | Oatmeal | 150 |

- John (abc-123) has 2 food logs
- Jane (def-456) has 1 food log
- Each log is linked to its owner via `patient_id`

---

## 🔐 Security - How We Ensure Privacy

### **When Patient John logs in and requests his food logs:**

```javascript
// 1. John's token contains his user ID: abc-123
const patientId = req.user.id; // abc-123

// 2. Query filters by HIS patient_id
const foodLogs = await FoodLog.findAll({
  where: { patient_id: 'abc-123' }
});

// 3. Result: Only John's food logs (log-1 and log-2)
// Jane's data (log-3) is NOT returned
```

### **When Patient Jane tries to view John's food log:**

```javascript
// Jane's token: def-456
// She tries to access log-1 (which belongs to John)

const foodLog = await FoodLog.findOne({
  where: { 
    id: 'log-1',
    patient_id: 'def-456'  // Jane's ID
  }
});

// Result: null (not found)
// Because log-1 has patient_id = 'abc-123' (John's ID)
```

---

## ✅ All the Fields We Agreed On - INCLUDED

| Field | Type | Purpose | Included? |
|-------|------|---------|-----------|
| id | UUID | Unique identifier | ✅ |
| patient_id | UUID | Link to patient | ✅ |
| meal_type | ENUM | breakfast/lunch/dinner/snack | ✅ |
| food_name | STRING | Name of food | ✅ |
| description | TEXT | Additional details | ✅ |
| image_url | STRING | Photo URL | ✅ |
| calories | FLOAT | Energy content | ✅ |
| protein_grams | FLOAT | Protein content | ✅ |
| carbs_grams | FLOAT | Carb content | ✅ |
| fat_grams | FLOAT | Fat content | ✅ |
| fiber_grams | FLOAT | Fiber content | ✅ |
| sugar_grams | FLOAT | Sugar content | ✅ |
| sodium_mg | FLOAT | Sodium content | ✅ |
| ai_analysis | JSONB | Full AI response | ✅ |
| ai_confidence | FLOAT | AI confidence (0-1) | ✅ |
| serving_size | STRING | e.g., "1 cup" | ✅ |
| servings_count | FLOAT | Number of servings | ✅ |
| consumed_at | TIMESTAMP | When eaten | ✅ |
| created_at | TIMESTAMP | When logged | ✅ |
| updated_at | TIMESTAMP | Last update | ✅ |

**Total: 20 fields - ALL the ones we agreed on! ✅**

---

## 🚀 Exact Steps to Set Up

### **1. Run the Migration:**
```bash
cd backend
npm run db:migrate
```

### **2. Verify It Worked:**
```bash
# Connect to your database and run:
\dt food_logs
```

You should see:
```
Schema |    Name    | Type  |  Owner
-------|------------|-------|----------
public | food_logs  | table | postgres
```

### **3. Test the Foreign Key:**
```sql
SELECT * FROM food_logs LIMIT 1;
```

If the table is empty (no food logs yet), that's fine! It means it's ready to receive data.

---

## 🎯 What Happens After Migration

### **The Backend API is Already Ready:**

1. **POST /api/food-tracking/analyze**
   - Patient uploads food image
   - AI analyzes it
   - Creates food log with `patient_id = req.user.id`
   - Returns nutrition data

2. **GET /api/food-tracking**
   - Returns ONLY the authenticated patient's food logs
   - Filters by `patient_id = req.user.id`

3. **GET /api/food-tracking/summary**
   - Calculates nutrition totals for date range
   - Only for the authenticated patient's data

4. **PUT /api/food-tracking/:id**
   - Updates food log
   - Only if it belongs to the authenticated patient

5. **DELETE /api/food-tracking/:id**
   - Deletes food log
   - Only if it belongs to the authenticated patient

---

## 📝 Summary - What to Change in Database

### **SHORT ANSWER:**
**Nothing manually! Just run the migration.**

### **LONG ANSWER:**
The migration file (`backend/src/migrations/20251202-create-food-logs.js`) contains all the SQL commands needed to:

1. ✅ Create the `food_logs` table
2. ✅ Add all 20 fields we agreed on
3. ✅ Create the foreign key linking `patient_id` → `users.id`
4. ✅ Set up CASCADE deletion (delete patient → delete their logs)
5. ✅ Create 4 indexes for fast queries
6. ✅ Set up proper data types and constraints

All you need to do is run:
```bash
npm run db:migrate
```

---

## 🔥 Ready to Deploy!

Everything is configured correctly:
- ✅ Migration file ready
- ✅ Model properly configured
- ✅ Controller with all CRUD operations
- ✅ Routes registered and protected
- ✅ Patient linkage set up
- ✅ Security filters in place
- ✅ All agreed fields included

**Just run the migration and you're done!** 🎉

```bash
cd backend
npm run db:migrate
```

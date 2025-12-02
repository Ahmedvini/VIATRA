# 🎯 Create Food Logs Table MANUALLY in Supabase

## ✅ YES! You Can Do It Manually!

Instead of running migrations, you can create the `food_logs` table directly in Supabase SQL Editor.

---

## 📋 STEP-BY-STEP GUIDE:

### **Step 1: Open Supabase Dashboard**
1. Go to https://supabase.com
2. Login to your account
3. Select your VIATRA project

### **Step 2: Open SQL Editor**
1. In the left sidebar, click **"SQL Editor"**
2. Click **"New Query"** button
3. You'll see an empty SQL editor

### **Step 3: Copy and Paste the SQL Script**
1. Open the file: **`CREATE_FOOD_LOGS_TABLE.sql`** (in project root)
2. Copy ALL the SQL code
3. Paste it into the Supabase SQL Editor

### **Step 4: Run the Script**
1. Click the **"Run"** button (or press `Ctrl+Enter` / `Cmd+Enter`)
2. Wait a few seconds for execution
3. Check the output panel at the bottom

### **Step 5: Verify Success**
You should see output like:
```
✅ food_logs table created successfully!
✅ Patient linkage: patient_id → users.id
✅ 20 fields created
✅ 4 indexes created
✅ Auto-update trigger created
🎉 Food tracking feature is ready to use!
```

---

## 🔍 VERIFY THE TABLE WAS CREATED:

### **Option 1: Using Supabase Table Editor**
1. Go to **"Table Editor"** in left sidebar
2. Look for **"food_logs"** in the table list
3. Click on it to see all columns

### **Option 2: Using SQL**
Run this query in SQL Editor:
```sql
SELECT * FROM food_logs LIMIT 1;
```

If you see "Success. No rows returned", that means the table exists but is empty (which is correct!).

### **Option 3: Check Table Structure**
Run this query:
```sql
\d food_logs
```
Or:
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'food_logs'
ORDER BY ordinal_position;
```

---

## 📊 WHAT GETS CREATED:

### **Table: food_logs**
| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | NO | Primary key |
| patient_id | UUID | NO | Foreign key → users.id |
| meal_type | VARCHAR(20) | NO | breakfast/lunch/dinner/snack |
| food_name | VARCHAR(255) | NO | Name of food |
| description | TEXT | YES | Additional details |
| image_url | VARCHAR(255) | YES | Photo URL (GCS) |
| calories | FLOAT | YES | Energy content |
| protein_grams | FLOAT | YES | Protein content |
| carbs_grams | FLOAT | YES | Carb content |
| fat_grams | FLOAT | YES | Fat content |
| fiber_grams | FLOAT | YES | Fiber content |
| sugar_grams | FLOAT | YES | Sugar content |
| sodium_mg | FLOAT | YES | Sodium content |
| ai_analysis | JSONB | YES | Full AI response |
| ai_confidence | FLOAT | YES | AI confidence (0-1) |
| serving_size | VARCHAR(255) | YES | e.g., "1 cup" |
| servings_count | FLOAT | NO | Number of servings (default: 1.0) |
| consumed_at | TIMESTAMP | NO | When food was eaten |
| created_at | TIMESTAMP | NO | When log was created |
| updated_at | TIMESTAMP | NO | Last update time |

**Total: 20 columns** ✅

### **Foreign Key:**
```
patient_id → users.id
  ON DELETE CASCADE
  ON UPDATE CASCADE
```
**Meaning:** When a user (patient) is deleted, all their food logs are automatically deleted.

### **Indexes (for fast queries):**
1. `idx_food_logs_patient_id` - Query logs by patient
2. `idx_food_logs_consumed_at` - Query logs by date
3. `idx_food_logs_patient_consumed` - Query logs by patient AND date (compound)
4. `idx_food_logs_meal_type` - Query logs by meal type

### **Trigger:**
- Auto-updates `updated_at` timestamp whenever a row is modified

---

## 🎯 AFTER TABLE IS CREATED:

### **Test the API Endpoints:**

1. **Login as a patient:**
```bash
curl -X POST https://your-backend-url.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"patient@example.com","password":"password"}'
```

2. **Upload food image:**
```bash
curl -X POST https://your-backend-url.com/api/food-tracking/analyze \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/food.jpg" \
  -F "meal_type=lunch"
```

3. **Get all food logs:**
```bash
curl -X GET https://your-backend-url.com/api/food-tracking \
  -H "Authorization: Bearer YOUR_TOKEN"
```

4. **Get nutrition summary:**
```bash
curl -X GET "https://your-backend-url.com/api/food-tracking/summary?start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔐 ROW LEVEL SECURITY (RLS) - Optional but Recommended:

If you want to add extra security in Supabase (so patients can only see their own logs):

```sql
-- Enable RLS on food_logs table
ALTER TABLE food_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own food logs
CREATE POLICY "Users can view own food logs"
  ON food_logs
  FOR SELECT
  USING (auth.uid() = patient_id);

-- Policy: Users can only insert their own food logs
CREATE POLICY "Users can insert own food logs"
  ON food_logs
  FOR INSERT
  WITH CHECK (auth.uid() = patient_id);

-- Policy: Users can only update their own food logs
CREATE POLICY "Users can update own food logs"
  ON food_logs
  FOR UPDATE
  USING (auth.uid() = patient_id);

-- Policy: Users can only delete their own food logs
CREATE POLICY "Users can delete own food logs"
  ON food_logs
  FOR DELETE
  USING (auth.uid() = patient_id);
```

**Note:** Only add RLS if you're using Supabase auth. If you're using your own JWT auth (like in the backend), you don't need this.

---

## 📝 TROUBLESHOOTING:

### **Error: "relation 'users' does not exist"**
**Solution:** Make sure the `users` table exists first. Run:
```sql
SELECT * FROM users LIMIT 1;
```
If this fails, you need to create the users table first.

### **Error: "uuid_generate_v4() does not exist"**
**Solution:** Enable the UUID extension:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### **Error: "permission denied"**
**Solution:** Make sure you're logged in as the database owner or have CREATE permissions.

---

## ✅ ADVANTAGES OF MANUAL CREATION:

1. ✅ **No migration errors** - Direct table creation
2. ✅ **Visual feedback** - See results immediately in Supabase UI
3. ✅ **Easy verification** - Check in Table Editor
4. ✅ **One-time operation** - No need to track migration state
5. ✅ **Full control** - Modify the SQL if needed

---

## 🎉 SUMMARY:

### **File to Use:**
📄 **`CREATE_FOOD_LOGS_TABLE.sql`** (in project root)

### **Where to Run:**
🌐 **Supabase Dashboard → SQL Editor**

### **What It Does:**
1. ✅ Creates `food_logs` table
2. ✅ Links to patients via `patient_id` foreign key
3. ✅ Adds all 20 fields we agreed on
4. ✅ Creates 4 indexes for performance
5. ✅ Sets up auto-update trigger
6. ✅ Verifies everything was created correctly

### **Time Required:**
⏱️ **~30 seconds** total

---

## 🚀 YOU'RE READY!

Just:
1. Copy the SQL from `CREATE_FOOD_LOGS_TABLE.sql`
2. Paste into Supabase SQL Editor
3. Click Run
4. Done! ✅

No migrations, no errors, just direct table creation! 🎯

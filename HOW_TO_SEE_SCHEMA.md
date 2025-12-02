# 🔍 How to See food_logs Table Schema

## 📋 Method 1: Supabase Table Editor (Visual - EASIEST)

### Steps:
1. Go to your Supabase Dashboard
2. Click **"Table Editor"** in the left sidebar
3. Find and click **"food_logs"** in the table list
4. You'll see all columns with:
   - Column names
   - Data types
   - Nullable (yes/no)
   - Default values
   - Foreign keys highlighted

---

## 💻 Method 2: SQL Query (Most Detailed)

### Run this in Supabase SQL Editor:

```sql
-- See all columns with details
SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'food_logs'
ORDER BY ordinal_position;
```

### Output will show:
```
column_name       | data_type            | char_max_length | is_nullable | column_default
------------------|----------------------|-----------------|-------------|-------------------
id                | uuid                 | null            | NO          | uuid_generate_v4()
patient_id        | uuid                 | null            | NO          | null
meal_type         | character varying    | 20              | NO          | null
food_name         | character varying    | 255             | NO          | null
description       | text                 | null            | YES         | null
image_url         | character varying    | 255             | YES         | null
calories          | double precision     | null            | YES         | null
protein_grams     | double precision     | null            | YES         | null
... (and more)
```

---

## 🔗 Method 3: See Foreign Keys

```sql
-- See foreign key relationships
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.update_rule,
  rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.table_name = 'food_logs' AND tc.constraint_type = 'FOREIGN KEY';
```

### Output:
```
constraint_name            | table_name | column_name | foreign_table_name | foreign_column_name | update_rule | delete_rule
---------------------------|------------|-------------|--------------------|--------------------|-------------|------------
food_logs_patient_id_fkey  | food_logs  | patient_id  | users              | id                 | CASCADE     | CASCADE
```

---

## 📊 Method 4: See Indexes

```sql
-- See all indexes on the table
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'food_logs';
```

### Output:
```
indexname                           | indexdef
------------------------------------|--------------------------------------------
food_logs_pkey                      | CREATE UNIQUE INDEX food_logs_pkey ON public.food_logs USING btree (id)
idx_food_logs_patient_id            | CREATE INDEX idx_food_logs_patient_id ON public.food_logs USING btree (patient_id)
idx_food_logs_consumed_at           | CREATE INDEX idx_food_logs_consumed_at ON public.food_logs USING btree (consumed_at)
idx_food_logs_patient_consumed      | CREATE INDEX idx_food_logs_patient_consumed ON public.food_logs USING btree (patient_id, consumed_at)
idx_food_logs_meal_type             | CREATE INDEX idx_food_logs_meal_type ON public.food_logs USING btree (meal_type)
```

---

## 📝 Method 5: PostgreSQL \d Command (Terminal-style)

```sql
-- See complete table structure
SELECT 
  c.column_name,
  c.data_type,
  c.character_maximum_length,
  c.is_nullable,
  c.column_default,
  pgd.description
FROM information_schema.columns c
LEFT JOIN pg_catalog.pg_statio_all_tables st
  ON c.table_name = st.relname
LEFT JOIN pg_catalog.pg_description pgd
  ON pgd.objoid = st.relid AND pgd.objsubid = c.ordinal_position
WHERE c.table_name = 'food_logs'
ORDER BY c.ordinal_position;
```

---

## 🔍 Method 6: See Everything at Once

```sql
-- Complete schema overview
DO $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'TABLE: food_logs';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'COLUMNS:';
  RAISE NOTICE '----------------------------------------------';
  
  FOR rec IN 
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns 
    WHERE table_name = 'food_logs'
    ORDER BY ordinal_position
  LOOP
    RAISE NOTICE '  % | % | Nullable: % | Default: %', 
      RPAD(rec.column_name, 20), 
      RPAD(rec.data_type, 25),
      rec.is_nullable,
      COALESCE(rec.column_default, 'none');
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE 'FOREIGN KEYS:';
  RAISE NOTICE '----------------------------------------------';
  
  FOR rec IN
    SELECT kcu.column_name, ccu.table_name AS foreign_table, ccu.column_name AS foreign_column
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
    WHERE tc.table_name = 'food_logs' AND tc.constraint_type = 'FOREIGN KEY'
  LOOP
    RAISE NOTICE '  % → %.%', rec.column_name, rec.foreign_table, rec.foreign_column;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE 'INDEXES:';
  RAISE NOTICE '----------------------------------------------';
  
  FOR rec IN
    SELECT indexname
    FROM pg_indexes
    WHERE tablename = 'food_logs'
    ORDER BY indexname
  LOOP
    RAISE NOTICE '  ✓ %', rec.indexname;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
END $$;
```

---

## 🎯 Quick Reference Card

### **Visual (No SQL):**
```
Supabase Dashboard → Table Editor → food_logs
```

### **Basic Info:**
```sql
SELECT * FROM information_schema.columns 
WHERE table_name = 'food_logs';
```

### **Foreign Keys:**
```sql
SELECT * FROM information_schema.table_constraints 
WHERE table_name = 'food_logs' AND constraint_type = 'FOREIGN KEY';
```

### **Indexes:**
```sql
SELECT * FROM pg_indexes WHERE tablename = 'food_logs';
```

### **Row Count:**
```sql
SELECT COUNT(*) FROM food_logs;
```

### **Sample Data:**
```sql
SELECT * FROM food_logs LIMIT 5;
```

---

## 📸 What You Should See:

### **20 Columns:**
1. id (UUID)
2. patient_id (UUID) ← Links to users
3. meal_type (VARCHAR)
4. food_name (VARCHAR)
5. description (TEXT)
6. image_url (VARCHAR)
7. calories (FLOAT)
8. protein_grams (FLOAT)
9. carbs_grams (FLOAT)
10. fat_grams (FLOAT)
11. fiber_grams (FLOAT)
12. sugar_grams (FLOAT)
13. sodium_mg (FLOAT)
14. ai_analysis (JSONB)
15. ai_confidence (FLOAT)
16. serving_size (VARCHAR)
17. servings_count (FLOAT)
18. consumed_at (TIMESTAMP)
19. created_at (TIMESTAMP)
20. updated_at (TIMESTAMP)

### **1 Foreign Key:**
- patient_id → users.id (CASCADE)

### **5 Indexes:**
- Primary key on id
- Index on patient_id
- Index on consumed_at
- Composite index on (patient_id, consumed_at)
- Index on meal_type

---

## 💡 Pro Tip:

The **easiest way** is just:
1. Go to Supabase Dashboard
2. Click "Table Editor"
3. Click "food_logs"
4. You'll see everything visually! 👁️

No SQL needed for basic viewing! ✨

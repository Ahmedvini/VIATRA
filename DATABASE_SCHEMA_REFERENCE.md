# VIATRA Database Schema Reference

## Quick Schema Reference for Test Patient Creation

### ✅ Patients Table
Located in: `/backend/src/migrations/20250101000003-create-patients-table.cjs`

**Columns:**
- `id` (UUID, primary key)
- `user_id` (UUID, references users.id, unique)
- `date_of_birth` (DATE)
- `gender` (ENUM: 'male', 'female', 'other', 'prefer_not_to_say')
- `address_line1` (STRING, nullable)
- `address_line2` (STRING, nullable)
- `city` (STRING, nullable)
- `state` (STRING(2), nullable)
- `zip_code` (STRING, nullable)
- `preferred_language` (STRING, default: 'en')
- `marital_status` (ENUM: 'single', 'married', 'divorced', 'widowed', 'other', nullable)
- `occupation` (STRING, nullable)
- `employer` (STRING, nullable)
- `created_at` (DATE)
- `updated_at` (DATE)

**⚠️ NOT in patients table:**
- ❌ `blood_type` (moved to health_profiles)
- ❌ `emergency_contact_*` (moved to health_profiles)

---

### ✅ Health Profiles Table
Located in: `/backend/src/migrations/20250101000004-create-health-profiles-table.cjs`

**Columns:**
- `id` (UUID, primary key)
- `patient_id` (UUID, references patients.id, unique)
- `blood_type` (ENUM: 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', nullable)
- `height` (DECIMAL(5,2), nullable) - **Note: just `height`, not `height_cm`**
- `weight` (DECIMAL(5,2), nullable) - **Note: just `weight`, not `weight_kg`**
- `allergies` (JSON, default: [])
- `chronic_conditions` (JSON, default: [])
- `current_medications` (JSON, default: [])
- `family_history` (JSON, default: {})
- `lifestyle` (JSON, default: {smoking, alcohol, exercise_frequency, diet})
- `emergency_contact_name` (STRING, nullable)
- `emergency_contact_phone` (STRING, nullable)
- `emergency_contact_relationship` (STRING, nullable)
- `preferred_pharmacy` (STRING, nullable)
- `insurance_provider` (STRING, nullable)
- `insurance_id` (STRING, nullable)
- `notes` (TEXT, nullable)
- `created_at` (DATE)
- `updated_at` (DATE)

**⚠️ Important:**
- Use `JSON` type (not ARRAY) for allergies, medications, conditions
- Use empty JSON array: `'[]'::JSON` or `'[]'::JSONB`

---

### ✅ Food Logs Table
Located in: `/backend/src/migrations/20251202-create-food-logs.cjs`

**Columns:**
- `id` (UUID, primary key)
- `patient_id` (UUID, references **users.id** NOT patients.id)
- `meal_type` (ENUM: 'breakfast', 'lunch', 'dinner', 'snack')
- `food_name` (STRING)
- `description` (TEXT, nullable)
- `image_url` (STRING, nullable)
- `calories` (FLOAT, nullable)
- `protein_grams` (FLOAT, nullable)
- `carbs_grams` (FLOAT, nullable)
- `fat_grams` (FLOAT, nullable)
- `fiber_grams` (FLOAT, nullable)
- `sugar_grams` (FLOAT, nullable)
- `sodium_mg` (FLOAT, nullable)
- `ai_analysis` (JSONB, nullable)
- `ai_confidence` (FLOAT, nullable)
- `serving_size` (STRING, nullable)
- `servings_count` (FLOAT, default: 1.0)
- `consumed_at` (DATE)
- `created_at` (DATE)
- `updated_at` (DATE)

**⚠️ Critical:**
- `food_logs.patient_id` → references `users.id` (NOT `patients.id`)
- This means you use the user's UUID directly

---

## Common Mistakes to Avoid

### ❌ Wrong:
```sql
INSERT INTO patients (..., blood_type, emergency_contact_name, ...)
VALUES (..., 'O+', 'John Doe', ...);
```
**Why:** `blood_type` and emergency contact fields don't exist in patients table

### ✅ Correct:
```sql
-- Step 1: Create patient (no blood_type)
INSERT INTO patients (id, user_id, date_of_birth, gender, ...)
VALUES (v_patient_id, v_user_id, '1990-01-01', 'other', ...);

-- Step 2: Create health profile (with blood_type)
INSERT INTO health_profiles (patient_id, blood_type, emergency_contact_name, ...)
VALUES (v_patient_id, 'O+', 'John Doe', ...);
```

---

### ❌ Wrong:
```sql
INSERT INTO health_profiles (..., height_cm, weight_kg, ...)
VALUES (..., 170, 70, ...);
```
**Why:** Column names are just `height` and `weight`, not `height_cm` and `weight_kg`

### ✅ Correct:
```sql
INSERT INTO health_profiles (..., height, weight, ...)
VALUES (..., 170.0, 70.0, ...);
```

---

### ❌ Wrong:
```sql
INSERT INTO health_profiles (..., allergies, ...)
VALUES (..., ARRAY['Peanuts'], ...);
```
**Why:** `allergies` is JSON type, not ARRAY

### ✅ Correct:
```sql
INSERT INTO health_profiles (..., allergies, ...)
VALUES (..., '[]'::JSON, ...);
-- Or with data:
VALUES (..., '[{"allergen": "Peanuts", "severity": "severe"}]'::JSON, ...);
```

---

### ❌ Wrong:
```sql
INSERT INTO food_logs (patient_id, ...)
VALUES (v_patient_id, ...);  -- Using patients.id
```
**Why:** `food_logs.patient_id` references `users.id`, not `patients.id`

### ✅ Correct:
```sql
INSERT INTO food_logs (patient_id, ...)
VALUES (v_user_id, ...);  -- Using users.id
```

---

## Relationship Diagram

```
users (id)
  ↓
  └─→ patients (user_id → users.id)
        ↓
        └─→ health_profiles (patient_id → patients.id)

users (id)
  ↓
  └─→ food_logs (patient_id → users.id)  ← Direct reference!
```

**Note:** Food logs skip the patients table and reference users directly.

---

## Data Types Quick Reference

| Type | SQL Example | Notes |
|------|-------------|-------|
| UUID | `gen_random_uuid()` | Primary keys, foreign keys |
| String | `'text'` | Varchar fields |
| JSON Array | `'[]'::JSON` | Empty array |
| JSON Object | `'{}'::JSON` | Empty object |
| JSONB | `'[]'::JSONB` | Binary JSON (more efficient) |
| Date | `NOW()` | Current timestamp |
| Date (specific) | `'1990-01-01'` | YYYY-MM-DD format |
| Float | `170.0` | Numeric with decimals |
| Enum | `'breakfast'` | Must match defined enum values |

---

## Verification Queries

### Check if patient exists:
```sql
SELECT u.email, p.id as patient_id, u.id as user_id
FROM users u
LEFT JOIN patients p ON p.user_id = u.id
WHERE u.email = 'testpatient@viatra.com';
```

### Check complete profile:
```sql
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    p.date_of_birth,
    p.gender,
    hp.blood_type,
    hp.height,
    hp.weight,
    COUNT(fl.id) as food_log_count
FROM users u
JOIN patients p ON p.user_id = u.id
LEFT JOIN health_profiles hp ON hp.patient_id = p.id
LEFT JOIN food_logs fl ON fl.patient_id = u.id
WHERE u.email = 'testpatient@viatra.com'
GROUP BY u.id, p.id, hp.id;
```

---

## Updated Files
- ✅ `CREATE_TEST_PATIENT_VERIFIED.sql` - Fixed schema
- ✅ All migrations verified
- ✅ Committed and pushed to GitHub

## Last Updated
December 2, 2025 - Schema corrections applied

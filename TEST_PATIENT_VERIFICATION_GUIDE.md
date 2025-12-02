# TEST PATIENT SETUP - QUICK VERIFICATION GUIDE

## Problem
The test patient might not be created correctly, or you haven't created it yet.

## Solution - Follow These Steps EXACTLY

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **New query**

### Step 2: Run the Simple Creation Script
1. Open the file: `CREATE_TEST_PATIENT_SIMPLE.sql`
2. **Copy the ENTIRE contents** (all 126 lines)
3. **Paste into Supabase SQL Editor**
4. Click **Run** (or press Ctrl+Enter)

### Step 3: Verify Success
You should see output like this:
```
message: Test patient created successfully!
user_id: [some UUID]
email: testpatient@viatra.com
role: patient
patient_id: [some UUID]
health_profile_id: [some UUID]
```

If you see this, **the patient is created!**

### Step 4: If You See Errors
Common errors and fixes:

**Error: "relation users does not exist"**
- Your database tables aren't created yet
- You need to run the backend migrations first
- See BACKEND_SETUP.md

**Error: "duplicate key value violates unique constraint"**
- The patient already exists
- The script will delete and recreate it
- Just run it again

**Error: "column [name] does not exist"**
- Schema mismatch
- Your database schema is different from expected
- Check VERIFY_TEST_PATIENT.sql to see what exists

### Step 5: Verify Patient Can Login
1. Open your mobile app
2. Click "Login"
3. Enter:
   - Email: `testpatient@viatra.com`
   - Password: `Test1234!`
4. Click Login

If login works: **SUCCESS! ✅**

If login fails with "Invalid credentials":
- The password hash might be wrong
- The user might not exist
- Run VERIFY_TEST_PATIENT.sql to check

---

## Alternative: Use the Node.js Script

If SQL doesn't work, you can use the Node.js script:

```bash
cd backend
node scripts/createTestPatient.js
```

This will:
1. Connect to your database
2. Create the test patient
3. Show you the credentials

---

## Files to Use

1. **CREATE_TEST_PATIENT_SIMPLE.sql** - Main creation script (USE THIS FIRST)
2. **VERIFY_TEST_PATIENT.sql** - Check if patient exists
3. **backend/scripts/createTestPatient.js** - Node.js alternative

---

## Expected Database Structure

The test patient creates:
- 1 record in `users` table (email: testpatient@viatra.com)
- 1 record in `patients` table (linked to user)
- 1 record in `health_profiles` table (linked to patient)
- 0 records in `food_logs` table (you'll create these by using the app)

---

## What If Nothing Works?

If you've tried everything and still can't create the patient:

1. Check your database connection
2. Verify tables exist: Run `\dt` in SQL editor
3. Check table schema: Run `\d users` to see columns
4. Share the error message with me

---

## Next Steps After Patient Creation

1. ✅ Patient created in database
2. 📱 Login to mobile app
3. 🍔 Add food logs using the app
4. 📊 View food reports
5. 📸 Try AI photo analysis

# 🚀 QUICK START: Create Test Patient NOW!

## ⚡ **FASTEST METHOD** (Just 3 steps!)

### Step 1: Go to Supabase
1. Open your browser
2. Go to https://supabase.com/dashboard
3. Select your VIATRA project
4. Click **"SQL Editor"** in the left sidebar

### Step 2: Run the SQL
1. Click **"New Query"**
2. Copy the ENTIRE content of `CREATE_TEST_PATIENT_SUPABASE.sql`
3. Paste it into the SQL editor
4. Click **"Run"** (or press Ctrl/Cmd + Enter)

### Step 3: Check Results
You should see output like:
```
✅ SUCCESS! Test patient created!
User ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Email: testpatient@viatra.com
Role: patient
...

🔑 LOGIN CREDENTIALS
Email: testpatient@viatra.com
Password: Test1234!
```

---

## 📱 Now Login to Mobile App!

### Login Credentials:
- **Email**: `testpatient@viatra.com`
- **Password**: `Test1234!`

### Test Food Tracking:
1. ✅ **Manual Entry**
   - Go to Food Tracking
   - Click "Track Food" → "Manual Entry"
   - Fill form: Chicken Salad, 350 cal, 35g protein
   - Save and see it in reports!

2. ✅ **AI Photo Analysis**
   - Click "Track Food" → "AI Photo Analysis"
   - Take/upload food photo
   - Select meal type (lunch/dinner/etc.)
   - Click "Analyze with AI"
   - Gemini analyzes and auto-saves!

3. ✅ **View Reports**
   - Go to "View Reports"
   - See all your meals
   - View nutrition summary
   - Filter by date

---

## 🆘 If SQL Fails

### Error: "users table does not exist"
Run migrations first:
```bash
cd backend
npm run db:migrate
```

### Error: "duplicate key value"
Patient already exists! Just login with:
- Email: testpatient@viatra.com
- Password: Test1234!

### Need to Reset Password
Run in Supabase SQL Editor:
```sql
UPDATE users 
SET password_hash = '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2'
WHERE email = 'testpatient@viatra.com';
```

---

## 🎯 What You Can Test Now

| Feature | Status | How to Test |
|---------|--------|-------------|
| Manual Food Entry | ✅ Ready | Fill form, save, check reports |
| AI Photo Analysis | ✅ Ready | Upload image, Gemini analyzes |
| View Food Logs | ✅ Ready | See all logged meals |
| Nutrition Summary | ✅ Ready | View aggregated stats |
| Date Filtering | ✅ Ready | Filter by today/week/month |
| Update Food Log | ✅ Ready | Edit existing entries |
| Delete Food Log | ✅ Ready | Remove entries |

---

## 🔥 ALTERNATIVE: Use Postman/curl

If you prefer API testing:

```bash
# 1. Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"testpatient@viatra.com","password":"Test1234!"}'

# 2. Copy token from response

# 3. Create food log
curl -X POST http://localhost:3000/api/health/food \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meal_type": "lunch",
    "food_name": "Chicken Salad",
    "calories": 350,
    "protein_grams": 35,
    "carbs_grams": 15,
    "fat_grams": 18
  }'
```

---

## ✨ Summary

**File to Run**: `CREATE_TEST_PATIENT_SUPABASE.sql`  
**Where to Run**: Supabase SQL Editor  
**Login Email**: testpatient@viatra.com  
**Login Password**: Test1234!  

**That's it! Go test your food tracking feature! 🍽️🚀**

# Quick Guide: Create Test Patient for Food Tracking

You have **3 options** to create a test patient account:

## Option 1: Run Node.js Script (RECOMMENDED)

```bash
# Navigate to backend folder
cd backend

# Run the script
node scripts/createTestPatient.js
```

**This will create:**
- Email: `testpatient@viatra.com`
- Password: `Test1234!`

Then you can login to the mobile app with these credentials!

---

## Option 2: Direct SQL in Supabase

1. Go to your Supabase Dashboard
2. Click on "SQL Editor"
3. Run this query:

```sql
-- Step 1: Create user with hashed password
-- Note: You'll need to generate bcrypt hash for 'Test1234!'
-- Use: https://bcrypt-generator.com/ with 10 rounds

INSERT INTO users (
  email, password_hash, role, first_name, last_name, 
  phone, is_verified, created_at, updated_at
) VALUES (
  'testpatient@viatra.com',
  '$2b$10$N9qo8uLOickgx2ZMOcR8MOx3iexYsGHXMJqE9U3p2JqN0xGxB8lW2', -- Hash for 'Test1234!'
  'patient', 'Test', 'Patient',
  '+1234567890', true, NOW(), NOW()
) RETURNING id;

-- Step 2: Copy the returned ID, then run (replace USER_ID):
INSERT INTO patients (
  user_id, date_of_birth, gender, blood_type, 
  height_cm, weight_kg, emergency_contact_name, 
  emergency_contact_phone, address, city, 
  created_at, updated_at
) VALUES (
  'PASTE_USER_ID_HERE', '1990-01-01', 'other', 'O+',
  170.0, 70.0, 'Emergency Contact', '+1234567891',
  '123 Test Street', 'Test City', NOW(), NOW()
);

-- Step 3: Verify
SELECT u.id, u.email, p.id as patient_id 
FROM users u 
LEFT JOIN patients p ON u.id = p.user_id 
WHERE u.email = 'testpatient@viatra.com';
```

---

## Option 3: Use Backend Registration API

If your backend is running:

```bash
# POST to registration endpoint
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testpatient@viatra.com",
    "password": "Test1234!",
    "firstName": "Test",
    "lastName": "Patient",
    "role": "patient",
    "dateOfBirth": "1990-01-01",
    "gender": "other",
    "phone": "+1234567890"
  }'
```

Or use Postman/Thunder Client:
- **Method**: POST
- **URL**: `http://localhost:3000/api/auth/register`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "email": "testpatient@viatra.com",
  "password": "Test1234!",
  "firstName": "Test",
  "lastName": "Patient",
  "role": "patient",
  "dateOfBirth": "1990-01-01",
  "gender": "other",
  "phone": "+1234567890"
}
```

---

## After Creating the Patient

### 1. Start Backend (if not running)
```bash
cd backend
npm install
npm run dev
```

### 2. Login with Mobile App
- **Email**: `testpatient@viatra.com`
- **Password**: `Test1234!`

### 3. Test Food Tracking Features

Once logged in, you can test:

#### Manual Food Entry
1. Navigate to Food Tracking
2. Click "Track Food"
3. Select "Manual Entry"
4. Fill in the form:
   - Meal Type: lunch
   - Food Name: Chicken Salad
   - Calories: 350
   - Protein: 35g
   - Carbs: 15g
   - Fat: 18g
5. Click "Save"
6. Should see success message!

#### AI Photo Analysis
1. Navigate to Food Tracking
2. Click "Track Food"
3. Select "AI Photo Analysis"
4. Take/select a food photo
5. Select meal type
6. Click "Analyze with AI"
7. Wait for Gemini to analyze
8. Results auto-saved to database!

#### View Reports
1. Navigate to Food Tracking
2. Click "View Reports"
3. See your logged meals
4. View nutrition summary
5. Filter by date range

---

## Test Login with curl

```bash
# Login to get token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testpatient@viatra.com",
    "password": "Test1234!"
  }'

# You'll get a response with token:
# {
#   "success": true,
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "user": { ... }
# }

# Save the token, then test food tracking:
export TOKEN="your_token_here"

curl -X POST http://localhost:3000/api/health/food \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "meal_type": "lunch",
    "food_name": "Test Meal",
    "calories": 350
  }'
```

---

## Troubleshooting

### "User already exists"
- The email is taken. Either:
  - Use the existing account
  - Change email in script/SQL
  - Delete existing: `DELETE FROM users WHERE email = 'testpatient@viatra.com'`

### "Cannot connect to database"
- Check DATABASE_URL in backend/.env
- Ensure backend dependencies installed: `npm install`
- Check Supabase is accessible

### "Password hash invalid"
- Use bcrypt generator: https://bcrypt-generator.com/
- Or run Node.js script (handles hashing automatically)

### "Login fails in mobile app"
- Ensure backend is running
- Check API_BASE_URL in mobile app config
- Check user is verified: `UPDATE users SET is_verified = true WHERE email = 'testpatient@viatra.com'`

---

## Quick Summary

**Easiest Method:**
```bash
cd backend
node scripts/createTestPatient.js
```

**Then login with:**
- Email: `testpatient@viatra.com`
- Password: `Test1234!`

**Start testing food tracking!** 🍽️✨

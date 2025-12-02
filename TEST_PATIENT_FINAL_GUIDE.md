# Test Patient Creation - Final Verified Steps

## ✅ VERIFIED INFORMATION

### Password Hashing
- **Algorithm**: bcrypt (Blowfish cipher)
- **Salt Rounds**: 12 (confirmed in `/backend/src/models/User.js` line 93)
- **PostgreSQL Function**: `crypt('password', gen_salt('bf', 12))`

### Database Schema
- `food_logs.patient_id` → references `users.id` (NOT `patients.id`)
- All UUIDs are generated with `gen_random_uuid()`
- pgcrypto extension required for password hashing

## 🎯 STEP-BY-STEP GUIDE

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on "SQL Editor" in the left sidebar
3. Click "New Query"

### Step 2: Run the Verified SQL Script
1. Copy the entire content from: `CREATE_TEST_PATIENT_VERIFIED.sql`
2. Paste it into the SQL Editor
3. Click "Run" or press Ctrl+Enter

### Step 3: Verify Success
Look for these messages in the output:
```
NOTICE: Test patient created successfully!
NOTICE: User ID: [some-uuid]
NOTICE: Patient ID: [some-uuid]
NOTICE: Email: testpatient@viatra.com
NOTICE: Password: TestPatient123!
```

### Step 4: Run Verification Queries
The script includes verification queries at the end. You should see:
- ✅ 1 user record
- ✅ 1 patient record  
- ✅ 1 health profile record
- ✅ 3 food log records

### Step 5: Test Password (Optional)
Run this query to verify the password is correctly hashed:
```sql
SELECT crypt('TestPatient123!', password_hash) = password_hash AS password_is_valid
FROM users
WHERE email = 'testpatient@viatra.com';
```
Should return: `password_is_valid: true`

## 📱 TEST WITH MOBILE APP

### Login Credentials:
- **Email**: testpatient@viatra.com
- **Password**: TestPatient123!

### Expected Behavior:
1. Open VIATRA mobile app
2. Enter the credentials above
3. Should successfully log in
4. Navigate to Food Tracking
5. Should see 3 existing food logs (Breakfast, Lunch, Dinner)
6. Can create new food logs
7. Can view nutrition reports

## 🔧 TROUBLESHOOTING

### Issue: "pgcrypto extension not found"
**Solution**: Enable it first:
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### Issue: "duplicate key value violates unique constraint"
**Solution**: User already exists. Either:
1. Delete existing user:
```sql
DELETE FROM users WHERE email = 'testpatient@viatra.com';
```
2. Or use a different email in the script

### Issue: "Cannot login with test credentials"
**Check**:
1. User exists: `SELECT * FROM users WHERE email = 'testpatient@viatra.com';`
2. User is active: Check `is_active = true`
3. Email is verified: Check `email_verified = true`
4. Password hash is correct: Run the verification query above

### Issue: "No food logs appearing in app"
**Check**:
1. Food logs exist: `SELECT COUNT(*) FROM food_logs fl JOIN users u ON fl.patient_id = u.id WHERE u.email = 'testpatient@viatra.com';`
2. Correct patient_id: Should reference `users.id`, not `patients.id`

## 📋 VERIFICATION CHECKLIST

Before testing in mobile app:

- [ ] Ran `CREATE_TEST_PATIENT_VERIFIED.sql` in Supabase
- [ ] Saw success messages (User ID, Patient ID, etc.)
- [ ] Verified user exists with correct email
- [ ] Verified patient profile is linked to user
- [ ] Verified health profile exists
- [ ] Verified 3 food logs were created
- [ ] Password validation query returns true
- [ ] Backend server is running (check logs for errors)
- [ ] Mobile app is built and installed
- [ ] API_URL in mobile app .env points to correct backend

## 🔐 SECURITY NOTES

### Production Considerations:
1. **Never commit passwords**: This is for testing only
2. **Change test password**: Before production deployment
3. **Email verification**: Should be required in production
4. **Rate limiting**: Implement login attempt limits
5. **Strong passwords**: Enforce password policy

### Current Test Setup:
- Email verification: **DISABLED** (for testing convenience)
- Account is **ACTIVE** by default
- Password is **SIMPLE** for testing (TestPatient123!)

## 📚 RELATED FILES

1. **SQL Scripts**:
   - `CREATE_TEST_PATIENT_VERIFIED.sql` - Main script (RECOMMENDED)
   - `CREATE_TEST_PATIENT_SIMPLE.sql` - Simpler version
   - `VERIFY_TEST_PATIENT.sql` - Verification queries only

2. **Documentation**:
   - `PASSWORD_HASHING_VERIFICATION.md` - Password hashing details
   - `TEST_PATIENT_VERIFICATION_GUIDE.md` - This guide

3. **Backend Code**:
   - `/backend/src/models/User.js` - User model with bcrypt
   - `/backend/src/services/authService.js` - Authentication logic
   - `/backend/src/controllers/foodTrackingController.js` - Food tracking

4. **Mobile Code**:
   - `/mobile/lib/services/food_tracking_service.dart`
   - `/mobile/lib/screens/food_tracking/`

## 🚀 NEXT STEPS AFTER PATIENT CREATION

1. **Test Login**: Try logging in with mobile app
2. **Test Food Tracking**: Create a manual food log entry
3. **Test AI Analysis**: Upload a food photo (if Gemini API configured)
4. **Test Reports**: View nutrition summaries
5. **Test Filtering**: Filter by date range, meal type

## ✨ SUCCESS CRITERIA

You'll know everything is working when:
- ✅ Can login to mobile app
- ✅ See existing 3 food logs
- ✅ Can create new food log manually
- ✅ Can view nutrition report with correct data
- ✅ Backend logs show no errors
- ✅ Food tracking API calls return 200 status

## 🆘 NEED HELP?

If you encounter issues:
1. Check backend logs for errors
2. Verify database records with verification queries
3. Check mobile app network requests (enable debug logging)
4. Ensure all environment variables are set correctly
5. Confirm backend and database are running

---

**Last Updated**: December 2, 2025
**Verified**: ✅ Password hashing confirmed (bcrypt with 12 rounds)
**Status**: Ready for testing

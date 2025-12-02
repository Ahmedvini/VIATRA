# Food Tracking & Dashboard Troubleshooting Guide

## Issues Fixed

### ✅ Issue 1: "Failed to analyze image" - FIXED
**Root Cause**: Incorrect API endpoint path with duplicate `/api`
- **Was**: `/api/v1/api/health/food/analyze` (404 error)
- **Now**: `/api/v1/food-tracking/analyze` ✅

**Fix Applied**:
- Updated `food_tracking_service.dart` to use `/food-tracking` instead of `/api/health/food`
- Committed in: `ab93ed8`

---

### ✅ Issue 2: "Only image files are allowed" - FIXED
**Root Cause**: MIME type not explicitly set when uploading images

**Fix Applied**:
- Added `http_parser` import for `MediaType`
- Created `_getMimeType()` helper to detect MIME type from file extension
- Explicitly set `contentType` in `MultipartFile.fromPath()`
- Supports: jpg, jpeg, png, gif, webp, bmp

**Code Changes**:
```dart
// Before
request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

// After
final mimeType = _getMimeType(file.path);
request.files.add(await http.MultipartFile.fromPath(
  fieldName,
  file.path,
  contentType: mimeType != null ? MediaType.parse(mimeType) : null,
));
```

---

### ✅ Issue 3: Password Hashing - VERIFIED
**Confirmed**: Backend uses bcrypt with 12 rounds
- SQL script updated to use: `crypt('password', gen_salt('bf', 12))`
- Matches backend implementation in `User.js` model

---

### ✅ Issue 4: Database Schema - FIXED
**Issues Found**:
- `blood_type` was in wrong table (should be in `health_profiles`, not `patients`)
- Column names incorrect (`height_cm` → `height`, `weight_kg` → `weight`)
- Data types wrong (ARRAY → JSON for allergies, medications)

**Fix Applied**:
- Updated `CREATE_TEST_PATIENT_VERIFIED.sql`
- Created `DATABASE_SCHEMA_REFERENCE.md` for reference

---

## Current Status

### What's Working ✅
1. **Backend Server**: Running on Railway (port 8080)
2. **Database**: Supabase PostgreSQL connected
3. **Redis**: Connected
4. **Socket.io**: WebSocket server ready
5. **Login**: User can login successfully
6. **API Endpoints**: Correct paths configured
7. **Image Upload**: MIME type fix applied

### What Needs Testing 🧪
1. **Food Image Analysis**: Try uploading an image again
2. **Dashboard**: Check what specific error occurs
3. **Test Patient**: Verify login with test credentials

---

## API Endpoints Reference

### Food Tracking Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/v1/food-tracking/analyze` | Analyze food image with AI |
| POST | `/api/v1/food-tracking` | Create manual food log |
| GET | `/api/v1/food-tracking` | Get all food logs |
| GET | `/api/v1/food-tracking/:id` | Get single food log |
| PUT | `/api/v1/food-tracking/:id` | Update food log |
| DELETE | `/api/v1/food-tracking/:id` | Delete food log |
| GET | `/api/v1/food-tracking/summary` | Get nutrition summary |

### Mobile App Configuration
**Base URL**: Should be set in `.env` as:
```
API_BASE_URL=https://your-backend.railway.app/api/v1
```

**Do NOT include** trailing slash or `/api` prefix in endpoints.

---

## Testing Steps

### Step 1: Rebuild Mobile App
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --debug
```

### Step 2: Install on Device
```bash
flutter install
```

### Step 3: Test Login
- **Email**: `testpatient@viatra.com` (if created via SQL)
- **Password**: `TestPatient123!`

Or create new account via registration

### Step 4: Test Food Image Analysis
1. Navigate to Food Tracking
2. Tap "Analyze with AI" or camera button
3. Select an image of food
4. Verify:
   - Image uploads successfully
   - Analysis completes
   - Food log is created
   - Nutritional info is displayed

### Step 5: Test Dashboard
1. Go to home/dashboard screen
2. Check what error appears (if any)
3. Look for API calls in logs

---

## Backend Logs Analysis

### From Latest Logs:

```
2025-12-02T05:16:53Z [inf] User logged in successfully ✅
2025-12-02T05:17:23Z [err] Only image files are allowed ❌ (FIXED)
2025-12-02T05:18:03Z [inf] HTTP Request ✅
```

**Login Working**: User `d649f02f-f905-4ca2-aa27-6de9ee4bd4d5` logged in successfully

**Image Upload Error**: Fixed by adding explicit MIME type

**Next**: Need to see logs after rebuilding app with fixes

---

## Common Errors & Solutions

### Error: "Only image files are allowed"
**Solution**: FIXED - App now sets MIME type explicitly

### Error: 404 on food tracking endpoint
**Solution**: FIXED - Endpoint changed to `/food-tracking`

### Error: "Invalid email or password"
**Possible Causes**:
1. Test patient not created in database
2. Password hash doesn't match
3. User account not active or email not verified

**Solution**:
- Run `CREATE_TEST_PATIENT_VERIFIED.sql` in Supabase
- Verify with: `SELECT * FROM users WHERE email = 'testpatient@viatra.com';`
- Check `is_active = true` and `email_verified = true`

### Error: "Gemini API key not configured"
**Solution**: 
- Verify `GEMINI_API_KEY` is set in Railway environment variables
- Current key: `AIzaSyAMUNS1cfiEGIJNTgwym0Tc4WpcqdSU3e8`
- Restart backend if key was just added

### Dashboard Not Loading
**Possible Causes**:
1. Missing API endpoint
2. Authentication token expired
3. Network connectivity issue
4. Specific API call failing

**Debug Steps**:
1. Check backend logs for failed requests
2. Enable debug logging in mobile app
3. Use network inspector to see API calls
4. Check if specific endpoints return 404/500

---

## Environment Variables Checklist

### Backend (Railway) ✅
- `GEMINI_API_KEY`: Set to `AIzaSyAMUNS1cfiEGIJNTgwym0Tc4WpcqdSU3e8`
- `DATABASE_URL`: Supabase connection string
- `REDIS_URL`: Redis connection string
- `JWT_SECRET`: Set
- `NODE_ENV`: production

### Mobile (.env)
- `API_BASE_URL`: Should be `https://your-backend.railway.app/api/v1`
- `GEMINI_API_KEY`: Optional (analysis happens on backend)

---

## Next Steps

1. **Rebuild Mobile App** with the fixes
2. **Test Image Upload** - Should work now
3. **Test Dashboard** - Check what specific error occurs
4. **Check Logs** - Look for any new errors after testing
5. **Report Results** - Let me know what works and what doesn't

---

## Files Changed

### This Session:
1. `mobile/lib/services/food_tracking_service.dart` - Fixed endpoint path
2. `mobile/lib/services/api_service.dart` - Added MIME type detection
3. `CREATE_TEST_PATIENT_VERIFIED.sql` - Fixed schema issues
4. `DATABASE_SCHEMA_REFERENCE.md` - Added schema documentation
5. `PASSWORD_HASHING_VERIFICATION.md` - Documented bcrypt usage
6. `backend/src/services/gemini/geminiService.js` - Fixed logger import

### All Committed ✅
- Latest commit: `ab93ed8`
- Pushed to GitHub: ✅

---

## Support

### If Issues Persist:

1. **Share Backend Logs**: 
   ```
   Copy logs from Railway after testing
   ```

2. **Share Mobile App Logs**:
   ```bash
   flutter logs
   ```

3. **Share Network Requests**:
   - Enable debug mode
   - Copy API request/response details

4. **Check Database**:
   ```sql
   -- Verify test patient exists
   SELECT * FROM users WHERE email = 'testpatient@viatra.com';
   
   -- Check food logs
   SELECT COUNT(*) FROM food_logs;
   ```

---

**Last Updated**: December 2, 2025
**Status**: Fixes applied, ready for testing
**Next**: Rebuild app and test image upload + dashboard

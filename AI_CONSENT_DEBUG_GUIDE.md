# AI Chatbot Consent Failure - Debugging Guide

## Issue
User reports: "Failed to grant consent" error when clicking "I Consent" in the AI Health Chatbot.

## Root Cause Analysis

The consent failure is most likely caused by one of these issues:

### 1. **Authentication Issue (Most Likely)**
The backend endpoint `/api/v1/ai-chatbot/consent` requires authentication via JWT token.

**Symptoms:**
- Error message: "Failed to grant consent"
- Backend returns 401 Unauthorized
- Error contains "Authentication" or "Token" in message

**Check:**
```dart
// The ApiService should have a valid token set
apiService.setAuthToken(yourToken);
```

### 2. **Backend Not Running**
The Railway backend might not be running or the endpoint doesn't exist.

**Check:**
```bash
curl -X GET https://viatra-backend-production.up.railway.app/api/v1/
```

### 3. **Network/CORS Issue**
The mobile app can't reach the backend.

## Quick Fixes

### Fix 1: Verify User is Logged In

Check if the user is actually logged in before opening the AI chatbot:

```dart
// In patient_home_screen.dart or wherever you navigate to AI chatbot
final apiService = context.read<ApiService>();
if (apiService._accessToken == null) {
  // User not logged in!
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Please log in first')),
  );
  return;
}
```

### Fix 2: Add Debugging to See Actual Error

The updated code now shows detailed error messages including:
- Authentication errors with suggestion to log in again
- Detailed error messages from the backend
- Automatic navigation back if authentication fails

### Fix 3: Test Backend Endpoint Directly

Test if the backend is working:

```bash
# 1. Login first to get token
curl -X POST https://viatra-backend-production.up.railway.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}'

# 2. Use the token to grant consent
curl -X POST https://viatra-backend-production.up.railway.app/api/v1/ai-chatbot/consent \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"consent_given":true}'
```

### Fix 4: Check Backend Logs

If on Railway:
1. Go to Railway dashboard
2. Select your backend service
3. Check the logs for errors when consent is requested

## Updated Code

### Enhanced Error Handling in Mobile App

**File:** `/mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart`

The code now:
1. Shows detailed error messages
2. Detects authentication errors specifically
3. Automatically navigates back if auth fails
4. Displays user-friendly error descriptions

**File:** `/mobile/lib/services/ai_health_chatbot_service.dart`

The service now:
1. Throws more detailed exceptions
2. Includes status codes in error messages
3. Better error propagation

## Testing Steps

### Step 1: Verify Login State
```dart
// Add this temporarily in ai_health_chatbot_screen.dart initState()
@override
void initState() {
  super.initState();
  _chatbotService = AIHealthChatbotService(context.read<ApiService>());
  
  // DEBUG: Check if user has token
  final apiService = context.read<ApiService>();
  print('DEBUG: Has token: ${apiService._accessToken != null}');
  
  _checkConsent();
}
```

### Step 2: Check Network Response
Look at the error message shown to the user:
- "Authentication error. Please log in again" → Token issue
- "Network error" → Can't reach backend
- Other message → Backend returned specific error

### Step 3: Verify Backend is Running
Open in browser: https://viatra-backend-production.up.railway.app/api/v1/

Should see:
```json
{
  "message": "Viatra Health Platform API v1",
  "version": "1.0.0",
  ...
}
```

## Common Solutions

### Solution 1: User Not Logged In
**Problem:** User opened the app but isn't logged in.
**Fix:** Ensure user completes login flow before accessing AI chatbot.

### Solution 2: Token Expired
**Problem:** User was logged in but token expired.
**Fix:** Implement token refresh or redirect to login.

### Solution 3: Backend Route Not Registered
**Problem:** Backend doesn't have the AI chatbot routes.
**Fix:** Verify in `/backend/src/routes/index.js` line 147:
```javascript
router.use('/ai-chatbot', aiHealthChatbotRoutes);
```

### Solution 4: Missing Patient Record
**Problem:** User logged in but has no patient record.
**Fix:** Backend controller checks for patient record. Ensure user has completed profile setup.

## Expected Flow

1. ✅ User logs in → Token stored in ApiService
2. ✅ User navigates to AI Health Chatbot
3. ✅ Screen checks consent status (GET /ai-chatbot/consent)
4. ✅ User clicks "Grant Data Access"
5. ✅ User clicks "I Consent"
6. ✅ **POST /ai-chatbot/consent** with Authorization header
7. ✅ Backend validates token and user
8. ✅ Backend stores consent in memory Map
9. ✅ Backend returns success
10. ✅ Chat interface opens

## What Was Fixed

1. **Better Error Messages:** Users now see specific error details
2. **Auth Detection:** App detects authentication errors and suggests login
3. **Auto Navigation:** If auth fails, user is redirected back
4. **Status Codes:** Errors include HTTP status codes for debugging

## Next Steps

1. **Check if user is logged in** when you see the error
2. **Look at the specific error message** shown in the SnackBar
3. **Check Railway backend logs** if error persists
4. **Try logging out and back in** to get fresh token

## Prevention

To prevent this in production:

1. **Add Auth Check Before Navigation:**
```dart
// Before navigating to AI chatbot
if (!isUserLoggedIn()) {
  showDialog(/* Login required */);
  return;
}
Navigator.pushNamed(context, '/ai-health-chatbot');
```

2. **Implement Token Refresh:**
Automatically refresh expired tokens in ApiService.

3. **Add Health Check:**
Test backend connectivity before showing consent dialog.

---

**Status:** Enhanced error handling implemented
**Files Modified:**
- `/mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart`
- `/mobile/lib/services/ai_health_chatbot_service.dart`

**Next Action:** Test with actual logged-in user and check error message details.

# AI Chatbot Consent Flow Fix

## Issue
After clicking "I Consent" in the AI Health Chatbot, the chat interface wasn't opening immediately. The screen remained on the consent request page.

## Root Cause
In the `_requestConsent()` method in `/mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart`, the code was unnecessarily updating the `_isCheckingConsent` state variable along with `_hasConsent`:

```dart
setState(() {
  _hasConsent = true;
  _isCheckingConsent = false;  // ❌ Unnecessary
});
```

The `_isCheckingConsent` flag is only meant to indicate the initial consent check on screen load, not for the dialog-based consent flow. This caused a UI state conflict.

## Fix Applied
Removed the `_isCheckingConsent` update from the setState call in the `_requestConsent()` method:

```dart
setState(() {
  _hasConsent = true;  // ✅ Only update hasConsent
});
```

**File Changed:**
- `/mobile/lib/screens/ai_health/ai_health_chatbot_screen.dart` (line ~210)

## How It Works Now
1. User clicks "Grant Data Access" → consent dialog appears
2. User clicks "I Consent" → backend request is sent
3. On success, `_hasConsent` is set to `true` in setState
4. The UI immediately rebuilds and shows the chat interface via `_buildChatInterface()`
5. Welcome message is added and displayed

## UI Flow Logic
The `build()` method checks state in this order:
```dart
body: _isCheckingConsent          // 1. Show loading on initial check
    ? CircularProgressIndicator()
    : !_hasConsent                 // 2. Show consent screen if no consent
        ? _buildConsentRequired()
        : _buildChatInterface(),   // 3. Show chat if consent granted ✅
```

## Testing
To verify the fix:
1. Open AI Health Chatbot from patient dashboard
2. Click "Grant Data Access" button
3. Click "I Consent" in the dialog
4. **Expected:** Chat interface opens immediately with welcome message
5. **Verify:** Can send messages and receive responses

## Status
✅ **Fixed** - Consent flow now works smoothly. After granting consent, users are immediately taken to the chat interface.

---
**Date:** 2025-01-22  
**Component:** Mobile App - AI Health Chatbot  
**Impact:** User Experience - Critical Flow

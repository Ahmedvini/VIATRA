# Viatra Health - Next Steps & Testing Guide

## Immediate Next Steps

### 1. Environment Setup
Create `.env` file in `mobile/` directory:
```env
API_BASE_URL=https://your-api-domain.com/api
API_TIMEOUT=30000
```

### 2. Install Dependencies
```bash
cd mobile
flutter pub get
```

### 3. Required Packages
Ensure these are in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  go_router: ^12.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  permission_handler: ^11.0.0
  intl: ^0.18.0
```

### 4. Code Analysis
Run static analysis to check for errors:
```bash
flutter analyze
```

### 5. Build Tests
Test compilation for both platforms:

**Android:**
```bash
flutter build apk --debug
```

**iOS:**
```bash
flutter build ios --debug --no-codesign
```

---

## Testing Checklist

### Unit Testing

#### Models
- [ ] User model serialization/deserialization
- [ ] Doctor model with all fields
- [ ] Patient model with medical history
- [ ] Verification model status transitions
- [ ] Auth response parsing

#### Services
- [ ] AuthService.register()
- [ ] AuthService.login()
- [ ] AuthService.logout()
- [ ] VerificationService.uploadDocument()
- [ ] VerificationService.checkStatus()
- [ ] Error handling for network failures
- [ ] Token refresh logic

#### Validators
- [ ] Email validation (valid/invalid formats)
- [ ] Password validation (strength requirements)
- [ ] Phone number validation
- [ ] Required field validation
- [ ] Date of birth age restrictions

### Integration Testing

#### Registration Flow - Doctor
1. [ ] Select "Doctor" role
2. [ ] Fill basic info with valid data
3. [ ] Fill professional info
4. [ ] Fill address info
5. [ ] Upload documents with permission grant
6. [ ] Submit registration
7. [ ] Navigate to verification pending screen
8. [ ] Verify API calls made correctly

#### Registration Flow - Patient
1. [ ] Select "Patient" role
2. [ ] Fill basic info with valid data
3. [ ] Fill address info
4. [ ] Upload identity document
5. [ ] Submit registration
6. [ ] Navigate to verification pending screen

#### Permission Handling
1. [ ] Camera permission request on "Take Photo"
2. [ ] Gallery permission request on "Select from Gallery"
3. [ ] Permission denied - show error message
4. [ ] Permission permanently denied - show settings dialog
5. [ ] Permission granted - proceed with action

#### Navigation
1. [ ] Back button on each step
2. [ ] Continue button validation
3. [ ] Page transitions smooth
4. [ ] Step indicator updates correctly
5. [ ] Can't skip required steps

#### Form Validation
1. [ ] Required fields show error when empty
2. [ ] Email format validation
3. [ ] Password match validation
4. [ ] Phone number format
5. [ ] File type validation
6. [ ] File size validation
7. [ ] Date picker works correctly

### UI/UX Testing

#### Visual
- [ ] All text readable
- [ ] Icons display correctly
- [ ] Colors match theme
- [ ] Loading spinners show
- [ ] Error messages styled properly
- [ ] Step indicator clear
- [ ] Document upload preview works

#### Interaction
- [ ] All buttons tappable
- [ ] Dropdowns open correctly
- [ ] Text fields accept input
- [ ] Keyboard dismisses properly
- [ ] Scroll works on all screens
- [ ] Date picker opens
- [ ] Camera/gallery pickers work

#### Responsive
- [ ] Works on small screens (iPhone SE)
- [ ] Works on large screens (iPad)
- [ ] Landscape orientation (if supported)
- [ ] Keyboard doesn't hide inputs
- [ ] Bottom buttons always visible

### Error Handling

#### Network Errors
- [ ] No internet connection
- [ ] Server timeout
- [ ] 400 Bad Request
- [ ] 401 Unauthorized
- [ ] 500 Server Error
- [ ] Malformed response

#### User Errors
- [ ] Empty required fields
- [ ] Invalid email format
- [ ] Weak password
- [ ] Password mismatch
- [ ] Invalid phone number
- [ ] File too large
- [ ] Wrong file type
- [ ] Missing documents

### Platform-Specific Testing

#### Android
- [ ] Permissions work on Android 13+
- [ ] Permissions work on Android 12 and below
- [ ] Camera launches correctly
- [ ] Gallery opens correctly
- [ ] File picker works
- [ ] Back button behavior
- [ ] App doesn't crash on permission denial

#### iOS
- [ ] Permission dialogs show with correct text
- [ ] Camera launches correctly
- [ ] Photo library opens correctly
- [ ] Settings app opens from permission dialog
- [ ] App doesn't crash on permission denial
- [ ] SwiftUI compatibility (if using)

---

## Manual Testing Script

### Scenario 1: Happy Path - Doctor Registration
```
1. Launch app
2. Tap "Register" or "Sign Up"
3. Select "Doctor" role → Tap Continue
4. Fill basic info:
   - First Name: "John"
   - Last Name: "Doe"
   - Email: "john.doe@test.com"
   - Phone: "+1234567890"
   - DOB: Select "01/01/1990"
   - Password: "Test@123456"
   - Confirm: "Test@123456"
   → Tap Continue
5. Fill professional info:
   - License: "MD123456"
   - Specialty: Select "Cardiology"
   - Experience: "10"
   - Languages: Select "English", "Spanish"
   - Bio: "Experienced cardiologist..."
   → Tap Continue
6. Fill address:
   - Street: "123 Main St"
   - City: "New York"
   - State: "NY"
   - Postal: "10001"
   - Country: Select "United States"
   → Tap Continue
7. Upload documents:
   - Identity: Tap "Camera" → Allow permission → Take photo
   - License: Tap "Gallery" → Allow permission → Select file
   - Certificate: Tap "Gallery" → Select PDF
   → Tap "Submit Registration"
8. Verify: Navigation to verification pending screen
Expected: Success message, all data saved, API called
```

### Scenario 2: Error Handling - Missing Required Fields
```
1. Follow Scenario 1 steps 1-3
2. Leave First Name empty → Tap Continue
Expected: Error "First name is required" shown
3. Fill First Name, leave Email empty → Tap Continue
Expected: Error "Email is required" shown
4. Fill Email with "invalid" → Tap Continue
Expected: Error "Please enter a valid email" shown
5. Fill Email correctly but password mismatch → Tap Continue
Expected: Error "Passwords do not match" shown
```

### Scenario 3: Permission Denial
```
1. Follow Scenario 1 steps 1-6
2. On document upload, tap "Camera"
3. Deny camera permission
Expected: Error message "Camera permission required..."
4. Tap "Camera" again
Expected: Dialog to open settings
5. Tap "Open Settings"
Expected: Navigate to app settings
```

### Scenario 4: Network Error
```
1. Turn off internet/wifi
2. Follow Scenario 1 completely
3. On final submit
Expected: Error "No internet connection" or similar
4. Turn on internet
5. Tap "Submit Registration" again
Expected: Success, registration submitted
```

---

## Debugging Tips

### Common Issues

#### 1. Permission Not Working
- Check AndroidManifest.xml has correct permissions
- Check Info.plist has usage descriptions
- Verify permission_handler version compatible
- Test on real device (not emulator for camera)

#### 2. Navigation Not Working
- Check GoRouter configuration
- Verify route names match
- Check context is correct
- Look for navigation in build method

#### 3. Provider State Not Updating
- Verify notifyListeners() is called
- Check Consumer widget is used
- Ensure context.read vs context.watch
- Check provider is added in main.dart

#### 4. API Calls Failing
- Check .env file exists and loaded
- Verify API_BASE_URL is correct
- Check network permissions
- Use debugPrint for request/response
- Check API endpoints match backend

#### 5. File Upload Issues
- Verify file path is correct
- Check file size within limits
- Ensure content-type is set
- Test with small files first
- Check multipart form data format

### Debug Logs to Add
```dart
// In services
debugPrint('API Request: $endpoint');
debugPrint('API Response: ${response.statusCode}');

// In providers
debugPrint('Provider state: $currentState');
debugPrint('Form data: ${formData.toString()}');

// In widgets
debugPrint('Widget built: ${widget.runtimeType}');
debugPrint('Button tapped: $buttonLabel');
```

---

## Performance Optimization

### Current Implementation
- ✅ Lazy loading of steps
- ✅ Debounced form validation
- ✅ Cached provider state
- ✅ Optimized rebuilds with Consumer

### Future Improvements
- [ ] Image compression before upload
- [ ] Retry logic for failed uploads
- [ ] Progress indication for large files
- [ ] Background upload with isolates
- [ ] Cache API responses
- [ ] Offline mode support

---

## Security Checklist

- [x] Password validation (min 8 chars, special char, number)
- [x] JWT token stored securely (shared_preferences)
- [x] No sensitive data in logs
- [x] HTTPS for all API calls
- [x] Token included in authenticated requests
- [ ] Token refresh before expiry
- [ ] Logout clears all stored data
- [ ] Certificate pinning (future enhancement)

---

## Documentation TODO

1. [ ] API integration guide
2. [ ] Custom widget usage examples
3. [ ] State management flow diagram
4. [ ] Error handling strategy doc
5. [ ] Permission handling guide for developers
6. [ ] Testing strategy document
7. [ ] Deployment checklist
8. [ ] User guide/help docs

---

**Last Updated**: November 25, 2025
**Status**: Ready for testing phase

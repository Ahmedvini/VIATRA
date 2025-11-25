# Viatra Health - Project Structure & Quick Reference

## Project Overview
Multi-role healthcare platform with separate registration flows for doctors and patients, including document verification and JWT authentication.

---

## Directory Structure

```
VIATRA/
├── mobile/                          # Flutter mobile app
│   ├── android/
│   │   └── app/src/main/
│   │       └── AndroidManifest.xml  # Android permissions
│   ├── ios/
│   │   └── Runner/
│   │       └── Info.plist           # iOS permissions & config
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── config/
│   │   │   └── routes.dart          # GoRouter configuration
│   │   ├── models/                  # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── doctor_model.dart
│   │   │   ├── patient_model.dart
│   │   │   ├── verification_model.dart
│   │   │   └── auth_response_model.dart
│   │   ├── services/                # API services
│   │   │   ├── auth_service.dart
│   │   │   ├── verification_service.dart
│   │   │   └── storage_service.dart
│   │   ├── providers/               # State management
│   │   │   ├── auth_provider.dart
│   │   │   └── registration_provider.dart
│   │   ├── screens/                 # UI screens
│   │   │   └── auth/
│   │   │       ├── login_screen.dart
│   │   │       ├── role_selection_screen.dart
│   │   │       ├── registration_form_screen.dart
│   │   │       ├── verification_pending_screen.dart
│   │   │       └── steps/
│   │   │           ├── basic_info_step.dart
│   │   │           ├── professional_info_step.dart
│   │   │           ├── address_info_step.dart
│   │   │           └── document_upload_step.dart
│   │   ├── widgets/                 # Reusable widgets
│   │   │   ├── common/
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   └── custom_dropdown.dart
│   │   │   └── registration/
│   │   │       ├── step_indicator.dart
│   │   │       ├── document_upload_widget.dart
│   │   │       └── verification_status_card.dart
│   │   └── utils/                   # Utilities
│   │       ├── validators.dart
│   │       └── constants.dart
│   ├── .env                         # Environment variables (create this)
│   ├── .env.example                 # Environment template
│   ├── pubspec.yaml                 # Flutter dependencies
│   └── README.md                    # Mobile app docs
├── IMPLEMENTATION_SUMMARY.md        # What was completed
├── TESTING_GUIDE.md                 # How to test
└── PROJECT_REFERENCE.md             # This file
```

---

## Key Files & Their Purpose

### Core Application

#### `main.dart`
- App entry point
- Provider setup (AuthProvider, RegistrationProvider, etc.)
- Material app configuration
- GoRouter initialization

```dart
// Key providers initialized:
- AuthService
- VerificationService
- AuthProvider
- RegistrationProvider
```

#### `config/routes.dart`
- All app routes defined
- Navigation logic
- Auth redirect middleware
- Route guards

```dart
// Main routes:
- '/' → LoginScreen
- '/role-selection' → RoleSelectionScreen
- '/registration' → RegistrationFormScreen
- '/verification-pending' → VerificationPendingScreen
- '/home' → HomeScreen (authenticated)
```

---

### Models (Data Structures)

#### `user_model.dart`
- Base user model
- UserType enum (doctor, patient, admin)
- User serialization/deserialization

#### `doctor_model.dart`
- Doctor-specific fields
- Extends User model
- Medical license, specialty, languages

#### `patient_model.dart`
- Patient-specific fields
- Medical history, allergies
- Emergency contact info

#### `verification_model.dart`
- Document verification status
- VerificationStatus enum
- Document type tracking

#### `auth_response_model.dart`
- API authentication response
- JWT token parsing
- User data extraction

---

### Services (API Communication)

#### `auth_service.dart`
**Methods:**
- `register(userData)` - Create new account
- `login(email, password)` - Authenticate user
- `logout()` - End session
- `refreshToken()` - Renew JWT token
- `getCurrentUser()` - Get user details

#### `verification_service.dart`
**Methods:**
- `uploadDocument(documentType, file, token)` - Upload verification doc
- `getVerificationStatus(userId, token)` - Check verification status
- `submitForVerification(userId, token)` - Submit all docs

#### `storage_service.dart`
**Methods:**
- `saveToken(token)` - Store JWT
- `getToken()` - Retrieve JWT
- `deleteToken()` - Remove JWT
- `saveUser(user)` - Cache user data
- `getUser()` - Retrieve cached user

---

### Providers (State Management)

#### `auth_provider.dart`
**State:**
- `user` - Current user object
- `isAuthenticated` - Login status
- `isLoading` - API call in progress
- `error` - Error message

**Methods:**
- `login(email, password)`
- `register(userData)`
- `logout()`
- `checkAuthStatus()`
- `updateUser(userData)`

#### `registration_provider.dart`
**State:**
- `currentStepIndex` - Current registration step
- `formData` - User input data
- `doctorData` - Doctor-specific data
- `uploadedDocuments` - Uploaded file map
- `isLoading` - Upload/submit in progress

**Methods:**
- `nextStep()` - Advance to next step
- `previousStep()` - Go back one step
- `updateFormData(data)` - Save form data
- `updateDoctorData(data)` - Save doctor info
- `uploadDocument(type, file)` - Upload doc
- `submitRegistration()` - Final submission

---

### Screens (UI)

#### `login_screen.dart`
- Email/password login
- Form validation
- Navigate to home or registration

#### `role_selection_screen.dart`
- Choose Doctor or Patient role
- Navigate to registration flow

#### `registration_form_screen.dart`
- Multi-step registration container
- PageView for step navigation
- Step indicator
- Coordinates step widgets

#### `verification_pending_screen.dart`
- Shows after registration
- Displays verification status
- Document list with status
- Retry upload if failed

#### Step Screens
- `basic_info_step.dart` - Name, email, password, DOB
- `professional_info_step.dart` - License, specialty (doctors only)
- `address_info_step.dart` - Address details
- `document_upload_step.dart` - Document uploads & submission

---

### Widgets (Reusable Components)

#### Common Widgets

**`custom_text_field.dart`**
```dart
CustomTextField(
  controller: controller,
  labelText: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
  isRequired: true,
  validator: Validators.validateEmail,
)
```

**`custom_button.dart`**
```dart
CustomButton(
  text: 'Continue',
  onPressed: () {},
  type: ButtonType.primary, // primary, outlined, text
  isLoading: false,
)
```

**`custom_dropdown.dart`**
```dart
CustomDropdown<String>(
  value: selectedValue,
  labelText: 'Country',
  hintText: 'Select country',
  items: countries.map((c) => DropdownMenuItem(...)),
  onChanged: (value) {},
)
```

#### Registration Widgets

**`step_indicator.dart`**
```dart
StepIndicator(
  currentStep: 2,
  totalSteps: 4,
  stepLabels: ['Basic', 'Professional', 'Address', 'Documents'],
)
```

**`document_upload_widget.dart`**
- Camera/gallery selection
- Permission handling
- File preview
- Upload progress
- Error display

**`verification_status_card.dart`**
- Document verification status
- Status icons (pending, approved, rejected)
- Action buttons (retry, view)

---

### Utilities

#### `validators.dart`
**Functions:**
- `validateEmail(value)` - Email format check
- `validatePassword(value)` - Password strength
- `validatePhone(value)` - Phone number format
- `validateName(value)` - Name validation
- `validateRequired(value, field)` - Required field

#### `constants.dart`
**Constants:**
- `AppConstants.appName`
- `AppConstants.apiTimeout`
- `AppConstants.maxFileSize`
- `AppConstants.allowedFileTypes`
- `AppConstants.medicalSpecialties`
- `AppConstants.countries`

---

## Data Flow

### Registration Flow

```
1. User Input → FormData (RegistrationProvider)
2. FormData → API Request (AuthService)
3. API Response → AuthResponse Model
4. AuthResponse → User Object (AuthProvider)
5. User Object → Local Storage (StorageService)
6. UI Updates (via notifyListeners)
```

### Document Upload Flow

```
1. User selects file → File object
2. Permission check → Platform-specific permission
3. File validation → Size/type check
4. File upload → API multipart request (VerificationService)
5. Upload response → Update verification status
6. Status display → UI update with status card
```

### Authentication Flow

```
1. Login credentials → AuthService.login()
2. API returns JWT token
3. Token saved → StorageService
4. Token added to headers → All subsequent API calls
5. Token expiry → Automatic refresh or logout
6. Logout → Clear token and user data
```

---

## Environment Variables

Create `.env` file in `mobile/` directory:

```env
# API Configuration
API_BASE_URL=https://api.viatrahealth.com/api
API_TIMEOUT=30000

# Feature Flags
ENABLE_BIOMETRIC_AUTH=false
ENABLE_OFFLINE_MODE=false

# Analytics (optional)
ANALYTICS_ID=your-analytics-id

# Sentry (optional)
SENTRY_DSN=your-sentry-dsn
```

---

## API Endpoints Reference

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user
- `POST /auth/refresh-token` - Refresh JWT
- `GET /auth/me` - Get current user

### Verification
- `POST /verification/upload-document` - Upload document
- `GET /verification/status/:userId` - Get verification status
- `POST /verification/submit/:userId` - Submit for verification
- `GET /verification/documents/:userId` - List user documents

### User Profile
- `GET /users/:id` - Get user details
- `PUT /users/:id` - Update user profile
- `DELETE /users/:id` - Delete account

---

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Run with specific flavor
flutter run --flavor dev

# Hot reload
r (in terminal while running)

# Hot restart
R (in terminal while running)
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_test.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS (requires Mac)
flutter build ios --release

# Build for specific flavor
flutter build apk --flavor prod --release
```

### Debugging
```bash
# Enable verbose logging
flutter run --verbose

# Debug paint (UI boundaries)
flutter run --debug-paint

# Performance overlay
flutter run --performance-overlay

# Observatory (debugging tool)
flutter run --observatory-port=8888
```

---

## Troubleshooting

### Build Issues
```bash
# Clean build cache
flutter clean

# Get fresh dependencies
flutter pub get

# Rebuild
flutter run
```

### Permission Issues
- Check `AndroidManifest.xml` for Android
- Check `Info.plist` for iOS
- Verify `permission_handler` version
- Test on real device for camera/gallery

### Provider Issues
- Verify provider is added in `main.dart`
- Use `context.watch` for UI updates
- Use `context.read` for one-time actions
- Check `notifyListeners()` is called

### Navigation Issues
- Check route is defined in `routes.dart`
- Use `context.go()` or `context.push()`
- Verify route names match exactly
- Check auth redirect logic

---

## Code Style Guidelines

### Naming Conventions
- Classes: `PascalCase` (e.g., `UserModel`)
- Functions/Variables: `camelCase` (e.g., `getUserData`)
- Constants: `UPPER_SNAKE_CASE` or `camelCase` (e.g., `API_BASE_URL`)
- Private: `_leadingUnderscore` (e.g., `_privateMethod`)

### File Organization
- One class per file
- File name matches class name (snake_case)
- Group imports: Flutter → Package → Relative
- Organize methods: Public → Private → Overrides

### Documentation
- Comment complex logic
- Use `///` for public API docs
- Add TODO comments with owner
- Document why, not what

---

## Useful Resources

### Flutter Documentation
- [Flutter.dev](https://flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Permission Handler](https://pub.dev/packages/permission_handler)

### Project-Specific
- API Documentation: `/docs/api.md`
- Design System: `/docs/design-system.md`
- Contributing Guide: `/docs/CONTRIBUTING.md`
- Changelog: `/CHANGELOG.md`

---

**Last Updated**: November 25, 2025
**Maintained By**: Development Team
**Version**: 1.0.0

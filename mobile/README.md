# Viatra Mobile App

The Flutter mobile application for the Viatra Health Platform, providing healthcare management for patients, doctors, and healthcare providers.

## Overview

A cross-platform mobile app built with Flutter that provides:
- User authentication and registration
- Health profile management
- Doctor search and discovery
- Appointment booking and management
- Telemedicine consultations
- Prescription management
- Real-time notifications

## Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Platform**: iOS, Android

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Xcode 14+ (for iOS development)
- Android Studio / VS Code with Flutter extensions
- CocoaPods (for iOS)

## Project Structure

```
mobile/
├── lib/
│   ├── config/              # App configuration
│   │   ├── app_config.dart  # Environment configuration
│   │   ├── routes.dart      # Navigation routes
│   │   └── theme.dart       # Theme configuration
│   ├── models/              # Data models
│   │   ├── user_model.dart
│   │   ├── health_profile_model.dart
│   │   └── ...
│   ├── providers/           # State management
│   │   ├── auth_provider.dart
│   │   ├── health_profile_provider.dart
│   │   └── ...
│   ├── screens/             # UI screens
│   │   ├── auth/
│   │   ├── health_profile/
│   │   └── ...
│   ├── services/            # API and external services
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── health_profile_service.dart
│   │   └── storage_service.dart
│   ├── utils/               # Utilities
│   │   ├── validators.dart
│   │   ├── logger.dart
│   │   └── error_handler.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── health_profile/
│   │   └── ...
│   └── main.dart            # App entry point
├── assets/                  # Static assets
│   ├── images/
│   ├── fonts/
│   └── icons/
├── test/                    # Tests
├── pubspec.yaml             # Dependencies
└── README.md
```

## Getting Started

### 1. Install Flutter

Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Clone and Setup

```bash
# Install dependencies
flutter pub get

# Generate necessary files
flutter pub run build_runner build
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
API_BASE_URL=http://localhost:8080/api/v1
API_TIMEOUT=30000
ENABLE_LOGGING=true
```

### 4. Run the App

```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run on physical device
flutter run
```

## Available Commands

- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run unit tests
- `flutter test --coverage` - Run tests with coverage
- `flutter analyze` - Run static analysis
- `flutter pub get` - Install dependencies
- `flutter clean` - Clean build files

## Features

### Authentication & Authorization

- **Multi-role Registration**: Patient, Doctor, Hospital, Pharmacy, Admin
- **Email Verification**: Two-factor authentication via email
- **Password Reset**: Secure password recovery flow
- **JWT Authentication**: Secure token-based authentication
- **Auto Token Refresh**: Seamless session management

**Screens**:
- `LoginScreen` - User login
- `RoleSelectionScreen` - Choose registration role
- `RegistrationFormScreen` - Role-specific registration
- `VerificationPendingScreen` - Email verification status
- `ForgotPasswordScreen` - Password recovery

### Health Profile Management

Comprehensive health information management for patients.

**Features**:
- View and edit personal health information
- Track vitals (blood pressure, heart rate, blood glucose, oxygen saturation)
- Manage chronic conditions
- Record allergies with severity levels
- Maintain medication lists
- Store emergency contact information
- Calculate BMI automatically
- Pull-to-refresh data synchronization
- Local caching with 5-minute TTL

**Screens**:
- `HealthProfileViewScreen` - View health profile with all sections
  - Vitals card with BMI calculation
  - Blood type display
  - Chronic conditions list
  - Allergies list with severity indicators
  - Current medications
  - Emergency contact
  - Additional notes
  - Quick actions floating button
  
- `HealthProfileEditScreen` - Create/edit health profile
  - Basic information (blood type)
  - Vitals input (height, weight, blood pressure, heart rate, blood glucose, oxygen)
  - Medications list
  - Additional notes
  - Form validation with real-time feedback
  
- `ChronicConditionFormScreen` - Add/edit chronic conditions
  - Condition name
  - Diagnosed year
  - Additional notes
  - Input validation
  
- `AllergyFormScreen` - Add/edit allergies
  - Allergen name
  - Reaction description
  - Severity level (mild, moderate, severe)
  - Color-coded severity indicators
  - Input validation

**Widgets**:
- `VitalsCard` - Display vitals with BMI calculation and color-coded indicators
- `ChronicConditionTile` - List tile for chronic conditions with delete confirmation
- `AllergyTile` - List tile for allergies with severity badges and delete confirmation

**Navigation**:
- `/health-profile` - View health profile
- `/health-profile/edit` - Edit profile
- `/health-profile/chronic-condition/add` - Add chronic condition
- `/health-profile/chronic-condition/edit` - Edit chronic condition
- `/health-profile/allergy/add` - Add allergy
- `/health-profile/allergy/edit` - Edit allergy

**Local Caching**:
- Health profiles are cached locally for offline access
- Cache expires after 5 minutes
- Force refresh available via pull-to-refresh
- Automatic cache invalidation on updates

**Validation**:
All inputs are validated using the `HealthProfileValidators` class:
- Height: 30-300 cm
- Weight: 1-500 kg
- Blood pressure systolic: 70-250 mmHg
- Blood pressure diastolic: 40-150 mmHg
- Heart rate: 30-250 bpm
- Blood glucose: 20-600 mg/dL
- Oxygen saturation: 50-100%
- Chronic condition name: 2-100 characters
- Allergen name: 2-100 characters
- Allergy reaction: 2-200 characters
- Notes: max 1000 characters

**UX Behaviors**:
- Loading indicators during API calls
- Success/error snackbar notifications
- Pull-to-refresh on view screen
- Confirmation dialogs for deletions
- Auto-save on form submission
- Keyboard dismissal on scroll
- Responsive layouts for different screen sizes

### Doctor Search & Discovery

Comprehensive doctor search feature with advanced filtering and real-time results.

**Features**:
- Real-time search with 500ms debounce
- Advanced filtering (specialty, location, fee, languages, availability)
- Sort by multiple criteria (fee, name, date added)
- Pagination with infinite scroll
- Redis-backed caching (5-minute TTL)
- Doctor profile view with full details
- Telehealth availability indication
- Accepting patients status

**Screens**:
- `DoctorSearchScreen` - Main search interface
  - Search bar with debounced input
  - Filter button with active filter badge
  - Doctor list with infinite scroll
  - Pull-to-refresh support
  - Loading states (initial, pagination, refresh)
  - Empty state with helpful message
  - Error state with retry action
  
- `DoctorDetailScreen` - Doctor profile view
  - Doctor profile picture and basic info
  - Specialty and sub-specialty
  - Years of experience
  - Education and qualifications
  - Consultation fee
  - Languages spoken
  - Location and contact details
  - Working hours
  - Accepting patients status
  - Telehealth availability
  - Bio/description
  - Action buttons (Book appointment, Contact)
  
- `DoctorSearchFilterSheet` - Advanced filters
  - Specialty dropdown
  - Sub-specialty dropdown (contextual)
  - Location filters (city, state, zip code)
  - Fee range slider or presets
  - Languages multi-select
  - Availability filters (accepting patients, telehealth)
  - Sort options
  - Active filter count indicator
  - Clear all filters button
  - Apply button

**Widgets**:
- `DoctorCard` - List item for search results
  - Doctor photo
  - Name and specialty
  - Years of experience
  - Consultation fee
  - Location
  - Rating (if available)
  - Accepting patients badge
  - Telehealth badge
  - Tap to view details

**Navigation**:
- `/doctors/search` - Search and filter doctors
- `/doctors/:id` - View doctor profile details

### Appointment Booking & Management

Complete appointment lifecycle management with availability checking and cancellation support.

**Features**:
- Doctor availability checking with time slot generation
- Real-time conflict detection
- Appointment type selection (consultation, follow-up, checkup, procedure)
- Reason for visit and chief complaint capture
- Urgent appointment marking
- Appointment list with upcoming/past tabs
- Status-based filtering (scheduled, confirmed, completed, cancelled)
- Appointment details with full information
- Reschedule functionality
- Cancellation with reason (minimum 2 hours notice)
- Dual caching (memory + persistent storage, 5-minute TTL)
- Pull-to-refresh support
- Pagination for appointment lists

**Screens**:
- `TimeSlotSelectionScreen` - Book appointment
  - Doctor information display
  - Appointment type selector (chips)
  - Date picker (Material Design calendar)
  - Duration selector dropdown
  - Time slot grid (morning/afternoon/evening groups)
  - Reason for visit field (required)
  - Chief complaint field (optional)
  - Urgent checkbox
  - Continue to confirmation button
  - Loading states for time slots
  - Validation and error handling

- `BookingConfirmationScreen` - Review before booking
  - Appointment summary card
  - Doctor information with avatar
  - Date, time, and duration display
  - Appointment type and priority badges
  - Reason for visit display
  - Cancellation policy notice
  - Edit button (go back to modify)
  - Confirm button with loading state
  - Success/error feedback
  - Navigate to appointment detail on success

- `AppointmentListScreen` - View all appointments
  - Tab bar (Upcoming / Past)
  - Status filter chips (All, Scheduled, Completed, Cancelled)
  - Pull-to-refresh support
  - Infinite scroll pagination
  - AppointmentCard widgets
  - Empty states per tab
  - Loading states (initial, pagination)
  - Error states with retry
  - Floating action button to book new appointment

- `AppointmentDetailScreen` - View appointment details
  - Status banner with color coding
  - Urgent badge if applicable
  - Doctor information card
  - Appointment details (type, date, time, duration)
  - Visit details (reason, chief complaint)
  - Cancellation information (if cancelled)
  - Action buttons:
    - Reschedule (if upcoming)
    - Cancel (if > 2 hours before and not completed)
  - Cancellation confirmation dialog
  - Success/error feedback

**Widgets**:
- `AppointmentCard` - List item for appointments
  - Doctor avatar with name and specialty
  - Date and time display
  - Duration badge
  - Appointment type icon and label
  - Status chip with color coding
  - Urgent badge (if applicable)
  - Reason for visit summary
  - Action buttons (Reschedule/Cancel for upcoming)
  - Cancellation info (if cancelled)
  - Tap to view full details

- `TimeSlotPicker` - Time selection grid
  - Grouped by time period (Morning/Afternoon/Evening)
  - Period headers with icons
  - Available slots (white background, blue border)
  - Selected slot (blue background, white text)
  - Unavailable slots (greyed out, disabled)
  - Empty state message
  - Responsive grid layout (3 columns)

**State Management**:
- `AppointmentProvider`:
  - Appointment list state with filtering
  - Current appointment detail state
  - Available time slots state
  - Loading/error states
  - Create appointment action
  - Update/cancel appointment actions
  - Cache management with TTL
  - Pagination state

### Doctor Features

Doctor-specific screens and features for managing appointments and viewing dashboard statistics.

**Screens**:
- **Doctor Dashboard** (`/doctor/dashboard`): Overview screen showing key statistics and today's schedule
  - Statistics Cards Grid (2x2):
    - Today's Appointments count (blue, with navigation)
    - Upcoming Appointments count (green, with navigation)
    - Total Patients count (orange, with navigation)
    - Pending Requests count (red, with navigation to filtered list)
  - Today's Schedule section:
    - List of appointments scheduled for today
    - Shows patient name, time, type, status
    - Tap to view appointment details
    - Empty state if no appointments today
  - Pull-to-refresh support
  - Refresh button in app bar
  - Loading and error states

- **Doctor Appointments List** (`/doctor/appointments`): Filterable list of all doctor's appointments
  - Filter by status (All, Scheduled, Confirmed, In Progress, Completed, Cancelled)
  - Filter button in app bar (opens bottom sheet with status chips)
  - DoctorAppointmentCard for each item:
    - Time and date on left
    - Patient name (bold)
    - Reason for visit (preview)
    - Status badge (colored chip)
    - Urgent indicator (red badge if urgent)
    - Type icon (telehealth/in-person/phone)
  - Pull-to-refresh support
  - Infinite scroll pagination
  - Loading states (initial, pagination)
  - Empty state with icon and message
  - Error state with retry button

- **Doctor Appointment Detail** (`/doctor/appointments/:id`): Detailed view with patient info and action buttons
  - Patient Information Card:
    - Profile picture (CircleAvatar)
    - Patient full name
    - Contact info (email, phone)
  - Appointment Details Card:
    - Type with icon
    - Date (formatted: "Wednesday, December 15, 2024")
    - Time range (formatted: "9:00 AM - 9:30 AM")
    - Duration in minutes
    - Status badge (colored chip)
    - Urgent badge (if applicable, red)
    - Reason for visit
    - Chief complaint (if present)
  - Consultation Notes Section:
    - Multiline TextField (5 lines)
    - Save button to update notes
    - Success/error feedback
  - Action Buttons (bottom sticky bar):
    - **Accept Button** (green, visible if status = 'scheduled'):
      - Changes status to 'confirmed'
      - Shows loading indicator during API call
      - Success/error SnackBar feedback
    - **Reschedule Button** (orange, visible if status = 'scheduled' or 'confirmed'):
      - Opens date picker → time picker flow
      - Validates new times (end > start, min 15 min duration)
      - Confirmation dialog with new date/time
      - Checks doctor availability
      - Success/error SnackBar feedback
    - **Cancel Button** (red, visible if canBeCancelled):
      - Opens confirmation dialog
      - Requires cancellation reason (TextField, max 500 chars)
      - Success/error SnackBar feedback
  - Disabled states during actions
  - Responsive layout (buttons in Row on large screens, Column on small)
  - Loading and error states

**Widgets**:
- `DashboardStatCard`: Reusable stat card for dashboard
  - CircleAvatar with icon (colored background with opacity)
  - Large bold count number (headline medium)
  - Small grey label text (body medium)
  - Tap handler for navigation
  - Card with rounded corners (12px) and elevation 2
  - Responsive sizing based on screen width
  - Semantics label for accessibility

- `DoctorAppointmentCard`: Appointment card for doctor's list view
  - Left section (80px width):
    - Time (bold, large)
    - Date (small, grey)
    - Type icon (colored)
  - Middle section (expanded):
    - Patient name (bold, truncated)
    - Reason for visit (grey, truncated to 1 line)
    - Status badge (colored chip)
    - Urgent indicator (red 'URGENT' badge in corner if urgent)
  - Right section:
    - Chevron right icon (grey)
  - InkWell for tap effect
  - Card elevation 1, padding 12px
  - Semantics label describing appointment details

- `AppointmentActionButtons`: Action buttons for appointment detail
  - State management for loading indicators per button
  - Accept button (ElevatedButton, green):
    - Calls onAccept callback
    - Shows CircularProgressIndicator when loading
    - Disabled when any action in progress
  - Reschedule button (OutlinedButton, orange):
    - Shows date/time picker dialogs sequentially
    - Validates new time selection
    - Confirmation dialog before saving
    - Shows CircularProgressIndicator when loading
  - Cancel button (TextButton, red):
    - Shows confirmation dialog with reason input
    - Validates reason is provided
    - Shows CircularProgressIndicator when loading
  - Responsive layout (Row on wide screens, Column on narrow)
  - All buttons disabled during any action

**Provider Methods**:
- `loadDoctorAppointments({ String? status, bool refresh })`:
  - Fetches doctor's appointments with optional status filter
  - Implements 5-minute cache (checks cache first unless refresh = true)
  - Updates `_appointments`, `_currentPage`, `_totalPages`, `_totalResults`
  - Caches results in memory and storage
  - Handles loading/error states
  - Notifies listeners

- `loadDoctorDashboardStats({ bool refresh })`:
  - Fetches dashboard statistics (today, upcoming, total patients, pending)
  - Implements 5-minute cache expiry check (`isStatsExpired` getter)
  - Returns early if cached and not expired
  - Updates `_doctorDashboardStats` and `_statsLastFetched`
  - Caches in storage
  - Handles loading/error states
  - Notifies listeners

- `acceptAppointment(String appointmentId)`:
  - Calls API to change appointment status to 'confirmed'
  - Updates local appointment in `_appointments` list
  - Updates `_currentAppointment` if IDs match
  - Invalidates all caches (appointments + stats)
  - Notifies listeners
  - Returns bool (true on success, false on failure)
  - Sets `_errorMessage` on failure

- `rescheduleAppointment(String appointmentId, DateTime scheduledStart, DateTime scheduledEnd)`:
  - Calls API to update appointment times
  - Updates local appointment times in `_appointments` and `_currentAppointment`
  - Invalidates all caches
  - Notifies listeners
  - Returns bool (true on success, false on failure)
  - Sets `_errorMessage` on failure

**Navigation**:
- Direct routes (no role-based redirection in this phase):
  - `context.push('/doctor/dashboard')` - Doctor dashboard
  - `context.push('/doctor/appointments')` - Doctor appointments list
  - `context.push('/doctor/appointments/$appointmentId')` - Appointment detail
- Routes defined in `lib/config/routes.dart`
- Accessible via GoRouter navigation

**Note**: Role-based navigation (automatic routing based on user role) will be implemented in the next phase. For now, doctor screens are accessible via direct routes.

**State Management**:
  - Update appointment action
  - Cancel appointment action
  - Fetch availability action
  - Cache management with expiration
  - Pagination support

**Navigation**:
- `/appointments` - List all appointments
- `/appointments/:id` - View appointment details
- Booking flow: Doctor Detail → Time Slot Selection → Booking Confirmation → Appointment Detail
- FAB from Appointment List → Doctor Search for new booking

**Integration Points**:
- Doctor Detail Screen: "Book Appointment" button
  - Disabled if doctor not accepting patients
  - Navigates to TimeSlotSelectionScreen
  - Passes doctor information
- Home Screen: "Appointments" quick action
  - Navigates to AppointmentListScreen
  - Shows upcoming appointment count badge (future enhancement)

## State Management

### Provider Pattern

The app uses the Provider pattern for state management:

```dart
// Accessing providers
final authProvider = Provider.of<AuthProvider>(context);
final healthProfileProvider = Provider.of<HealthProfileProvider>(context);

// Using Consumer for selective rebuilds
Consumer<HealthProfileProvider>(
  builder: (context, provider, child) {
    return Text(provider.healthProfile?.bloodType ?? 'N/A');
  },
)
```

### Available Providers

- **AuthProvider**: User authentication state
- **RegistrationProvider**: Registration flow management
- **HealthProfileProvider**: Health profile data and operations
- **DoctorSearchProvider**: Doctor search, filtering, and pagination
- **ThemeProvider**: App theme management
- **LocaleProvider**: Localization management

## API Integration

### Services

#### ApiService
Base HTTP client with:
- Authentication header injection
- Error handling
- Request/response logging
- Timeout management

#### AuthService
Handles all authentication operations:
- Register, login, logout
- Email verification
- Password reset
- Token refresh

#### HealthProfileService
Manages health profile operations:
- Get health profile
- Create/update profile
- Add/remove chronic conditions
- Add/remove allergies
- Update vitals

#### DoctorService
Manages doctor-related operations:
- Search doctors with filters
- Get doctor details
- Pagination support
- Backend caching integration

#### StorageService
Local storage management:
- Secure token storage
- User preferences
- Cache management

## Validation

### Validators Utility

Centralized validation logic in `utils/validators.dart`:

**Generic Validators**:
- Email validation
- Password validation (8+ chars, uppercase, lowercase, number, special char)
- Phone number validation
- Name validation
- Date of birth validation
- Address validation

**Health Profile Validators**:
- Blood type validation
- Height validation (30-300 cm)
- Weight validation (1-500 kg)
- Blood pressure validation
- Heart rate validation (30-250 bpm)
- Blood glucose validation (20-600 mg/dL)
- Oxygen saturation validation (50-100%)
- Chronic condition name validation
- Allergen validation
- Allergy reaction validation

Example usage:
```dart
TextFormField(
  validator: HealthProfileValidators.validateHeight,
  decoration: InputDecoration(labelText: 'Height (cm)'),
  keyboardType: TextInputType.number,
)
```

## Navigation

### GoRouter Configuration

Routes are defined in `config/routes.dart`:

```dart
// Navigate to a route
context.go('/health-profile');
context.push('/health-profile/edit');

// Pass parameters
context.push('/health-profile/edit', extra: healthProfile);

// Navigate back
context.pop();
```

### Authentication Flow

1. Splash screen checks auth status
2. Redirect to login if not authenticated
3. Redirect to home if authenticated
4. Protected routes require authentication

## Error Handling

### Centralized Error Handler

The `ErrorHandler` utility provides:
- User-friendly error messages
- Error logging
- Crash reporting
- Retry mechanisms

Example:
```dart
try {
  await healthProfileService.getMyHealthProfile();
} catch (e, stackTrace) {
  ErrorHandler.logError(e, stackTrace);
  ErrorHandler.showErrorSnackbar(context, 'Failed to load health profile');
}
```

## Theming

### Theme Configuration

Defined in `config/theme.dart`:
- Light and dark themes
- Color schemes
- Typography
- Component themes

```dart
// Access theme
final theme = Theme.of(context);
final primaryColor = theme.colorScheme.primary;
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/validators_test.dart
```

### Test Structure

```
test/
├── unit/           # Unit tests
│   ├── validators_test.dart
│   ├── models_test.dart
│   └── ...
├── widget/         # Widget tests
│   └── screens_test.dart
└── integration/    # Integration tests
    └── app_test.dart
```

## Building for Release

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build for iOS
flutter build ios --release

# Create IPA
flutter build ipa
```

## Performance Optimization

### Best Practices

- Use `const` constructors where possible
- Implement `RepaintBoundary` for complex widgets
- Lazy load data with pagination
- Cache network images
- Use `ListView.builder` for long lists
- Implement proper dispose methods

### Caching Strategy

- API responses cached for 5 minutes
- Images cached automatically
- User preferences persisted locally
- Offline mode for critical features

## Accessibility

- Screen reader support
- High contrast mode
- Scalable text
- Keyboard navigation
- ARIA labels on interactive elements

## Internationalization

### Supported Languages

- English (en_US)
- Arabic (ar_SA)

### Adding Translations

Translations are managed through `lib/l10n/`:
- Add new ARB files for languages
- Run code generation
- Use localized strings in widgets

## Security

### Best Practices

- Secure token storage with flutter_secure_storage
- Certificate pinning for API requests
- Input sanitization
- Secure form handling
- Biometric authentication (planned)

### Data Protection

- Encrypted local storage
- Secure API communication (HTTPS only)
- No sensitive data in logs
- Token refresh mechanism

## Troubleshooting

### Common Issues

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **CocoaPods Issues (iOS)**
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Gradle Issues (Android)**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```

4. **API Connection Issues**
   - Check API_BASE_URL in .env
   - Verify network connectivity
   - Check backend server status

### Getting Help

- Check Flutter documentation: https://flutter.dev/docs
- Review app logs: `flutter logs`
- Enable debug mode: `flutter run --debug`

## Contributing

1. Follow Flutter style guide
2. Write tests for new features
3. Update documentation
4. Follow commit message conventions
5. Create pull requests with clear descriptions

## License

Copyright © 2024 Viatra Health. All rights reserved.

# Authentication & Provider Integration - Complete Implementation

## Overview

Complete authentication system with JWT tokens, OAuth integration (Google, Apple, Facebook), email/password authentication, and comprehensive state management using Flutter Provider pattern.

## Features Implemented

### Backend Authentication

#### 1. Authentication Service (`backend/src/services/authService.js`)

**Core Functions**:
- `registerUser()`: Create new user account with role-specific profiles
- `loginUser()`: Authenticate with email/password
- `verifyEmail()`: Email verification with token
- `requestPasswordReset()`: Password reset request
- `resetPassword()`: Reset password with token
- `refreshAccessToken()`: Refresh JWT tokens

**OAuth Integration**:
- Google OAuth 2.0
- Apple Sign In
- Facebook Login
- Token validation and user creation

#### 2. Auth Controller (`backend/src/controllers/authController.js`)

**Endpoints**:
- `POST /api/v1/auth/register`: User registration
- `POST /api/v1/auth/login`: User login
- `POST /api/v1/auth/logout`: User logout
- `POST /api/v1/auth/verify-email`: Email verification
- `POST /api/v1/auth/forgot-password`: Password reset request
- `POST /api/v1/auth/reset-password`: Reset password
- `POST /api/v1/auth/refresh`: Refresh access token
- `GET /api/v1/auth/me`: Get current user
- `POST /api/v1/auth/oauth/google`: Google OAuth
- `POST /api/v1/auth/oauth/apple`: Apple OAuth
- `POST /api/v1/auth/oauth/facebook`: Facebook OAuth

#### 3. JWT Strategy
- **Access Token**: Short-lived (15 minutes), used for API requests
- **Refresh Token**: Long-lived (7 days or 30 days with remember-me)
- **Token Storage**: HttpOnly cookies or Authorization header
- **Token Rotation**: New refresh token on each refresh

#### 4. Middleware (`backend/src/middleware/auth.js`)
- `authenticate`: Verify JWT and attach user to request
- `requireRole`: Role-based access control
- `requireVerification`: Ensure email is verified

### Mobile Authentication

#### 1. AuthProvider (`mobile/lib/providers/auth_provider.dart`)

**State Management**:
```dart
enum AuthState {
  initial,      // App starting up
  loading,      // Auth operation in progress
  authenticated,// User logged in
  unauthenticated, // No valid session
  error,        // Auth error occurred
}
```

**Core Features**:
- User session persistence
- Automatic token refresh
- Role switching (Doctor/Patient for dual-role users)
- Logout with cleanup
- Error handling
- Token validation

**Key Methods**:
- `login()`: Email/password login
- `register()`: New user registration
- `logout()`: Clear session and tokens
- `loadUserFromStorage()`: Restore session on app start
- `refreshAccessToken()`: Automatic token refresh
- `switchRole()`: Switch between doctor/patient roles
- `updateProfile()`: Update user profile
- `verifyEmail()`: Email verification

#### 2. AuthService (`mobile/lib/services/auth_service.dart`)
- API integration for auth endpoints
- Token management
- OAuth flow handling
- Secure storage integration

#### 3. Screens (`mobile/lib/screens/auth/`)
- **Login Screen**: Email/password + OAuth buttons
- **Registration Screen**: Multi-step registration form
- **Role Selection Screen**: Choose initial role
- **Forgot Password Screen**: Password reset request
- **Reset Password Screen**: New password entry
- **Email Verification Screen**: Enter verification code

#### 4. Widgets (`mobile/lib/widgets/auth/`)
- OAuth buttons (Google, Apple, Facebook)
- Password strength indicator
- Email validation widget
- Login form
- Registration form

### OAuth Integration

#### Google OAuth
**Backend**:
```javascript
// Verify Google token
const ticket = await client.verifyIdToken({
  idToken: googleToken,
  audience: process.env.GOOGLE_CLIENT_ID,
});
const payload = ticket.getPayload();
// Create or login user
```

**Mobile** (Flutter):
```dart
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

Future<void> signInWithGoogle() async {
  final account = await _googleSignIn.signIn();
  final auth = await account.authentication;
  // Send token to backend
}
```

#### Apple Sign In
**Backend**:
```javascript
import appleSignin from 'apple-signin-auth';

const appleUser = await appleSignin.verifyIdToken(token, {
  audience: process.env.APPLE_CLIENT_ID,
});
```

**Mobile**:
```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);
```

#### Facebook Login
**Backend**:
```javascript
// Verify Facebook access token
const response = await axios.get(
  `https://graph.facebook.com/me?fields=id,name,email&access_token=${token}`
);
```

**Mobile**:
```dart
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final LoginResult result = await FacebookAuth.instance.login();
if (result.status == LoginStatus.success) {
  final AccessToken accessToken = result.accessToken!;
}
```

## API Endpoints

### Register User
```http
POST /api/v1/auth/register

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "role": "patient",  // or "doctor"
  
  // For doctors, include:
  "licenseNumber": "MD123456",
  "specialty": "Cardiology",
  "title": "MD",
  "yearsOfExperience": 10
}

Response:
{
  "message": "User registered successfully",
  "user": {...},
  "profile": {...},
  "tokens": {
    "accessToken": "...",
    "refreshToken": "...",
    "expiresIn": 900
  },
  "emailSent": true
}
```

### Login
```http
POST /api/v1/auth/login

{
  "email": "john@example.com",
  "password": "SecurePass123!",
  "rememberMe": true
}

Response:
{
  "message": "Login successful",
  "user": {...},
  "profile": {...},
  "tokens": {
    "accessToken": "...",
    "refreshToken": "...",
    "expiresIn": 900
  }
}
```

### Verify Email
```http
POST /api/v1/auth/verify-email

{
  "token": "verification-token-from-email"
}
```

### Forgot Password
```http
POST /api/v1/auth/forgot-password

{
  "email": "john@example.com"
}
```

### Reset Password
```http
POST /api/v1/auth/reset-password

{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePass123!"
}
```

### Refresh Token
```http
POST /api/v1/auth/refresh

{
  "refreshToken": "current-refresh-token"
}

Response:
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token",
  "expiresIn": 900
}
```

### Get Current User
```http
GET /api/v1/auth/me
Authorization: Bearer <access-token>

Response:
{
  "id": "uuid",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "patient",
  "emailVerified": true,
  "profile": {...}
}
```

## Flutter Provider Usage

### Setup in main.dart
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        authService: AuthService(),
        storageService: StorageService(),
        apiService: ApiService(),
      ),
    ),
    // ... other providers
  ],
  child: MyApp(),
)
```

### Using in Widgets
```dart
// Watch for auth state changes
final authProvider = Provider.of<AuthProvider>(context);

if (authProvider.isAuthenticated) {
  // Show authenticated UI
}

// Listen without rebuilding
context.read<AuthProvider>().login(email, password);

// Select specific value
final user = context.select((AuthProvider p) => p.user);
```

### Login Example
```dart
Future<void> _handleLogin() async {
  final authProvider = context.read<AuthProvider>();
  
  final result = await authProvider.login(
    email: _emailController.text,
    password: _passwordController.text,
    rememberMe: _rememberMe,
  );
  
  if (result.isSuccess) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error ?? 'Login failed')),
    );
  }
}
```

## Security Features

1. **Password Hashing**: BCrypt with configurable rounds
2. **JWT Security**: 
   - Short-lived access tokens
   - Secure refresh token rotation
   - Token blacklisting on logout
3. **Rate Limiting**: Prevent brute force attacks
4. **Email Verification**: Required for sensitive actions
5. **Password Policy**: Minimum length, complexity requirements
6. **OAuth Security**: Token validation, secure redirect URIs
7. **Session Management**: Device tracking, concurrent session control

## Testing

### Backend Tests
```bash
cd backend
npm test -- auth
```

### Mobile Tests
```bash
cd mobile
flutter test test/providers/auth_provider_test.dart
flutter test test/services/auth_service_test.dart
```

### Integration Tests
```bash
cd mobile
flutter test integration_test/auth_flow_test.dart
```

## Error Handling

### Common Errors
- `401`: Invalid credentials
- `403`: Email not verified
- `409`: Email already exists
- `429`: Too many attempts (rate limited)
- `500`: Server error

### Mobile Error Display
```dart
if (authProvider.state == AuthState.error) {
  ErrorHandler.showError(
    context,
    authProvider.errorMessage ?? 'Authentication failed',
  );
}
```

## Role Switching

For users with multiple roles (e.g., a doctor who is also a patient):

```dart
// Check available roles
final canBeDoctor = user.canSwitchToRole(UserRole.doctor);

// Switch role
await authProvider.switchRole(UserRole.doctor);

// Get active role
final activeRole = authProvider.activeRole;

// Get role-specific profile
final doctorProfile = authProvider.currentRoleProfile;
```

## Future Enhancements

- [ ] Biometric authentication (fingerprint, face ID)
- [ ] Two-factor authentication (2FA)
- [ ] Social login with Twitter, LinkedIn
- [ ] Password-less login (magic links)
- [ ] SSO integration
- [ ] Device management (view/revoke sessions)
- [ ] Login history and activity log
- [ ] Account recovery options

## Dependencies

### Backend
- `jsonwebtoken`: JWT token generation
- `bcrypt`: Password hashing
- `passport`: OAuth strategies
- `google-auth-library`: Google OAuth
- `apple-signin-auth`: Apple Sign In

### Mobile
- `provider`: State management
- `google_sign_in`: Google OAuth
- `sign_in_with_apple`: Apple Sign In
- `flutter_facebook_auth`: Facebook Login
- `flutter_secure_storage`: Secure token storage

## Documentation Links

- [Authentication API](../api/AUTH_API.md)
- [Security Best Practices](../SECURITY.md)
- [Testing Guide](../TESTING_GUIDE.md)

---

**Status**: ✅ Complete  
**Last Updated**: November 2024  
**Maintained By**: Platform Team

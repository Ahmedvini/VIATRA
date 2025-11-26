# AuthProvider Quick Reference

## Usage Guide for Developers

### Login
```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.login(
  'user@example.com',
  'password123',
  rememberMe: true, // Optional, defaults to false
);

if (success) {
  // Navigate to home
  context.go('/home');
} else {
  // Show error
  showSnackBar(authProvider.errorMessage ?? 'Login failed');
}
```

### Register
```dart
final userData = {
  'email': 'user@example.com',
  'password': 'password123',
  'firstName': 'John',
  'lastName': 'Doe',
  'phone': '+1234567890',
  'role': 'patient', // or 'doctor', 'hospital', 'pharmacy'
};

final success = await authProvider.register(userData);

if (success) {
  // User is now authenticated, navigate to home
  context.go('/home');
}
```

### Logout
```dart
await authProvider.logout();
// User is now unauthenticated
context.go('/login');
```

### Check Authentication State
```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.isAuthenticated) {
  // User is logged in
  final user = authProvider.user!;
  print('Welcome ${user.fullName}');
} else {
  // Redirect to login
  context.go('/login');
}
```

### Access Current User
```dart
final authProvider = context.read<AuthProvider>();
final user = authProvider.user;

if (user != null) {
  print('Email: ${user.email}');
  print('Name: ${user.fullName}');
  print('Role: ${user.role}');
  print('Verified: ${user.emailVerified}');
}
```

### Update Profile
```dart
final updates = {
  'firstName': 'Jane',
  'lastName': 'Smith',
  'phone': '+0987654321',
};

final success = await authProvider.updateProfile(updates);

if (success) {
  // Profile updated
  final updatedUser = authProvider.user!;
  print('Updated: ${updatedUser.fullName}');
}
```

### Forgot Password
```dart
final success = await authProvider.forgotPassword('user@example.com');

if (success) {
  showSnackBar('Password reset email sent');
}
```

### Manual Token Refresh
```dart
// Usually automatic, but can be called manually
final success = await authProvider.refreshToken();

if (!success) {
  // Refresh failed, logout user
  await authProvider.logout();
  context.go('/login');
}
```

### Handle Loading States
```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.isLoading) {
  return CircularProgressIndicator();
}

// Show content
```

### Handle Errors
```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.state == AuthState.error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(authProvider.errorMessage ?? 'An error occurred'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## AuthState Enum

```dart
enum AuthState {
  initial,      // Before initialization
  loading,      // During async operations
  authenticated, // User logged in
  unauthenticated, // User logged out
  error,        // Operation failed
}
```

## Available Getters

```dart
authProvider.state           // Current AuthState
authProvider.user            // Current User? (null if not authenticated)
authProvider.errorMessage    // String? (error from last operation)
authProvider.accessToken     // String? (current access token)
authProvider.refreshToken    // String? (current refresh token)
authProvider.lastAuthResponse // AuthResponse? (last login/register response)
authProvider.isAuthenticated // bool (true if authenticated)
authProvider.isLoading       // bool (true if loading)
```

## Integration with Registration Flow

The `RegistrationProvider` already integrates with `AuthProvider`:

```dart
// In RegistrationProvider
final authProvider = /* get from context */;
registrationProvider.setAuthProvider(authProvider);

// When completing registration
await registrationProvider.completeRegistration();
// This calls authProvider.register(userData) internally
```

## Session Persistence

- **Automatic on app start**: Tokens are loaded from storage and validated
- **Automatic refresh**: Expired tokens are refreshed transparently
- **Remember Me**: Controls token lifespan (configurable on backend)

## Backend API Endpoints Used

- `POST /auth/login` - Login with email/password
- `POST /auth/register` - Register new user
- `POST /auth/logout` - Logout (invalidate token)
- `POST /auth/refresh-token` - Refresh access token
- `POST /auth/request-password-reset` - Send password reset email
- `GET /auth/me` - Get current user profile
- `PUT /auth/profile` - Update user profile

## Common Patterns

### Protected Route
```dart
class ProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return SizedBox.shrink();
    }
    
    return Scaffold(
      // Protected content
    );
  }
}
```

### Login Form
```dart
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.login(
    _emailController.text.trim(),
    _passwordController.text,
    rememberMe: _rememberMe,
  );
  
  if (mounted) {
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Registration Form
```dart
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = context.read<AuthProvider>();
  
  final userData = {
    'email': _emailController.text.trim(),
    'password': _passwordController.text,
    'firstName': _firstNameController.text.trim(),
    'lastName': _lastNameController.text.trim(),
    'phone': _phoneController.text.trim(),
    'role': _selectedRole.toString().split('.').last,
  };
  
  final success = await authProvider.register(userData);
  
  if (mounted && success) {
    context.go('/home');
  }
}
```

## Notes

- All methods return `Future<bool>` (except `logout()` which is `Future<void>`)
- Success = `true`, Failure = `false`
- On failure, check `errorMessage` for details
- `notifyListeners()` is called automatically on state changes
- Use `context.watch<AuthProvider>()` for reactive UI
- Use `context.read<AuthProvider>()` for one-time actions

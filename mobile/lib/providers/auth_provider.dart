import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication provider for managing user state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  final ApiService _apiService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  AuthResponse? _lastAuthResponse;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
    required ApiService apiService,
  })  : _authService = authService,
        _storageService = storageService,
        _apiService = apiService {
    _initialize();
  }

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthResponse? get lastAuthResponse => _lastAuthResponse;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize authentication state
  Future<void> _initialize() async {
    try {
      _setState(AuthState.loading);
      await loadUserFromStorage();
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
  }

  /// Load user from storage and validate token
  Future<void> loadUserFromStorage() async {
    try {
      final token = await _storageService.getSecureValue('access_token');
      final refreshToken = await _storageService.getSecureValue('refresh_token');
      
      if (token != null) {
        _accessToken = token;
        _refreshToken = refreshToken;
        
        // Set token on API service for authenticated requests
        _apiService.setAuthToken(token);
        
        // Validate token with backend
        final response = await _authService.getCurrentUser(token);
        
        if (response.isSuccess && response.data != null) {
          _user = response.data!;
          _setState(AuthState.authenticated);
          return;
        } else {
          // Try to refresh token if we have a refresh token
          if (refreshToken != null) {
            final refreshResult = await this.refreshToken();
            if (refreshResult) return;
          }
        }
      }
      
      // Clear invalid tokens
      await _clearStoredAuth();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      await _clearStoredAuth();
      _setState(AuthState.unauthenticated);
    }
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    await _storageService.removeSecureValue('access_token');
    await _storageService.removeSecureValue('refresh_token');
    await _storageService.removeValue('user_data');
    _apiService.clearAuthToken();
    _user = null;
    _accessToken = null;
    _refreshToken = null;
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final authResponse = await _authService.login(email, password);
      
      _lastAuthResponse = authResponse;
      _user = authResponse.user;
      _accessToken = authResponse.tokens.accessToken;
      _refreshToken = authResponse.tokens.refreshToken;

      // Set token on API service
      _apiService.setAuthToken(_accessToken!);

      // Store credentials
      await _storageService.setSecureValue('access_token', _accessToken!);
      await _storageService.setSecureValue('refresh_token', _refreshToken!);
      await _storageService.setValue('user_data', _user!.toJson());

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    }
  }

  /// Register new user
  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final authResponse = await _authService.register(userData);
      
      _lastAuthResponse = authResponse;
      _user = authResponse.user;
      _accessToken = authResponse.tokens.accessToken;
      _refreshToken = authResponse.tokens.refreshToken;

      // Set token on API service
      _apiService.setAuthToken(_accessToken!);

      // Store credentials
      await _storageService.setSecureValue('access_token', _accessToken!);
      await _storageService.setSecureValue('refresh_token', _refreshToken!);
      await _storageService.setValue('user_data', _user!.toJson());

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);

      // Call backend logout if we have an access token
      if (_accessToken != null) {
        try {
          await _authService.logout(_accessToken!);
        } catch (e) {
          // Continue with local logout even if backend call fails
          debugPrint('Backend logout failed: $e');
        }
      }

      // Clear stored credentials
      await _clearStoredAuth();

      // Clear error state
      _clearError();

      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      if (_refreshToken == null) return false;

      final authResponse = await _authService.refreshToken(_refreshToken!);
      
      _accessToken = authResponse.tokens.accessToken;
      _refreshToken = authResponse.tokens.refreshToken;
      _user = authResponse.user;

      // Set token on API service
      _apiService.setAuthToken(_accessToken!);
      
      // Update stored tokens
      await _storageService.setSecureValue('access_token', _accessToken!);
      await _storageService.setSecureValue('refresh_token', _refreshToken!);
      await _storageService.setValue('user_data', _user!.toJson());
      
      return true;
    } catch (e) {
      _setError('Token refresh failed: $e');
      await _clearStoredAuth();
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      await _authService.requestPasswordReset(email);
      
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      await _authService.resetPassword(token, newPassword);
      
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (_user == null || _accessToken == null) return false;
      
      _setState(AuthState.loading);
      _clearError();

      // TODO: Add update profile endpoint to AuthService
      // For now, update local user data
      final updatedUser = _user!.copyWith(
        firstName: updates['firstName'] as String?,
        lastName: updates['lastName'] as String?,
        phone: updates['phone'] as String?,
        profilePicture: updates['profilePicture'] as String?,
      );
      
      _user = updatedUser;
      await _storageService.setValue('user_data', _user!.toJson());
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    }
  }

  // Private methods
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

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
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // Call real auth service
      final response = await _authService.login(email, password, rememberMe);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Store tokens and user data
        _accessToken = authResponse.tokens.accessToken;
        _refreshToken = authResponse.tokens.refreshToken;
        _user = authResponse.user;
        _lastAuthResponse = authResponse;
        
        // Persist tokens and user data
        await _storageService.setSecureValue('access_token', _accessToken!);
        await _storageService.setSecureValue('refresh_token', _refreshToken!);
        await _storageService.setValue('user_data', _user!.toJson());
        
        // Set token on API service for subsequent requests
        _apiService.setAuthToken(_accessToken!);
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message ?? 'Login failed');
        return false;
      }
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

      // Call real auth service with user data
      final response = await _authService.register(userData);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;
        
        // Store tokens and user data
        _accessToken = authResponse.tokens.accessToken;
        _refreshToken = authResponse.tokens.refreshToken;
        _user = authResponse.user;
        _lastAuthResponse = authResponse;
        
        // Persist tokens and user data
        await _storageService.setSecureValue('access_token', _accessToken!);
        await _storageService.setSecureValue('refresh_token', _refreshToken!);
        await _storageService.setValue('user_data', _user!.toJson());
        
        // Set token on API service for subsequent requests
        _apiService.setAuthToken(_accessToken!);
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);

      // Call backend logout if we have a token
      if (_accessToken != null) {
        await _authService.logout(_accessToken!);
      }

      // Clear stored credentials and state
      await _clearStoredAuth();

      // Clear in-memory state
      _user = null;
      _accessToken = null;
      _refreshToken = null;
      _lastAuthResponse = null;
      _clearError();

      _setState(AuthState.unauthenticated);
    } catch (e) {
      // Even if backend logout fails, clear local state
      await _clearStoredAuth();
      _user = null;
      _accessToken = null;
      _refreshToken = null;
      _lastAuthResponse = null;
      _setError('Logout failed: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      if (_refreshToken == null) return false;

      // Call real auth service to refresh token
      final response = await _authService.refreshToken(_refreshToken!);
      
      if (response.isSuccess && response.data != null) {
        final tokens = response.data!;
        
        // Update tokens
        _accessToken = tokens.accessToken;
        if (tokens.refreshToken.isNotEmpty) {
          _refreshToken = tokens.refreshToken;
        }
        
        // Persist new tokens
        await _storageService.setSecureValue('access_token', _accessToken!);
        if (tokens.refreshToken.isNotEmpty) {
          await _storageService.setSecureValue('refresh_token', _refreshToken!);
        }
        
        // Update API service with new token
        _apiService.setAuthToken(_accessToken!);
        
        // Fetch updated user profile with new token
        final userResponse = await _authService.getCurrentUser(_accessToken!);
        if (userResponse.isSuccess && userResponse.data != null) {
          _user = userResponse.data!;
          await _storageService.setValue('user_data', _user!.toJson());
          _setState(AuthState.authenticated);
        }
        
        return true;
      } else {
        _setError(response.message ?? 'Token refresh failed');
        return false;
      }
    } catch (e) {
      _setError('Token refresh failed: $e');
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // Call real auth service to request password reset
      final response = await _authService.requestPasswordReset(email);
      
      if (response.isSuccess) {
        _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
        return true;
      } else {
        _setError(response.message ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      _setError('Failed to send reset email: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (_user == null || _accessToken == null) {
        _setError('User not authenticated');
        return false;
      }
      
      _setState(AuthState.loading);
      _clearError();

      // Call real auth service to update profile
      final response = await _authService.updateProfile(_accessToken!, updates);
      
      if (response.isSuccess && response.data != null) {
        // Update local user data with response
        _user = response.data!;
        await _storageService.setValue('user_data', _user!.toJson());
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message ?? 'Profile update failed');
        return false;
      }
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

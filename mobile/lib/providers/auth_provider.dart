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

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
    required ApiService apiService,
  })  : _authService = authService,
        _storageService = storageService,
        _apiService = apiService {
    _initialize();
  }
  final AuthService _authService;
  final StorageService _storageService;
  final ApiService _apiService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  AuthResponse? _lastAuthResponse;
  UserRole? _activeRole;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthResponse? get lastAuthResponse => _lastAuthResponse;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  
  // Role management getters
  UserRole? get activeRole => _activeRole;
  bool get isActiveRoleDoctor => _activeRole == UserRole.doctor;
  bool get isActiveRolePatient => _activeRole == UserRole.patient;
  
  /// Get the current role profile (Doctor or Patient) based on active role
  dynamic get currentRoleProfile {
    if (_user == null || _activeRole == null) return null;
    return _user!.getProfileForRole(_activeRole!);
  }

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
          
          // Load saved active role or default to user's primary role
          final savedRole = await _storageService.getValue('active_role');
          if (savedRole != null && savedRole is String) {
            _activeRole = _parseRole(savedRole);
            // Validate that the saved role is still available
            if (!_user!.canSwitchToRole(_activeRole!)) {
              _activeRole = _user!.role;
              await _storageService.setValue('active_role', _roleToString(_activeRole!));
            }
          } else {
            _activeRole = _user!.role;
            await _storageService.setValue('active_role', _roleToString(_activeRole!));
          }
          
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
    await _storageService.removeValue('active_role');
    _apiService.clearAuthToken();
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    _activeRole = null;
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
        
        // Set initial active role to user's primary role
        _activeRole = _user!.role;
        await _storageService.setValue('active_role', _roleToString(_activeRole!));
        
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
        
        // Set initial active role to user's primary role
        _activeRole = _user!.role;
        await _storageService.setValue('active_role', _roleToString(_activeRole!));
        
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
          
          // Re-validate active role against new user data
          if (_activeRole == null || !_user!.canSwitchToRole(_activeRole!)) {
            // Active role is invalid, reset to user's primary role
            _activeRole = _user!.role;
            await _storageService.setValue('active_role', _roleToString(_activeRole!));
          } else {
            // Active role is still valid, ensure storage is in sync
            await _storageService.setValue('active_role', _roleToString(_activeRole!));
          }
          
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

  /// Switch active role
  Future<bool> switchRole(UserRole newRole) async {
    try {
      if (_user == null) {
        _setError('User not authenticated');
        return false;
      }

      // Validate that the user can switch to this role
      if (!_user!.canSwitchToRole(newRole)) {
        _setError('Cannot switch to this role. Profile not available.');
        return false;
      }

      // Update active role
      _activeRole = newRole;
      
      // Persist the active role
      await _storageService.setValue('active_role', _roleToString(newRole));
      
      // Notify listeners to rebuild UI
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Role switch failed: $e');
      return false;
    }
  }

  // Helper methods for role parsing
  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'patient':
        return UserRole.patient;
      case 'doctor':
        return UserRole.doctor;
      case 'hospital':
        return UserRole.hospital;
      case 'pharmacy':
        return UserRole.pharmacy;
      default:
        return UserRole.patient;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return 'patient';
      case UserRole.doctor:
        return 'doctor';
      case UserRole.hospital:
        return 'hospital';
      case UserRole.pharmacy:
        return 'pharmacy';
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

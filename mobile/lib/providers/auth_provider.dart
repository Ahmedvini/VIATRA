import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// User authentication model
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      lastLogin: json['lastLogin'] != null 
        ? DateTime.parse(json['lastLogin'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

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
  final ApiService _apiService;
  final StorageService _storageService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  String? _accessToken;

  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService, _storageService = storageService {
    _initialize();
  }

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize authentication state
  Future<void> _initialize() async {
    try {
      _setState(AuthState.loading);
      
      // Check for stored token
      final token = await _storageService.getSecureValue('access_token');
      if (token != null) {
        _accessToken = token;
        
        // Verify token and get user info
        final userJson = await _storageService.getValue('user_data');
        if (userJson != null) {
          _user = User.fromJson(userJson as Map<String, dynamic>);
          _setState(AuthState.authenticated);
          return;
        }
      }
      
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Simulate successful login
      _accessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = User(
        id: 'user_123',
        email: email,
        name: 'Mock User',
        lastLogin: DateTime.now(),
      );

      // Store credentials
      await _storageService.setSecureValue('access_token', _accessToken!);
      await _storageService.setValue('user_data', _user!.toJson());

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    }
  }

  /// Register new user
  Future<bool> register(String email, String password, String name) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Simulate successful registration
      return await login(email, password);
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);

      // Clear stored credentials
      await _storageService.removeSecureValue('access_token');
      await _storageService.removeValue('user_data');

      // Clear in-memory state
      _user = null;
      _accessToken = null;
      _clearError();

      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      if (_accessToken == null) return false;

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate token refresh
      _accessToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      await _storageService.setSecureValue('access_token', _accessToken!);
      
      return true;
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

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (_user == null) return false;
      
      _setState(AuthState.loading);
      _clearError();

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local user data
      final updatedUser = User(
        id: _user!.id,
        email: updates['email'] ?? _user!.email,
        name: updates['name'] ?? _user!.name,
        avatar: updates['avatar'] ?? _user!.avatar,
        lastLogin: _user!.lastLogin,
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

import '../services/api_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Register a new user
  Future<ApiResponse<AuthResponse>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/auth/register', userData);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        
        // Set tokens in ApiService headers for subsequent requests
        if (authResponse.tokens.hasValidTokens) {
          _apiService.setAuthToken(authResponse.tokens.accessToken);
        }
        
        return ApiResponse.success(authResponse);
      }
      
      return ApiResponse.error(response.message ?? 'Registration failed');
    } catch (e) {
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<ApiResponse<AuthResponse>> login(
    String email, 
    String password, 
    bool rememberMe
  ) async {
    try {
      final loginData = {
        'email': email,
        'password': password,
        'remember': rememberMe,
      };
      
      final response = await _apiService.post('/auth/login', loginData);
      
      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        
        // Set tokens in ApiService headers for subsequent requests
        if (authResponse.tokens.hasValidTokens) {
          _apiService.setAuthToken(authResponse.tokens.accessToken);
        }
        
        return ApiResponse.success(authResponse);
      }
      
      return ApiResponse.error(response.message ?? 'Login failed');
    } catch (e) {
      return ApiResponse.error('Login failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout(String token) async {
    try {
      // Set token for logout request
      _apiService.setAuthToken(token);
      
      final response = await _apiService.post('/auth/logout', {});
      
      // Clear token from ApiService regardless of response
      _apiService.clearAuthToken();
      
      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(response.message ?? 'Logout failed');
    } catch (e) {
      // Clear token even if request fails
      _apiService.clearAuthToken();
      return ApiResponse.error('Logout failed: ${e.toString()}');
    }
  }

  /// Verify email with code
  Future<ApiResponse<void>> verifyEmail(String email, String code) async {
    try {
      final verifyData = {
        'email': email,
        'code': code,
      };
      
      final response = await _apiService.post('/auth/verify-email', verifyData);
      
      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(response.message ?? 'Email verification failed');
    } catch (e) {
      return ApiResponse.error('Email verification failed: ${e.toString()}');
    }
  }

  /// Get current user profile
  Future<ApiResponse<User>> getCurrentUser(String token) async {
    try {
      // Set token for authenticated request
      _apiService.setAuthToken(token);
      
      final response = await _apiService.get('/auth/me');
      
      if (response.isSuccess && response.data != null) {
        final userData = response.data!['data'] ?? response.data!;
        final user = User.fromJson(userData);
        return ApiResponse.success(user);
      }
      
      return ApiResponse.error(response.message ?? 'Failed to get user profile');
    } catch (e) {
      return ApiResponse.error('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<ApiResponse<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final refreshData = {
        'refreshToken': refreshToken,
      };
      
      final response = await _apiService.post('/auth/refresh-token', refreshData);
      
      if (response.isSuccess && response.data != null) {
        final tokensData = response.data!['data'] ?? response.data!;
        final tokens = AuthTokens.fromJson(tokensData);
        
        // Update ApiService with new access token
        if (tokens.accessToken.isNotEmpty) {
          _apiService.setAuthToken(tokens.accessToken);
        }
        
        return ApiResponse.success(tokens);
      }
      
      return ApiResponse.error(response.message ?? 'Token refresh failed');
    } catch (e) {
      return ApiResponse.error('Token refresh failed: ${e.toString()}');
    }
  }

  /// Request password reset
  Future<ApiResponse<void>> requestPasswordReset(String email) async {
    try {
      final resetData = {
        'email': email,
      };
      
      final response = await _apiService.post('/auth/request-password-reset', resetData);
      
      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(response.message ?? 'Password reset request failed');
    } catch (e) {
      return ApiResponse.error('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<ApiResponse<void>> resetPassword(String token, String newPassword) async {
    try {
      final resetData = {
        'token': token,
        'newPassword': newPassword,
      };
      
      final response = await _apiService.post('/auth/reset-password', resetData);
      
      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(response.message ?? 'Password reset failed');
    } catch (e) {
      return ApiResponse.error('Password reset failed: ${e.toString()}');
    }
  }

  /// Validate current token
  Future<ApiResponse<User>> validateToken(String token) async {
    try {
      // Set token for validation request
      _apiService.setAuthToken(token);
      
      final response = await _apiService.get('/auth/validate-token');
      
      if (response.isSuccess && response.data != null) {
        final userData = response.data!['data']?['user'] ?? response.data!['user'];
        if (userData != null) {
          final user = User.fromJson(userData);
          return ApiResponse.success(user);
        }
      }
      
      return ApiResponse.error(response.message ?? 'Token validation failed');
    } catch (e) {
      return ApiResponse.error('Token validation failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile(String token, Map<String, dynamic> updates) async {
    try {
      // Set token for authenticated request
      _apiService.setAuthToken(token);
      
      final response = await _apiService.put('/auth/profile', updates);
      
      if (response.isSuccess && response.data != null) {
        final userData = response.data!['data'] ?? response.data!;
        final user = User.fromJson(userData);
        return ApiResponse.success(user);
      }
      
      return ApiResponse.error(response.message ?? 'Profile update failed');
    } catch (e) {
      return ApiResponse.error('Profile update failed: ${e.toString()}');
    }
  }
}

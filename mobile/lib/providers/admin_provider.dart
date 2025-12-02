import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;

  AdminProvider(this._adminService);

  bool _isLoading = false;
  String? _error;
  List<AdminUser> _users = [];
  AdminUser? _selectedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AdminUser> get users => _users;
  AdminUser? get selectedUser => _selectedUser;

  /// Load users by role and status
  Future<void> loadUsers(String role, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      ApiResponse<List<AdminUser>> response;

      switch (status) {
        case 'pending':
          response = await _adminService.getPendingUsers(role: role);
          break;
        case 'active':
          response = await _adminService.getActiveUsers(role: role);
          break;
        case 'deactivated':
          response = await _adminService.getDeactivatedUsers(role: role);
          break;
        default:
          throw Exception('Invalid status: $status');
      }

      if (response.success && response.data != null) {
        _users = response.data!;
      } else {
        _error = response.message ?? 'Failed to load users';
      }
    } catch (e) {
      _error = 'Error loading users: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load detailed user information
  Future<void> loadUserDetails(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.getUserDetails(userId);

      if (response.success && response.data != null) {
        _selectedUser = response.data;
      } else {
        _error = response.message ?? 'Failed to load user details';
      }
    } catch (e) {
      _error = 'Error loading user details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Authorize a pending user
  Future<bool> authorizeUser(String userId, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.authorizeUser(userId, notes: notes);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to authorize user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error authorizing user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reject a pending user
  Future<bool> rejectUser(String userId, String reason,
      {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.rejectUser(
        userId,
        reason: reason,
        notes: notes,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to reject user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error rejecting user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Activate a deactivated user
  Future<bool> activateUser(String userId, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.activateUser(userId, notes: notes);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to activate user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error activating user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deactivate an active user
  Future<bool> deactivateUser(String userId, String reason,
      {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.deactivateUser(
        userId,
        reason: reason,
        notes: notes,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to deactivate user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deactivating user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a user permanently
  Future<bool> deleteUser(String userId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _adminService.deleteUser(userId, reason: reason);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Failed to delete user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}

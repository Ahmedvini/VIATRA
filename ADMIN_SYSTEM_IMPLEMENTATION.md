# Admin User Management System - Implementation Guide

## Overview
Complete admin panel system for reviewing patients and doctors with three status categories: Pending, Active, and Deactivated users.

## Backend Implementation ✅ COMPLETE

### 1. Admin Routes (`/backend/src/routes/admin.js`) ✅ Created

**Base URL**: `/api/v1/admin`

#### Get Users by Status
- `GET /admin/users/pending?role=doctor|patient&page=1&limit=20` - Get pending users
- `GET /admin/users/active?role=doctor|patient&page=1&limit=20` - Get active users
- `GET /admin/users/deactivated?role=doctor|patient&page=1&limit=20` - Get deactivated users

#### Get User Details
- `GET /admin/users/:userId` - Get detailed user info with all documents

#### User Actions
**Pending Users**:
- `PATCH /admin/users/:userId/authorize` - Approve and activate user
  ```json
  { "notes": "Approved after document review" }
  ```
- `PATCH /admin/users/:userId/reject` - Reject user registration
  ```json
  { "reason": "Invalid documents", "notes": "..." }
  ```

**Active Users**:
- `PATCH /admin/users/:userId/deactivate` - Deactivate user account
  ```json
  { "reason": "Policy violation", "notes": "..." }
  ```
- `DELETE /admin/users/:userId` - Permanently delete user
  ```json
  { "reason": "User request", "confirmation": true }
  ```

**Deactivated Users**:
- `PATCH /admin/users/:userId/activate` - Reactivate user account
  ```json
  { "notes": "Reactivated after appeal" }
  ```
- `DELETE /admin/users/:userId` - Permanently delete user

### 2. Admin Controller (`/backend/src/controllers/adminUserController.js`) ✅ Created

Functions implemented:
- `getPendingUsers()` - Fetch users with is_active=false
- `getActiveUsers()` - Fetch users with is_active=true  
- `getDeactivatedUsers()` - Fetch deactivated users
- `getUserDetails()` - Get full user info with profiles and documents
- `authorizeUser()` - Approve pending user + auto-approve all documents
- `rejectUser()` - Reject user + mark all documents as rejected
- `activateUser()` - Reactivate deactivated user
- `deactivateUser()` - Deactivate active user
- `deleteUser()` - Permanently delete user (with safety checks)

### 3. Routes Registration ✅ Complete
- Added `import adminRoutes from './admin.js'` to `/backend/src/routes/index.js`
- Mounted at `router.use('/admin', adminRoutes)`

## Mobile App Implementation 🚧 IN PROGRESS

### Files Created:
1. ✅ `/mobile/lib/services/admin_service.dart` - API service for admin operations
2. ✅ `/mobile/lib/screens/admin/admin_dashboard_screen.dart` - Main dashboard with 2 options
3. ✅ `/mobile/lib/screens/admin/admin_users_list_screen.dart` - Status selector (3 options)
4. ✅ `/mobile/lib/screens/admin/admin_user_status_list_screen.dart` - List users by status
5. ✅ `/mobile/lib/services/api_service.dart` - Updated DELETE method to support body

### Files Still Needed:
1. ❌ `/mobile/lib/providers/admin_provider.dart` - State management
2. ❌ `/mobile/lib/screens/admin/admin_user_detail_screen.dart` - User details with actions
3. ❌ Add admin route to main app navigation

## Complete Implementation Steps

### Step 1: Create Admin Provider

Create `/mobile/lib/providers/admin_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/admin_service.dart';

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
          throw Exception('Invalid status');
      }
      
      if (response.success && response.data != null) {
        _users = response.data!;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadUserDetails(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _adminService.getUserDetails(userId);
      
      if (response.success && response.data != null) {
        _selectedUser = response.data;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> authorizeUser(String userId, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _adminService.authorizeUser(userId, notes: notes);
      
      if (response.success) {
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> rejectUser(String userId, String reason, {String? notes}) async {
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
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> activateUser(String userId, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _adminService.activateUser(userId, notes: notes);
      
      if (response.success) {
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deactivateUser(String userId, String reason, {String? notes}) async {
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
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteUser(String userId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _adminService.deleteUser(userId, reason: reason);
      
      if (response.success) {
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### Step 2: Create User Detail Screen

Create `/mobile/lib/screens/admin/admin_user_detail_screen.dart`:

This screen should display:
1. User basic info (name, email, phone, role)
2. User profile details (doctor specialty/license or patient DOB/gender)
3. All uploaded documents with preview
4. Action buttons based on status:
   - **Pending**: [Authorize] [Reject]
   - **Active**: [Deactivate] [Delete]
   - **Deactivated**: [Activate] [Delete]

```dart
// See full implementation in next section
```

### Step 3: Register Provider

In your main app file, add the AdminProvider:

```dart
MultiProvider(
  providers: [
    // ...existing providers
    ChangeNotifierProvider(
      create: (context) => AdminProvider(
        context.read<AdminService>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### Step 4: Add Admin Navigation

Add admin dashboard to your main navigation (e.g., drawer or bottom nav):

```dart
if (user?.role == 'admin')
  ListTile(
    leading: const Icon(Icons.admin_panel_settings),
    title: const Text('Admin Panel'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
        ),
      );
    },
  ),
```

## Navigation Flow

```
Admin Dashboard
├── Review Patients
│   ├── Pending Patients
│   │   └── Patient Detail → [Authorize] [Reject]
│   ├── Active Patients
│   │   └── Patient Detail → [Deactivate] [Delete]
│   └── Deactivated Patients
│       └── Patient Detail → [Activate] [Delete]
└── Review Doctors
    ├── Pending Doctors
    │   └── Doctor Detail → [Authorize] [Reject]
    ├── Active Doctors
    │   └── Doctor Detail → [Deactivate] [Delete]
    └── Deactivated Doctors
        └── Doctor Detail → [Activate] [Delete]
```

## Backend Response Examples

### GET /admin/users/pending?role=doctor

```json
{
  "success": true,
  "message": "Pending users retrieved successfully",
  "data": {
    "users": [
      {
        "id": "user-uuid",
        "email": "doctor@example.com",
        "firstName": "John",
        "lastName": "Doe",
        "phone": "+1234567890",
        "role": "doctor",
        "isActive": false,
        "emailVerified": false,
        "createdAt": "2024-12-02T10:00:00.000Z",
        "updatedAt": "2024-12-02T10:00:00.000Z",
        "lastLogin": null,
        "doctorProfile": {
          "id": "doctor-uuid",
          "specialty": "Cardiology",
          "licenseNumber": "MD12345",
          "title": "Dr.",
          "bio": "Experienced cardiologist...",
          "education": "Harvard Medical School",
          "experience": 10,
          "consultationFee": 150.00,
          "rating": null,
          "totalReviews": 0,
          "availabilityStatus": "available"
        },
        "verifications": [
          {
            "id": "verification-uuid",
            "type": "identity",
            "status": "pending",
            "documentUrl": "https://storage.googleapis.com/.../identity.jpg",
            "documentType": "id_card.jpg",
            "verificationData": {
              "description": "ID card",
              "uploadedAt": "2024-12-02T10:05:00.000Z"
            },
            "verifiedAt": null,
            "rejectionReason": null,
            "attempts": 1,
            "createdAt": "2024-12-02T10:05:00.000Z"
          },
          {
            "id": "verification-uuid-2",
            "type": "medical_license",
            "status": "pending",
            "documentUrl": "https://storage.googleapis.com/.../license.pdf",
            "documentType": "medical_license.pdf",
            "verificationData": {
              "description": "Medical license",
              "uploadedAt": "2024-12-02T10:06:00.000Z"
            },
            "verifiedAt": null,
            "rejectionReason": null,
            "attempts": 1,
            "createdAt": "2024-12-02T10:06:00.000Z"
          }
        ]
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalCount": 1,
      "limit": 20
    }
  }
}
```

## Testing Endpoints

### 1. Get Pending Doctors
```bash
curl -X GET 'https://your-backend-url/api/v1/admin/users/pending?role=doctor' \
  -H "Authorization: Bearer <admin-token>"
```

### 2. Authorize User
```bash
curl -X PATCH 'https://your-backend-url/api/v1/admin/users/<userId>/authorize' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"notes": "All documents verified"}'
```

### 3. Reject User
```bash
curl -X PATCH 'https://your-backend-url/api/v1/admin/users/<userId>/reject' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Invalid license number", "notes": "License not found in registry"}'
```

### 4. Deactivate User
```bash
curl -X PATCH 'https://your-backend-url/api/v1/admin/users/<userId>/deactivate' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Policy violation", "notes": "Multiple complaints received"}'
```

### 5. Delete User
```bash
curl -X DELETE 'https://your-backend-url/api/v1/admin/users/<userId>' \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"reason": "User requested account deletion", "confirmation": true}'
```

## Next Steps

1. ✅ Backend routes and controllers - COMPLETE
2. ✅ Admin service (mobile) - COMPLETE
3. ✅ Dashboard and list screens - COMPLETE
4. ❌ Create AdminProvider - TODO
5. ❌ Create UserDetailScreen - TODO
6. ❌ Add to app navigation - TODO
7. ❌ Test all flows - TODO

## Security Notes

- All admin endpoints require authentication + admin role
- Admins cannot deactivate/delete themselves
- Admins cannot delete other admin accounts
- Deletion requires explicit confirmation
- All actions are logged with admin ID and timestamp
- Rate limiting applied to prevent abuse (100 actions per 5 minutes)

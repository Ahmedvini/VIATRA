import '../models/verification_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService;

  AdminService(this._apiService);

  /// Get pending users (doctors or patients)
  Future<ApiResponse<List<AdminUser>>> getPendingUsers({
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '/admin/users/pending?page=$page&limit=$limit';
      if (role != null) {
        url += '&role=$role';
      }

      final response = await _apiService.get(url);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final usersData = data['data']?['users'] as List? ?? [];
        final users = usersData
            .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(users);
      }

      return ApiResponse.error(
          response.message ?? 'Failed to get pending users');
    } catch (e) {
      return ApiResponse.error('Failed to get pending users: ${e.toString()}');
    }
  }

  /// Get active users
  Future<ApiResponse<List<AdminUser>>> getActiveUsers({
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '/admin/users/active?page=$page&limit=$limit';
      if (role != null) {
        url += '&role=$role';
      }

      final response = await _apiService.get(url);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final usersData = data['data']?['users'] as List? ?? [];
        final users = usersData
            .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(users);
      }

      return ApiResponse.error(
          response.message ?? 'Failed to get active users');
    } catch (e) {
      return ApiResponse.error('Failed to get active users: ${e.toString()}');
    }
  }

  /// Get deactivated users
  Future<ApiResponse<List<AdminUser>>> getDeactivatedUsers({
    String? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '/admin/users/deactivated?page=$page&limit=$limit';
      if (role != null) {
        url += '&role=$role';
      }

      final response = await _apiService.get(url);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final usersData = data['data']?['users'] as List? ?? [];
        final users = usersData
            .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(users);
      }

      return ApiResponse.error(
          response.message ?? 'Failed to get deactivated users');
    } catch (e) {
      return ApiResponse.error(
          'Failed to get deactivated users: ${e.toString()}');
    }
  }

  /// Get detailed user information
  Future<ApiResponse<AdminUser>> getUserDetails(String userId) async {
    try {
      final response = await _apiService.get('/admin/users/$userId');

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['data'] as Map<String, dynamic>;
        final user = AdminUser.fromJson(userData);
        return ApiResponse.success(user);
      }

      return ApiResponse.error(
          response.message ?? 'Failed to get user details');
    } catch (e) {
      return ApiResponse.error('Failed to get user details: ${e.toString()}');
    }
  }

  /// Authorize a pending user
  Future<ApiResponse<void>> authorizeUser(String userId,
      {String? notes}) async {
    try {
      final response = await _apiService.patch(
        '/admin/users/$userId/authorize',
        body: {'notes': notes},
      );

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.message ?? 'Failed to authorize user');
    } catch (e) {
      return ApiResponse.error('Failed to authorize user: ${e.toString()}');
    }
  }

  /// Reject a pending user
  Future<ApiResponse<void>> rejectUser(
    String userId, {
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _apiService.patch(
        '/admin/users/$userId/reject',
        body: {
          'reason': reason,
          'notes': notes,
        },
      );

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.message ?? 'Failed to reject user');
    } catch (e) {
      return ApiResponse.error('Failed to reject user: ${e.toString()}');
    }
  }

  /// Activate a deactivated user
  Future<ApiResponse<void>> activateUser(String userId,
      {String? notes}) async {
    try {
      final response = await _apiService.patch(
        '/admin/users/$userId/activate',
        body: {'notes': notes},
      );

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.message ?? 'Failed to activate user');
    } catch (e) {
      return ApiResponse.error('Failed to activate user: ${e.toString()}');
    }
  }

  /// Deactivate an active user
  Future<ApiResponse<void>> deactivateUser(
    String userId, {
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _apiService.patch(
        '/admin/users/$userId/deactivate',
        body: {
          'reason': reason,
          'notes': notes,
        },
      );

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.message ?? 'Failed to deactivate user');
    } catch (e) {
      return ApiResponse.error('Failed to deactivate user: ${e.toString()}');
    }
  }

  /// Delete a user permanently
  Future<ApiResponse<void>> deleteUser(
    String userId, {
    required String reason,
  }) async {
    try {
      final response = await _apiService.delete(
        '/admin/users/$userId',
        body: {
          'reason': reason,
          'confirmation': true,
        },
      );

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.message ?? 'Failed to delete user');
    } catch (e) {
      return ApiResponse.error('Failed to delete user: ${e.toString()}');
    }
  }
}

/// Admin User Model (extended user model with all details)
class AdminUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  // Role-specific profiles
  final DoctorProfile? doctorProfile;
  final PatientProfile? patientProfile;

  // Documents
  final List<Verification> verifications;

  AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.doctorProfile,
    this.patientProfile,
    required this.verifications,
  });

  String get fullName => '$firstName $lastName';

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      doctorProfile: json['doctorProfile'] != null
          ? DoctorProfile.fromJson(json['doctorProfile'] as Map<String, dynamic>)
          : null,
      patientProfile: json['patientProfile'] != null
          ? PatientProfile.fromJson(
              json['patientProfile'] as Map<String, dynamic>)
          : null,
      verifications: (json['verifications'] as List<dynamic>? ?? [])
          .map((v) => Verification.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Doctor Profile (subset for admin view)
class DoctorProfile {
  final String id;
  final String? specialty;
  final String? licenseNumber;
  final String? title;
  final String? bio;
  final String? education;
  final int? experience;
  final double? consultationFee;
  final double? rating;
  final int? totalReviews;
  final String? availabilityStatus;

  DoctorProfile({
    required this.id,
    this.specialty,
    this.licenseNumber,
    this.title,
    this.bio,
    this.education,
    this.experience,
    this.consultationFee,
    this.rating,
    this.totalReviews,
    this.availabilityStatus,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      specialty: json['specialty'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      title: json['title'] as String?,
      bio: json['bio'] as String?,
      education: json['education'] as String?,
      experience: json['experience'] as int?,
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int?,
      availabilityStatus: json['availabilityStatus'] as String?,
    );
  }
}

/// Patient Profile (subset for admin view)
class PatientProfile {
  final String id;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final Map<String, dynamic>? emergencyContact;

  PatientProfile({
    required this.id,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.emergencyContact,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      bloodType: json['bloodType'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      emergencyContact: json['emergencyContact'] as Map<String, dynamic>?,
    );
  }
}

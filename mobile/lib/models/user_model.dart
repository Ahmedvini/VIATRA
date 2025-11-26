import 'doctor_model.dart';
import 'patient_model.dart';

enum UserRole { patient, doctor, hospital, pharmacy }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole role;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Role profile fields
  final Doctor? doctorProfile;
  final Patient? patientProfile;
  final UserRole? activeRole;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.doctorProfile,
    this.patientProfile,
    this.activeRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      role: _parseRole(json['role']),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      emailVerified: json['emailVerified'] ?? json['email_verified'] ?? false,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      doctorProfile: json['doctorProfile'] != null 
          ? Doctor.fromJson(json['doctorProfile']) 
          : null,
      patientProfile: json['patientProfile'] != null 
          ? Patient.fromJson(json['patientProfile']) 
          : null,
      activeRole: json['activeRole'] != null 
          ? _parseRole(json['activeRole']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': _roleToString(role),
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (doctorProfile != null) 'doctorProfile': doctorProfile!.toJson(),
      if (patientProfile != null) 'patientProfile': patientProfile!.toJson(),
      if (activeRole != null) 'activeRole': _roleToString(activeRole!),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Doctor? doctorProfile,
    Patient? patientProfile,
    UserRole? activeRole,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      patientProfile: patientProfile ?? this.patientProfile,
      activeRole: activeRole ?? this.activeRole,
    );
  }

  String get fullName => '$firstName $lastName';

  /// Returns list of available roles based on existing profiles
  List<UserRole> get availableRoles {
    final roles = <UserRole>[];
    if (patientProfile != null) roles.add(UserRole.patient);
    if (doctorProfile != null) roles.add(UserRole.doctor);
    // If no profiles exist, use the user's primary role
    if (roles.isEmpty) roles.add(role);
    return roles;
  }

  /// Check if user has multiple roles
  bool get hasMultipleRoles => availableRoles.length > 1;

  /// Check if user can switch to a specific role
  bool canSwitchToRole(UserRole targetRole) {
    return availableRoles.contains(targetRole);
  }

  /// Get profile for a specific role
  dynamic getProfileForRole(UserRole targetRole) {
    switch (targetRole) {
      case UserRole.doctor:
        return doctorProfile;
      case UserRole.patient:
        return patientProfile;
      default:
        return null;
    }
  }

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

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

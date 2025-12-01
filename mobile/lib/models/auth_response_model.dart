import 'user_model.dart';
import 'doctor_model.dart';
import 'patient_model.dart';

class AuthResponse {

  AuthResponse({
    required this.user,
    required this.tokens, this.profile,
    this.emailSent,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = (json['data']?['user'] ?? json['user'] ?? {}) as Map<String, dynamic>;
    final user = User.fromJson(userData);
    
    // Parse profile based on user role
    dynamic profile;
    final profileData = json['data']?['profile'] ?? json['profile'];
    if (profileData != null) {
      switch (user.role) {
        case UserRole.doctor:
          profile = Doctor.fromJson(profileData as Map<String, dynamic>);
          break;
        case UserRole.patient:
          profile = Patient.fromJson(profileData as Map<String, dynamic>);
          break;
        default:
          profile = profileData; // Keep as raw data for hospital/pharmacy
      }
    }

    final tokensData = (json['data']?['tokens'] ?? json['tokens'] ?? {}) as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(tokensData);

    return AuthResponse(
      user: user,
      profile: profile,
      tokens: tokens,
      emailSent: (json['data']?['emailSent'] ?? json['emailSent']) as bool?,
    );
  }
  final User user;
  final dynamic profile; // Can be Doctor or Patient
  final AuthTokens tokens;
  final bool? emailSent;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> profileJson;
    if (profile is Doctor) {
      profileJson = (profile as Doctor).toJson();
    } else if (profile is Patient) {
      profileJson = (profile as Patient).toJson();
    } else if (profile is Map<String, dynamic>) {
      profileJson = profile as Map<String, dynamic>;
    } else {
      profileJson = {};
    }

    return {
      'user': user.toJson(),
      'profile': profileJson,
      'tokens': tokens.toJson(),
      'emailSent': emailSent,
    };
  }

  Doctor? get doctorProfile => profile is Doctor ? profile as Doctor : null;
  Patient? get patientProfile => profile is Patient ? profile as Patient : null;

  bool get isDoctor => user.role == UserRole.doctor;
  bool get isPatient => user.role == UserRole.patient;
  bool get isHospital => user.role == UserRole.hospital;
  bool get isPharmacy => user.role == UserRole.pharmacy;

  @override
  String toString() => 'AuthResponse(user: ${user.fullName}, role: ${user.role}, hasTokens: ${tokens.accessToken.isNotEmpty})';
}

class AuthTokens {

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
      accessToken: (json['accessToken'] ?? json['access_token'] ?? '') as String,
      refreshToken: (json['refreshToken'] ?? json['refresh_token'] ?? '') as String,
    );
  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };

  bool get hasValidTokens => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  @override
  String toString() => 'AuthTokens(hasAccessToken: ${accessToken.isNotEmpty}, hasRefreshToken: ${refreshToken.isNotEmpty})';
}

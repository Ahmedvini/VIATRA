class Doctor {

  Doctor({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialty,
    this.subSpecialty,
    required this.title,
    this.npiNumber,
    this.deaNumber,
    this.yearsOfExperience,
    this.bio,
    this.education,
    this.certifications,
    this.consultationFee,
    this.availableSchedule,
    this.languagesSpoken,
    this.telehealthEnabled,
    this.isAcceptingPatients,
    this.officeAddressLine1,
    this.officeAddressLine2,
    this.officeCity,
    this.officeState,
    this.officeZipCode,
    this.officePhone,
    this.workingHours,
    this.rating,
    this.totalReviews,
    required this.isVerified,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Parse user data if present
    final user = json['user'] as Map<String, dynamic>?;
    
    return Doctor(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? json['user_id']?.toString() ?? '',
      licenseNumber: json['licenseNumber'] ?? json['license_number'] ?? '',
      specialty: json['specialty'] ?? '',
      subSpecialty: json['subSpecialty'] ?? json['sub_specialty'],
      title: json['title'] ?? 'Dr.',
      npiNumber: json['npiNumber'] ?? json['npi_number'],
      deaNumber: json['deaNumber'] ?? json['dea_number'],
      yearsOfExperience: json['yearsOfExperience'] ?? json['years_of_experience'],
      bio: json['bio'],
      education: json['education'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      consultationFee: json['consultationFee']?.toDouble() ?? json['consultation_fee']?.toDouble(),
      availableSchedule: json['availableSchedule'] != null
          ? List<String>.from(json['availableSchedule'])
          : json['available_schedule'] != null
              ? List<String>.from(json['available_schedule'])
              : null,
      languagesSpoken: json['languagesSpoken'] != null
          ? List<String>.from(json['languagesSpoken'])
          : json['languages_spoken'] != null
              ? List<String>.from(json['languages_spoken'])
              : null,
      telehealthEnabled: json['telehealthEnabled'] ?? json['telehealth_enabled'],
      isAcceptingPatients: json['isAcceptingPatients'] ?? json['is_accepting_patients'],
      officeAddressLine1: json['officeAddressLine1'] ?? json['office_address_line1'],
      officeAddressLine2: json['officeAddressLine2'] ?? json['office_address_line2'],
      officeCity: json['officeCity'] ?? json['office_city'],
      officeState: json['officeState'] ?? json['office_state'],
      officeZipCode: json['officeZipCode'] ?? json['office_zip_code'],
      officePhone: json['officePhone'] ?? json['office_phone'],
      workingHours: json['workingHours'] ?? json['working_hours'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['totalReviews'] ?? json['total_reviews'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      firstName: user?['firstName'] ?? user?['first_name'],
      lastName: user?['lastName'] ?? user?['last_name'],
      email: user?['email'],
      phone: user?['phone'],
      profileImage: user?['profileImage'] ?? user?['profile_image'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }
  final String id;
  final String userId;
  final String licenseNumber;
  final String specialty;
  final String? subSpecialty;
  final String title;
  final String? npiNumber;
  final String? deaNumber;
  final int? yearsOfExperience;
  final String? bio;
  final String? education;
  final List<String>? certifications;
  final double? consultationFee;
  final List<String>? availableSchedule;
  final List<String>? languagesSpoken;
  final bool? telehealthEnabled;
  final bool? isAcceptingPatients;
  final String? officeAddressLine1;
  final String? officeAddressLine2;
  final String? officeCity;
  final String? officeState;
  final String? officeZipCode;
  final String? officePhone;
  final Map<String, dynamic>? workingHours;
  final double? rating;
  final int? totalReviews;
  final bool isVerified;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'licenseNumber': licenseNumber,
      'specialty': specialty,
      'subSpecialty': subSpecialty,
      'title': title,
      'npiNumber': npiNumber,
      'deaNumber': deaNumber,
      'yearsOfExperience': yearsOfExperience,
      'bio': bio,
      'education': education,
      'certifications': certifications,
      'consultationFee': consultationFee,
      'availableSchedule': availableSchedule,
      'languagesSpoken': languagesSpoken,
      'telehealthEnabled': telehealthEnabled,
      'isAcceptingPatients': isAcceptingPatients,
      'officeAddressLine1': officeAddressLine1,
      'officeAddressLine2': officeAddressLine2,
      'officeCity': officeCity,
      'officeState': officeState,
      'officeZipCode': officeZipCode,
      'officePhone': officePhone,
      'workingHours': workingHours,
      'rating': rating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  Doctor copyWith({
    String? id,
    String? userId,
    String? licenseNumber,
    String? specialty,
    String? subSpecialty,
    String? title,
    String? npiNumber,
    String? deaNumber,
    int? yearsOfExperience,
    String? bio,
    String? education,
    List<String>? certifications,
    double? consultationFee,
    List<String>? availableSchedule,
    List<String>? languagesSpoken,
    bool? telehealthEnabled,
    bool? isAcceptingPatients,
    String? officeAddressLine1,
    String? officeAddressLine2,
    String? officeCity,
    String? officeState,
    String? officeZipCode,
    String? officePhone,
    Map<String, dynamic>? workingHours,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Doctor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialty: specialty ?? this.specialty,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      title: title ?? this.title,
      npiNumber: npiNumber ?? this.npiNumber,
      deaNumber: deaNumber ?? this.deaNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      consultationFee: consultationFee ?? this.consultationFee,
      availableSchedule: availableSchedule ?? this.availableSchedule,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      telehealthEnabled: telehealthEnabled ?? this.telehealthEnabled,
      isAcceptingPatients: isAcceptingPatients ?? this.isAcceptingPatients,
      officeAddressLine1: officeAddressLine1 ?? this.officeAddressLine1,
      officeAddressLine2: officeAddressLine2 ?? this.officeAddressLine2,
      officeCity: officeCity ?? this.officeCity,
      officeState: officeState ?? this.officeState,
      officeZipCode: officeZipCode ?? this.officeZipCode,
      officePhone: officePhone ?? this.officePhone,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get displayName => fullName.isNotEmpty ? '$title $fullName' : '$title $licenseNumber';

  String get displayAddress {
    final parts = <String>[];
    if (officeAddressLine1 != null) parts.add(officeAddressLine1!);
    if (officeCity != null) parts.add(officeCity!);
    if (officeState != null) parts.add(officeState!);
    if (officeZipCode != null) parts.add(officeZipCode!);
    return parts.join(', ');
  }

  bool get isAvailableToday {
    if (workingHours == null) return false;
    final today = DateTime.now().weekday;
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayName = dayNames[today - 1];
    final todayHours = workingHours![dayName];
    return todayHours != null && todayHours is Map && todayHours['open'] != null;
  }

  String get formattedFee {
    if (consultationFee == null) return 'Fee not available';
    return '\$${consultationFee!.toStringAsFixed(2)}';
  }
  
  String get formattedRating {
    if (rating == null) return 'No ratings yet';
    return '${rating!.toStringAsFixed(1)} (${totalReviews ?? 0} reviews)';
  }

  @override
  String toString() => 'Doctor(id: $id, licenseNumber: $licenseNumber, specialty: $specialty, isVerified: $isVerified)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Doctor {
  final String id;
  final String userId;
  final String licenseNumber;
  final String specialty;
  final String title;
  final int? yearsOfExperience;
  final String? bio;
  final double? consultationFee;
  final List<String>? availableSchedule;
  final double? rating;
  final int? totalReviews;
  final bool isVerified;

  Doctor({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialty,
    required this.title,
    this.yearsOfExperience,
    this.bio,
    this.consultationFee,
    this.availableSchedule,
    this.rating,
    this.totalReviews,
    required this.isVerified,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? json['user_id']?.toString() ?? '',
      licenseNumber: json['licenseNumber'] ?? json['license_number'] ?? '',
      specialty: json['specialty'] ?? '',
      title: json['title'] ?? 'Dr.',
      yearsOfExperience: json['yearsOfExperience'] ?? json['years_of_experience'],
      bio: json['bio'],
      consultationFee: json['consultationFee']?.toDouble() ?? json['consultation_fee']?.toDouble(),
      availableSchedule: json['availableSchedule'] != null
          ? List<String>.from(json['availableSchedule'])
          : json['available_schedule'] != null
              ? List<String>.from(json['available_schedule'])
              : null,
      rating: json['rating']?.toDouble(),
      totalReviews: json['totalReviews'] ?? json['total_reviews'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'licenseNumber': licenseNumber,
      'specialty': specialty,
      'title': title,
      'yearsOfExperience': yearsOfExperience,
      'bio': bio,
      'consultationFee': consultationFee,
      'availableSchedule': availableSchedule,
      'rating': rating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
    };
  }

  Doctor copyWith({
    String? id,
    String? userId,
    String? licenseNumber,
    String? specialty,
    String? title,
    int? yearsOfExperience,
    String? bio,
    double? consultationFee,
    List<String>? availableSchedule,
    double? rating,
    int? totalReviews,
    bool? isVerified,
  }) {
    return Doctor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialty: specialty ?? this.specialty,
      title: title ?? this.title,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      consultationFee: consultationFee ?? this.consultationFee,
      availableSchedule: availableSchedule ?? this.availableSchedule,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get displayName => '$title $licenseNumber';
  
  String get formattedRating {
    if (rating == null) return 'No ratings yet';
    return '${rating!.toStringAsFixed(1)} (${totalReviews ?? 0} reviews)';
  }

  @override
  String toString() {
    return 'Doctor(id: $id, licenseNumber: $licenseNumber, specialty: $specialty, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

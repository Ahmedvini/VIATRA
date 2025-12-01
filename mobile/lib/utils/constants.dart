// App constants and enums
class AppConstants {
  // App info
  static const String appName = 'Viatra Health';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.viatrahealth.com';
  static const int requestTimeout = 30000; // 30 seconds
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 8.0;
  static const double largeRadius = 12.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // File upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

// Medical Specializations
class MedicalSpecializations {
  static const List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Emergency Medicine',
    'Endocrinology',
    'Family Medicine',
    'Gastroenterology',
    'General Surgery',
    'Gynecology',
    'Hematology',
    'Internal Medicine',
    'Nephrology',
    'Neurology',
    'Neurosurgery',
    'Obstetrics',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Otolaryngology (ENT)',
    'Pathology',
    'Pediatrics',
    'Plastic Surgery',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Rheumatology',
    'Urology',
    'Anesthesiology',
    'Physical Medicine',
    'Preventive Medicine',
    'Other',
  ];
}

// Languages
class Languages {
  static const List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese (Mandarin)',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Bengali',
    'Turkish',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Polish',
    'Czech',
    'Hungarian',
    'Romanian',
    'Bulgarian',
    'Greek',
    'Hebrew',
    'Thai',
    'Vietnamese',
    'Indonesian',
    'Malay',
    'Filipino',
    'Swahili',
    'Other',
  ];
}

// Countries
class Countries {
  static const List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Argentina',
    'Australia',
    'Austria',
    'Bangladesh',
    'Belgium',
    'Brazil',
    'Bulgaria',
    'Cambodia',
    'Canada',
    'Chile',
    'China',
    'Colombia',
    'Czech Republic',
    'Denmark',
    'Egypt',
    'Ethiopia',
    'Finland',
    'France',
    'Germany',
    'Ghana',
    'Greece',
    'Hungary',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Jordan',
    'Kenya',
    'South Korea',
    'Kuwait',
    'Lebanon',
    'Malaysia',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Pakistan',
    'Philippines',
    'Poland',
    'Portugal',
    'Romania',
    'Russia',
    'Saudi Arabia',
    'Singapore',
    'South Africa',
    'Spain',
    'Sweden',
    'Switzerland',
    'Thailand',
    'Turkey',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
    'Zimbabwe',
  ];
}

// Blood Types
class BloodTypes {
  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}

// Relationship Types (for emergency contacts)
class RelationshipTypes {
  static const List<String> relationships = [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Grandparent',
    'Grandchild',
    'Uncle/Aunt',
    'Nephew/Niece',
    'Cousin',
    'Friend',
    'Guardian',
    'Caregiver',
    'Other',
  ];
}

// Document Types
class DocumentTypes {
  // Doctor document types
  static const String medicalLicense = 'medical_license';
  static const String educationCertificate = 'education_certificate';
  static const String identityDocument = 'identity_document';
  static const String proofOfAddress = 'proof_of_address';
  
  // Patient document types
  static const String patientId = 'patient_id';
  static const String insuranceCard = 'insurance_card';
  
  static const Map<String, String> documentLabels = {
    medicalLicense: 'Medical License',
    educationCertificate: 'Education Certificate',
    identityDocument: 'Identity Document',
    proofOfAddress: 'Proof of Address',
    patientId: 'Patient ID',
    insuranceCard: 'Insurance Card',
  };
  
  static List<String> getRequiredDocuments(String userRole) {
    if (userRole == 'doctor') {
      return [medicalLicense, identityDocument, educationCertificate];
    } else {
      return [identityDocument];
    }
  }
  
  static List<String> getOptionalDocuments(String userRole) {
    if (userRole == 'doctor') {
      return [proofOfAddress];
    } else {
      return [insuranceCard, proofOfAddress];
    }
  }
}

// Common Medical Conditions
class MedicalConditions {
  static const List<String> commonConditions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Arthritis',
    'Cancer',
    'Chronic Kidney Disease',
    'COPD',
    'Depression',
    'Anxiety',
    'Migraine',
    'Obesity',
    'Sleep Apnea',
    'Thyroid Disorders',
    'Allergies',
    'High Cholesterol',
    'Stroke',
    'Epilepsy',
    'Osteoporosis',
    'Anemia',
  ];
}

// Common Allergies
class CommonAllergies {
  static const List<String> allergies = [
    'Penicillin',
    'Aspirin',
    'Peanuts',
    'Tree Nuts',
    'Shellfish',
    'Fish',
    'Milk',
    'Eggs',
    'Soy',
    'Wheat/Gluten',
    'Latex',
    'Dust Mites',
    'Pollen',
    'Pet Dander',
    'Bee Stings',
    'Iodine',
    'Sulfa Drugs',
    'NSAIDs',
    'Local Anesthetics',
    'Codeine',
  ];
}

// Time Slots (for appointments)
class TimeSlots {
  static const List<String> morningSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
  ];
  
  static const List<String> afternoonSlots = [
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];
  
  static const List<String> eveningSlots = [
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
  ];
  
  static List<String> get allSlots => [...morningSlots, ...afternoonSlots, ...eveningSlots];
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Unauthorized access. Please login again.';
  static const String validationError = 'Please check your input and try again.';
  static const String fileUploadError = 'Failed to upload file. Please try again.';
  static const String fileSizeError = 'File size is too large. Maximum size is 10MB.';
  static const String fileTypeError = 'Unsupported file type. Please upload JPG, PNG, or PDF files.';
  static const String cameraPermissionError = 'Camera permission is required to take photos.';
  static const String storagePermissionError = 'Storage permission is required to access files.';
  static const String locationPermissionError = 'Location permission is required for this feature.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
}

// Success Messages
class SuccessMessages {
  static const String registrationSuccess = 'Registration successful! Please check your email for verification.';
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String passwordChanged = 'Password changed successfully.';
  static const String emailVerified = 'Email verified successfully.';
  static const String documentUploaded = 'Document uploaded successfully.';
  static const String appointmentBooked = 'Appointment booked successfully.';
  static const String appointmentCancelled = 'Appointment cancelled successfully.';
}

// Regular Expressions
class RegexPatterns {
  static const String email = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phone = r'^\+?[\d\s\-\(\)]+$';
  static const String name = r"^[a-zA-Z\s\-']+$";
  static const String alphanumeric = r'^[a-zA-Z0-9]+$';
  static const String alphanumericWithSpaces = r'^[a-zA-Z0-9\s]+$';
  static const String password = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
}

// App Themes
class AppThemes {
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
}

// Notification Types
class NotificationTypes {
  static const String appointment = 'appointment';
  static const String verification = 'verification';
  static const String message = 'message';
  static const String reminder = 'reminder';
  static const String general = 'general';
}

// Feature Flags
class FeatureFlags {
  static const bool enableBiometricAuth = true;
  static const bool enableNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableChatFeature = true;
  static const bool enableVideoCall = true;
  static const bool enableOfflineMode = false;
}

// Doctor Search Constants
class DoctorSearchConstants {
  // Search parameters
  static const double defaultSearchRadius = 25.0;
  static const double minConsultationFee = 0.0;
  static const double maxConsultationFee = 500.0;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int loadMoreThreshold = 200; // pixels from bottom
  
  // Caching
  static const int cacheTTLMinutes = 5;
  static const int cacheExpirationMinutes = 5;
  
  // Search debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const int searchDebounceMilliseconds = 500;
  
  // Sort options
  static const List<Map<String, String>> sortOptions = [
    {'label': 'Newest First', 'sortBy': 'created_at', 'sortOrder': 'DESC'},
    {'label': 'Oldest First', 'sortBy': 'created_at', 'sortOrder': 'ASC'},
    {'label': 'Fee: Low to High', 'sortBy': 'consultation_fee', 'sortOrder': 'ASC'},
    {'label': 'Fee: High to Low', 'sortBy': 'consultation_fee', 'sortOrder': 'DESC'},
    {'label': 'Name: A-Z', 'sortBy': 'user.first_name', 'sortOrder': 'ASC'},
    {'label': 'Name: Z-A', 'sortBy': 'user.first_name', 'sortOrder': 'DESC'},
  ];
  
  // Fee range presets (in USD)
  static const List<Map<String, dynamic>> feeRanges = [
    {'label': 'Any', 'min': null, 'max': null},
    {'label': 'Under \$50', 'min': null, 'max': 50.0},
    {'label': '\$50 - \$100', 'min': 50.0, 'max': 100.0},
    {'label': '\$100 - \$200', 'min': 100.0, 'max': 200.0},
    {'label': 'Over \$200', 'min': 200.0, 'max': null},
  ];
}

// Doctor Sort Options
class DoctorSortOptions {
  static const String byRelevance = 'relevance';
  static const String byRating = 'rating';
  static const String byPrice = 'consultation_fee';
  static const String byDistance = 'distance';
  static const String byExperience = 'years_of_experience';
  static const String byName = 'user.first_name';
  static const String byNewest = 'created_at';
}

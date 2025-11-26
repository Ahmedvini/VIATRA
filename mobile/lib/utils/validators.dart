class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check for valid length (10-15 digits)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Date of birth validation
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    
    final now = DateTime.now();
    final age = now.year - value.year;
    
    // Check minimum age (13 years)
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    
    // Check maximum age (120 years)
    if (age > 120) {
      return 'Please enter a valid date of birth';
    }
    
    // Check if date is not in the future
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }
    
    return null;
  }

  // Medical license number validation
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    
    if (value.trim().length < 5) {
      return 'License number must be at least 5 characters long';
    }
    
    // Basic alphanumeric validation
    if (!RegExp(r'^[a-zA-Z0-9\-/]+$').hasMatch(value.trim())) {
      return 'License number can only contain letters, numbers, hyphens, and slashes';
    }
    
    return null;
  }

  // Years of experience validation
  static String? validateYearsOfExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Years of experience is required';
    }
    
    final years = int.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }
    
    if (years < 0) {
      return 'Years of experience cannot be negative';
    }
    
    if (years > 70) {
      return 'Please enter a valid number of years';
    }
    
    return null;
  }

  // Consultation fee validation
  static String? validateConsultationFee(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final fee = double.tryParse(value);
    if (fee == null) {
      return 'Please enter a valid amount';
    }
    
    if (fee < 0) {
      return 'Consultation fee cannot be negative';
    }
    
    if (fee > 100000) {
      return 'Please enter a reasonable consultation fee';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value, {String fieldName = 'Address'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 5) {
      return '$fieldName must be at least 5 characters long';
    }
    
    return null;
  }

  // City validation
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    
    if (value.trim().length < 2) {
      return 'City name must be at least 2 characters long';
    }
    
    // Check for valid city name characters
    if (!RegExp(r"^[a-zA-Z\s\-'\.]+$").hasMatch(value.trim())) {
      return 'City name can only contain letters, spaces, hyphens, apostrophes, and periods';
    }
    
    return null;
  }

  // Postal code validation
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    
    if (value.trim().length < 3) {
      return 'Postal code must be at least 3 characters long';
    }
    
    // Basic alphanumeric validation
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(value.trim())) {
      return 'Postal code can only contain letters, numbers, spaces, and hyphens';
    }
    
    return null;
  }

  // Emergency contact validation
  static String? validateEmergencyContactName(String? value) {
    return validateName(value, fieldName: 'Emergency contact name');
  }

  static String? validateEmergencyContactPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emergency contact phone is required';
    }
    
    return validatePhone(value);
  }

  static String? validateRelationship(String? value) {
    if (value == null || value.isEmpty) {
      return 'Relationship is required';
    }
    
    if (value.trim().length < 2) {
      return 'Relationship must be at least 2 characters long';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Generic text validation with min/max length
  static String? validateText(
    String? value, {
    required String fieldName,
    int minLength = 1,
    int? maxLength,
    bool required = true,
    RegExp? pattern,
    String? patternError,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters long';
    }
    
    if (pattern != null && !pattern.hasMatch(value)) {
      return patternError ?? '$fieldName contains invalid characters';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  // Age validation (for numeric age input)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 0 || age > 120) {
      return 'Please enter a valid age between 0 and 120';
    }
    
    return null;
  }
}

/// Validators specific to health profile management
class HealthProfileValidators {
  // Blood type validation
  static String? validateBloodType(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!validBloodTypes.contains(value)) {
      return 'Please select a valid blood type';
    }
    
    return null;
  }

  // Height validation (in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }
    
    if (height < 30 || height > 300) {
      return 'Height must be between 30 and 300 cm';
    }
    
    return null;
  }

  // Weight validation (in kg)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }
    
    if (weight < 1 || weight > 500) {
      return 'Weight must be between 1 and 500 kg';
    }
    
    return null;
  }

  // Blood pressure systolic validation
  static String? validateBloodPressureSystolic(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final systolic = int.tryParse(value);
    if (systolic == null) {
      return 'Please enter a valid number';
    }
    
    if (systolic < 70 || systolic > 250) {
      return 'Systolic pressure must be between 70 and 250 mmHg';
    }
    
    return null;
  }

  // Blood pressure diastolic validation
  static String? validateBloodPressureDiastolic(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final diastolic = int.tryParse(value);
    if (diastolic == null) {
      return 'Please enter a valid number';
    }
    
    if (diastolic < 40 || diastolic > 150) {
      return 'Diastolic pressure must be between 40 and 150 mmHg';
    }
    
    return null;
  }

  // Heart rate validation
  static String? validateHeartRate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final heartRate = int.tryParse(value);
    if (heartRate == null) {
      return 'Please enter a valid number';
    }
    
    if (heartRate < 30 || heartRate > 250) {
      return 'Heart rate must be between 30 and 250 bpm';
    }
    
    return null;
  }

  // Blood glucose validation
  static String? validateBloodGlucose(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final glucose = double.tryParse(value);
    if (glucose == null) {
      return 'Please enter a valid number';
    }
    
    if (glucose < 20 || glucose > 600) {
      return 'Blood glucose must be between 20 and 600 mg/dL';
    }
    
    return null;
  }

  // Oxygen saturation validation
  static String? validateOxygenSaturation(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final oxygen = double.tryParse(value);
    if (oxygen == null) {
      return 'Please enter a valid number';
    }
    
    if (oxygen < 50 || oxygen > 100) {
      return 'Oxygen saturation must be between 50 and 100%';
    }
    
    return null;
  }

  // Chronic condition name validation
  static String? validateChronicConditionName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Condition name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Condition name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Condition name must be no more than 100 characters';
    }
    
    return null;
  }

  // Diagnosed year validation
  static String? validateDiagnosedYear(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Please enter a valid year';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Year must be between 1900 and $currentYear';
    }
    
    return null;
  }

  // Allergen validation
  static String? validateAllergen(String? value) {
    if (value == null || value.isEmpty) {
      return 'Allergen name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Allergen name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Allergen name must be no more than 100 characters';
    }
    
    return null;
  }

  // Allergy reaction validation
  static String? validateAllergyReaction(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reaction description is required';
    }
    
    if (value.trim().length < 2) {
      return 'Reaction must be at least 2 characters';
    }
    
    if (value.trim().length > 200) {
      return 'Reaction must be no more than 200 characters';
    }
    
    return null;
  }

  // Notes validation
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.trim().length > 1000) {
      return 'Notes must be no more than 1000 characters';
    }
    
    return null;
  }
}

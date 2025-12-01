import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/verification_model.dart';
import '../services/auth_service.dart';
import '../services/verification_service.dart';
import 'auth_provider.dart';

enum RegistrationStep {
  roleSelection,
  basicInfo,
  professionalInfo, // For doctors only
  addressInfo,
  documentUpload,
  verification,
  complete,
}

class RegistrationProvider with ChangeNotifier {
  RegistrationProvider(this._authService, this._verificationService);
  final AuthService _authService;
  final VerificationService _verificationService;
  AuthProvider? _authProvider;

  // Set auth provider for accessing tokens
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Get current access token
  String? get _accessToken => _authProvider?.accessToken;

  // Current state
  RegistrationStep _currentStep = RegistrationStep.roleSelection;
  UserRole? _selectedRole;
  bool _isLoading = false;
  String? _error;

  // Form data
  final Map<String, dynamic> _formData = {};
  final Map<String, File> _documents = {};
  List<Verification> _verifications = [];

  // Getters
  RegistrationStep get currentStep => _currentStep;
  UserRole? get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);
  Map<String, File> get documents => Map.unmodifiable(_documents);
  List<Verification> get verifications => List.unmodifiable(_verifications);

  // Step navigation
  bool get canGoNext {
    switch (_currentStep) {
      case RegistrationStep.roleSelection:
        return _selectedRole != null;
      case RegistrationStep.basicInfo:
        return _validateBasicInfo();
      case RegistrationStep.professionalInfo:
        return _selectedRole != UserRole.doctor || _validateProfessionalInfo();
      case RegistrationStep.addressInfo:
        return _validateAddressInfo();
      case RegistrationStep.documentUpload:
        return _validateDocuments();
      case RegistrationStep.verification:
      case RegistrationStep.complete:
        return false;
    }
  }

  bool get canGoBack =>
      _currentStep != RegistrationStep.roleSelection &&
      _currentStep != RegistrationStep.verification &&
      _currentStep != RegistrationStep.complete;

  int get totalSteps {
    if (_selectedRole == UserRole.doctor) {
      return 6; // All steps
    } else {
      return 5; // Skip professional info
    }
  }

  int get currentStepIndex {
    switch (_currentStep) {
      case RegistrationStep.roleSelection:
        return 0;
      case RegistrationStep.basicInfo:
        return 1;
      case RegistrationStep.professionalInfo:
        return _selectedRole == UserRole.doctor ? 2 : -1;
      case RegistrationStep.addressInfo:
        return _selectedRole == UserRole.doctor ? 3 : 2;
      case RegistrationStep.documentUpload:
        return _selectedRole == UserRole.doctor ? 4 : 3;
      case RegistrationStep.verification:
        return _selectedRole == UserRole.doctor ? 5 : 4;
      case RegistrationStep.complete:
        return totalSteps;
    }
  }

  // Role selection
  void selectRole(UserRole role) {
    _selectedRole = role;
    _error = null;
    notifyListeners();
  }

  // Form data management
  void updateFormData(String key, dynamic value) {
    _formData[key] = value;
    _error = null;
    notifyListeners();
  }

  void updateMultipleFormData(Map<String, dynamic> data) {
    _formData.addAll(data);
    _error = null;
    notifyListeners();
  }

  // Document management
  void addDocument(String type, File file) {
    _documents[type] = file;
    _error = null;
    notifyListeners();
  }

  void removeDocument(String type) {
    _documents.remove(type);
    notifyListeners();
  }

  // Navigation
  Future<void> nextStep() async {
    if (!canGoNext) return;

    switch (_currentStep) {
      case RegistrationStep.roleSelection:
        _currentStep = RegistrationStep.basicInfo;
        break;
      case RegistrationStep.basicInfo:
        if (_selectedRole == UserRole.doctor) {
          _currentStep = RegistrationStep.professionalInfo;
        } else {
          _currentStep = RegistrationStep.addressInfo;
        }
        break;
      case RegistrationStep.professionalInfo:
        _currentStep = RegistrationStep.addressInfo;
        break;
      case RegistrationStep.addressInfo:
        _currentStep = RegistrationStep.documentUpload;
        break;
      case RegistrationStep.documentUpload:
        await _submitRegistration();
        break;
      case RegistrationStep.verification:
      case RegistrationStep.complete:
        break;
    }
    notifyListeners();
  }

  void previousStep() {
    if (!canGoBack) return;

    switch (_currentStep) {
      case RegistrationStep.basicInfo:
        _currentStep = RegistrationStep.roleSelection;
        break;
      case RegistrationStep.professionalInfo:
        _currentStep = RegistrationStep.basicInfo;
        break;
      case RegistrationStep.addressInfo:
        if (_selectedRole == UserRole.doctor) {
          _currentStep = RegistrationStep.professionalInfo;
        } else {
          _currentStep = RegistrationStep.basicInfo;
        }
        break;
      case RegistrationStep.documentUpload:
        _currentStep = RegistrationStep.addressInfo;
        break;
      case RegistrationStep.roleSelection:
      case RegistrationStep.verification:
      case RegistrationStep.complete:
        break;
    }
    notifyListeners();
  }

  // Validation methods
  bool _validateBasicInfo() {
    // Check basic fields - support both fullName and firstName+lastName
    final hasName = (_formData['fullName']?.toString().isNotEmpty == true) ||
        (_formData['firstName']?.toString().isNotEmpty == true &&
            _formData['lastName']?.toString().isNotEmpty == true);

    final hasBasicFields = hasName &&
        _formData['email']?.toString().isNotEmpty == true &&
        _formData['password']?.toString().isNotEmpty == true &&
        _formData['phone']?.toString().isNotEmpty == true &&
        _formData['dateOfBirth'] != null &&
        _formData['gender']?.toString().isNotEmpty == true;

    // Check if password matches confirm password
    final password = _formData['password']?.toString() ?? '';
    final confirmPassword = _formData['confirmPassword']?.toString() ?? '';
    final passwordsMatch = password.isNotEmpty && password == confirmPassword;

    return hasBasicFields && passwordsMatch;
  }

  bool _validateProfessionalInfo() {
    if (_selectedRole != UserRole.doctor) return true;

    // Support both 'specialty' and 'specialization' field names
    final hasSpecialty =
        (_formData['specialty']?.toString().isNotEmpty == true) ||
            (_formData['specialization']?.toString().isNotEmpty == true);

    // Support both 'bio' and 'hospitalAffiliation' field names
    final hasBioOrHospital =
        (_formData['bio']?.toString().isNotEmpty == true) ||
            (_formData['hospitalAffiliation']?.toString().isNotEmpty == true);

    return hasSpecialty &&
        _formData['licenseNumber']?.toString().isNotEmpty == true &&
        _formData['yearsOfExperience'] != null &&
        _formData['consultationFee'] != null &&
        hasBioOrHospital;
  }

  bool _validateAddressInfo() {
    // Support both 'address' and 'addressLine1' field names
    final hasAddress = (_formData['address']?.toString().isNotEmpty == true) ||
        (_formData['addressLine1']?.toString().isNotEmpty == true);

    return hasAddress &&
        _formData['city']?.toString().isNotEmpty == true &&
        _formData['state']?.toString().isNotEmpty == true &&
        _formData['postalCode']?.toString().isNotEmpty == true;
  }

  bool _validateDocuments() {
    if (_selectedRole == UserRole.doctor) {
      // Support both camelCase and snake_case key names
      return (_documents.containsKey('medicalLicense') ||
              _documents.containsKey('medical_license')) &&
          (_documents.containsKey('identityDocument') ||
              _documents.containsKey('identity_document')) &&
          (_documents.containsKey('educationCertificate') ||
              _documents.containsKey('education_certificate'));
    } else {
      // For patients, only identity document is required
      return _documents.containsKey('identityDocument') ||
          _documents.containsKey('identity_document');
    }
  }

  // Registration submission
  Future<void> _submitRegistration() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Handle name fields - support both fullName and firstName/lastName
      String firstName = 'User';
      String lastName = 'Name';
      
      if (_formData['firstName'] != null && _formData['lastName'] != null) {
        firstName = _formData['firstName'].toString();
        lastName = _formData['lastName'].toString();
      } else if (_formData['fullName'] != null) {
        // Split fullName into firstName and lastName
        final nameParts = (_formData['fullName'] as String).trim().split(' ');
        firstName = nameParts.first;
        lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : nameParts.first;
      }

      // Create base user data
      final userData = <String, dynamic>{
        'email': _formData['email'],
        'password': _formData['password'],
        'firstName': firstName,
        'lastName': lastName,
        'phone': _formData['phone'],
        'role': _selectedRole!.name,
      };

      // Add role-specific data
      if (_selectedRole == UserRole.doctor) {
        // Doctor-specific fields
        userData['specialty'] = _formData['specialty'] ?? _formData['specialization'];
        userData['licenseNumber'] = _formData['licenseNumber'];
        userData['consultationFee'] = _formData['consultationFee'];
        userData['title'] = 'Dr.'; // Default title
        userData['education'] = _formData['bio'] ?? _formData['hospitalAffiliation'];
      } else {
        // Patient-specific fields
        userData['dateOfBirth'] = _formData['dateOfBirth']?.toIso8601String();
        userData['gender'] = _formData['gender'];
      }

      // Register user via AuthProvider if available, otherwise use AuthService directly
      if (_authProvider != null) {
        final success = await _authProvider!.register(userData);
        if (!success) {
          throw Exception(_authProvider!.errorMessage ?? 'Registration failed');
        }
      } else {
        // Fallback: register directly via AuthService
        await _authService.register(userData);
      }

      // Upload documents if registration successful
      await _uploadDocuments();

      // Move to verification step
      _currentStep = RegistrationStep.verification;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _uploadDocuments() async {
    if (_accessToken == null) {
      _error = 'Authentication token not available';
      return;
    }

    for (final entry in _documents.entries) {
      try {
        // Submit document with proper parameters
        await _verificationService.submitDocument(
          entry.value, // File
          entry.key, // Document type
          'Document verification for ${entry.key}', // Description
          _accessToken!, // Access token
        );
      } catch (e) {
        // Log error but continue with other documents
        debugPrint('Failed to upload ${entry.key}: $e');
      }
    }
  }

  // Verification methods
  Future<void> checkVerificationStatus() async {
    if (_accessToken == null) {
      _error = 'Authentication token not available';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response =
          await _verificationService.getVerificationStatus(_accessToken!);

      if (response.success && response.data != null) {
        _verifications = response.data!;
      }

      // Check if all required verifications are completed
      if (_areAllVerificationsCompleted()) {
        _currentStep = RegistrationStep.complete;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _areAllVerificationsCompleted() {
    final requiredTypes = _selectedRole == UserRole.doctor
        ? ['medical_license', 'identity_document', 'education_certificate']
        : ['identity_document'];

    for (final type in requiredTypes) {
      final verification =
          _verifications.where((v) => v.documentType == type).firstOrNull;

      if (verification?.status != VerificationStatus.approved) {
        return false;
      }
    }

    return true;
  }

  Future<void> resendVerificationEmail() async {
    if (_accessToken == null) {
      _error = 'Authentication token not available';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _verificationService.resendVerificationEmail(_accessToken!,
          language: 'en');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset and cleanup
  void reset() {
    _currentStep = RegistrationStep.roleSelection;
    _selectedRole = null;
    _isLoading = false;
    _error = null;
    _formData.clear();
    _documents.clear();
    _verifications.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

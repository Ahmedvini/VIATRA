import 'dart:io';
import '../services/api_service.dart';
import '../models/verification_model.dart';

class VerificationService {

  VerificationService(this._apiService);
  final ApiService _apiService;

  /// Submit document for verification
  Future<ApiResponse<Verification>> submitDocument(
    File file, 
    String documentType, 
    String description, 
    String token
  ) async {
    try {
      // Set auth token
      _apiService.setAuthToken(token);
      
      // Prepare form data
      final formData = {
        'documentType': documentType,
        'description': description,
      };
      
      final response = await _apiService.uploadFile(
        '/verification/submit',
        file,
        fieldName: 'document',
        additionalData: formData,
      );
      
      if (response.isSuccess && response.data != null) {
        final verificationData = response.data!['data'] ?? response.data!;
        
        // Map the response to Verification model
        final verification = Verification(
          id: verificationData['verificationId']?.toString() ?? '',
          userId: token, // We don't get userId back, using token as placeholder
          documentType: _parseDocumentType(verificationData['documentType'] ?? documentType),
          documentUrl: verificationData['documentUrl'],
          status: _parseStatus(verificationData['status']),
          submittedAt: _parseDateTime(verificationData['submittedAt']),
        );
        
        return ApiResponse.success(verification);
      }
      
      return ApiResponse.error(response.message ?? 'Document submission failed');
    } catch (e) {
      return ApiResponse.error('Document submission failed: ${e.toString()}');
    }
  }

  /// Get verification status for current user
  Future<ApiResponse<List<Verification>>> getVerificationStatus(String token) async {
    try {
      // Set auth token
      _apiService.setAuthToken(token);
      
      final response = await _apiService.get('/verification/status');
      
      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        final verificationsData = data['verifications'] as List? ?? [];
        
        final verifications = verificationsData
            .map((item) => Verification.fromJson(item))
            .toList();
        
        return ApiResponse.success(verifications);
      }
      
      return ApiResponse.error(response.message ?? 'Failed to get verification status');
    } catch (e) {
      return ApiResponse.error('Failed to get verification status: ${e.toString()}');
    }
  }

  /// Resend verification email
  Future<ApiResponse<void>> resendVerificationEmail(String token, {String? language}) async {
    try {
      // Set auth token
      _apiService.setAuthToken(token);
      
      final requestData = <String, dynamic>{};
      if (language != null) {
        requestData['language'] = language;
      }
      
      final response = await _apiService.post('/verification/resend-email', requestData);
      
      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      
      return ApiResponse.error(response.message ?? 'Failed to resend verification email');
    } catch (e) {
      return ApiResponse.error('Failed to resend verification email: ${e.toString()}');
    }
  }

  /// Get specific document verification status
  Future<ApiResponse<Verification>> getDocumentStatus(String documentId, String token) async {
    try {
      // Set auth token
      _apiService.setAuthToken(token);
      
      final response = await _apiService.get('/verification/document/$documentId');
      
      if (response.isSuccess && response.data != null) {
        final verificationData = response.data!['data'] ?? response.data!;
        final verification = Verification.fromJson(verificationData);
        
        return ApiResponse.success(verification);
      }
      
      return ApiResponse.error(response.message ?? 'Failed to get document status');
    } catch (e) {
      return ApiResponse.error('Failed to get document status: ${e.toString()}');
    }
  }

  // Helper methods for parsing backend data
  static DocumentType _parseDocumentType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'medical_license':
      case 'license':
        return DocumentType.license;
      case 'board_certification':
      case 'education_certificate':
      case 'certificate':
        return DocumentType.certificate;
      case 'identification':
      case 'id_card':
        return DocumentType.id_card;
      default:
        return DocumentType.license;
    }
  }

  static VerificationStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
      case 'verified':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
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
}

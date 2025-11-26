import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_profile_model.dart';
import 'api_service.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
}

class HealthProfileService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<HealthProfile>> getMyHealthProfile() async {
    try {
      final response = await _apiService.get('/health-profiles/me');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final profile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: profile,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Health profile not found',
          error: 'NOT_FOUND',
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to fetch health profile',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while fetching health profile',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> createHealthProfile(
      HealthProfile profile) async {
    try {
      final response = await _apiService.post(
        '/health-profiles',
        body: profile.toJson(),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final createdProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: createdProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to create health profile',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while creating health profile',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> updateHealthProfile(
      HealthProfile profile) async {
    try {
      final response = await _apiService.patch(
        '/health-profiles/me',
        body: profile.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to update health profile',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while updating health profile',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> addChronicCondition(
      ChronicCondition condition) async {
    try {
      final response = await _apiService.post(
        '/health-profiles/me/chronic-conditions',
        body: condition.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to add chronic condition',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while adding chronic condition',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> removeChronicCondition(
      String conditionId) async {
    try {
      final response = await _apiService.delete(
        '/health-profiles/me/chronic-conditions/$conditionId',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to remove chronic condition',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while removing chronic condition',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> addAllergy(Allergy allergy) async {
    try {
      final response = await _apiService.post(
        '/health-profiles/me/allergies',
        body: allergy.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to add allergy',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while adding allergy',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> removeAllergy(String allergen) async {
    try {
      final encodedAllergen = Uri.encodeComponent(allergen);
      final response = await _apiService.delete(
        '/health-profiles/me/allergies/$encodedAllergen',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to remove allergy',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while removing allergy',
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse<HealthProfile>> updateVitals({
    double? height,
    double? weight,
    String? bloodType,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (height != null) body['height'] = height;
      if (weight != null) body['weight'] = weight;
      if (bloodType != null) body['bloodType'] = bloodType;

      final response = await _apiService.patch(
        '/health-profiles/me/vitals',
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final updatedProfile = HealthProfile.fromJson(jsonData['data']);
        
        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: updatedProfile,
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to update vitals',
          error: jsonData['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An error occurred while updating vitals',
        error: e.toString(),
      );
    }
  }
}

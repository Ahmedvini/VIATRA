import 'dart:convert';
import '../models/doctor_model.dart';
import '../models/doctor_search_filter.dart';
import 'api_service.dart';

class ApiResponse<T> {

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;
}

class PaginationMetadata {

  PaginationMetadata({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 0,
    );
  }
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

class DoctorSearchResult {

  DoctorSearchResult({
    required this.doctors,
    required this.pagination,
  });
  final List<Doctor> doctors;
  final PaginationMetadata pagination;
}

class DoctorService {

  DoctorService(this._apiService);
  final ApiService _apiService;

  /// Search doctors with filters and pagination
  Future<ApiResponse<DoctorSearchResult>> searchDoctors(
    DoctorSearchFilter filter, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = filter.toQueryParams();
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final response = await _apiService.get(
        '/doctors/search',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        
        // Parse doctors list
        final List<dynamic> doctorsJson = jsonData['data']['doctors'] ?? [];
        final doctors = doctorsJson
            .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
            .toList();

        // Parse pagination
        final paginationJson = jsonData['data']['pagination'] ?? {};
        final pagination = PaginationMetadata.fromJson(paginationJson);

        final result = DoctorSearchResult(
          doctors: doctors,
          pagination: pagination,
        );

        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: result,
        );
      } else {
        final errorData = response.data;
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to search doctors',
          error: errorData,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Get doctor by ID
  Future<ApiResponse<Doctor>> getDoctorById(String doctorId) async {
    try {
      final response = await _apiService.get('/doctors/$doctorId');

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final doctor = Doctor.fromJson(jsonData['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: doctor,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Doctor not found',
          error: 'NOT_FOUND',
        );
      } else {
        final errorData = response.data;
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch doctor',
          error: errorData,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Get doctor availability
  Future<ApiResponse<Map<String, dynamic>>> getDoctorAvailability(
      String doctorId) async {
    try {
      final response = await _apiService.get('/doctors/$doctorId/availability');

      if (response.statusCode == 200) {
        final jsonData = response.data;
        final availability = jsonData['data'] as Map<String, dynamic>;

        return ApiResponse(
          success: true,
          message: jsonData['message'],
          data: availability,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Doctor not found',
          error: 'NOT_FOUND',
        );
      } else {
        final errorData = response.data;
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to fetch availability',
          error: errorData,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        error: e,
      );
    }
  }
}

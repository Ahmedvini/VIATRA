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

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) => PaginationMetadata(
      total: (json['total'] ?? 0) as int,
      page: (json['page'] ?? 1) as int,
      limit: (json['limit'] ?? 20) as int,
      totalPages: (json['totalPages'] ?? json['total_pages'] ?? 0) as int,
    );
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

      if (response.success && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        
        // Parse doctors list
        final doctorsJson = (jsonData['data']['doctors'] ?? []) as List<dynamic>;
        final doctors = doctorsJson
            .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
            .toList();

        // Parse pagination
        final paginationJson = (jsonData['data']['pagination'] ?? {}) as Map<String, dynamic>;
        final pagination = PaginationMetadata.fromJson(paginationJson);

        final result = DoctorSearchResult(
          doctors: doctors,
          pagination: pagination,
        );

        return ApiResponse(
          success: true,
          message: jsonData['message'] as String?,
          data: result,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.message ?? 'Failed to search doctors',
          error: response.error,
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

      if (response.success && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        final doctor = Doctor.fromJson(jsonData['data'] as Map<String, dynamic>);

        return ApiResponse(
          success: true,
          message: jsonData['message'] as String?,
          data: doctor,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Doctor not found',
          error: 'NOT_FOUND',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.message ?? 'Failed to fetch doctor',
          error: response.error,
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

      if (response.success && response.data != null) {
        final jsonData = response.data as Map<String, dynamic>;
        final availability = jsonData['data'] as Map<String, dynamic>;

        return ApiResponse(
          success: true,
          message: jsonData['message'] as String?,
          data: availability,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          success: false,
          message: 'Doctor not found',
          error: 'NOT_FOUND',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.message ?? 'Failed to fetch availability',
          error: response.error,
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

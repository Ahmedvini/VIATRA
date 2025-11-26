import '../models/appointment_model.dart';
import 'api_service.dart';

class AppointmentListResult {
  final List<Appointment> appointments;
  final PaginationMetadata pagination;

  AppointmentListResult({
    required this.appointments,
    required this.pagination,
  });
}

class PaginationMetadata {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMetadata({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class AppointmentService {
  final ApiService _apiService;

  AppointmentService(this._apiService);

  /// Create new appointment
  Future<ApiResponse<Appointment>> createAppointment(
    String doctorId,
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      final body = {
        'doctorId': doctorId,
        'appointmentType': appointmentData['appointmentType'],
        'scheduledStart': appointmentData['scheduledStart'],
        'scheduledEnd': appointmentData['scheduledEnd'],
        'reasonForVisit': appointmentData['reasonForVisit'],
        'chiefComplaint': appointmentData['chiefComplaint'],
        'urgent': appointmentData['urgent'] ?? false,
      };

      final response = await _apiService.post('/appointments', body: body);

      if (response.success && response.data != null) {
        final appointment = Appointment.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(
          data: appointment,
          message: response.message ?? 'Appointment created successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to create appointment',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while creating appointment: $e',
      );
    }
  }

  /// Get patient's appointments
  Future<ApiResponse<AppointmentListResult>> getMyAppointments({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiService.get('/appointments', queryParams: queryParams);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final appointmentsList = (data['appointments'] as List)
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .toList();
        
        final pagination = PaginationMetadata.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );

        final result = AppointmentListResult(
          appointments: appointmentsList,
          pagination: pagination,
        );

        return ApiResponse.success(
          data: result,
          message: response.message ?? 'Appointments retrieved successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to retrieve appointments',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while fetching appointments: $e',
      );
    }
  }

  /// Get appointment by ID
  Future<ApiResponse<Appointment>> getAppointmentById(String appointmentId) async {
    try {
      final response = await _apiService.get('/appointments/$appointmentId');

      if (response.success && response.data != null) {
        final appointment = Appointment.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(
          data: appointment,
          message: response.message ?? 'Appointment retrieved successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to retrieve appointment',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while fetching appointment: $e',
      );
    }
  }

  /// Update appointment
  Future<ApiResponse<Appointment>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.patch(
        '/appointments/$appointmentId',
        body: updateData,
      );

      if (response.success && response.data != null) {
        final appointment = Appointment.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(
          data: appointment,
          message: response.message ?? 'Appointment updated successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to update appointment',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while updating appointment: $e',
      );
    }
  }

  /// Cancel appointment
  Future<ApiResponse<Map<String, dynamic>>> cancelAppointment(
    String appointmentId,
    String reason,
  ) async {
    try {
      final response = await _apiService.post(
        '/appointments/$appointmentId/cancel',
        body: {'cancellationReason': reason},
      );

      if (response.success) {
        return ApiResponse.success(
          data: response.data as Map<String, dynamic>? ?? {},
          message: response.message ?? 'Appointment cancelled successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to cancel appointment',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while cancelling appointment: $e',
      );
    }
  }

  /// Get doctor availability
  Future<ApiResponse<List<TimeSlot>>> getDoctorAvailability(
    String doctorId,
    DateTime date,
    int duration,
  ) async {
    try {
      final queryParams = {
        'date': date.toIso8601String(),
        'duration': duration.toString(),
      };

      final response = await _apiService.get(
        '/doctors/$doctorId/availability',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final timeSlots = (response.data as List)
            .map((json) => TimeSlot.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          data: timeSlots,
          message: response.message ?? 'Time slots retrieved successfully',
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to retrieve availability',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An error occurred while fetching availability: $e',
      );
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({String? message, dynamic error}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}

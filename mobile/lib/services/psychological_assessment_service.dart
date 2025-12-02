import '../models/psychological/psychological_assessment.dart';
import 'api_service.dart';

class PsychologicalAssessmentService {
  PsychologicalAssessmentService(this._apiService);

  final ApiService _apiService;
  static const String baseUrl = '/psychological-assessment';

  /// Submit a new PHQ-9 assessment
  Future<Map<String, dynamic>> submitAssessment({
    required int q1Interest,
    required int q2FeelingDown,
    required int q3Sleep,
    required int q4Energy,
    required int q5Appetite,
    required int q6SelfWorth,
    required int q7Concentration,
    required int q8Movement,
    required int q9SelfHarm,
    String? notes,
    String? difficultyLevel,
  }) async {
    try {
      final response = await _apiService.post(
        '$baseUrl/submit',
        body: {
          'q1_interest': q1Interest,
          'q2_feeling_down': q2FeelingDown,
          'q3_sleep': q3Sleep,
          'q4_energy': q4Energy,
          'q5_appetite': q5Appetite,
          'q6_self_worth': q6SelfWorth,
          'q7_concentration': q7Concentration,
          'q8_movement': q8Movement,
          'q9_self_harm': q9SelfHarm,
          if (notes != null) 'notes': notes,
          if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
        },
      );

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.message ?? 'Failed to submit assessment');
      }
    } catch (e) {
      throw Exception('Error submitting assessment: $e');
    }
  }

  /// Get assessment history
  Future<List<PsychologicalAssessment>> getAssessmentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '$baseUrl/history',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => PsychologicalAssessment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to fetch assessment history');
      }
    } catch (e) {
      throw Exception('Error fetching assessment history: $e');
    }
  }

  /// Get a specific assessment by ID
  Future<Map<String, dynamic>> getAssessmentById(String assessmentId) async {
    try {
      final response = await _apiService.get('$baseUrl/$assessmentId');

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.message ?? 'Failed to fetch assessment');
      }
    } catch (e) {
      throw Exception('Error fetching assessment: $e');
    }
  }

  /// Get analytics and trends
  Future<Map<String, dynamic>> getAnalytics({int days = 90}) async {
    try {
      final response = await _apiService.get(
        '$baseUrl/analytics',
        queryParams: {'days': days.toString()},
      );

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.message ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }

  /// Delete an assessment
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      final response = await _apiService.delete('$baseUrl/$assessmentId');

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete assessment');
      }
    } catch (e) {
      throw Exception('Error deleting assessment: $e');
    }
  }
}

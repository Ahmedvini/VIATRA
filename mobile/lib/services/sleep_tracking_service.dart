import '../models/sleep_tracking/sleep_session.dart';
import '../models/sleep_tracking/sleep_interruption.dart';
import '../models/sleep_tracking/sleep_analytics.dart';
import 'api_service.dart';

class SleepTrackingService {
  final ApiService _apiService;

  SleepTrackingService(this._apiService);
  static const String baseUrl = '/sleep-tracking';

  Future<SleepSession> startSleepSession({
    DateTime? startTime,
    String? notes,
    Map<String, dynamic>? environmentFactors,
  }) async {
    try {
      final response = await _apiService.post(
        '$baseUrl/start',
        body: {
          'start_time': (startTime ?? DateTime.now()).toIso8601String(),
          if (notes != null) 'notes': notes,
          if (environmentFactors != null) 'environment_factors': environmentFactors,
        },
      );
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SleepSession.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to start sleep session');
      }
    } catch (e) {
      throw Exception('Error starting sleep session: $e');
    }
  }

  Future<SleepSession> pauseSleepSession(String sessionId, {String? reason, String? notes}) async {
    try {
      final response = await _apiService.put('$baseUrl/$sessionId/pause', body: {
        if (reason != null) 'reason': reason,
        if (notes != null) 'notes': notes,
      });
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final sessionData = responseData['data'] as Map<String, dynamic>;
        final session = sessionData['session'] ?? sessionData;
        return SleepSession.fromJson(session as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to pause sleep session');
      }
    } catch (e) {
      throw Exception('Error pausing sleep session: $e');
    }
  }

  Future<SleepSession> resumeSleepSession(String sessionId) async {
    try {
      final response = await _apiService.put('$baseUrl/$sessionId/resume');
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SleepSession.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to resume sleep session');
      }
    } catch (e) {
      throw Exception('Error resuming sleep session: $e');
    }
  }

  Future<SleepSession> endSleepSession(String sessionId, {int? qualityRating, String? notes}) async {
    try {
      final response = await _apiService.put('$baseUrl/$sessionId/end', body: {
        if (qualityRating != null) 'quality_rating': qualityRating,
        if (notes != null) 'notes': notes,
      });
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SleepSession.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to end sleep session');
      }
    } catch (e) {
      throw Exception('Error ending sleep session: $e');
    }
  }

  Future<SleepInterruption> recordInterruption(String sessionId, {required String reason, String? notes}) async {
    try {
      final response = await _apiService.post('$baseUrl/$sessionId/interruption', body: {
        'reason': reason,
        if (notes != null) 'notes': notes,
      });
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SleepInterruption.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to record interruption');
      }
    } catch (e) {
      throw Exception('Error recording interruption: $e');
    }
  }

  Future<List<SleepSession>> getSleepSessions({DateTime? startDate, DateTime? endDate, String? status, int limit = 50, int offset = 0}) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString(), 'offset': offset.toString()};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (status != null) queryParams['status'] = status;
      final response = await _apiService.get(baseUrl, queryParams: queryParams);
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final List<dynamic> sessionsJson = responseData['data'] as List<dynamic>;
        return sessionsJson.map((json) => SleepSession.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.message ?? 'Failed to get sleep sessions');
      }
    } catch (e) {
      throw Exception('Error getting sleep sessions: $e');
    }
  }

  Future<SleepSession> getSleepSessionById(String sessionId) async {
    try {
      final response = await _apiService.get('$baseUrl/$sessionId');
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        return SleepSession.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.message ?? 'Failed to get sleep session');
      }
    } catch (e) {
      throw Exception('Error getting sleep session: $e');
    }
  }

  Future<SleepAnalytics> getSleepAnalytics({int days = 7}) async {
    try {
      final response = await _apiService.get('$baseUrl/analytics', queryParams: {'days': days.toString()});
      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        Map<String, dynamic> analyticsData = responseData['data'] as Map<String, dynamic>;
        if (responseData['sessions'] != null) analyticsData['sessions'] = responseData['sessions'];
        return SleepAnalytics.fromJson(analyticsData);
      } else {
        throw Exception(response.message ?? 'Failed to get sleep analytics');
      }
    } catch (e) {
      throw Exception('Error getting sleep analytics: $e');
    }
  }

  Future<void> deleteSleepSession(String sessionId) async {
    try {
      final response = await _apiService.delete('$baseUrl/$sessionId');
      if (!response.success) throw Exception(response.message ?? 'Failed to delete sleep session');
    } catch (e) {
      throw Exception('Error deleting sleep session: $e');
    }
  }

  Future<SleepSession?> getActiveSession() async {
    try {
      final sessions = await getSleepSessions(status: 'active', limit: 1);
      if (sessions.isNotEmpty) return sessions.first;
      final pausedSessions = await getSleepSessions(status: 'paused', limit: 1);
      if (pausedSessions.isNotEmpty) return pausedSessions.first;
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<SleepSession>> getRecentSessions({int limit = 10}) async {
    try {
      return await getSleepSessions(status: 'completed', limit: limit);
    } catch (e) {
      throw Exception('Error getting recent sessions: $e');
    }
  }

  Future<List<SleepSession>> getSleepSessionsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return await getSleepSessions(startDate: startOfDay, endDate: endOfDay, status: 'completed');
    } catch (e) {
      throw Exception('Error getting sleep sessions: $e');
    }
  }
}

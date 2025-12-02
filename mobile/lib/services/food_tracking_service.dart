import 'dart:io';
import '../models/food_tracking/food_log.dart';
import '../models/food_tracking/nutrition_summary.dart';
import 'api_service.dart';
import '../utils/logger.dart';

/// Service for managing food tracking operations
class FoodTrackingService {
  FoodTrackingService(this._apiService);

  final ApiService _apiService;
  static const String _baseEndpoint = '/food-tracking';

  /// Create a food log entry (manual entry)
  /// No validation is performed - all fields are optional except meal_type and food_name
  Future<FoodLog?> createFoodLog({
    required String mealType,
    required String foodName,
    String? description,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    double? sugarGrams,
    double? sodiumMg,
    String? servingSize,
    double? servingsCount,
    DateTime? consumedAt,
  }) async {
    try {
      Logger.info('Creating food log: $foodName');

      final response = await _apiService.post<Map<String, dynamic>>(
        _baseEndpoint,
        body: {
          'meal_type': mealType,
          'food_name': foodName,
          if (description != null) 'description': description,
          if (calories != null) 'calories': calories,
          if (proteinGrams != null) 'protein_grams': proteinGrams,
          if (carbsGrams != null) 'carbs_grams': carbsGrams,
          if (fatGrams != null) 'fat_grams': fatGrams,
          if (fiberGrams != null) 'fiber_grams': fiberGrams,
          if (sugarGrams != null) 'sugar_grams': sugarGrams,
          if (sodiumMg != null) 'sodium_mg': sodiumMg,
          if (servingSize != null) 'serving_size': servingSize,
          if (servingsCount != null) 'servings_count': servingsCount,
          if (consumedAt != null) 'consumed_at': consumedAt.toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        final foodLogData = response.data!['data'] as Map<String, dynamic>;
        Logger.info('Food log created successfully');
        return FoodLog.fromJson(foodLogData);
      } else {
        Logger.error('Failed to create food log: ${response.message}');
        return null;
      }
    } catch (e) {
      Logger.error('Error creating food log: $e');
      return null;
    }
  }

  /// Analyze food image with AI and create log entry
  Future<FoodLog?> analyzeFoodImage({
    required File imageFile,
    required String mealType,
    double? servingsCount,
    DateTime? consumedAt,
  }) async {
    try {
      Logger.info('Analyzing food image');

      final response = await _apiService.uploadFile<Map<String, dynamic>>(
        '$_baseEndpoint/analyze',
        imageFile,
        fieldName: 'image',
        fields: {
          'meal_type': mealType,
          if (servingsCount != null)
            'servings_count': servingsCount.toString(),
          if (consumedAt != null)
            'consumed_at': consumedAt.toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        final foodLogData = response.data!['data'] as Map<String, dynamic>;
        Logger.info('Food image analyzed successfully');
        return FoodLog.fromJson(foodLogData);
      } else {
        Logger.error('Failed to analyze food image: ${response.message}');
        return null;
      }
    } catch (e) {
      Logger.error('Error analyzing food image: $e');
      return null;
    }
  }

  /// Get all food logs for the current user
  /// Filters can be applied for date range, meal type, pagination
  Future<List<FoodLog>> getFoodLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      Logger.info('Fetching food logs');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (mealType != null) 'meal_type': mealType,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        _baseEndpoint,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as List<dynamic>;
        Logger.info('Food logs fetched: ${data.length} logs');
        return data
            .map((json) => FoodLog.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        Logger.error('Failed to fetch food logs: ${response.message}');
        return [];
      }
    } catch (e) {
      Logger.error('Error fetching food logs: $e');
      return [];
    }
  }

  /// Get a single food log by ID
  Future<FoodLog?> getFoodLogById(String id) async {
    try {
      Logger.info('Fetching food log: $id');

      final response = await _apiService.get<Map<String, dynamic>>(
        '$_baseEndpoint/$id',
      );

      if (response.success && response.data != null) {
        final foodLogData = response.data!['data'] as Map<String, dynamic>;
        Logger.info('Food log fetched successfully');
        return FoodLog.fromJson(foodLogData);
      } else {
        Logger.error('Failed to fetch food log: ${response.message}');
        return null;
      }
    } catch (e) {
      Logger.error('Error fetching food log: $e');
      return null;
    }
  }

  /// Update an existing food log
  /// Only provided fields will be updated
  Future<FoodLog?> updateFoodLog({
    required String id,
    String? mealType,
    String? foodName,
    String? description,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    double? sugarGrams,
    double? sodiumMg,
    String? servingSize,
    double? servingsCount,
    DateTime? consumedAt,
  }) async {
    try {
      Logger.info('Updating food log: $id');

      final response = await _apiService.put<Map<String, dynamic>>(
        '$_baseEndpoint/$id',
        body: {
          if (mealType != null) 'meal_type': mealType,
          if (foodName != null) 'food_name': foodName,
          if (description != null) 'description': description,
          if (calories != null) 'calories': calories,
          if (proteinGrams != null) 'protein_grams': proteinGrams,
          if (carbsGrams != null) 'carbs_grams': carbsGrams,
          if (fatGrams != null) 'fat_grams': fatGrams,
          if (fiberGrams != null) 'fiber_grams': fiberGrams,
          if (sugarGrams != null) 'sugar_grams': sugarGrams,
          if (sodiumMg != null) 'sodium_mg': sodiumMg,
          if (servingSize != null) 'serving_size': servingSize,
          if (servingsCount != null) 'servings_count': servingsCount,
          if (consumedAt != null) 'consumed_at': consumedAt.toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        final foodLogData = response.data!['data'] as Map<String, dynamic>;
        Logger.info('Food log updated successfully');
        return FoodLog.fromJson(foodLogData);
      } else {
        Logger.error('Failed to update food log: ${response.message}');
        return null;
      }
    } catch (e) {
      Logger.error('Error updating food log: $e');
      return null;
    }
  }

  /// Delete a food log
  Future<bool> deleteFoodLog(String id) async {
    try {
      Logger.info('Deleting food log: $id');

      final response = await _apiService.delete<Map<String, dynamic>>(
        '$_baseEndpoint/$id',
      );

      if (response.success) {
        Logger.info('Food log deleted successfully');
        return true;
      } else {
        Logger.error('Failed to delete food log: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.error('Error deleting food log: $e');
      return false;
    }
  }

  /// Get nutrition summary for a date range
  Future<NutritionSummary?> getNutritionSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      Logger.info('Fetching nutrition summary');

      final response = await _apiService.get<Map<String, dynamic>>(
        '$_baseEndpoint/summary',
        queryParams: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.success && response.data != null) {
        final summaryData =
            response.data!['data']['summary'] as Map<String, dynamic>;
        Logger.info('Nutrition summary fetched successfully');
        return NutritionSummary.fromJson(summaryData);
      } else {
        Logger.error('Failed to fetch nutrition summary: ${response.message}');
        return null;
      }
    } catch (e) {
      Logger.error('Error fetching nutrition summary: $e');
      return null;
    }
  }

  /// Get food logs for today
  Future<List<FoodLog>> getTodayLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getFoodLogs(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get food logs for a specific date
  Future<List<FoodLog>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getFoodLogs(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get food logs for the last N days
  Future<List<FoodLog>> getLogsForLastDays(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    return getFoodLogs(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get nutrition summary for today
  Future<NutritionSummary?> getTodaySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getNutritionSummary(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get nutrition summary for the last N days
  Future<NutritionSummary?> getSummaryForLastDays(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    return getNutritionSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

import 'package:intl/intl.dart';

/// Food log model representing a single food tracking entry
class FoodLog {
  final String id;
  final String patientId;
  final MealType mealType;
  final String foodName;
  final String? description;
  final String? imageUrl;
  
  // Nutritional information
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatGrams;
  final double? fiberGrams;
  final double? sugarGrams;
  final double? sodiumMg;
  
  // AI Analysis
  final Map<String, dynamic>? aiAnalysis;
  final double? aiConfidence;
  
  // Serving info
  final String? servingSize;
  final double servingsCount;
  
  // Timestamps
  final DateTime consumedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodLog({
    required this.id,
    required this.patientId,
    required this.mealType,
    required this.foodName,
    this.description,
    this.imageUrl,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
    this.fiberGrams,
    this.sugarGrams,
    this.sodiumMg,
    this.aiAnalysis,
    this.aiConfidence,
    this.servingSize,
    this.servingsCount = 1.0,
    required this.consumedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create FoodLog from JSON
  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      mealType: MealType.fromString(json['mealType'] as String),
      foodName: json['foodName'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble(),
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble(),
      fatGrams: (json['fatGrams'] as num?)?.toDouble(),
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
      aiAnalysis: json['aiAnalysis'] as Map<String, dynamic>?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      servingSize: json['servingSize'] as String?,
      servingsCount: (json['servingsCount'] as num?)?.toDouble() ?? 1.0,
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert FoodLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'mealType': mealType.value,
      'foodName': foodName,
      'description': description,
      'imageUrl': imageUrl,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'fiberGrams': fiberGrams,
      'sugarGrams': sugarGrams,
      'sodiumMg': sodiumMg,
      'aiAnalysis': aiAnalysis,
      'aiConfidence': aiConfidence,
      'servingSize': servingSize,
      'servingsCount': servingsCount,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  FoodLog copyWith({
    String? id,
    String? patientId,
    MealType? mealType,
    String? foodName,
    String? description,
    String? imageUrl,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    double? sugarGrams,
    double? sodiumMg,
    Map<String, dynamic>? aiAnalysis,
    double? aiConfidence,
    String? servingSize,
    double? servingsCount,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodLog(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      sugarGrams: sugarGrams ?? this.sugarGrams,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      servingSize: servingSize ?? this.servingSize,
      servingsCount: servingsCount ?? this.servingsCount,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format consumed time
  String get formattedTime => DateFormat('h:mm a').format(consumedAt);
  
  /// Format consumed date
  String get formattedDate => DateFormat('MMM d, y').format(consumedAt);
  
  /// Get total calories (accounting for servings)
  double? get totalCalories => calories != null ? calories! * servingsCount : null;
}

/// Meal type enum
enum MealType {
  breakfast('breakfast', 'Breakfast', '🌅'),
  lunch('lunch', 'Lunch', '☀️'),
  dinner('dinner', 'Dinner', '🌙'),
  snack('snack', 'Snack', '🍎');

  final String value;
  final String displayName;
  final String emoji;

  const MealType(this.value, this.displayName, this.emoji);

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.snack,
    );
  }
}

/// Nutrition summary model for reports
class NutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  
  final Map<MealType, MealBreakdown> mealBreakdown;
  final DailyAverages dailyAverages;
  
  final int totalLogs;
  final DateTime startDate;
  final DateTime endDate;
  final int days;

  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalSodium,
    required this.mealBreakdown,
    required this.dailyAverages,
    required this.totalLogs,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    final mealBreakdownData = summary['mealBreakdown'] as Map<String, dynamic>;
    final dailyAveragesData = summary['dailyAverages'] as Map<String, dynamic>;
    final dateRange = json['dateRange'] as Map<String, dynamic>;

    return NutritionSummary(
      totalCalories: (summary['totalCalories'] as num).toDouble(),
      totalProtein: (summary['totalProtein'] as num).toDouble(),
      totalCarbs: (summary['totalCarbs'] as num).toDouble(),
      totalFat: (summary['totalFat'] as num).toDouble(),
      totalFiber: (summary['totalFiber'] as num).toDouble(),
      totalSugar: (summary['totalSugar'] as num).toDouble(),
      totalSodium: (summary['totalSodium'] as num).toDouble(),
      mealBreakdown: {
        MealType.breakfast: MealBreakdown.fromJson(mealBreakdownData['breakfast'] as Map<String, dynamic>),
        MealType.lunch: MealBreakdown.fromJson(mealBreakdownData['lunch'] as Map<String, dynamic>),
        MealType.dinner: MealBreakdown.fromJson(mealBreakdownData['dinner'] as Map<String, dynamic>),
        MealType.snack: MealBreakdown.fromJson(mealBreakdownData['snack'] as Map<String, dynamic>),
      },
      dailyAverages: DailyAverages.fromJson(dailyAveragesData),
      totalLogs: json['totalLogs'] as int,
      startDate: DateTime.parse(dateRange['start_date'] as String),
      endDate: DateTime.parse(dateRange['end_date'] as String),
      days: dateRange['days'] as int,
    );
  }

  /// Convenience getter for meal count (same as totalLogs)
  int get mealCount => totalLogs;

  /// Convenience getter for average daily calories
  double get averageDailyCalories => dailyAverages.calories;
}

/// Meal breakdown data
class MealBreakdown {
  final int count;
  final double calories;

  const MealBreakdown({
    required this.count,
    required this.calories,
  });

  factory MealBreakdown.fromJson(Map<String, dynamic> json) {
    return MealBreakdown(
      count: json['count'] as int,
      calories: (json['calories'] as num).toDouble(),
    );
  }
}

/// Daily averages data
class DailyAverages {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const DailyAverages({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory DailyAverages.fromJson(Map<String, dynamic> json) {
    return DailyAverages(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}

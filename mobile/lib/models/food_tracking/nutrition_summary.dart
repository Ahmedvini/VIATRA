/// Nutrition summary model for aggregated food tracking data
class NutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final int mealCount;
  final double averageDailyCalories;
  final String dateRange;

  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.totalSugar,
    required this.totalSodium,
    required this.mealCount,
    required this.averageDailyCalories,
    required this.dateRange,
  });

  /// Create NutritionSummary from JSON (backend response)
  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      totalFiber: (json['totalFiber'] as num?)?.toDouble() ?? 0.0,
      totalSugar: (json['totalSugar'] as num?)?.toDouble() ?? 0.0,
      totalSodium: (json['totalSodium'] as num?)?.toDouble() ?? 0.0,
      mealCount: (json['mealBreakdown'] as Map<String, dynamic>?)?.values
              .fold<int>(0, (sum, meal) => sum + ((meal as Map)['count'] as int? ?? 0)) ??
          0,
      averageDailyCalories: (json['dailyAverages']?['calories'] as num?)?.toDouble() ?? 0.0,
      dateRange: 'Custom',
    );
  }

  /// Convert NutritionSummary to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'totalSugar': totalSugar,
      'totalSodium': totalSodium,
      'mealCount': mealCount,
      'averageDailyCalories': averageDailyCalories,
      'dateRange': dateRange,
    };
  }

  /// Calculate total macros (protein + carbs + fat)
  double get totalMacros => totalProtein + totalCarbs + totalFat;

  /// Calculate protein percentage
  double get proteinPercentage =>
      totalMacros > 0 ? (totalProtein / totalMacros) * 100 : 0;

  /// Calculate carbs percentage
  double get carbsPercentage =>
      totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0;

  /// Calculate fat percentage
  double get fatPercentage =>
      totalMacros > 0 ? (totalFat / totalMacros) * 100 : 0;

  /// Copy with method for creating modified copies
  NutritionSummary copyWith({
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    int? mealCount,
    double? averageDailyCalories,
    String? dateRange,
  }) {
    return NutritionSummary(
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSodium,
      totalSodium: totalSodium ?? this.totalSodium,
      mealCount: mealCount ?? this.mealCount,
      averageDailyCalories: averageDailyCalories ?? this.averageDailyCalories,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  /// Check if summary has any data
  bool get hasData => totalCalories > 0 || mealCount > 0;

  /// Get a formatted string for date range
  String get formattedDateRange => dateRange;

  @override
  String toString() {
    return 'NutritionSummary(totalCalories: $totalCalories, totalProtein: $totalProtein, '
        'totalCarbs: $totalCarbs, totalFat: $totalFat, mealCount: $mealCount, '
        'averageDailyCalories: $averageDailyCalories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NutritionSummary &&
        other.totalCalories == totalCalories &&
        other.totalProtein == totalProtein &&
        other.totalCarbs == totalCarbs &&
        other.totalFat == totalFat &&
        other.totalFiber == totalFiber &&
        other.totalSugar == totalSugar &&
        other.totalSodium == totalSodium &&
        other.mealCount == mealCount &&
        other.averageDailyCalories == averageDailyCalories &&
        other.dateRange == dateRange;
  }

  @override
  int get hashCode {
    return totalCalories.hashCode ^
        totalProtein.hashCode ^
        totalCarbs.hashCode ^
        totalFat.hashCode ^
        totalFiber.hashCode ^
        totalSugar.hashCode ^
        totalSodium.hashCode ^
        mealCount.hashCode ^
        averageDailyCalories.hashCode ^
        dateRange.hashCode;
  }
}

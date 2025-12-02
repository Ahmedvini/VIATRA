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

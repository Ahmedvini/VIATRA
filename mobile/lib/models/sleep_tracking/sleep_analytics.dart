import 'package:json_annotation/json_annotation.dart';
import 'sleep_session.dart';

part 'sleep_analytics.g.dart';

// Helper functions to handle string or number conversion
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@JsonSerializable()
class SleepAnalytics {
  @JsonKey(name: 'totalSessions', fromJson: _toInt)
  final int totalSessions;
  @JsonKey(name: 'averageDuration', fromJson: _toInt)
  final int averageDuration; // in minutes
  @JsonKey(name: 'averageQuality', fromJson: _toDouble)
  final double averageQuality;
  @JsonKey(name: 'totalWakeUps', fromJson: _toInt)
  final int totalWakeUps;
  @JsonKey(name: 'averageWakeUps', fromJson: _toDouble)
  final double averageWakeUps;
  @JsonKey(name: 'sleepEfficiency', fromJson: _toInt)
  final int sleepEfficiency; // percentage
  final List<SleepSession>? sessions;

  SleepAnalytics({
    required this.totalSessions,
    required this.averageDuration,
    required this.averageQuality,
    required this.totalWakeUps,
    required this.averageWakeUps,
    required this.sleepEfficiency,
    this.sessions,
  });

  /// Get formatted average duration (e.g., "7h 30m")
  String get formattedAverageDuration {
    if (averageDuration < 60) {
      return '$averageDuration min';
    }
    final hours = averageDuration ~/ 60;
    final mins = averageDuration % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  /// Get formatted average quality (e.g., "4.2/5")
  String get formattedAverageQuality {
    return '${averageQuality.toStringAsFixed(1)}/5';
  }

  /// Get average quality stars
  String get averageQualityStars {
    final stars = averageQuality.round();
    return '⭐' * stars;
  }

  /// Get formatted average wake-ups (e.g., "2.1")
  String get formattedAverageWakeUps {
    return averageWakeUps.toStringAsFixed(1);
  }

  /// Get formatted sleep efficiency (e.g., "92%")
  String get formattedSleepEfficiency {
    return '$sleepEfficiency%';
  }

  /// Get quality color based on average
  String get qualityColor {
    if (averageQuality >= 4.5) return '#4CAF50'; // green
    if (averageQuality >= 3.5) return '#8BC34A'; // light green
    if (averageQuality >= 2.5) return '#FFC107'; // yellow
    if (averageQuality >= 1.5) return '#FF9800'; // orange
    return '#F44336'; // red
  }

  /// Get efficiency color
  String get efficiencyColor {
    if (sleepEfficiency >= 90) return '#4CAF50'; // green
    if (sleepEfficiency >= 80) return '#8BC34A'; // light green
    if (sleepEfficiency >= 70) return '#FFC107'; // yellow
    if (sleepEfficiency >= 60) return '#FF9800'; // orange
    return '#F44336'; // red
  }

  /// Check if sleep quality is good (>= 4.0)
  bool get isGoodQuality => averageQuality >= 4.0;

  /// Check if sleep duration is adequate (>= 7 hours)
  bool get isAdequateDuration => averageDuration >= 420; // 7 hours

  /// Check if sleep efficiency is good (>= 85%)
  bool get isGoodEfficiency => sleepEfficiency >= 85;

  /// Get overall sleep health status
  String get overallStatus {
    if (isGoodQuality && isAdequateDuration && isGoodEfficiency) {
      return 'Excellent';
    } else if (averageQuality >= 3.5 && averageDuration >= 360) {
      return 'Good';
    } else if (averageQuality >= 2.5 && averageDuration >= 300) {
      return 'Fair';
    } else {
      return 'Needs Improvement';
    }
  }

  /// Get recommendations based on analytics
  List<String> get recommendations {
    List<String> tips = [];

    if (!isAdequateDuration) {
      tips.add('Try to get at least 7-8 hours of sleep per night');
    }

    if (averageWakeUps > 2) {
      tips.add('Frequent wake-ups detected. Consider improving sleep environment');
    }

    if (!isGoodEfficiency) {
      tips.add('Low sleep efficiency. Try to minimize time awake during the night');
    }

    if (!isGoodQuality) {
      tips.add('Work on sleep quality by maintaining a consistent sleep schedule');
    }

    if (tips.isEmpty) {
      tips.add('Great job! Keep maintaining your healthy sleep habits');
    }

    return tips;
  }

  factory SleepAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SleepAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$SleepAnalyticsToJson(this);
}

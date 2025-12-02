import 'package:json_annotation/json_annotation.dart';
import 'sleep_interruption.dart';

part 'sleep_session.g.dart';

// Helper functions to handle string or number conversion
int? _toIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@JsonSerializable()
class SleepSession {
  final String? id;
  @JsonKey(name: 'patient_id')
  final String? patientId;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  @JsonKey(name: 'quality_rating', fromJson: _toIntNullable)
  final int? qualityRating;
  @JsonKey(name: 'total_duration_minutes', fromJson: _toIntNullable)
  final int? totalDurationMinutes;
  @JsonKey(name: 'wake_up_count', fromJson: _toInt)
  final int wakeUpCount;
  final String? notes;
  @JsonKey(name: 'environment_factors')
  final Map<String, dynamic>? environmentFactors;
  final String? status; // 'active', 'paused', 'completed'
  final List<SleepInterruption>? interruptions;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  SleepSession({
    this.id,
    this.patientId,
    required this.startTime,
    this.endTime,
    this.qualityRating,
    this.totalDurationMinutes,
    required this.wakeUpCount,
    this.notes,
    this.environmentFactors,
    this.status,
    this.interruptions,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if session is currently active (not completed)
  bool get isActive => status == 'active' || status == 'paused';

  /// Check if session is paused (user is awake)
  bool get isPaused => status == 'paused';

  /// Check if session is completed
  bool get isCompleted => status == 'completed';

  /// Get total duration as Duration object
  Duration? get totalDuration {
    if (totalDurationMinutes == null) return null;
    return Duration(minutes: totalDurationMinutes!);
  }

  /// Get current duration (for active sessions)
  Duration get currentDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get formatted duration string (e.g., "8h 15m")
  String get formattedDuration {
    final minutes = totalDurationMinutes ?? currentDuration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  /// Get formatted start time (e.g., "10:00 PM")
  String get formattedStartTime {
    return _formatTime(startTime);
  }

  /// Get formatted end time (e.g., "6:00 AM")
  String get formattedEndTime {
    if (endTime == null) return 'Ongoing';
    return _formatTime(endTime!);
  }

  /// Get date string (e.g., "Dec 2, 2024")
  String get dateString {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[startTime.month - 1]} ${startTime.day}, ${startTime.year}';
  }

  /// Calculate actual sleep duration (excluding interruptions)
  Duration? get actualSleepDuration {
    if (totalDurationMinutes == null) return null;
    
    int interruptionMinutes = 0;
    if (interruptions != null) {
      for (var interruption in interruptions!) {
        interruptionMinutes += interruption.durationMinutes ?? 0;
      }
    }
    
    return Duration(minutes: totalDurationMinutes! - interruptionMinutes);
  }

  /// Calculate sleep efficiency percentage (actual sleep / total time)
  double? get sleepEfficiency {
    if (totalDurationMinutes == null || totalDurationMinutes == 0) return null;
    
    final actualMinutes = actualSleepDuration?.inMinutes ?? totalDurationMinutes!;
    return (actualMinutes / totalDurationMinutes!) * 100;
  }

  /// Get formatted sleep efficiency (e.g., "94%")
  String get formattedSleepEfficiency {
    final efficiency = sleepEfficiency;
    if (efficiency == null) return 'N/A';
    return '${efficiency.round()}%';
  }

  /// Get quality stars emoji
  String get qualityStars {
    if (qualityRating == null) return '';
    return '⭐' * qualityRating!;
  }

  /// Get quality color (for UI)
  String get qualityColor {
    if (qualityRating == null) return '#9E9E9E'; // grey
    switch (qualityRating!) {
      case 5:
        return '#4CAF50'; // green
      case 4:
        return '#8BC34A'; // light green
      case 3:
        return '#FFC107'; // yellow
      case 2:
        return '#FF9800'; // orange
      case 1:
        return '#F44336'; // red
      default:
        return '#9E9E9E'; // grey
    }
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Sleeping';
      case 'paused':
        return 'Awake';
      case 'completed':
        return 'Completed';
      default:
        return status ?? 'Unknown';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  factory SleepSession.fromJson(Map<String, dynamic> json) =>
      _$SleepSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SleepSessionToJson(this);

  SleepSession copyWith({
    String? id,
    String? patientId,
    DateTime? startTime,
    DateTime? endTime,
    int? qualityRating,
    int? totalDurationMinutes,
    int? wakeUpCount,
    String? notes,
    Map<String, dynamic>? environmentFactors,
    String? status,
    List<SleepInterruption>? interruptions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepSession(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      qualityRating: qualityRating ?? this.qualityRating,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      wakeUpCount: wakeUpCount ?? this.wakeUpCount,
      notes: notes ?? this.notes,
      environmentFactors: environmentFactors ?? this.environmentFactors,
      status: status ?? this.status,
      interruptions: interruptions ?? this.interruptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'sleep_interruption.g.dart';

// Helper function to handle string or number conversion
int? _toIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable()
class SleepInterruption {
  final String id;
  @JsonKey(name: 'sleep_session_id')
  final String sleepSessionId;
  @JsonKey(name: 'pause_time')
  final DateTime pauseTime;
  @JsonKey(name: 'resume_time')
  final DateTime? resumeTime;
  @JsonKey(name: 'duration_minutes', fromJson: _toIntNullable)
  final int? durationMinutes;
  final String? reason;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SleepInterruption({
    required this.id,
    required this.sleepSessionId,
    required this.pauseTime,
    this.resumeTime,
    this.durationMinutes,
    this.reason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if interruption is still active (not resumed yet)
  bool get isActive => resumeTime == null;

  /// Get duration as Duration object
  Duration? get duration {
    if (durationMinutes == null) return null;
    return Duration(minutes: durationMinutes!);
  }

  /// Get formatted duration string (e.g., "15 min")
  String get formattedDuration {
    if (durationMinutes == null) return 'Ongoing';
    if (durationMinutes! < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  /// Get formatted time range (e.g., "2:30 AM - 2:45 AM")
  String getTimeRange() {
    final pauseStr = _formatTime(pauseTime);
    if (resumeTime == null) {
      return '$pauseStr - Ongoing';
    }
    final resumeStr = _formatTime(resumeTime!);
    return '$pauseStr - $resumeStr';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  factory SleepInterruption.fromJson(Map<String, dynamic> json) =>
      _$SleepInterruptionFromJson(json);

  Map<String, dynamic> toJson() => _$SleepInterruptionToJson(this);

  SleepInterruption copyWith({
    String? id,
    String? sleepSessionId,
    DateTime? pauseTime,
    DateTime? resumeTime,
    int? durationMinutes,
    String? reason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepInterruption(
      id: id ?? this.id,
      sleepSessionId: sleepSessionId ?? this.sleepSessionId,
      pauseTime: pauseTime ?? this.pauseTime,
      resumeTime: resumeTime ?? this.resumeTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

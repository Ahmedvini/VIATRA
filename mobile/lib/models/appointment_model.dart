import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'doctor_model.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentType; // telehealth, in_person, phone
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String status; // scheduled, confirmed, in_progress, completed, cancelled, no_show
  final String reasonForVisit;
  final String? chiefComplaint;
  final bool urgent;
  final bool? followUpRequired;
  final String? followUpInstructions;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Nested objects
  final Doctor? doctor;
  final Map<String, dynamic>? patient;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentType,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.status,
    required this.reasonForVisit,
    this.chiefComplaint,
    required this.urgent,
    this.followUpRequired,
    this.followUpInstructions,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.patient,
  });

  // Computed properties
  bool get isUpcoming => scheduledStart.isAfter(DateTime.now());
  
  bool get isPast => scheduledEnd.isBefore(DateTime.now());
  
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(scheduledStart) && now.isBefore(scheduledEnd);
  }
  
  bool get canBeCancelled {
    if (status == 'cancelled' || status == 'completed' || status == 'no_show') {
      return false;
    }
    final hoursUntilStart = scheduledStart.difference(DateTime.now()).inHours;
    return hoursUntilStart >= 2;
  }
  
  bool get canBeRescheduled {
    if (status == 'cancelled' || status == 'completed' || status == 'no_show') {
      return false;
    }
    final hoursUntilStart = scheduledStart.difference(DateTime.now()).inHours;
    return hoursUntilStart >= 2;
  }
  
  String get doctorName {
    return doctor?.displayName ?? doctor?.fullName ?? '';
  }
  
  String get specialty {
    return doctor?.specialty ?? '';
  }
  
  String get statusLabel {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }
  
  int get duration {
    return scheduledEnd.difference(scheduledStart).inMinutes;
  }
  
  String get formattedDate {
    return DateFormat('EEEE, MMMM d, yyyy').format(scheduledStart);
  }
  
  String get formattedTime {
    final start = DateFormat('h:mm a').format(scheduledStart);
    final end = DateFormat('h:mm a').format(scheduledEnd);
    return '$start - $end';
  }
  
  Color get statusColor {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
  
  IconData get typeIcon {
    switch (appointmentType) {
      case 'telehealth':
        return Icons.videocam;
      case 'in_person':
        return Icons.local_hospital;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.event;
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId'] ?? json['patient_id']?.toString() ?? '',
      doctorId: json['doctorId'] ?? json['doctor_id']?.toString() ?? '',
      appointmentType: json['appointmentType'] ?? json['appointment_type'] ?? '',
      scheduledStart: DateTime.parse(json['scheduledStart'] ?? json['scheduled_start']),
      scheduledEnd: DateTime.parse(json['scheduledEnd'] ?? json['scheduled_end']),
      actualStart: json['actualStart'] != null 
          ? DateTime.parse(json['actualStart'])
          : json['actual_start'] != null
              ? DateTime.parse(json['actual_start'])
              : null,
      actualEnd: json['actualEnd'] != null
          ? DateTime.parse(json['actualEnd'])
          : json['actual_end'] != null
              ? DateTime.parse(json['actual_end'])
              : null,
      status: json['status'] ?? '',
      reasonForVisit: json['reasonForVisit'] ?? json['reason_for_visit'] ?? '',
      chiefComplaint: json['chiefComplaint'] ?? json['chief_complaint'],
      urgent: json['urgent'] ?? false,
      followUpRequired: json['followUpRequired'] ?? json['follow_up_required'],
      followUpInstructions: json['followUpInstructions'] ?? json['follow_up_instructions'],
      cancellationReason: json['cancellationReason'] ?? json['cancellation_reason'],
      cancelledBy: json['cancelledBy'] ?? json['cancelled_by'],
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : json['cancelled_at'] != null
              ? DateTime.parse(json['cancelled_at'])
              : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      patient: json['patient'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentType': appointmentType,
      'scheduledStart': scheduledStart.toIso8601String(),
      'scheduledEnd': scheduledEnd.toIso8601String(),
      'actualStart': actualStart?.toIso8601String(),
      'actualEnd': actualEnd?.toIso8601String(),
      'status': status,
      'reasonForVisit': reasonForVisit,
      'chiefComplaint': chiefComplaint,
      'urgent': urgent,
      'followUpRequired': followUpRequired,
      'followUpInstructions': followUpInstructions,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'doctor': doctor?.toJson(),
      'patient': patient,
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? appointmentType,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    String? status,
    String? reasonForVisit,
    String? chiefComplaint,
    bool? urgent,
    bool? followUpRequired,
    String? followUpInstructions,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Doctor? doctor,
    Map<String, dynamic>? patient,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentType: appointmentType ?? this.appointmentType,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      status: status ?? this.status,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      urgent: urgent ?? this.urgent,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpInstructions: followUpInstructions ?? this.followUpInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctor: doctor ?? this.doctor,
      patient: patient ?? this.patient,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctorId: $doctorId, type: $appointmentType, start: $scheduledStart, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool available;

  TimeSlot({
    required this.start,
    required this.end,
    required this.available,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'available': available,
    };
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(start);
  }

  @override
  String toString() {
    return 'TimeSlot(start: $start, available: $available)';
  }
}

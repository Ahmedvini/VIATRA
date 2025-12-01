import 'package:flutter/material.dart';

/// Helper class for localization - Currently using hardcoded English strings
/// TODO: Implement proper localization when l10n files are available
class LocalizationHelper {
  static bool isRTL(BuildContext context) => Directionality.of(context) == TextDirection.rtl;

  static String getLocalizedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static String getLocalizedRole(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'patient':
        return 'Patient';
      default:
        return role;
    }
  }

  static String getLocalizedGender(BuildContext context, String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Prefer not to say';
    }
  }

  static String getLocalizedSeverity(BuildContext context, String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return 'Mild';
      case 'moderate':
        return 'Moderate';
      case 'severe':
        return 'Severe';
      case 'life-threatening':
      case 'lifethreatening':
        return 'Life-threatening';
      default:
        return severity;
    }
  }

  static String getLocalizedAppointmentStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      default:
        return status;
    }
  }

  static String getLocalizedVerificationStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
      case 'underreview':
        return 'Under Review';
      default:
        return status;
    }
  }

  static String getLocalizedBMICategory(BuildContext context, double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static String getLocalizedConsultationType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'in_person':
      case 'inperson':
        return 'In Person';
      case 'video':
        return 'Video';
      case 'phone':
        return 'Phone';
      default:
        return type;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationHelper {
  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context)!;

  static bool isRTL(BuildContext context) => Directionality.of(context) == TextDirection.rtl;

  static String getLocalizedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = of(context);

    if (hour < 12) {
      return l10n.greetingMorning;
    } else if (hour < 18) {
      return l10n.greetingAfternoon;
    } else {
      return l10n.greetingEvening;
    }
  }

  static String getLocalizedRole(BuildContext context, String role) {
    final l10n = of(context);
    switch (role.toLowerCase()) {
      case 'doctor':
        return l10n.roleDoctor;
      case 'patient':
        return l10n.rolePatient;
      default:
        return role;
    }
  }

  static String getLocalizedGender(BuildContext context, String gender) {
    final l10n = of(context);
    switch (gender.toLowerCase()) {
      case 'male':
        return l10n.genderMale;
      case 'female':
        return l10n.genderFemale;
      case 'other':
        return l10n.genderOther;
      default:
        return l10n.genderPreferNotToSay;
    }
  }

  static String getLocalizedSeverity(BuildContext context, String severity) {
    final l10n = of(context);
    switch (severity.toLowerCase()) {
      case 'mild':
        return l10n.severityMild;
      case 'moderate':
        return l10n.severityModerate;
      case 'severe':
        return l10n.severitySevere;
      case 'life-threatening':
      case 'lifethreatening':
        return l10n.severityLifeThreatening;
      default:
        return severity;
    }
  }

  static String getLocalizedAppointmentStatus(BuildContext context, String status) {
    final l10n = of(context);
    switch (status.toLowerCase()) {
      case 'scheduled':
        return l10n.statusScheduled;
      case 'completed':
        return l10n.statusCompleted;
      case 'cancelled':
        return l10n.statusCancelled;
      case 'pending':
        return l10n.statusPending;
      case 'confirmed':
        return l10n.filterConfirmed;
      default:
        return status;
    }
  }

  static String getLocalizedVerificationStatus(BuildContext context, String status) {
    final l10n = of(context);
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.verificationPending;
      case 'approved':
        return l10n.verificationApproved;
      case 'rejected':
        return l10n.verificationRejected;
      case 'under_review':
      case 'underreview':
        return l10n.verificationUnderReview;
      default:
        return status;
    }
  }

  static String getLocalizedBMICategory(BuildContext context, double bmi) {
    final l10n = of(context);
    if (bmi < 18.5) {
      return l10n.bmiUnderweight;
    } else if (bmi < 25) {
      return l10n.bmiNormal;
    } else if (bmi < 30) {
      return l10n.bmiOverweight;
    } else {
      return l10n.bmiObese;
    }
  }

  static String getLocalizedConsultationType(BuildContext context, String type) {
    final l10n = of(context);
    switch (type.toLowerCase()) {
      case 'in_person':
      case 'inperson':
        return l10n.consultationTypeInPerson;
      case 'video':
        return l10n.consultationTypeVideo;
      case 'phone':
        return l10n.consultationTypePhone;
      default:
        return type;
    }
  }
}

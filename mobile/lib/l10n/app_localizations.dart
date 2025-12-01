import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application name displayed in app bar and splash screen
  ///
  /// In en, this message translates to:
  /// **'Viatra Health'**
  String get appName;

  /// Welcome message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcome;

  /// Subtitle text on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your account'**
  String get loginSubtitle;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// Label for remember me checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get labelRememberMe;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get buttonSignIn;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get buttonSignUp;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text prompting user to register
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Registration screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registrationTitle;

  /// Registration step 1 label
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get stepPersonalInfo;

  /// Registration step 2 label for doctors
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get stepProfessionalInfo;

  /// Registration step for document upload
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get stepDocuments;

  /// Final registration step label
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// Label for full name input field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// Label for phone number input field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get labelPhone;

  /// Label for date of birth picker
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get labelDateOfBirth;

  /// Label for gender selection
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get labelGender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// Prefer not to say gender option
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// Label for address input field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// Label for city input field
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labelCity;

  /// Label for doctor specialty selection
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get labelSpecialty;

  /// Label for medical license number
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get labelLicenseNumber;

  /// Label for years of experience input
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get labelYearsOfExperience;

  /// Label for consultation fee input
  ///
  /// In en, this message translates to:
  /// **'Consultation Fee'**
  String get labelConsultationFee;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get buttonSubmit;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// Bottom navigation home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom navigation appointments label
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// Bottom navigation profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom navigation dashboard label for doctors
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom navigation patients label for doctors
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Morning greeting message
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Afternoon greeting message
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Evening greeting message
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// Book appointment action label
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get actionBookAppointment;

  /// Find doctor action label
  ///
  /// In en, this message translates to:
  /// **'Find Doctor'**
  String get actionFindDoctor;

  /// Health profile action label
  ///
  /// In en, this message translates to:
  /// **'Health Profile'**
  String get actionHealthProfile;

  /// My appointments action label
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get actionMyAppointments;

  /// Upcoming appointments section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get sectionUpcomingAppointments;

  /// Search input placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search doctors...'**
  String get searchDoctorsHint;

  /// Initial search screen title
  ///
  /// In en, this message translates to:
  /// **'Search for Doctors'**
  String get searchDoctorsTitle;

  /// Empty state message when no doctors match search
  ///
  /// In en, this message translates to:
  /// **'No Doctors Found'**
  String get noDoctorsFound;

  /// Generic error message for search failures
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get searchErrorMessage;

  /// Clear search button label
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get buttonClearSearch;

  /// Filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// Apply filters button label
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get buttonApplyFilters;

  /// Clear all filters button label
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get buttonClearAll;

  /// Price range filter label
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get filterPriceRange;

  /// Location filter label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// Availability filter label
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get filterAvailability;

  /// Languages filter label
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get filterLanguages;

  /// About section title on doctor detail screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get doctorDetailsAbout;

  /// Specialties section title
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get doctorDetailsSpecialties;

  /// Languages section title
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get doctorDetailsLanguages;

  /// Working hours section title
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get doctorDetailsWorkingHours;

  /// Reviews section title
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get doctorDetailsReviews;

  /// Book appointment button label
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get buttonBookAppointment;

  /// Call button label
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get buttonCall;

  /// Message button label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get buttonMessage;

  /// Experience label for doctor card
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get labelExperience;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get labelRating;

  /// Available status label
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labelAvailable;

  /// Unavailable status label
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get labelUnavailable;

  /// Book now button label on doctor card
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get buttonBookNow;

  /// Message when doctor has no reviews
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Appointments screen title
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get appointmentsTitle;

  /// Upcoming appointments tab label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// Past appointments tab label
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Scheduled appointment status
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// Completed appointment status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Cancelled appointment status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Pending appointment status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Empty state message for upcoming appointments
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// Empty state message for past appointments
  ///
  /// In en, this message translates to:
  /// **'No past appointments'**
  String get noPastAppointments;

  /// Prompt message to book first appointment
  ///
  /// In en, this message translates to:
  /// **'Book an appointment to get started'**
  String get bookAppointmentPrompt;

  /// Appointment details screen title
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetailsTitle;

  /// Doctor information section title
  ///
  /// In en, this message translates to:
  /// **'Doctor Information'**
  String get sectionDoctorInfo;

  /// Appointment notes section title
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sectionAppointmentNotes;

  /// Cancel appointment button label
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get buttonCancelAppointment;

  /// Reschedule button label
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get buttonReschedule;

  /// Start video call button label
  ///
  /// In en, this message translates to:
  /// **'Start Video Call'**
  String get buttonStartVideoCall;

  /// Confirmation message for cancelling appointment
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get confirmCancelAppointment;

  /// Success message after cancelling appointment
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled successfully'**
  String get appointmentCancelledSuccess;

  /// Time slot selection screen title
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeSlotTitle;

  /// Message when no time slots available
  ///
  /// In en, this message translates to:
  /// **'No available slots for selected date'**
  String get noAvailableSlots;

  /// Confirm booking button label
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get buttonConfirmBooking;

  /// Success message after booking appointment
  ///
  /// In en, this message translates to:
  /// **'Appointment Booked Successfully!'**
  String get appointmentBookedSuccess;

  /// Doctor label
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get labelDoctor;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labelTime;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get labelLocation;

  /// View appointment button label
  ///
  /// In en, this message translates to:
  /// **'View Appointment'**
  String get buttonViewAppointment;

  /// Back to home button label
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get buttonBackToHome;

  /// Add to calendar button label
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get buttonAddToCalendar;

  /// Health profile screen title
  ///
  /// In en, this message translates to:
  /// **'Health Profile'**
  String get healthProfileTitle;

  /// Chronic conditions section title
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get sectionChronicConditions;

  /// Allergies section title
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get sectionAllergies;

  /// Current medications section title
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get sectionMedications;

  /// Emergency contact section title
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get sectionEmergencyContact;

  /// Empty state message for chronic conditions
  ///
  /// In en, this message translates to:
  /// **'No chronic conditions recorded'**
  String get noChronicConditions;

  /// Empty state message for allergies
  ///
  /// In en, this message translates to:
  /// **'No allergies recorded'**
  String get noAllergies;

  /// Empty state message for medications
  ///
  /// In en, this message translates to:
  /// **'No current medications'**
  String get noMedications;

  /// Edit profile button label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get buttonEditProfile;

  /// Create health profile button label
  ///
  /// In en, this message translates to:
  /// **'Create Health Profile'**
  String get buttonCreateHealthProfile;

  /// Edit health profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Health Profile'**
  String get editHealthProfileTitle;

  /// Height label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get labelHeight;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get labelWeight;

  /// Blood pressure label
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get labelBloodPressure;

  /// Blood type label
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get labelBloodType;

  /// Heart rate label
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get labelHeartRate;

  /// Temperature label
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get labelTemperature;

  /// Centimeters unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// Millimeters of mercury unit
  ///
  /// In en, this message translates to:
  /// **'mmHg'**
  String get unitMmHg;

  /// Beats per minute unit
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get unitBpm;

  /// Celsius unit
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get unitCelsius;

  /// Vitals card title
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get vitalsTitle;

  /// BMI label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get labelBMI;

  /// BMI underweight category
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// BMI normal category
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// BMI overweight category
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// BMI obese category
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// Add chronic condition screen title
  ///
  /// In en, this message translates to:
  /// **'Add Chronic Condition'**
  String get addChronicConditionTitle;

  /// Edit chronic condition screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Chronic Condition'**
  String get editChronicConditionTitle;

  /// Condition name label
  ///
  /// In en, this message translates to:
  /// **'Condition Name'**
  String get labelConditionName;

  /// Diagnosed date label
  ///
  /// In en, this message translates to:
  /// **'Diagnosed Date'**
  String get labelDiagnosedDate;

  /// Severity label
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get labelSeverity;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// Mild severity option
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// Moderate severity option
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// Severe severity option
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// Diagnosed label prefix
  ///
  /// In en, this message translates to:
  /// **'Diagnosed'**
  String get labelDiagnosed;

  /// Confirmation message for deleting chronic condition
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this condition?'**
  String get confirmDeleteCondition;

  /// Add allergy screen title
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergyTitle;

  /// Edit allergy screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Allergy'**
  String get editAllergyTitle;

  /// Allergen label
  ///
  /// In en, this message translates to:
  /// **'Allergen'**
  String get labelAllergen;

  /// Reaction label
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get labelReaction;

  /// Life-threatening severity option
  ///
  /// In en, this message translates to:
  /// **'Life-threatening'**
  String get severityLifeThreatening;

  /// Confirmation message for deleting allergy
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this allergy?'**
  String get confirmDeleteAllergy;

  /// Doctor dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctorDashboardTitle;

  /// Today's appointments stat label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get statTodaysAppointments;

  /// Upcoming stat label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statUpcoming;

  /// Total patients stat label
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get statTotalPatients;

  /// Pending requests stat label
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get statPendingRequests;

  /// Today's schedule section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get sectionTodaysSchedule;

  /// Recent patients section title
  ///
  /// In en, this message translates to:
  /// **'Recent Patients'**
  String get sectionRecentPatients;

  /// Empty state message for today's appointments
  ///
  /// In en, this message translates to:
  /// **'No appointments today'**
  String get noAppointmentsToday;

  /// Accept button label
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get buttonAccept;

  /// Reject button label
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get buttonReject;

  /// Complete button label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get buttonComplete;

  /// Add notes button label
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get buttonAddNotes;

  /// Confirmation message for accepting appointment
  ///
  /// In en, this message translates to:
  /// **'Accept this appointment request?'**
  String get confirmAcceptAppointment;

  /// Confirmation message for rejecting appointment
  ///
  /// In en, this message translates to:
  /// **'Reject this appointment request?'**
  String get confirmRejectAppointment;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Account information section title
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get sectionAccountInfo;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get sectionPreferences;

  /// Change password menu item
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get menuChangePassword;

  /// Language menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// Theme menu item
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuTheme;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// Privacy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get menuPrivacy;

  /// Terms and conditions menu item
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get menuTerms;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// Patient role label
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// Doctor role label
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// Switch role label
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get labelSwitchRole;

  /// Switch role confirmation message
  ///
  /// In en, this message translates to:
  /// **'Switch to {role}?'**
  String confirmSwitchRole(String role);

  /// Upload documents widget title
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocumentsTitle;

  /// Choose from gallery button label
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get buttonChooseFromGallery;

  /// Take photo button label
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get buttonTakePhoto;

  /// Remove button label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buttonRemove;

  /// Upload in progress status message
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get statusUploading;

  /// Upload success status message
  ///
  /// In en, this message translates to:
  /// **'Upload successful'**
  String get statusUploadSuccess;

  /// Upload failed status message
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get statusUploadFailed;

  /// Verification pending status
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// Verification approved status
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get verificationApproved;

  /// Verification rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get verificationRejected;

  /// Verification under review status
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get verificationUnderReview;

  /// Message shown during verification pending
  ///
  /// In en, this message translates to:
  /// **'Your documents are being reviewed'**
  String get verificationPendingMessage;

  /// Message shown when verification is complete
  ///
  /// In en, this message translates to:
  /// **'Verification complete! You can now access all features'**
  String get verificationCompleteMessage;

  /// Message shown when verification is rejected
  ///
  /// In en, this message translates to:
  /// **'Please resubmit your documents'**
  String get verificationRejectedMessage;

  /// Resubmit button label
  ///
  /// In en, this message translates to:
  /// **'Resubmit'**
  String get buttonResubmit;

  /// View details button label
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get buttonViewDetails;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please login again.'**
  String get errorAuth;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get errorValidation;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnknown;

  /// Invalid email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorInvalidEmail;

  /// Invalid password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorInvalidPassword;

  /// Invalid phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get errorInvalidPhone;

  /// Required field validation error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequiredField;

  /// Generic loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// Loading message asking user to wait
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get loadingPleaseWait;

  /// Generic empty state message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get emptyStateNoData;

  /// Empty state message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptyStateNoResults;

  /// Confirmed filter option for appointments
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get filterConfirmed;

  /// In-person consultation type
  ///
  /// In en, this message translates to:
  /// **'In-Person'**
  String get consultationTypeInPerson;

  /// Video consultation type
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get consultationTypeVideo;

  /// Phone consultation type
  ///
  /// In en, this message translates to:
  /// **'Phone Call'**
  String get consultationTypePhone;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

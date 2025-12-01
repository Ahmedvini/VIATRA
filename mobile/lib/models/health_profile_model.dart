class HealthProfile {

  HealthProfile({
    required this.id,
    required this.patientId,
    required this.createdAt, required this.updatedAt, this.bloodType,
    this.height,
    this.weight,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.bloodGlucose,
    this.oxygenSaturation,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.familyHistory = const [],
    this.lifestyle,
    this.emergencyContact,
    this.preferredPharmacy,
    this.insurance,
    this.notes,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? json['patientId']?.toString() ?? '',
      bloodType: (json['blood_type'] as String?) ?? (json['bloodType'] as String?),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodPressureSystolic: (json['blood_pressure_systolic'] as int?) ?? (json['bloodPressureSystolic'] as int?),
      bloodPressureDiastolic: (json['blood_pressure_diastolic'] as int?) ?? (json['bloodPressureDiastolic'] as int?),
      heartRate: (json['heart_rate'] as int?) ?? (json['heartRate'] as int?),
      bloodGlucose: (json['blood_glucose'] as num?)?.toDouble() ?? (json['bloodGlucose'] as num?)?.toDouble(),
      oxygenSaturation: (json['oxygen_saturation'] as int?) ?? (json['oxygenSaturation'] as int?),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => Allergy.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      chronicConditions: (json['chronic_conditions'] as List<dynamic>? ??
              json['chronicConditions'] as List<dynamic>?)
          ?.map((e) => ChronicCondition.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      currentMedications: (json['current_medications'] as List<dynamic>? ??
              json['currentMedications'] as List<dynamic>?)
          ?.map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      familyHistory: (json['family_history'] as List<dynamic>? ??
              json['familyHistory'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      lifestyle: json['lifestyle'] != null
          ? Lifestyle.fromJson(json['lifestyle'] as Map<String, dynamic>)
          : null,
      emergencyContact: json['emergency_contact_name'] != null ||
              json['emergencyContactName'] != null
          ? EmergencyContact(
              name: (json['emergency_contact_name'] as String?) ?? (json['emergencyContactName'] as String?),
              phone: (json['emergency_contact_phone'] as String?) ?? (json['emergencyContactPhone'] as String?),
              relationship: (json['emergency_contact_relationship'] as String?) ??
                  (json['emergencyContactRelationship'] as String?),
            )
          : null,
      preferredPharmacy:
          (json['preferred_pharmacy'] as String?) ?? (json['preferredPharmacy'] as String?),
      insurance: json['insurance_provider'] != null ||
              json['insuranceProvider'] != null
          ? Insurance(
              provider: (json['insurance_provider'] as String?) ?? (json['insuranceProvider'] as String?),
              insuranceId: (json['insurance_id'] as String?) ?? (json['insuranceId'] as String?),
            )
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
          (json['created_at'] as String?) ?? (json['createdAt'] as String?) ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          (json['updated_at'] as String?) ?? (json['updatedAt'] as String?) ?? DateTime.now().toIso8601String()),
    );
  final String id;
  final String patientId;
  final String? bloodType;
  final double? height;
  final double? weight;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final double? bloodGlucose;
  final int? oxygenSaturation;
  final List<Allergy> allergies;
  final List<ChronicCondition> chronicConditions;
  final List<Medication> currentMedications;
  final List<String> familyHistory;
  final Lifestyle? lifestyle;
  final EmergencyContact? emergencyContact;
  final String? preferredPharmacy;
  final Insurance? insurance;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'patientId': patientId,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
      'bloodGlucose': bloodGlucose,
      'oxygenSaturation': oxygenSaturation,
      'allergies': allergies.map((e) => e.toJson()).toList(),
      'chronicConditions': chronicConditions.map((e) => e.toJson()).toList(),
      'currentMedications': currentMedications.map((e) => e.toJson()).toList(),
      'familyHistory': familyHistory,
      'lifestyle': lifestyle?.toJson(),
      'emergencyContactName': emergencyContact?.name,
      'emergencyContactPhone': emergencyContact?.phone,
      'emergencyContactRelationship': emergencyContact?.relationship,
      'preferredPharmacy': preferredPharmacy,
      'insuranceProvider': insurance?.provider,
      'insuranceId': insurance?.insuranceId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

  HealthProfile copyWith({
    String? id,
    String? patientId,
    String? bloodType,
    double? height,
    double? weight,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    double? bloodGlucose,
    int? oxygenSaturation,
    List<Allergy>? allergies,
    List<ChronicCondition>? chronicConditions,
    List<Medication>? currentMedications,
    List<String>? familyHistory,
    Lifestyle? lifestyle,
    EmergencyContact? emergencyContact,
    String? preferredPharmacy,
    Insurance? insurance,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HealthProfile(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      familyHistory: familyHistory ?? this.familyHistory,
      lifestyle: lifestyle ?? this.lifestyle,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      preferredPharmacy: preferredPharmacy ?? this.preferredPharmacy,
      insurance: insurance ?? this.insurance,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  double? calculateBMI() {
    if (height == null || weight == null || height! <= 0) {
      return null;
    }
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  String getBMICategory() {
    final bmi = calculateBMI();
    if (bmi == null) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  bool hasAllergy(String allergen) => allergies.any((a) =>
        a.allergen.toLowerCase().contains(allergen.toLowerCase()));

  bool hasChronicCondition(String name) => chronicConditions
        .any((c) => c.name.toLowerCase().contains(name.toLowerCase()));
}

class Allergy {

  Allergy({
    required this.allergen,
    required this.severity,
    this.notes,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Allergy.fromJson(Map<String, dynamic> json) => Allergy(
      allergen: (json['allergen'] as String?) ?? '',
      severity: (json['severity'] as String?) ?? 'mild',
      notes: json['notes'] as String?,
      dateAdded: json['date_added'] != null || json['dateAdded'] != null
          ? DateTime.parse(((json['date_added'] as String?) ?? (json['dateAdded'] as String?))!)
          : DateTime.now(),
    );
  final String allergen;
  final String severity;
  final String? notes;
  final DateTime dateAdded;

  Map<String, dynamic> toJson() => {
      'allergen': allergen,
      'severity': severity,
      'notes': notes,
      'dateAdded': dateAdded.toIso8601String(),
    };
}

class ChronicCondition {

  ChronicCondition({
    required this.name, required this.severity, String? id,
    this.diagnosedDate,
    this.medications = const [],
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory ChronicCondition.fromJson(Map<String, dynamic> json) => ChronicCondition(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: (json['name'] as String?) ?? '',
      diagnosedDate: json['diagnosed_date'] != null || json['diagnosedDate'] != null
          ? DateTime.parse(((json['diagnosed_date'] as String?) ?? (json['diagnosedDate'] as String?))!)
          : null,
      severity: (json['severity'] as String?) ?? 'mild',
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  final String id;
  final String name;
  final DateTime? diagnosedDate;
  final String severity;
  final List<String> medications;
  final String? notes;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'diagnosedDate': diagnosedDate?.toIso8601String(),
      'severity': severity,
      'medications': medications,
      'notes': notes,
    };
}

class Medication {

  Medication({
    required this.name,
    this.dosage,
    this.frequency,
    this.startDate,
    this.endDate,
    this.prescribedBy,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
      name: (json['name'] as String?) ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      startDate: json['start_date'] != null || json['startDate'] != null
          ? DateTime.parse(((json['start_date'] as String?) ?? (json['startDate'] as String?))!)
          : null,
      endDate: json['end_date'] != null || json['endDate'] != null
          ? DateTime.parse(((json['end_date'] as String?) ?? (json['endDate'] as String?))!)
          : null,
      prescribedBy: (json['prescribed_by'] as String?) ?? (json['prescribedBy'] as String?),
    );
  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribedBy;

  Map<String, dynamic> toJson() => {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
    };
}

class Lifestyle {

  Lifestyle({
    this.smoking,
    this.alcohol,
    this.exerciseFrequency,
    this.diet,
  });

  factory Lifestyle.fromJson(Map<String, dynamic> json) => Lifestyle(
      smoking: json['smoking'] as String?,
      alcohol: json['alcohol'] as String?,
      exerciseFrequency: (json['exercise_frequency'] as String?) ?? (json['exerciseFrequency'] as String?),
      diet: json['diet'] as String?,
    );
  final String? smoking;
  final String? alcohol;
  final String? exerciseFrequency;
  final String? diet;

  Map<String, dynamic> toJson() => {
      'smoking': smoking,
      'alcohol': alcohol,
      'exerciseFrequency': exerciseFrequency,
      'diet': diet,
    };
}

class EmergencyContact {

  EmergencyContact({
    this.name,
    this.phone,
    this.relationship,
  });
  final String? name;
  final String? phone;
  final String? relationship;

  Map<String, dynamic> toJson() => {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
}

class Insurance {

  Insurance({
    this.provider,
    this.insuranceId,
  });
  final String? provider;
  final String? insuranceId;

  Map<String, dynamic> toJson() => {
      'provider': provider,
      'insuranceId': insuranceId,
    };
}

class HealthProfile {
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

  HealthProfile({
    required this.id,
    required this.patientId,
    this.bloodType,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? json['patientId']?.toString() ?? '',
      bloodType: json['blood_type'] ?? json['bloodType'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bloodPressureSystolic: json['blood_pressure_systolic']?.toInt() ?? json['bloodPressureSystolic']?.toInt(),
      bloodPressureDiastolic: json['blood_pressure_diastolic']?.toInt() ?? json['bloodPressureDiastolic']?.toInt(),
      heartRate: json['heart_rate']?.toInt() ?? json['heartRate']?.toInt(),
      bloodGlucose: json['blood_glucose']?.toDouble() ?? json['bloodGlucose']?.toDouble(),
      oxygenSaturation: json['oxygen_saturation']?.toInt() ?? json['oxygenSaturation']?.toInt(),
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
              name: json['emergency_contact_name'] ?? json['emergencyContactName'],
              phone: json['emergency_contact_phone'] ?? json['emergencyContactPhone'],
              relationship: json['emergency_contact_relationship'] ??
                  json['emergencyContactRelationship'],
            )
          : null,
      preferredPharmacy:
          json['preferred_pharmacy'] ?? json['preferredPharmacy'],
      insurance: json['insurance_provider'] != null ||
              json['insuranceProvider'] != null
          ? Insurance(
              provider: json['insurance_provider'] ?? json['insuranceProvider'],
              insuranceId: json['insurance_id'] ?? json['insuranceId'],
            )
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

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
  }) {
    return HealthProfile(
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
  }

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

  bool hasAllergy(String allergen) {
    return allergies.any((a) =>
        a.allergen.toLowerCase().contains(allergen.toLowerCase()));
  }

  bool hasChronicCondition(String name) {
    return chronicConditions
        .any((c) => c.name.toLowerCase().contains(name.toLowerCase()));
  }
}

class Allergy {
  final String allergen;
  final String severity;
  final String? notes;
  final DateTime dateAdded;

  Allergy({
    required this.allergen,
    required this.severity,
    this.notes,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      allergen: json['allergen'] ?? '',
      severity: json['severity'] ?? 'mild',
      notes: json['notes'],
      dateAdded: json['date_added'] != null || json['dateAdded'] != null
          ? DateTime.parse(json['date_added'] ?? json['dateAdded'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergen': allergen,
      'severity': severity,
      'notes': notes,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}

class ChronicCondition {
  final String id;
  final String name;
  final DateTime? diagnosedDate;
  final String severity;
  final List<String> medications;
  final String? notes;

  ChronicCondition({
    String? id,
    required this.name,
    this.diagnosedDate,
    required this.severity,
    this.medications = const [],
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory ChronicCondition.fromJson(Map<String, dynamic> json) {
    return ChronicCondition(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      diagnosedDate: json['diagnosed_date'] != null || json['diagnosedDate'] != null
          ? DateTime.parse(json['diagnosed_date'] ?? json['diagnosedDate'])
          : null,
      severity: json['severity'] ?? 'mild',
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diagnosedDate': diagnosedDate?.toIso8601String(),
      'severity': severity,
      'medications': medications,
      'notes': notes,
    };
  }
}

class Medication {
  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribedBy;

  Medication({
    required this.name,
    this.dosage,
    this.frequency,
    this.startDate,
    this.endDate,
    this.prescribedBy,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: json['start_date'] != null || json['startDate'] != null
          ? DateTime.parse(json['start_date'] ?? json['startDate'])
          : null,
      endDate: json['end_date'] != null || json['endDate'] != null
          ? DateTime.parse(json['end_date'] ?? json['endDate'])
          : null,
      prescribedBy: json['prescribed_by'] ?? json['prescribedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
    };
  }
}

class Lifestyle {
  final String? smoking;
  final String? alcohol;
  final String? exerciseFrequency;
  final String? diet;

  Lifestyle({
    this.smoking,
    this.alcohol,
    this.exerciseFrequency,
    this.diet,
  });

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(
      smoking: json['smoking'],
      alcohol: json['alcohol'],
      exerciseFrequency: json['exercise_frequency'] ?? json['exerciseFrequency'],
      diet: json['diet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smoking': smoking,
      'alcohol': alcohol,
      'exerciseFrequency': exerciseFrequency,
      'diet': diet,
    };
  }
}

class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relationship;

  EmergencyContact({
    this.name,
    this.phone,
    this.relationship,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}

class Insurance {
  final String? provider;
  final String? insuranceId;

  Insurance({
    this.provider,
    this.insuranceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'insuranceId': insuranceId,
    };
  }
}

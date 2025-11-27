class Patient {

  Patient({
    required this.id,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.emergencyContact,
    this.address,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? json['user_id']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      gender: json['gender'],
      bloodType: json['bloodType'] ?? json['blood_type'],
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContact.fromJson(json['emergencyContact'])
          : json['emergency_contact'] != null
              ? EmergencyContact.fromJson(json['emergency_contact'])
              : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
  final String id;
  final String userId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final EmergencyContact? emergencyContact;
  final Address? address;

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'emergencyContact': emergencyContact?.toJson(),
      'address': address?.toJson(),
    };

  Patient copyWith({
    String? id,
    String? userId,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    EmergencyContact? emergencyContact,
    Address? address,
  }) => Patient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
    );

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    var age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() => 'Patient(id: $id, age: $age, gender: $gender, bloodType: $bloodType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class EmergencyContact {

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }
  final String name;
  final String phone;
  final String relationship;

  Map<String, dynamic> toJson() => {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
  }) => EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );

  @override
  String toString() => 'EmergencyContact(name: $name, phone: $phone, relationship: $relationship)';
}

class Address {

  Address({
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? json['postal_code'] ?? '',
    );
  }
  final String street;
  final String city;
  final String country;
  final String postalCode;

  Map<String, dynamic> toJson() => {
      'street': street,
      'city': city,
      'country': country,
      'postalCode': postalCode,
    };

  Address copyWith({
    String? street,
    String? city,
    String? country,
    String? postalCode,
  }) => Address(
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );

  String get fullAddress => '$street, $city, $country $postalCode';

  @override
  String toString() => 'Address($fullAddress)';
}

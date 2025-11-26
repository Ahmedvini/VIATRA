class DoctorSearchFilter {
  final String? searchQuery;
  final String? specialty;
  final String? subSpecialty;
  final String? city;
  final String? state;
  final String? zipCode;
  final double? minFee;
  final double? maxFee;
  final List<String>? languages;
  final bool? isAcceptingPatients;
  final bool? telehealthEnabled;
  final String sortBy;
  final String sortOrder;

  DoctorSearchFilter({
    this.searchQuery,
    this.specialty,
    this.subSpecialty,
    this.city,
    this.state,
    this.zipCode,
    this.minFee,
    this.maxFee,
    this.languages,
    this.isAcceptingPatients,
    this.telehealthEnabled,
    this.sortBy = 'created_at',
    this.sortOrder = 'DESC',
  });

  /// Convert filter to query parameters for API
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['searchQuery'] = searchQuery!;
    }
    if (specialty != null && specialty!.isNotEmpty) {
      params['specialty'] = specialty!;
    }
    if (subSpecialty != null && subSpecialty!.isNotEmpty) {
      params['subSpecialty'] = subSpecialty!;
    }
    if (city != null && city!.isNotEmpty) {
      params['city'] = city!;
    }
    if (state != null && state!.isNotEmpty) {
      params['state'] = state!;
    }
    if (zipCode != null && zipCode!.isNotEmpty) {
      params['zipCode'] = zipCode!;
    }
    if (minFee != null) {
      params['minFee'] = minFee!.toString();
    }
    if (maxFee != null) {
      params['maxFee'] = maxFee!.toString();
    }
    if (languages != null && languages!.isNotEmpty) {
      params['languages'] = languages!.join(',');
    }
    if (isAcceptingPatients != null) {
      params['isAcceptingPatients'] = isAcceptingPatients!.toString();
    }
    if (telehealthEnabled != null) {
      params['telehealthEnabled'] = telehealthEnabled!.toString();
    }
    
    params['sortBy'] = sortBy;
    params['sortOrder'] = sortOrder;

    return params;
  }

  /// Create filter from JSON
  factory DoctorSearchFilter.fromJson(Map<String, dynamic> json) {
    return DoctorSearchFilter(
      searchQuery: json['searchQuery'],
      specialty: json['specialty'],
      subSpecialty: json['subSpecialty'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      minFee: json['minFee']?.toDouble(),
      maxFee: json['maxFee']?.toDouble(),
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      isAcceptingPatients: json['isAcceptingPatients'],
      telehealthEnabled: json['telehealthEnabled'],
      sortBy: json['sortBy'] ?? 'created_at',
      sortOrder: json['sortOrder'] ?? 'DESC',
    );
  }

  /// Convert filter to JSON
  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'specialty': specialty,
      'subSpecialty': subSpecialty,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'minFee': minFee,
      'maxFee': maxFee,
      'languages': languages,
      'isAcceptingPatients': isAcceptingPatients,
      'telehealthEnabled': telehealthEnabled,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }

  /// Create a copy with updated fields
  DoctorSearchFilter copyWith({
    String? searchQuery,
    String? specialty,
    String? subSpecialty,
    String? city,
    String? state,
    String? zipCode,
    double? minFee,
    double? maxFee,
    List<String>? languages,
    bool? isAcceptingPatients,
    bool? telehealthEnabled,
    String? sortBy,
    String? sortOrder,
  }) {
    return DoctorSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      specialty: specialty ?? this.specialty,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      minFee: minFee ?? this.minFee,
      maxFee: maxFee ?? this.maxFee,
      languages: languages ?? this.languages,
      isAcceptingPatients: isAcceptingPatients ?? this.isAcceptingPatients,
      telehealthEnabled: telehealthEnabled ?? this.telehealthEnabled,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Create an empty filter
  factory DoctorSearchFilter.clear() {
    return DoctorSearchFilter();
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return specialty != null ||
        subSpecialty != null ||
        city != null ||
        state != null ||
        zipCode != null ||
        minFee != null ||
        maxFee != null ||
        (languages != null && languages!.isNotEmpty) ||
        isAcceptingPatients != null ||
        telehealthEnabled != null;
  }

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (specialty != null) count++;
    if (subSpecialty != null) count++;
    if (city != null) count++;
    if (state != null) count++;
    if (zipCode != null) count++;
    if (minFee != null || maxFee != null) count++;
    if (languages != null && languages!.isNotEmpty) count++;
    if (isAcceptingPatients != null) count++;
    if (telehealthEnabled != null) count++;
    return count;
  }
}

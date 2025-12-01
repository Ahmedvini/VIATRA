import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_search_filter.dart';
import '../../providers/doctor_search_provider.dart';
import '../../utils/constants.dart';

class DoctorSearchFilterSheet extends StatefulWidget {
  const DoctorSearchFilterSheet({super.key});

  @override
  State<DoctorSearchFilterSheet> createState() => _DoctorSearchFilterSheetState();
}

class _DoctorSearchFilterSheetState extends State<DoctorSearchFilterSheet> {
  late DoctorSearchFilter _localFilter;
  late RangeValues _priceRange;

  final List<String> _specialties = [
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Family Medicine',
    'Gastroenterology',
    'Internal Medicine',
    'Neurology',
    'Obstetrics and Gynecology',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Surgery',
    'Urology',
  ];

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Arabic',
    'Hindi',
    'Portuguese',
    'Russian',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<DoctorSearchProvider>();
    _localFilter = DoctorSearchFilter(
      specialty: provider.filter.specialty,
      subSpecialty: provider.filter.subSpecialty,
      city: provider.filter.city,
      state: provider.filter.state,
      zipCode: provider.filter.zipCode,
      minFee: provider.filter.minFee,
      maxFee: provider.filter.maxFee,
      languages: provider.filter.languages != null
          ? List<String>.from(provider.filter.languages!)
          : null,
      isAcceptingPatients: provider.filter.isAcceptingPatients,
      telehealthEnabled: provider.filter.telehealthEnabled,
      sortBy: provider.filter.sortBy,
      sortOrder: provider.filter.sortOrder,
    );
    
    _priceRange = RangeValues(
      _localFilter.minFee ?? DoctorSearchConstants.minConsultationFee,
      _localFilter.maxFee ?? DoctorSearchConstants.maxConsultationFee,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filter Doctors',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Specialty
                    _buildSectionHeader('Specialty', Icons.medical_services),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _localFilter.specialty,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select specialty',
                      ),
                      items: _specialties
                          .map((spec) => DropdownMenuItem(
                                value: spec,
                                child: Text(spec),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _localFilter = _localFilter.copyWith(specialty: value);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Location
                    _buildSectionHeader('Location', Icons.location_on),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'City',
                        hintText: 'Enter city',
                      ),
                      controller: TextEditingController(text: _localFilter.city),
                      onChanged: (value) {
                        _localFilter = _localFilter.copyWith(city: value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'State',
                        hintText: 'Enter state',
                      ),
                      controller: TextEditingController(text: _localFilter.state),
                      onChanged: (value) {
                        _localFilter = _localFilter.copyWith(state: value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Zip Code',
                        hintText: 'Enter zip code',
                      ),
                      controller: TextEditingController(text: _localFilter.zipCode),
                      onChanged: (value) {
                        _localFilter = _localFilter.copyWith(zipCode: value);
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Price Range
                    _buildSectionHeader('Consultation Fee', Icons.attach_money),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: DoctorSearchConstants.minConsultationFee,
                      max: DoctorSearchConstants.maxConsultationFee,
                      divisions: 50,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                          _localFilter = _localFilter.copyWith(
                            minFee: values.start,
                            maxFee: values.end,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Languages
                    _buildSectionHeader('Languages Spoken', Icons.language),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _languages.map((lang) {
                        final isSelected = _localFilter.languages?.contains(lang) ?? false;
                        return FilterChip(
                          label: Text(lang),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              final currentLangs = _localFilter.languages ?? [];
                              final newLangs = List<String>.from(currentLangs);
                              
                              if (selected) {
                                newLangs.add(lang);
                              } else {
                                newLangs.remove(lang);
                              }
                              
                              _localFilter = _localFilter.copyWith(
                                languages: newLangs.isEmpty ? null : newLangs,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Availability
                    _buildSectionHeader('Availability', Icons.check_circle_outline),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Accepting New Patients'),
                      subtitle: const Text('Only show doctors accepting patients'),
                      value: _localFilter.isAcceptingPatients ?? false,
                      onChanged: (value) {
                        setState(() {
                          _localFilter = _localFilter.copyWith(
                            isAcceptingPatients: value,
                          );
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Telehealth Available'),
                      subtitle: const Text('Only show doctors offering telehealth'),
                      value: _localFilter.telehealthEnabled ?? false,
                      onChanged: (value) {
                        setState(() {
                          _localFilter = _localFilter.copyWith(
                            telehealthEnabled: value,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: Text(
                          'Apply Filters${_localFilter.activeFilterCount > 0 ? ' (${_localFilter.activeFilterCount})' : ''}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );

  void _clearFilters() {
    setState(() {
      _localFilter = DoctorSearchFilter.clear();
      _priceRange = const RangeValues(0, 500);
    });
  }

  void _applyFilters() {
    context.read<DoctorSearchProvider>().updateFilter(_localFilter);
    Navigator.pop(context);
  }
}

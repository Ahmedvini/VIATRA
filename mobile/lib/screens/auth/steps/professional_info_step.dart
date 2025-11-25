import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_dropdown.dart';
import '../../../utils/constants.dart';
import '../../../models/doctor_model.dart';

class ProfessionalInfoStep extends StatefulWidget {
  const ProfessionalInfoStep({Key? key}) : super(key: key);

  @override
  State<ProfessionalInfoStep> createState() => _ProfessionalInfoStepState();
}

class _ProfessionalInfoStepState extends State<ProfessionalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  
  String? _selectedSpecialty;
  List<String> _selectedLanguages = [];
  
  final List<String> _availableLanguages = [
    'English',
    'Arabic',
    'French',
    'Spanish',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<RegistrationProvider>();
    final doctorData = provider.doctorData;
    
    if (doctorData != null) {
      _licenseNumberController.text = doctorData.licenseNumber ?? '';
      _selectedSpecialty = doctorData.specialty;
      _yearsOfExperienceController.text = doctorData.yearsOfExperience?.toString() ?? '';
      _selectedLanguages = doctorData.languages ?? [];
      _bioController.text = doctorData.bio ?? '';
      _clinicNameController.text = doctorData.clinicName ?? '';
      _clinicAddressController.text = doctorData.clinicAddress ?? '';
    }
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _bioController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialty')),
      );
      return;
    }

    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }

    final provider = context.read<RegistrationProvider>();
    
    // Update doctor data
    provider.updateDoctorData({
      'licenseNumber': _licenseNumberController.text.trim(),
      'specialty': _selectedSpecialty,
      'yearsOfExperience': int.tryParse(_yearsOfExperienceController.text.trim()) ?? 0,
      'languages': _selectedLanguages,
      'bio': _bioController.text.trim(),
      'clinicName': _clinicNameController.text.trim(),
      'clinicAddress': _clinicAddressController.text.trim(),
    });

    provider.nextStep();
  }

  void _back() {
    context.read<RegistrationProvider>().previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Professional Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your professional details',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // License Number
          CustomTextField(
            controller: _licenseNumberController,
            labelText: 'Medical License Number',
            hintText: 'Enter your license number',
            prefixIcon: Icons.badge,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'License number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Specialty
          CustomDropdown<String>(
            value: _selectedSpecialty,
            labelText: 'Specialty',
            hintText: 'Select your specialty',
            prefixIcon: Icons.local_hospital,
            isRequired: true,
            items: AppConstants.medicalSpecialties
                .map((specialty) => DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSpecialty = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Years of Experience
          CustomTextField(
            controller: _yearsOfExperienceController,
            labelText: 'Years of Experience',
            hintText: 'Enter years of experience',
            prefixIcon: Icons.work,
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Years of experience is required';
              }
              final years = int.tryParse(value.trim());
              if (years == null || years < 0) {
                return 'Please enter a valid number';
              }
              if (years > 70) {
                return 'Please enter a realistic number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Languages
          _buildLanguagesSelector(theme, colorScheme),
          const SizedBox(height: 16),

          // Bio
          CustomTextField(
            controller: _bioController,
            labelText: 'Professional Bio',
            hintText: 'Tell us about yourself and your experience',
            prefixIcon: Icons.description,
            maxLines: 5,
            maxLength: 500,
            validator: (value) {
              if (value != null && value.trim().length > 500) {
                return 'Bio must be 500 characters or less';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Clinic Name (Optional)
          CustomTextField(
            controller: _clinicNameController,
            labelText: 'Clinic/Hospital Name',
            hintText: 'Enter clinic or hospital name (optional)',
            prefixIcon: Icons.business,
          ),
          const SizedBox(height: 16),

          // Clinic Address (Optional)
          CustomTextField(
            controller: _clinicAddressController,
            labelText: 'Clinic/Hospital Address',
            hintText: 'Enter clinic or hospital address (optional)',
            prefixIcon: Icons.location_on,
            maxLines: 2,
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  onPressed: _back,
                  type: ButtonType.outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Continue',
                  onPressed: _continue,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Languages Spoken',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLanguages.map((language) {
            final isSelected = _selectedLanguages.contains(language);
            return FilterChip(
              label: Text(language),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(language);
                  } else {
                    _selectedLanguages.remove(language);
                  }
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
            );
          }).toList(),
        ),
        if (_selectedLanguages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one language',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}

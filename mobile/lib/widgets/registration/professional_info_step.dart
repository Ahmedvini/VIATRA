import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfessionalInfoStep extends StatefulWidget {

  const ProfessionalInfoStep({
    Key? key,
    required this.formData,
    required this.onDataChanged,
  }) : super(key: key);
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onDataChanged;

  @override
  State<ProfessionalInfoStep> createState() => _ProfessionalInfoStepState();
}

class _ProfessionalInfoStepState extends State<ProfessionalInfoStep> {
  final _licenseNumberController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _bioController = TextEditingController();
  
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _licenseNumberController.text = widget.formData['licenseNumber'] ?? '';
    _yearsOfExperienceController.text = 
        widget.formData['yearsOfExperience']?.toString() ?? '';
    _consultationFeeController.text = 
        widget.formData['consultationFee']?.toString() ?? '';
    _bioController.text = widget.formData['bio'] ?? '';
    _selectedSpecialty = widget.formData['specialty'];
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepProfessionalInfo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide your professional details',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // License Number
          TextFormField(
            key: const Key('registration_license_number_field'),
            controller: _licenseNumberController,
            decoration: InputDecoration(
              labelText: l10n.labelLicenseNumber,
              prefixIcon: const Icon(Icons.badge),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('licenseNumber', value),
          ),
          const SizedBox(height: 16),

          // Specialty
          DropdownButtonFormField<String>(
            key: const Key('registration_specialty_field'),
            value: _selectedSpecialty,
            decoration: InputDecoration(
              labelText: l10n.labelSpecialty,
              prefixIcon: const Icon(Icons.medical_services),
            ),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General Medicine')),
              DropdownMenuItem(value: 'cardiology', child: Text('Cardiology')),
              DropdownMenuItem(value: 'dermatology', child: Text('Dermatology')),
              DropdownMenuItem(value: 'neurology', child: Text('Neurology')),
              DropdownMenuItem(value: 'pediatrics', child: Text('Pediatrics')),
              DropdownMenuItem(value: 'psychiatry', child: Text('Psychiatry')),
              DropdownMenuItem(value: 'orthopedics', child: Text('Orthopedics')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              return null;
            },
            onChanged: (value) {
              setState(() => _selectedSpecialty = value);
              widget.onDataChanged('specialty', value);
            },
          ),
          const SizedBox(height: 16),

          // Years of Experience
          TextFormField(
            key: const Key('registration_experience_field'),
            controller: _yearsOfExperienceController,
            decoration: InputDecoration(
              labelText: l10n.labelYearsOfExperience,
              prefixIcon: const Icon(Icons.work),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              final years = int.tryParse(value);
              if (years == null || years < 0 || years > 60) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onChanged: (value) {
              final years = int.tryParse(value);
              if (years != null) {
                widget.onDataChanged('yearsOfExperience', years);
              }
            },
          ),
          const SizedBox(height: 16),

          // Consultation Fee
          TextFormField(
            key: const Key('registration_fee_field'),
            controller: _consultationFeeController,
            decoration: InputDecoration(
              labelText: l10n.labelConsultationFee,
              prefixIcon: const Icon(Icons.attach_money),
              suffix: const Text('EGP'),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              final fee = double.tryParse(value);
              if (fee == null || fee < 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onChanged: (value) {
              final fee = double.tryParse(value);
              if (fee != null) {
                widget.onDataChanged('consultationFee', fee);
              }
            },
          ),
          const SizedBox(height: 16),

          // Bio
          TextFormField(
            key: const Key('registration_bio_field'),
            controller: _bioController,
            decoration: InputDecoration(
              labelText: 'Bio',
              prefixIcon: const Icon(Icons.description),
              hintText: 'Tell us about yourself and your practice',
            ),
            maxLines: 4,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              if (value.length < 50) {
                return 'Please provide a bio of at least 50 characters';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('bio', value),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

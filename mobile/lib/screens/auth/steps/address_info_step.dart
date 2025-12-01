import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_dropdown.dart';
import '../../../widgets/common/custom_text_field.dart';

class AddressInfoStep extends StatefulWidget {
  const AddressInfoStep({super.key});

  @override
  State<AddressInfoStep> createState() => _AddressInfoStepState();
}

class _AddressInfoStepState extends State<AddressInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String? _selectedCountry;
  
  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Australia',
    'Brazil',
    'India',
    'China',
    'Japan',
    'South Africa',
    'Mexico',
    'Argentina',
    'Netherlands',
    'Sweden',
    'Norway',
    'Denmark',
    'Switzerland',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<RegistrationProvider>();
    final data = provider.formData;
    
    _streetAddressController.text = (data['streetAddress'] as String?) ?? '';
    _cityController.text = (data['city'] as String?) ?? '';
    _stateController.text = (data['state'] as String?) ?? '';
    _postalCodeController.text = (data['postalCode'] as String?) ?? '';
    _selectedCountry = data['country'] as String?;
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return;
    }

    final provider = context.read<RegistrationProvider>();
    
    // Update form data
    provider.updateMultipleFormData({
      'streetAddress': _streetAddressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'country': _selectedCountry,
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
            'Address Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your address details',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Street Address
          CustomTextField(
            controller: _streetAddressController,
            label: 'Street Address',
            hint: 'Enter your street address',
            prefixIcon: const Icon(Icons.home),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Street address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City
          CustomTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
            prefixIcon: const Icon(Icons.location_city),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'City is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // State/Province
          CustomTextField(
            controller: _stateController,
            label: 'State/Province',
            hint: 'Enter your state or province',
            prefixIcon: const Icon(Icons.map),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'State/Province is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Postal Code
          CustomTextField(
            controller: _postalCodeController,
            label: 'Postal/ZIP Code',
            hint: 'Enter your postal or ZIP code',
            prefixIcon: const Icon(Icons.markunread_mailbox),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Postal/ZIP code is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Country
          CustomDropdown<String>(
            value: _selectedCountry,
            label: 'Country',
            hint: 'Select your country',
            prefixIcon: const Icon(Icons.public),
            items: _countries
                .map((country) => DropdownItem<String>(
                      value: country,
                      text: country,
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Country is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  onPressed: _back,
                  variant: ButtonVariant.outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Continue',
                  onPressed: _continue,
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

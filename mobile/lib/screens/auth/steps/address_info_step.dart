import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_dropdown.dart';
import '../../../utils/validators.dart';

class AddressInfoStep extends StatefulWidget {
  const AddressInfoStep({Key? key}) : super(key: key);

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
    
    _streetAddressController.text = data['streetAddress'] ?? '';
    _cityController.text = data['city'] ?? '';
    _stateController.text = data['state'] ?? '';
    _postalCodeController.text = data['postalCode'] ?? '';
    _selectedCountry = data['country'];
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
    provider.updateFormData({
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
            labelText: 'Street Address',
            hintText: 'Enter your street address',
            prefixIcon: Icons.home,
            isRequired: true,
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
            labelText: 'City',
            hintText: 'Enter your city',
            prefixIcon: Icons.location_city,
            isRequired: true,
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
            labelText: 'State/Province',
            hintText: 'Enter your state or province',
            prefixIcon: Icons.map,
            isRequired: true,
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
            labelText: 'Postal/ZIP Code',
            hintText: 'Enter your postal or ZIP code',
            prefixIcon: Icons.markunread_mailbox,
            isRequired: true,
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
            labelText: 'Country',
            hintText: 'Select your country',
            prefixIcon: Icons.public,
            isRequired: true,
            items: _countries
                .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
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
}

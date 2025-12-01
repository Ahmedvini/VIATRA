import 'package:flutter/material.dart';

class AddressInfoStep extends StatefulWidget {

  const AddressInfoStep({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onDataChanged;

  @override
  State<AddressInfoStep> createState() => _AddressInfoStepState();
}

class _AddressInfoStepState extends State<AddressInfoStep> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = (widget.formData['address'] as String?) ?? '';
    _cityController.text = (widget.formData['city'] as String?) ?? '';
    _stateController.text = (widget.formData['state'] as String?) ?? '';
    _postalCodeController.text = (widget.formData['postalCode'] as String?) ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide your address information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Street Address
          TextFormField(
            key: const Key('registration_address_field'),
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('address', value),
          ),
          const SizedBox(height: 16),

          // City
          TextFormField(
            key: const Key('registration_city_field'),
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('city', value),
          ),
          const SizedBox(height: 16),

          // State/Governorate
          TextFormField(
            key: const Key('registration_state_field'),
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'State/Governorate',
              prefixIcon: Icon(Icons.map),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('state', value),
          ),
          const SizedBox(height: 16),

          // Postal Code
          TextFormField(
            key: const Key('registration_postal_code_field'),
            controller: _postalCodeController,
            decoration: const InputDecoration(
              labelText: 'Postal Code',
              prefixIcon: Icon(Icons.mail),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('postalCode', value),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

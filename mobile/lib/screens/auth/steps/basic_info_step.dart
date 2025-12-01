import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({super.key});

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    // Add listeners to update provider in real-time
    _firstNameController.addListener(_updateProvider);
    _lastNameController.addListener(_updateProvider);
    _emailController.addListener(_updateProvider);
    _phoneController.addListener(_updateProvider);
    _passwordController.addListener(_updateProvider);
    _confirmPasswordController.addListener(_updateProvider);
  }

  void _loadExistingData() {
    final provider = context.read<RegistrationProvider>();
    final data = provider.formData;

    _firstNameController.text = (data['firstName'] as String?) ?? '';
    _lastNameController.text = (data['lastName'] as String?) ?? '';
    _emailController.text = (data['email'] as String?) ?? '';
    _phoneController.text = (data['phone'] as String?) ?? '';
    _passwordController.text = (data['password'] as String?) ?? '';
    _confirmPasswordController.text =
        (data['confirmPassword'] as String?) ?? '';
    _dateOfBirth = data['dateOfBirth'] as DateTime?;
  }

  void _updateProvider() {
    final provider = context.read<RegistrationProvider>();
    provider.updateMultipleFormData({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'dateOfBirth': _dateOfBirth,
    });
  }

  @override
  void dispose() {
    // Remove listeners
    _firstNameController.removeListener(_updateProvider);
    _lastNameController.removeListener(_updateProvider);
    _emailController.removeListener(_updateProvider);
    _phoneController.removeListener(_updateProvider);
    _passwordController.removeListener(_updateProvider);
    _confirmPasswordController.removeListener(_updateProvider);
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - 25);
    final firstDate = DateTime(now.year - 120);
    final lastDate = DateTime(now.year - 13);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
    );

    if (date != null) {
      setState(() {
        _dateOfBirth = date;
      });
      _updateProvider(); // Update provider when date changes
    }
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    final provider = context.read<RegistrationProvider>();

    // Update form data
    provider.updateMultipleFormData({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'dateOfBirth': _dateOfBirth,
    });

    provider.nextStep();
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
            'Basic Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your basic information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // First Name and Last Name
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),

          // Phone
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            onTap: _selectDateOfBirth,
            child: IgnorePointer(
              child: CustomTextField(
                controller: TextEditingController(
                  text: _dateOfBirth != null
                      ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                      : '',
                ),
                label: 'Date of Birth',
                hint: 'Select your date of birth',
                prefixIcon: const Icon(Icons.calendar_today),
                validator: (value) {
                  if (_dateOfBirth == null) {
                    return 'Date of birth is required';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Continue Button
          CustomButton(
            text: 'Continue',
            onPressed: _continue,
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}

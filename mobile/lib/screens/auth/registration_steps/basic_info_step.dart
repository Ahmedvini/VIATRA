import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/registration_provider.dart';
import '../../../utils/validators.dart';
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    // Add listeners to password fields to trigger validation
    _passwordController.addListener(_saveData);
    _confirmPasswordController.addListener(_saveData);
  }

  void _loadSavedData() {
    final provider = context.read<RegistrationProvider>();
    final formData = provider.formData;

    _firstNameController.text = (formData['firstName'] as String?) ?? '';
    _lastNameController.text = (formData['lastName'] as String?) ?? '';
    _emailController.text = (formData['email'] as String?) ?? '';
    _passwordController.text = (formData['password'] as String?) ?? '';
    _confirmPasswordController.text = (formData['password'] as String?) ?? '';
    _phoneController.text = (formData['phone'] as String?) ?? '';
    _dateOfBirth = formData['dateOfBirth'] as DateTime?;
  }

  @override
  void dispose() {
    // Remove listeners
    _passwordController.removeListener(_saveData);
    _confirmPasswordController.removeListener(_saveData);
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveData() {
    // Always save data to provider, even if form validation fails
    // The provider will do its own validation for the Next button
    final provider = context.read<RegistrationProvider>();
    provider.updateMultipleFormData({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'phone': _phoneController.text.trim(),
      'dateOfBirth': _dateOfBirth,
    });
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        onChanged: _saveData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s get to know you',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please provide your basic information to create your account.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            // First Name
            CustomTextField(
              label: 'First Name',
              hint: 'Enter your first name',
              controller: _firstNameController,
              validator: (value) =>
                  Validators.validateName(value, fieldName: 'First name'),
              prefixIcon: const Icon(Icons.person_outline),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Last Name
            CustomTextField(
              label: 'Last Name',
              hint: 'Enter your last name',
              controller: _lastNameController,
              validator: (value) =>
                  Validators.validateName(value, fieldName: 'Last name'),
              prefixIcon: const Icon(Icons.person_outline),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Email
            EmailTextField(
              controller: _emailController,
              validator: Validators.validateEmail,
            ),

            const SizedBox(height: 16),

            // Phone
            PhoneTextField(
              controller: _phoneController,
              validator: Validators.validatePhone,
            ),

            const SizedBox(height: 16),

            // Date of Birth
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDateOfBirth,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select your date of birth',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _dateOfBirth != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_dateOfBirth == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      'Date of birth is required',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Password Section
            Text(
              'Create Password',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Password
            PasswordTextField(
              controller: _passwordController,
              validator: Validators.validatePassword,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Confirm Password
            PasswordTextField(
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              controller: _confirmPasswordController,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 24),

            // Password requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password must contain:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement('At least 8 characters'),
                  _buildPasswordRequirement('One uppercase letter'),
                  _buildPasswordRequirement('One lowercase letter'),
                  _buildPasswordRequirement('One number'),
                  _buildPasswordRequirement('One special character'),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

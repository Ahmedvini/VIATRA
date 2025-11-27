import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class BasicInfoStep extends StatefulWidget {

  const BasicInfoStep({
    Key? key,
    required this.formData,
    required this.onDataChanged,
  }) : super(key: key);
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onDataChanged;

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.formData['email'] ?? '';
    _passwordController.text = widget.formData['password'] ?? '';
    _confirmPasswordController.text = widget.formData['confirmPassword'] ?? '';
    _fullNameController.text = widget.formData['fullName'] ?? '';
    _phoneController.text = widget.formData['phone'] ?? '';
    _selectedDate = widget.formData['dateOfBirth'];
    _selectedGender = widget.formData['gender'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
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
            l10n.stepPersonalInfo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Full Name
          TextFormField(
            key: const Key('registration_full_name_field'),
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: l10n.labelFullName,
              prefixIcon: const Icon(Icons.person),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('fullName', value),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            key: const Key('registration_email_field'),
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.labelEmail,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              if (!value.contains('@')) {
                return l10n.errorInvalidEmail;
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('email', value),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            key: const Key('registration_phone_field'),
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.labelPhone,
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              if (value.length < 10) {
                return l10n.errorInvalidPhone;
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('phone', value),
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            key: const Key('registration_dob_field'),
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.labelDateOfBirth,
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : l10n.labelDateOfBirth,
                style: _selectedDate != null
                    ? theme.textTheme.bodyLarge
                    : theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            key: const Key('registration_gender_field'),
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: l10n.labelGender,
              prefixIcon: const Icon(Icons.wc),
            ),
            items: [
              DropdownMenuItem(value: 'male', child: Text(l10n.genderMale)),
              DropdownMenuItem(value: 'female', child: Text(l10n.genderFemale)),
              DropdownMenuItem(value: 'other', child: Text(l10n.genderOther)),
              DropdownMenuItem(
                  value: 'prefer_not_to_say',
                  child: Text(l10n.genderPreferNotToSay)),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              return null;
            },
            onChanged: (value) {
              setState(() => _selectedGender = value);
              widget.onDataChanged('gender', value);
            },
          ),
          const SizedBox(height: 24),

          // Password
          TextFormField(
            key: const Key('registration_password_field'),
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.labelPassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              if (value.length < 8) {
                return l10n.errorInvalidPassword;
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('password', value),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            key: const Key('registration_confirm_password_field'),
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: '${l10n.labelPassword} (Confirm)',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorRequiredField;
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onChanged: (value) => widget.onDataChanged('confirmPassword', value),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 25);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13), // Minimum age 13
      helpText: l10n.labelDateOfBirth,
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      widget.onDataChanged('dateOfBirth', pickedDate);
    }
  }
}

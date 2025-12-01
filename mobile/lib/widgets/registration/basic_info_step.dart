import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

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
    _emailController.text = (widget.formData['email'] as String?) ?? '';
    _passwordController.text = (widget.formData['password'] as String?) ?? '';
    _confirmPasswordController.text = (widget.formData['confirmPassword'] as String?) ?? '';
    _fullNameController.text = (widget.formData['fullName'] as String?) ?? '';
    _phoneController.text = (widget.formData['phone'] as String?) ?? '';
    _selectedDate = widget.formData['dateOfBirth'] as DateTime?;
    _selectedGender = widget.formData['gender'] as String?;
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your personal information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Full Name
          TextFormField(
            key: const Key('registration_full_name_field'),
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
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
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
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
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
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
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : 'Select date of birth',
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
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
              DropdownMenuItem(
                  value: 'prefer_not_to_say',
                  child: Text('Prefer not to say')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
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
              labelText: 'Password',
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
                return 'This field is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
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
              labelText: 'Confirm Password',
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
                return 'This field is required';
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
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 25);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13), // Minimum age 13
      helpText: 'Date of Birth',
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      widget.onDataChanged('dateOfBirth', pickedDate);
    }
  }
}

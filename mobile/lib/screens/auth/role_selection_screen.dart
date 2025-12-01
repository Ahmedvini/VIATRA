import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/common/custom_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                'Choose Your Role',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Select how you\'ll be using Viatra Health to get started with the right registration process.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'I am a Doctor',
                      subtitle: 'Provide medical consultations and manage patients',
                      icon: Icons.medical_services,
                      features: const [
                        'Create professional profile',
                        'Manage patient appointments',
                        'Conduct video consultations',
                        'Access medical records',
                      ],
                      role: UserRole.doctor,
                      color: colorScheme.primary,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _RoleCard(
                      title: 'I am a Patient',
                      subtitle: 'Find doctors and book appointments for healthcare',
                      icon: Icons.person,
                      features: const [
                        'Find and book doctors',
                        'Manage health records',
                        'Receive medical consultations',
                        'Track appointments',
                      ],
                      role: UserRole.patient,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: Text(
                      'Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {

  const _RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
    required this.role,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;
  final UserRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => GestureDetector(
          onTap: () => _selectRole(context, registrationProvider),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onSurface.withOpacity(0.4),
                      size: 16,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Features
                Text(
                  'What you can do:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 20),
                
                // Select button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Select ${role.name.toUpperCase()}',
                    onPressed: () => _selectRole(context, registrationProvider),
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _selectRole(BuildContext context, RegistrationProvider registrationProvider) {
    registrationProvider.selectRole(role);
    registrationProvider.nextStep();
    context.push('/auth/registration');
  }
}

// Alternative minimal role selection for quick setup
class MinimalRoleSelection extends StatelessWidget {

  const MinimalRoleSelection({
    super.key,
    this.onRoleSelected,
  });
  final void Function(UserRole role)? onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'I am a...',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onRoleSelected?.call(UserRole.doctor),
                icon: const Icon(Icons.medical_services),
                label: const Text('Doctor'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onRoleSelected?.call(UserRole.patient),
                icon: const Icon(Icons.person),
                label: const Text('Patient'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/registration/verification_status_card.dart';
import '../../widgets/common/custom_button.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({Key? key}) : super(key: key);

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    final provider = context.read<RegistrationProvider>();
    await provider.checkVerificationStatus();
  }

  Future<void> _refreshStatus() async {
    await _checkVerificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<RegistrationProvider>(
        builder: (context, registrationProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshStatus,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_user,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Account Verification',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Your registration has been submitted successfully. We\'re reviewing your documents.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Verification Status Card
                  VerificationStatusCard(
                    verifications: registrationProvider.verifications,
                    userRole: registrationProvider.selectedRole?.name ?? 'patient',
                    isLoading: registrationProvider.isLoading,
                    onRefresh: _refreshStatus,
                    onResubmit: (documentType) {
                      // Navigate back to document upload
                      context.push(
                        '/auth/registration',
                        extra: {'resubmitDocument': documentType},
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Information card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'What happens next?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildInfoItem(
                          context,
                          '1',
                          'Document Review',
                          'Our team will review your submitted documents within 1-2 business days.',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildInfoItem(
                          context,
                          '2',
                          'Email Notification',
                          'You\'ll receive an email once your account is verified or if we need additional information.',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildInfoItem(
                          context,
                          '3',
                          'Account Activation',
                          'Once approved, you\'ll have full access to all features based on your role.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Email verification reminder
                  if (registrationProvider.selectedRole != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verify your email',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please check your email and click the verification link.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend verification email button
                  TextCustomButton(
                    text: 'Resend Verification Email',
                    onPressed: () async {
                      try {
                        await registrationProvider.resendVerificationEmail();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification email sent!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    isLoading: registrationProvider.isLoading,
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedCustomButton(
                          text: 'Go to Dashboard',
                          onPressed: () {
                            context.go('/home');
                          },
                          size: ButtonSize.large,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Refresh Status',
                          onPressed: _refreshStatus,
                          isLoading: registrationProvider.isLoading,
                          size: ButtonSize.large,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

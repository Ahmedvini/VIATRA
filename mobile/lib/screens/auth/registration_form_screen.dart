import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/registration_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/registration/address_info_step.dart';
import '../../widgets/registration/basic_info_step.dart';
import '../../widgets/registration/document_upload_step.dart';
import '../../widgets/registration/professional_info_step.dart';
import '../../widgets/registration/verification_step.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          key: const Key('registration_app_bar'),
          title: const Text('Registration'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Consumer<RegistrationProvider>(
            builder: (context, registrationProvider, _) {
              if (registrationProvider.canGoBack) {
                return IconButton(
                  key: const Key('registration_back_button'),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // If currently on Basic Info (first step after role selection),
                    // navigate back to role selection screen
                    if (registrationProvider.currentStep ==
                        RegistrationStep.basicInfo) {
                      context.go('/auth/role-selection');
                    } else {
                      // Normal step navigation within the form
                      registrationProvider.previousStep();
                    }
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showExitConfirmation(context),
              );
            },
          ),
        ),
        body: Consumer<RegistrationProvider>(
          builder: (context, registrationProvider, _) {
            if (registrationProvider.isLoading) {
              return const LoadingWidget(
                message: 'Loading...',
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(context, registrationProvider),

                  // Error display
                  if (registrationProvider.error != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.all(16.0),
                      child: custom_error.ErrorDisplayWidget(
                        message: registrationProvider.error!,
                        onRetry: () => registrationProvider.clearError(),
                      ),
                    ),

                  // Step content
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: _buildStepContent(context, registrationProvider),
                    ),
                  ),

                  // Navigation buttons
                  _buildNavigationButtons(context, registrationProvider),
                ],
              ),
            );
          },
        ),
      );

  Widget _buildProgressIndicator(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalSteps = registrationProvider.totalSteps;
    final currentStepIndex = registrationProvider.currentStepIndex;
    final progress = (currentStepIndex + 1) / totalSteps;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStepTitle(registrationProvider.currentStep),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${currentStepIndex + 1}/$totalSteps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadiusDirectional.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) {
    switch (registrationProvider.currentStep) {
      case RegistrationStep.basicInfo:
        return BasicInfoStep(
          key: const Key('basic_info_step'),
          formData: registrationProvider.formData,
          onDataChanged: registrationProvider.updateFormData,
        );
      case RegistrationStep.professionalInfo:
        return ProfessionalInfoStep(
          key: const Key('professional_info_step'),
          formData: registrationProvider.formData,
          onDataChanged: registrationProvider.updateFormData,
        );
      case RegistrationStep.addressInfo:
        return AddressInfoStep(
          key: const Key('address_info_step'),
          formData: registrationProvider.formData,
          onDataChanged: registrationProvider.updateFormData,
        );
      case RegistrationStep.documentUpload:
        return DocumentUploadStep(
          key: const Key('document_upload_step'),
          userRole: registrationProvider.selectedRole!,
          documents: registrationProvider.documents,
          onDocumentAdded: registrationProvider.addDocument,
          onDocumentRemoved: registrationProvider.removeDocument,
        );
      case RegistrationStep.verification:
        return VerificationStep(
          key: const Key('verification_step'),
          userRole: registrationProvider.selectedRole!,
          verifications: registrationProvider.verifications,
          onRefresh: registrationProvider.checkVerificationStatus,
        );
      case RegistrationStep.complete:
        return _buildCompleteStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompleteStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your account has been successfully created.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              key: const Key('complete_go_home_button'),
              text: 'Go to Home',
              onPressed: () => context.go('/'),
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) {
    if (registrationProvider.currentStep == RegistrationStep.verification ||
        registrationProvider.currentStep == RegistrationStep.complete) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsetsDirectional.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (registrationProvider.canGoBack)
            Expanded(
              child: CustomButton(
                key: const Key('registration_back_button_bottom'),
                text: 'Back',
                onPressed: () => registrationProvider.previousStep(),
                variant: ButtonVariant.outlined,
                size: ButtonSize.large,
              ),
            ),
          if (registrationProvider.canGoBack) const SizedBox(width: 16),
          Expanded(
            flex: registrationProvider.canGoBack ? 1 : 2,
            child: CustomButton(
              key: const Key('registration_next_button'),
              text: _getNextButtonText(registrationProvider.currentStep),
              onPressed: registrationProvider.canGoNext
                  ? () => _handleNext(context, registrationProvider)
                  : null,
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              isDisabled: !registrationProvider.canGoNext,
              isLoading: registrationProvider.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return 'Personal Information';
      case RegistrationStep.professionalInfo:
        return 'Professional Information';
      case RegistrationStep.addressInfo:
        return 'Address';
      case RegistrationStep.documentUpload:
        return 'Documents';
      case RegistrationStep.verification:
        return 'Verification Pending';
      case RegistrationStep.complete:
        return 'Complete';
      default:
        return '';
    }
  }

  String _getNextButtonText(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.documentUpload:
        return 'Submit';
      default:
        return 'Next';
    }
  }

  Future<void> _handleNext(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) async {
    if (_formKey.currentState?.validate() ?? false) {
      await registrationProvider.nextStep();
    }
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text(
            'Are you sure you want to cancel registration? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.go('/auth/login');
    }
  }
}

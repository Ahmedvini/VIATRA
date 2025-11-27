import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
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
  const RegistrationFormScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        key: const Key('registration_app_bar'),
        title: Text(l10n.registrationTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Consumer<RegistrationProvider>(
          builder: (context, registrationProvider, _) {
            if (registrationProvider.canGoBack) {
              return IconButton(
                key: const Key('registration_back_button'),
                icon: const Icon(Icons.arrow_back),
                onPressed: () => registrationProvider.previousStep(),
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
            return LoadingWidget(
              message: l10n.loadingMessage,
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
                      error: registrationProvider.error!,
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
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    RegistrationProvider registrationProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
                _getStepTitle(l10n, registrationProvider.currentStep),
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
              backgroundColor: colorScheme.surfaceVariant,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.verificationCompleteMessage,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.buttonBackToHome,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              key: const Key('complete_go_home_button'),
              text: l10n.buttonBackToHome,
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
    final l10n = AppLocalizations.of(context)!;

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
              child: OutlinedCustomButton(
                key: const Key('registration_back_button_bottom'),
                text: l10n.buttonBack,
                onPressed: () => registrationProvider.previousStep(),
                size: ButtonSize.large,
              ),
            ),
          if (registrationProvider.canGoBack) const SizedBox(width: 16),
          Expanded(
            flex: registrationProvider.canGoBack ? 1 : 2,
            child: CustomButton(
              key: const Key('registration_next_button'),
              text: _getNextButtonText(l10n, registrationProvider.currentStep),
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

  String _getStepTitle(AppLocalizations l10n, RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return l10n.stepPersonalInfo;
      case RegistrationStep.professionalInfo:
        return l10n.stepProfessionalInfo;
      case RegistrationStep.addressInfo:
        return l10n.labelAddress;
      case RegistrationStep.documentUpload:
        return l10n.stepDocuments;
      case RegistrationStep.verification:
        return l10n.verificationPending;
      case RegistrationStep.complete:
        return l10n.verificationCompleteMessage;
      default:
        return '';
    }
  }

  String _getNextButtonText(AppLocalizations l10n, RegistrationStep step) {
    switch (step) {
      case RegistrationStep.documentUpload:
        return l10n.buttonSubmit;
      default:
        return l10n.buttonNext;
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
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.buttonCancel),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.buttonSubmit),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.go('/auth/login');
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/registration/document_upload_widget.dart';
import '../../../models/user_model.dart';

class DocumentUploadStep extends StatefulWidget {
  const DocumentUploadStep({super.key});

  @override
  State<DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends State<DocumentUploadStep> {
  Map<String, File> _selectedFiles = {};
  final Map<String, String> _errors = {};
  final Set<String> _uploadingDocuments = {};

  @override
  void initState() {
    super.initState();
    _loadExistingFiles();
  }

  void _loadExistingFiles() {
    final provider = context.read<RegistrationProvider>();
    setState(() {
      _selectedFiles = Map.from(provider.documents);
    });
  }

  List<DocumentUploadConfig> _getRequiredDocuments() {
    final provider = context.read<RegistrationProvider>();
    final userRole = provider.selectedRole;

    if (userRole == UserRole.doctor) {
      return [
        const DocumentUploadConfig(
          type: 'identity_document',
          title: 'Identity Document',
          description: 'Upload a government-issued ID (passport, driver\'s license, or national ID)',
          isRequired: true,
        ),
        const DocumentUploadConfig(
          type: 'medical_license',
          title: 'Medical License',
          description: 'Upload your valid medical license or certificate (optional)',
          isRequired: false,
        ),
        const DocumentUploadConfig(
          type: 'education_certificate',
          title: 'Education Certificate',
          description: 'Upload your medical degree or education certificate (optional)',
          isRequired: false,
        ),
        const DocumentUploadConfig(
          type: 'proof_of_address',
          title: 'Proof of Address',
          description: 'Upload a recent utility bill or bank statement (optional)',
          isRequired: false,
        ),
      ];
    } else {
      return [
        const DocumentUploadConfig(
          type: 'identity_document',
          title: 'Identity Document',
          description: 'Upload a government-issued ID (passport, driver\'s license, or national ID)',
          isRequired: true,
        ),
        const DocumentUploadConfig(
          type: 'insurance_card',
          title: 'Insurance Card',
          description: 'Upload your health insurance card (optional)',
          isRequired: false,
        ),
      ];
    }
  }

  Future<void> _handleFileSelected(String documentType, File file) async {
    setState(() {
      _selectedFiles[documentType] = file;
      _errors.remove(documentType);
      _uploadingDocuments.add(documentType);
    });

    final provider = context.read<RegistrationProvider>();
    
    try {
      provider.addDocument(documentType, file);
      
      setState(() {
        _uploadingDocuments.remove(documentType);
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getDocumentTitle(documentType)} uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _uploadingDocuments.remove(documentType);
        _errors[documentType] = e.toString();
        _selectedFiles.remove(documentType);
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload ${_getDocumentTitle(documentType)}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleFileRemoved(String documentType) {
    final provider = context.read<RegistrationProvider>();
    provider.removeDocument(documentType);
    setState(() {
      _selectedFiles.remove(documentType);
      _errors.remove(documentType);
    });
  }

  String _getDocumentTitle(String documentType) => _getRequiredDocuments()
        .firstWhere((doc) => doc.type == documentType)
        .title;

  bool _canContinue() {
    final requiredDocuments = _getRequiredDocuments()
        .where((doc) => doc.isRequired)
        .map((doc) => doc.type)
        .toList();
    
    return requiredDocuments.every((type) => _selectedFiles.containsKey(type)) &&
        _uploadingDocuments.isEmpty;
  }

  Future<void> _continue() async {
    if (!_canContinue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<RegistrationProvider>();
    
    try {
      // The actual registration submission happens in nextStep
      // which internally calls _submitRegistration
      await provider.nextStep();
      
      if (!mounted) return;
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit registration: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _back() {
    context.read<RegistrationProvider>().previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<RegistrationProvider>();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Document Upload',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please upload the required documents for verification',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Make sure documents are clear and readable. Supported formats: JPG, PNG, PDF. Max size: 10MB per file.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Document Upload Widgets
              BatchDocumentUpload(
                documents: _getRequiredDocuments(),
                selectedFiles: _selectedFiles,
                errors: _errors,
                loadingDocuments: _uploadingDocuments,
                onFileSelected: _handleFileSelected,
                onFileRemoved: _handleFileRemoved,
                enabled: !provider.isLoading,
              ),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [                  Expanded(
                  child: CustomButton(
                    text: 'Back',
                    onPressed: provider.isLoading ? null : _back,
                    variant: ButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: provider.isLoading ? 'Submitting...' : 'Submit Registration',
                    onPressed: provider.isLoading || !_canContinue()
                        ? null
                        : _continue,
                    variant: ButtonVariant.primary,
                    isLoading: provider.isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

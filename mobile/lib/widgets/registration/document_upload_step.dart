import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';

class DocumentUploadStep extends StatefulWidget {

  const DocumentUploadStep({
    Key? key,
    required this.userRole,
    required this.documents,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
  }) : super(key: key);
  final UserRole userRole;
  final Map<String, File> documents;
  final Function(String, File) onDocumentAdded;
  final Function(String) onDocumentRemoved;

  @override
  State<DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends State<DocumentUploadStep> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final requiredDocuments = DocumentTypes.getRequiredDocuments(
      widget.userRole == UserRole.doctor ? 'doctor' : 'patient',
    );

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepDocuments,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload required documents for verification',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          ...requiredDocuments.map((docType) {
            final docLabel = DocumentTypes.documentLabels[docType] ?? docType;
            final hasDocument = widget.documents.containsKey(docType);

            return _buildDocumentCard(
              context,
              theme,
              docType,
              docLabel,
              hasDocument,
            );
          }).toList(),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsetsDirectional.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadiusDirectional.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Make sure documents are clear and readable. Accepted formats: JPG, PNG, PDF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    ThemeData theme,
    String docType,
    String docLabel,
    bool hasDocument,
  ) => Container(
      key: Key('document_upload_$docType'),
      margin: const EdgeInsetsDirectional.only(bottom: 16.0),
      padding: const EdgeInsetsDirectional.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadiusDirectional.circular(12),
        border: Border.all(
          color: hasDocument
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: hasDocument ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDocumentIcon(docType),
                color: hasDocument
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasDocument)
                      Text(
                        'Document uploaded',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasDocument)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: Key('upload_button_$docType'),
                  onPressed: () => _pickDocument(docType, ImageSource.gallery),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(hasDocument ? 'Replace' : 'Upload'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDocument(docType, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (hasDocument) ...[
                const SizedBox(width: 8),
                IconButton(
                  key: Key('remove_button_$docType'),
                  onPressed: () => widget.onDocumentRemoved(docType),
                  icon: const Icon(Icons.delete),
                  color: theme.colorScheme.error,
                ),
              ],
            ],
          ),
        ],
      ),
    );

  Future<void> _pickDocument(String docType, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        widget.onDocumentAdded(docType, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'medical_license':
        return Icons.verified_user;
      case 'education_certificate':
        return Icons.school;
      case 'identity_document':
        return Icons.badge;
      case 'proof_of_address':
        return Icons.home;
      case 'insurance_card':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }
}

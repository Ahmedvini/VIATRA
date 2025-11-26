import 'package:flutter/material.dart';
import '../../models/verification_model.dart';
import '../../utils/constants.dart';

class VerificationStatusCard extends StatelessWidget {
  final List<Verification> verifica                  ),
                ],
                if (verification?.comments?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    verification!.comments!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],al String userRole;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final void Function(String documentType)? onResubmit;

  const VerificationStatusCard({
    Key? key,
    required this.verifications,
    required this.userRole,
    this.isLoading = false,
    this.onRefresh,
    this.onResubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final requiredDocuments = DocumentTypes.getRequiredDocuments(userRole);
    final overallStatus = _getOverallStatus(requiredDocuments);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Status',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(overallStatus),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh status',
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Overall status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(overallStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(overallStatus).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(overallStatus),
                    color: _getStatusColor(overallStatus),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(overallStatus),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _getStatusColor(overallStatus),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getDetailedStatusMessage(overallStatus, requiredDocuments),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Document verification details
            Text(
              'Document Verification Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            ...requiredDocuments.map((docType) {
              final verification = verifications
                  .where((v) => v.documentType == docType)
                  .firstOrNull;
              
              return _buildDocumentStatusTile(
                context,
                theme,
                colorScheme,
                docType,
                verification,
              );
            }).toList(),

            const SizedBox(height: 16),

            // Action buttons based on status
            if (overallStatus == VerificationStatus.rejected ||
                overallStatus == VerificationStatus.pending)
              _buildActionButtons(context, theme, colorScheme, overallStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStatusTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String documentType,
    Verification? verification,
  ) {
    final docLabel = DocumentTypes.documentLabels[documentType] ?? documentType;
    final status = verification?.status ?? VerificationStatus.notSubmitted;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getDocumentIcon(documentType),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (verification?.comments?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    verification!.comments!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status == VerificationStatus.rejected)
            IconButton(
              onPressed: () => onResubmit?.call(documentType),
              icon: Icon(
                Icons.refresh,
                color: colorScheme.primary,
              ),
              tooltip: 'Resubmit document',
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    VerificationStatus status,
  ) {
    if (status == VerificationStatus.rejected) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showResubmissionDialog(context),
          icon: const Icon(Icons.upload),
          label: const Text('Resubmit Rejected Documents'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: const Text('Check Status'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
    );
  }

  VerificationStatus _getOverallStatus(List<String> requiredDocuments) {
    if (verifications.isEmpty) {
      return VerificationStatus.notSubmitted;
    }

    bool hasRejected = false;
    bool hasPending = false;
    int approvedCount = 0;

    for (final docType in requiredDocuments) {
      final verification = verifications
          .where((v) => v.documentType == docType)
          .firstOrNull;

      if (verification == null) {
        return VerificationStatus.notSubmitted;
      }

      switch (verification.status) {
        case VerificationStatus.approved:
          approvedCount++;
          break;
        case VerificationStatus.rejected:
          hasRejected = true;
          break;
        case VerificationStatus.pending:
          hasPending = true;
          break;
        case VerificationStatus.notSubmitted:
          return VerificationStatus.notSubmitted;
      }
    }

    if (approvedCount == requiredDocuments.length) {
      return VerificationStatus.approved;
    } else if (hasRejected) {
      return VerificationStatus.rejected;
    } else if (hasPending) {
      return VerificationStatus.pending;
    }

    return VerificationStatus.notSubmitted;
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.notSubmitted:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.pending:
        return Icons.schedule;
      case VerificationStatus.notSubmitted:
        return Icons.upload;
    }
  }

  String _getStatusTitle(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'Verification Complete';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
      case VerificationStatus.pending:
        return 'Verification in Progress';
      case VerificationStatus.notSubmitted:
        return 'Documents Required';
    }
  }

  String _getStatusLabel(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
    }
  }

  String _getStatusDescription(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'Your account has been verified and is ready to use.';
      case VerificationStatus.rejected:
        return 'Some documents were rejected. Please resubmit.';
      case VerificationStatus.pending:
        return 'Your documents are being reviewed.';
      case VerificationStatus.notSubmitted:
        return 'Please upload required documents for verification.';
    }
  }

  String _getDetailedStatusMessage(
    VerificationStatus status,
    List<String> requiredDocuments,
  ) {
    switch (status) {
      case VerificationStatus.approved:
        return 'All documents have been approved. You can now access all features.';
      case VerificationStatus.rejected:
        final rejectedDocs = verifications
            .where((v) => v.status == VerificationStatus.rejected)
            .length;
        return '$rejectedDocs document(s) need to be resubmitted.';
      case VerificationStatus.pending:
        final pendingDocs = verifications
            .where((v) => v.status == VerificationStatus.pending)
            .length;
        return '$pendingDocs document(s) are being reviewed. This usually takes 1-2 business days.';
      case VerificationStatus.notSubmitted:
        return 'Please upload ${requiredDocuments.length} required document(s) to start verification.';
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

  void _showResubmissionDialog(BuildContext context) {
    final rejectedDocuments = verifications
        .where((v) => v.status == VerificationStatus.rejected)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resubmit Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following documents were rejected and need to be resubmitted:'),
            const SizedBox(height: 12),
            ...rejectedDocuments.map((verification) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DocumentTypes.documentLabels[verification.documentType] ?? 
                          verification.documentType,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to document upload screen
              // This would be handled by the parent widget
            },
            child: const Text('Resubmit'),
          ),
        ],
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

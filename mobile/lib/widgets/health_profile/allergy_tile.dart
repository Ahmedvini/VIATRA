import 'package:flutter/material.dart';

/// Widget for displaying an allergy in a tile format
class AllergyTile extends StatelessWidget {
  final Map<String, dynamic> allergy;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AllergyTile({
    super.key,
    required this.allergy,
    this.onTap,
    this.onDelete,
  });

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String? severity) {
    switch (severity) {
      case 'mild':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'severe':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allergen = allergy['allergen'] as String? ?? 'Unknown Allergen';
    final reaction = allergy['reaction'] as String?;
    final severity = allergy['severity'] as String? ?? 'mild';

    final severityColor = _getSeverityColor(severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.coronavirus,
            color: severityColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                allergen,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: severityColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSeverityIcon(severity),
                    size: 14,
                    color: severityColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    severity.substring(0, 1).toUpperCase() + severity.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: reaction != null && reaction.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.sick,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reaction,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(context, allergen);
                },
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String allergen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Allergy'),
        content: Text(
          'Are you sure you want to delete the allergy to "$allergen"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

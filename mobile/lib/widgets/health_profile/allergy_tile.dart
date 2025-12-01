import 'package:flutter/material.dart';
import '../../models/health_profile_model.dart';

/// Widget for displaying an allergy in a tile format
class AllergyTile extends StatelessWidget {

  const AllergyTile({
    required this.allergy, super.key,
    this.onTap,
    this.onDelete,
  });
  final Allergy allergy;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  Color _getSeverityColor() {
    switch (allergy.severity.toLowerCase()) {
      case 'life-threatening':
        return Colors.red.shade900;
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
      default:
        return Colors.green;
    }
  }

  IconData _getSeverityIcon() {
    switch (allergy.severity.toLowerCase()) {
      case 'life-threatening':
        return Icons.dangerous;
      case 'severe':
        return Icons.error;
      case 'moderate':
        return Icons.warning;
      case 'mild':
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();

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
                allergy.allergen,
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
                    _getSeverityIcon(),
                    size: 14,
                    color: severityColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    allergy.severity.toUpperCase(),
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
        subtitle: allergy.notes != null && allergy.notes!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.notes,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        allergy.notes!,
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
                  _showDeleteConfirmation(context);
                },
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Allergy'),
        content: Text(
          'Are you sure you want to delete the allergy to "${allergy.allergen}"?',
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

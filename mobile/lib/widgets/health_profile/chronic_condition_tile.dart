import 'package:flutter/material.dart';

/// Widget for displaying a chronic condition in a tile format
class ChronicConditionTile extends StatelessWidget {
  final Map<String, dynamic> condition;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ChronicConditionTile({
    super.key,
    required this.condition,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = condition['name'] as String? ?? 'Unknown Condition';
    final diagnosedYear = condition['diagnosedYear'] as int?;
    final notes = condition['notes'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medical_information,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (diagnosedYear != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Diagnosed: $diagnosedYear',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                notes,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
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
        title: const Text('Delete Condition'),
        content: Text(
          'Are you sure you want to delete "${condition['name']}"?',
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

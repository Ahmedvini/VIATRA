import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_profile_provider.dart';
import '../../utils/validators.dart';

/// Screen for adding or editing an allergy
class AllergyFormScreen extends StatefulWidget {

  const AllergyFormScreen({
    super.key,
    this.existingAllergy,
  });
  final Map<String, dynamic>? existingAllergy;

  @override
  State<AllergyFormScreen> createState() => _AllergyFormScreenState();
}

class _AllergyFormScreenState extends State<AllergyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergenController = TextEditingController();
  final _reactionController = TextEditingController();
  
  String _severity = 'mild';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAllergy != null) {
      _allergenController.text = widget.existingAllergy!['allergen'] ?? '';
      _reactionController.text = widget.existingAllergy!['reaction'] ?? '';
      _severity = widget.existingAllergy!['severity'] ?? 'mild';
    }
  }

  @override
  void dispose() {
    _allergenController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  Future<void> _saveAllergy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<HealthProfileProvider>();
      
      final allergyData = {
        'allergen': _allergenController.text.trim(),
        'reaction': _reactionController.text.trim(),
        'severity': _severity,
      };

      await provider.addAllergy(allergyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allergy saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save allergy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getSeverityColor(String severity) {
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

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'mild':
        return Icons.check_circle_outline;
      case 'moderate':
        return Icons.warning_amber;
      case 'severe':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAllergy == null 
              ? 'Add Allergy' 
              : 'Edit Allergy'
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAllergy,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Record any allergies to medications, foods, or substances.',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Allergen Name
            TextFormField(
              controller: _allergenController,
              decoration: const InputDecoration(
                labelText: 'Allergen *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.coronavirus),
                hintText: 'e.g., Penicillin, Peanuts, Latex',
              ),
              textCapitalization: TextCapitalization.words,
              validator: HealthProfileValidators.validateAllergen,
              autofocus: widget.existingAllergy == null,
            ),
            const SizedBox(height: 16),

            // Reaction
            TextFormField(
              controller: _reactionController,
              decoration: const InputDecoration(
                labelText: 'Reaction *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sick),
                hintText: 'e.g., Rash, Difficulty breathing, Swelling',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              validator: HealthProfileValidators.validateAllergyReaction,
            ),
            const SizedBox(height: 24),

            // Severity
            Text(
              'Severity *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            ...['mild', 'moderate', 'severe'].map((severity) {
              return RadioListTile<String>(
                value: severity,
                groupValue: _severity,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _severity = value);
                  }
                },
                title: Row(
                  children: [
                    Icon(
                      _getSeverityIcon(severity),
                      color: _getSeverityColor(severity),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      severity.substring(0, 1).toUpperCase() + severity.substring(1),
                      style: TextStyle(
                        color: _getSeverityColor(severity),
                        fontWeight: _severity == severity ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                secondary: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity),
                    shape: BoxShape.circle,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _severity == severity
                        ? _getSeverityColor(severity)
                        : Colors.grey.shade300,
                    width: _severity == severity ? 2 : 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
            
            const SizedBox(height: 24),

            // Severity info
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Severity Guide:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSeverityInfo('Mild', 'Minor discomfort, no medical attention needed'),
                    _buildSeverityInfo('Moderate', 'Requires medical attention or medication'),
                    _buildSeverityInfo('Severe', 'Life-threatening, requires immediate medical care'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveAllergy,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.existingAllergy == null ? 'Add Allergy' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            if (!_isLoading)
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );

  Widget _buildSeverityInfo(String title, String description) => Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_profile_provider.dart';
import '../../utils/validators.dart';

/// Screen for adding or editing a chronic condition
class ChronicConditionFormScreen extends StatefulWidget {
  final String? existingCondition;
  final int? conditionIndex;

  const ChronicConditionFormScreen({
    super.key,
    this.existingCondition,
    this.conditionIndex,
  });

  @override
  State<ChronicConditionFormScreen> createState() => _ChronicConditionFormScreenState();
}

class _ChronicConditionFormScreenState extends State<ChronicConditionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diagnosedYearController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCondition != null) {
      _nameController.text = widget.existingCondition!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosedYearController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCondition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<HealthProfileProvider>();
      
      final conditionData = {
        'name': _nameController.text.trim(),
        if (_diagnosedYearController.text.isNotEmpty)
          'diagnosedYear': int.parse(_diagnosedYearController.text),
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      await provider.addChronicCondition(conditionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chronic condition saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save condition: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCondition == null 
              ? 'Add Chronic Condition' 
              : 'Edit Chronic Condition'
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
              onPressed: _saveCondition,
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
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add any chronic or long-term health conditions you have been diagnosed with.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Condition Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Condition Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
                hintText: 'e.g., Diabetes Type 2, Hypertension',
              ),
              textCapitalization: TextCapitalization.words,
              validator: HealthProfileValidators.validateChronicConditionName,
              autofocus: widget.existingCondition == null,
            ),
            const SizedBox(height: 16),

            // Diagnosed Year
            TextFormField(
              controller: _diagnosedYearController,
              decoration: const InputDecoration(
                labelText: 'Year Diagnosed (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'e.g., 2020',
              ),
              keyboardType: TextInputType.number,
              validator: HealthProfileValidators.validateDiagnosedYear,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                hintText: 'Any additional information about this condition...',
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveCondition,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.existingCondition == null ? 'Add Condition' : 'Save Changes'),
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
  }
}

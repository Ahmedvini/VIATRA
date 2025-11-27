import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_profile_model.dart';
import '../../providers/health_profile_provider.dart';
import '../../utils/validators.dart';

/// Screen for editing the user's health profile
class HealthProfileEditScreen extends StatefulWidget {

  const HealthProfileEditScreen({
    super.key,
    this.profile,
  });
  final HealthProfile? profile;

  @override
  State<HealthProfileEditScreen> createState() => _HealthProfileEditScreenState();
}

class _HealthProfileEditScreenState extends State<HealthProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodGlucoseController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    if (widget.profile != null) {
      _bloodTypeController.text = widget.profile!.bloodType ?? '';
      _heightController.text = widget.profile!.height?.toString() ?? '';
      _weightController.text = widget.profile!.weight?.toString() ?? '';
      _bloodPressureSystolicController.text = 
          widget.profile!.bloodPressureSystolic?.toString() ?? '';
      _bloodPressureDiastolicController.text = 
          widget.profile!.bloodPressureDiastolic?.toString() ?? '';
      _heartRateController.text = widget.profile!.heartRate?.toString() ?? '';
      _bloodGlucoseController.text = widget.profile!.bloodGlucose?.toString() ?? '';
      _oxygenSaturationController.text = 
          widget.profile!.oxygenSaturation?.toString() ?? '';
      _medicationsController.text = widget.profile!.medications?.join(', ') ?? '';
      _notesController.text = widget.profile!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _heartRateController.dispose();
    _bloodGlucoseController.dispose();
    _oxygenSaturationController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<HealthProfileProvider>();
      
      final data = <String, dynamic>{};
      
      if (_bloodTypeController.text.isNotEmpty) {
        data['bloodType'] = _bloodTypeController.text;
      }
      if (_heightController.text.isNotEmpty) {
        data['height'] = double.parse(_heightController.text);
      }
      if (_weightController.text.isNotEmpty) {
        data['weight'] = double.parse(_weightController.text);
      }
      if (_bloodPressureSystolicController.text.isNotEmpty) {
        data['bloodPressureSystolic'] = int.parse(_bloodPressureSystolicController.text);
      }
      if (_bloodPressureDiastolicController.text.isNotEmpty) {
        data['bloodPressureDiastolic'] = int.parse(_bloodPressureDiastolicController.text);
      }
      if (_heartRateController.text.isNotEmpty) {
        data['heartRate'] = int.parse(_heartRateController.text);
      }
      if (_bloodGlucoseController.text.isNotEmpty) {
        data['bloodGlucose'] = double.parse(_bloodGlucoseController.text);
      }
      if (_oxygenSaturationController.text.isNotEmpty) {
        data['oxygenSaturation'] = double.parse(_oxygenSaturationController.text);
      }
      if (_medicationsController.text.isNotEmpty) {
        data['medications'] = _medicationsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (_notesController.text.isNotEmpty) {
        data['notes'] = _notesController.text;
      }

      if (widget.profile == null) {
        await provider.createProfile(data);
      } else {
        await provider.updateProfile(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Create Health Profile' : 'Edit Health Profile'),
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
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _bloodTypeController.text.isEmpty ? null : _bloodTypeController.text,
              decoration: const InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _bloodTypeController.text = value;
                }
              },
              validator: HealthProfileValidators.validateBloodType,
            ),
            const SizedBox(height: 16),

            // Vitals Section
            _buildSectionHeader('Vitals'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    validator: HealthProfileValidators.validateHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.number,
                    validator: HealthProfileValidators.validateWeight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Blood Pressure
            Text(
              'Blood Pressure (mmHg)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureSystolicController,
                    decoration: const InputDecoration(
                      labelText: 'Systolic',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: HealthProfileValidators.validateBloodPressureSystolic,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureDiastolicController,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: HealthProfileValidators.validateBloodPressureDiastolic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _heartRateController,
              decoration: const InputDecoration(
                labelText: 'Heart Rate (bpm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite),
              ),
              keyboardType: TextInputType.number,
              validator: HealthProfileValidators.validateHeartRate,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bloodGlucoseController,
              decoration: const InputDecoration(
                labelText: 'Blood Glucose (mg/dL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop),
              ),
              keyboardType: TextInputType.number,
              validator: HealthProfileValidators.validateBloodGlucose,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _oxygenSaturationController,
              decoration: const InputDecoration(
                labelText: 'Oxygen Saturation (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.air),
              ),
              keyboardType: TextInputType.number,
              validator: HealthProfileValidators.validateOxygenSaturation,
            ),
            const SizedBox(height: 24),

            // Medications Section
            _buildSectionHeader('Medications'),
            const SizedBox(height: 8),
            Text(
              'Enter medications separated by commas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(
                labelText: 'Medications',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
                hintText: 'e.g., Aspirin, Metformin',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Additional Notes'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Any additional health information...',
              ),
              maxLines: 4,
              validator: HealthProfileValidators.validateNotes,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );

  Widget _buildSectionHeader(String title) => Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
}

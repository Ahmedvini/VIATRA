# Health Profile Flutter Quick Reference

## Model Classes

### HealthProfile
```dart
class HealthProfile {
  final String id;
  final String patientId;
  final String? bloodType;
  final double? height;
  final double? weight;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final double? bloodGlucose;
  final int? oxygenSaturation;
  final List<Allergy> allergies;
  final List<ChronicCondition> chronicConditions;
  final List<Medication> currentMedications;
  final List<String> familyHistory;
  final Lifestyle? lifestyle;
  final EmergencyContact? emergencyContact;
  final String? preferredPharmacy;
  final Insurance? insurance;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### ChronicCondition
```dart
class ChronicCondition {
  final String id;
  final String name;
  final DateTime? diagnosedDate;
  final String severity; // 'mild', 'moderate', 'severe'
  final List<String> medications;
  final String? notes;
}
```

### Allergy
```dart
class Allergy {
  final String allergen;
  final String severity; // 'mild', 'moderate', 'severe', 'life-threatening'
  final String? notes;
  final DateTime dateAdded;
}
```

### Medication
```dart
class Medication {
  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribedBy;
}
```

---

## Provider Usage

### Get Health Profile
```dart
final provider = context.watch<HealthProfileProvider>();
final profile = provider.healthProfile;

if (profile != null) {
  print('BMI: ${profile.calculateBMI()}');
  print('Category: ${profile.getBMICategory()}');
}
```

### Load Profile
```dart
final provider = context.read<HealthProfileProvider>();
await provider.loadHealthProfile(forceRefresh: true);
```

### Create Profile
```dart
final profile = HealthProfile(
  id: '', // Will be generated
  patientId: currentPatientId,
  bloodType: 'A+',
  height: 175.0,
  weight: 70.0,
  allergies: [],
  chronicConditions: [],
  currentMedications: [],
  familyHistory: [],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await provider.createHealthProfile(profile);
```

### Update Profile
```dart
final updated = profile.copyWith(
  weight: 72.0,
  bloodPressureSystolic: 120,
  bloodPressureDiastolic: 80,
);

await provider.updateHealthProfile(updated);
```

### Add Chronic Condition
```dart
final condition = ChronicCondition(
  name: 'Type 2 Diabetes',
  diagnosedDate: DateTime(2023, 1, 15),
  severity: 'moderate',
  medications: ['Metformin 500mg'],
  notes: 'Monitor blood sugar regularly',
);

await provider.addChronicCondition(condition);
```

### Remove Chronic Condition
```dart
await provider.removeChronicCondition(conditionId);
```

### Add Allergy
```dart
final allergy = Allergy(
  allergen: 'Penicillin',
  severity: 'severe',
  notes: 'Causes anaphylaxis',
);

await provider.addAllergy(allergy);
```

### Remove Allergy
```dart
await provider.removeAllergy(allergen);
```

---

## Widget Usage

### ChronicConditionTile
```dart
import 'package:viatra/widgets/health_profile/chronic_condition_tile.dart';

ChronicConditionTile(
  condition: chronicCondition, // ChronicCondition object
  onTap: () {
    // Navigate to details
  },
  onDelete: () {
    // Delete condition
    provider.removeChronicCondition(condition.id);
  },
)
```

**Features:**
- Severity-based color coding
- Severity badge
- Diagnosed date display
- Medications list
- Notes display
- Delete confirmation dialog

### AllergyTile
```dart
import 'package:viatra/widgets/health_profile/allergy_tile.dart';

AllergyTile(
  allergy: allergy, // Allergy object
  onTap: () {
    // Navigate to details
  },
  onDelete: () {
    // Delete allergy
    provider.removeAllergy(allergy.allergen);
  },
)
```

**Features:**
- Severity-based color coding and icons
- Severity badge
- Notes display
- Delete confirmation dialog

---

## Screen Templates

### List Chronic Conditions
```dart
Widget _buildConditionsList() {
  final provider = context.watch<HealthProfileProvider>();
  final profile = provider.healthProfile;

  if (profile == null || profile.chronicConditions.isEmpty) {
    return Center(child: Text('No chronic conditions'));
  }

  return ListView.builder(
    itemCount: profile.chronicConditions.length,
    itemBuilder: (context, index) {
      final condition = profile.chronicConditions[index];
      return ChronicConditionTile(
        condition: condition,
        onTap: () => _viewDetails(condition),
        onDelete: () => _deleteCondition(condition.id),
      );
    },
  );
}
```

### List Allergies
```dart
Widget _buildAllergiesList() {
  final provider = context.watch<HealthProfileProvider>();
  final profile = provider.healthProfile;

  if (profile == null || profile.allergies.isEmpty) {
    return Center(child: Text('No allergies'));
  }

  return ListView.builder(
    itemCount: profile.allergies.length,
    itemBuilder: (context, index) {
      final allergy = profile.allergies[index];
      return AllergyTile(
        allergy: allergy,
        onTap: () => _viewDetails(allergy),
        onDelete: () => _deleteAllergy(allergy.allergen),
      );
    },
  );
}
```

### Display Medications
```dart
Widget _buildMedicationsList() {
  final medications = profile.currentMedications;

  return ListView.builder(
    itemCount: medications.length,
    itemBuilder: (context, index) {
      final med = medications[index];
      return ListTile(
        leading: Icon(Icons.medication),
        title: Text(med.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (med.dosage != null) Text('Dosage: ${med.dosage}'),
            if (med.frequency != null) Text('Frequency: ${med.frequency}'),
          ],
        ),
      );
    },
  );
}
```

### Display Vitals
```dart
Widget _buildVitalsCard() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vitals', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16),
          if (profile.height != null)
            _buildVitalRow('Height', '${profile.height} cm'),
          if (profile.weight != null)
            _buildVitalRow('Weight', '${profile.weight} kg'),
          if (profile.bloodPressureSystolic != null)
            _buildVitalRow('Blood Pressure', 
              '${profile.bloodPressureSystolic}/${profile.bloodPressureDiastolic} mmHg'),
          if (profile.heartRate != null)
            _buildVitalRow('Heart Rate', '${profile.heartRate} bpm'),
          if (profile.bloodGlucose != null)
            _buildVitalRow('Blood Glucose', '${profile.bloodGlucose} mg/dL'),
          if (profile.oxygenSaturation != null)
            _buildVitalRow('O₂ Saturation', '${profile.oxygenSaturation}%'),
        ],
      ),
    ),
  );
}

Widget _buildVitalRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
```

### Display Emergency Contact
```dart
Widget _buildEmergencyContact() {
  final contact = profile.emergencyContact;

  if (contact == null || contact.name == null) {
    return Text('No emergency contact set');
  }

  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.shade100,
        child: Icon(Icons.emergency, color: Colors.red),
      ),
      title: Text(contact.name!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.phone != null) Text('📞 ${contact.phone}'),
          if (contact.relationship != null) 
            Text('Relationship: ${contact.relationship}'),
        ],
      ),
    ),
  );
}
```

---

## Form Examples

### Add Chronic Condition Form
```dart
class ChronicConditionFormScreen extends StatefulWidget {
  @override
  State<ChronicConditionFormScreen> createState() => 
    _ChronicConditionFormScreenState();
}

class _ChronicConditionFormScreenState 
    extends State<ChronicConditionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedSeverity = 'mild';
  List<String> _medications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Chronic Condition')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Condition Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a condition name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: InputDecoration(labelText: 'Severity'),
              items: ['mild', 'moderate', 'severe']
                  .map((severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedSeverity = value!);
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Diagnosed Date'),
              subtitle: Text(_selectedDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCondition,
              child: Text('Save Condition'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCondition() async {
    if (!_formKey.currentState!.validate()) return;

    final condition = ChronicCondition(
      name: _nameController.text.trim(),
      diagnosedDate: _selectedDate,
      severity: _selectedSeverity,
      medications: _medications,
      notes: _notesController.text.trim(),
    );

    final provider = context.read<HealthProfileProvider>();
    await provider.addChronicCondition(condition);

    if (mounted) Navigator.pop(context);
  }
}
```

### Add Allergy Form
```dart
class AllergyFormScreen extends StatefulWidget {
  @override
  State<AllergyFormScreen> createState() => _AllergyFormScreenState();
}

class _AllergyFormScreenState extends State<AllergyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergenController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSeverity = 'mild';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Allergy')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _allergenController,
              decoration: InputDecoration(labelText: 'Allergen'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an allergen';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: InputDecoration(labelText: 'Severity'),
              items: ['mild', 'moderate', 'severe', 'life-threatening']
                  .map((severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedSeverity = value!);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAllergy,
              child: Text('Save Allergy'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllergy() async {
    if (!_formKey.currentState!.validate()) return;

    final allergy = Allergy(
      allergen: _allergenController.text.trim(),
      severity: _selectedSeverity,
      notes: _notesController.text.trim(),
    );

    final provider = context.read<HealthProfileProvider>();
    await provider.addAllergy(allergy);

    if (mounted) Navigator.pop(context);
  }
}
```

---

## Constants

### Blood Types
```dart
const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
```

### Severity Levels (Condition)
```dart
const conditionSeverities = ['mild', 'moderate', 'severe'];
```

### Severity Levels (Allergy)
```dart
const allergySeverities = ['mild', 'moderate', 'severe', 'life-threatening'];
```

### Lifestyle Options
```dart
const smokingOptions = ['never', 'former', 'current', 'occasional'];
const alcoholOptions = ['never', 'occasional', 'moderate', 'heavy'];
const exerciseOptions = ['sedentary', 'light', 'moderate', 'active', 'very-active'];
const dietOptions = ['omnivore', 'vegetarian', 'vegan', 'pescatarian', 'other'];
```

---

## Helper Methods

### Calculate BMI
```dart
final bmi = profile.calculateBMI(); // double?
if (bmi != null) {
  print('BMI: ${bmi.toStringAsFixed(1)}');
}
```

### Get BMI Category
```dart
final category = profile.getBMICategory(); // 'Underweight', 'Normal', 'Overweight', 'Obese', 'Unknown'
```

### Check Allergy
```dart
final hasPenicillinAllergy = profile.hasAllergy('penicillin'); // bool
```

### Check Chronic Condition
```dart
final hasDiabetes = profile.hasChronicCondition('diabetes'); // bool
```

---

## State Management

### Loading States
```dart
final provider = context.watch<HealthProfileProvider>();

if (provider.isLoading) {
  return CircularProgressIndicator();
}

if (provider.state == HealthProfileState.error) {
  return Text('Error: ${provider.errorMessage}');
}

if (!provider.hasProfile) {
  return Text('No profile found');
}

// Display profile
final profile = provider.healthProfile!;
```

### Provider States
```dart
enum HealthProfileState {
  initial,  // Not loaded yet
  loading,  // Fetching data
  loaded,   // Data available
  error,    // Error occurred
}
```

---

**Last Updated:** November 26, 2025  
**Version:** 1.0.0  
**Status:** Production Ready

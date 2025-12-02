import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/food_tracking/food_log.dart';
import '../../services/food_tracking_service.dart';
import '../../services/api_service.dart';

/// Manual food entry screen - allows users to manually input nutrition data
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _foodNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingsCountController = TextEditingController(text: '1.0');
  
  // Form values
  MealType _selectedMealType = MealType.lunch;
  DateTime _consumedAt = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _servingSizeController.dispose();
    _servingsCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _consumedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_consumedAt),
      );

      if (time != null && mounted) {
        setState(() {
          _consumedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveFoodLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get API service with authentication
      final apiService = context.read<ApiService>();
      final foodTrackingService = FoodTrackingService(apiService);

      // Create food log via API
      final foodLog = await foodTrackingService.createFoodLog(
        mealType: _selectedMealType.value,
        foodName: _foodNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        calories: _parseDouble(_caloriesController.text),
        proteinGrams: _parseDouble(_proteinController.text),
        carbsGrams: _parseDouble(_carbsController.text),
        fatGrams: _parseDouble(_fatController.text),
        fiberGrams: _parseDouble(_fiberController.text),
        sugarGrams: _parseDouble(_sugarController.text),
        sodiumMg: _parseDouble(_sodiumController.text),
        servingSize: _servingSizeController.text.trim().isEmpty
            ? null
            : _servingSizeController.text.trim(),
        servingsCount: double.tryParse(_servingsCountController.text) ?? 1.0,
        consumedAt: _consumedAt,
      );

      if (mounted) {
        if (foodLog != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food log saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to main screen
          context.go('/food-tracking');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save food log. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving food log: $e'),
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

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Food name
              _buildTextField(
                controller: _foodNameController,
                label: 'Food Name',
                hint: 'e.g., Grilled Chicken Breast',
                icon: Icons.restaurant,
                required: true,
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add notes about preparation, brand, etc.',
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Meal type and date
              _buildMealTypeAndDate(),
              const SizedBox(height: 24),

              // Nutrition section header
              _buildSectionHeader('Nutrition Information', Icons.analytics),
              const SizedBox(height: 16),

              // Macros - Calories
              _buildNumberField(
                controller: _caloriesController,
                label: 'Calories',
                hint: '0',
                suffix: 'kcal',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Protein, Carbs, Fat - in a row
              _buildMacroRow(),
              const SizedBox(height: 24),

              // Additional nutrition section
              _buildSectionHeader('Additional Details (Optional)', Icons.add_circle_outline),
              const SizedBox(height: 16),

              // Fiber and Sugar
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      controller: _fiberController,
                      label: 'Fiber',
                      hint: '0',
                      suffix: 'g',
                      icon: Icons.grain,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      controller: _sugarController,
                      label: 'Sugar',
                      hint: '0',
                      suffix: 'g',
                      icon: Icons.cookie,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sodium
              _buildNumberField(
                controller: _sodiumController,
                label: 'Sodium',
                hint: '0',
                suffix: 'mg',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              // Serving info section
              _buildSectionHeader('Serving Information', Icons.room_service),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _servingSizeController,
                      label: 'Serving Size',
                      hint: 'e.g., 1 cup, 100g',
                      icon: Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      controller: _servingsCountController,
                      label: 'Count',
                      hint: '1',
                      suffix: '',
                      icon: Icons.numbers,
                      color: Colors.teal,
                      decimals: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log Your Meal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the nutritional information for your meal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
    required Color color,
    bool decimals = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimals),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimals ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: color),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: color.withOpacity(0.05),
      ),
    );
  }

  Widget _buildMealTypeAndDate() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal type
            Text(
              'Meal Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMealType = type);
                    }
                  },
                  selectedColor: Colors.blue.withOpacity(0.3),
                  avatar: Text(type.emoji),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            
            // Date and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When did you eat this?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(_consumedAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _selectDateTime,
                  icon: const Icon(Icons.calendar_today),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(
            controller: _proteinController,
            label: 'Protein',
            hint: '0',
            suffix: 'g',
            icon: Icons.fitness_center,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberField(
            controller: _carbsController,
            label: 'Carbs',
            hint: '0',
            suffix: 'g',
            icon: Icons.cake,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberField(
            controller: _fatController,
            label: 'Fat',
            hint: '0',
            suffix: 'g',
            icon: Icons.opacity,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveFoodLog,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Save Food Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}

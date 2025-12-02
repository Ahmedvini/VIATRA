import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/food_tracking/food_log.dart';
import '../../services/food_tracking_service.dart';
import '../../services/api_service.dart';

/// AI Photo Analysis screen - allows users to take/select photos for AI food analysis
class AiPhotoAnalysisScreen extends StatefulWidget {
  const AiPhotoAnalysisScreen({super.key});

  @override
  State<AiPhotoAnalysisScreen> createState() => _AiPhotoAnalysisScreenState();
}

class _AiPhotoAnalysisScreenState extends State<AiPhotoAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  // Form controllers
  final _contextController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingsCountController = TextEditingController(text: '1.0');
  
  // State
  File? _selectedImage;
  MealType _selectedMealType = MealType.lunch;
  DateTime _consumedAt = DateTime.now();
  bool _isAnalyzing = false;
  bool _isAnalyzed = false;
  bool _isSaving = false;
  double? _aiConfidence;
  String? _aiRawResponse;

  @override
  void dispose() {
    _contextController.dispose();
    _foodNameController.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isAnalyzed = false; // Reset analysis state when new image is selected
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from existing photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Get API service with authentication
      final apiService = context.read<ApiService>();
      final foodTrackingService = FoodTrackingService(apiService);

      // Analyze image with Gemini AI via backend
      final foodLog = await foodTrackingService.analyzeFoodImage(
        imageFile: _selectedImage!,
        mealType: _selectedMealType.value,
        servingsCount: double.tryParse(_servingsCountController.text) ?? 1.0,
        consumedAt: _consumedAt,
      );

      if (foodLog != null && mounted) {
        // Populate form with AI results
        setState(() {
          _foodNameController.text = foodLog.foodName;
          _caloriesController.text = foodLog.calories.toString();
          _proteinController.text = foodLog.proteinGrams.toString();
          _carbsController.text = foodLog.carbsGrams.toString();
          _fatController.text = foodLog.fatGrams.toString();
          _fiberController.text = (foodLog.fiberGrams ?? 0).toString();
          _sugarController.text = (foodLog.sugarGrams ?? 0).toString();
          _sodiumController.text = (foodLog.sodiumMg ?? 0).toString();
          _servingSizeController.text = foodLog.servingSize ?? '';
          _servingsCountController.text = foodLog.servingsCount.toString();
          _aiConfidence = foodLog.aiConfidence;
          _aiRawResponse = foodLog.aiAnalysis?.toString();
          _isAnalyzed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ AI analysis complete and saved! Review if needed.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back after successful analysis and save
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/food-tracking');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to analyze image. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _saveFoodLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Note: The AI analysis already saves the food log.
    // This method is for manual edits after analysis.
    // For now, we'll just navigate back.
    if (_isAnalyzed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food log already saved via AI analysis!'),
            backgroundColor: Colors.blue,
          ),
        );
        context.go('/food-tracking');
      }
    } else {
      // If not analyzed yet, trigger analysis
      await _analyzeImage();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Analysis'),
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

              // Image selection/preview
              _buildImageSection(),
              const SizedBox(height: 24),

              // Context input (before analysis)
              if (!_isAnalyzed) ...[
                _buildContextInput(),
                const SizedBox(height: 24),
              ],

              // Analyze button
              if (!_isAnalyzed) _buildAnalyzeButton(),

              // AI confidence badge
              if (_isAnalyzed && _aiConfidence != null) ...[
                _buildConfidenceBadge(),
                const SizedBox(height: 24),
              ],

              // Results (after analysis)
              if (_isAnalyzed) ...[
                _buildResultsSection(),
                const SizedBox(height: 24),
              ],

              // Save button (after analysis)
              if (_isAnalyzed) _buildSaveButton(),
              
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-Powered Analysis',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Take or select a photo of your food',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.05),
              Colors.blue.withOpacity(0.05),
            ],
          ),
        ),
        child: _selectedImage == null
            ? _buildImagePlaceholder()
            : _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to add food photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Camera or Gallery',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay with change button
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.change_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Change',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Context (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contextController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., "Homemade pasta with tomato sauce" or "McDonald\'s Big Mac"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Providing context helps AI make more accurate predictions',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _isAnalyzing ? null : _analyzeImage,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.purple,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isAnalyzing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analyzing with AI...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Analyze with AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildConfidenceBadge() {
    final confidencePercent = (_aiConfidence! * 100).toInt();
    final color = confidencePercent >= 80
        ? Colors.green
        : confidencePercent >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Confidence: $confidencePercent%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                if (_aiRawResponse != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _aiRawResponse!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              'Review & Edit Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Verify the AI results and make any necessary adjustments',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),

        // Meal type and date
        _buildMealTypeAndDate(),
        const SizedBox(height: 16),

        // Food name
        _buildTextField(
          controller: _foodNameController,
          label: 'Food Name',
          icon: Icons.restaurant,
          required: true,
        ),
        const SizedBox(height: 16),

        // Macros
        _buildNumberField(
          controller: _caloriesController,
          label: 'Calories',
          suffix: 'kcal',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _proteinController,
                label: 'Protein',
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
                suffix: 'g',
                icon: Icons.cake,
                color: Colors.amber,
              ),
            ),
            Expanded(
              child: _buildNumberField(
                controller: _fatController,
                label: 'Fat',
                suffix: 'g',
                icon: Icons.opacity,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Additional nutrition in expandable section
        ExpansionTile(
          title: const Text('Additional Details'),
          leading: const Icon(Icons.add_circle_outline),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          controller: _fiberController,
                          label: 'Fiber',
                          suffix: 'g',
                          icon: Icons.grain,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          controller: _sugarController,
                          label: 'Sugar',
                          suffix: 'g',
                          icon: Icons.cookie,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    controller: _sodiumController,
                    label: 'Sodium',
                    suffix: 'mg',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _servingSizeController,
                          label: 'Serving Size',
                          icon: Icons.straighten,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          controller: _servingsCountController,
                          label: 'Count',
                          suffix: '',
                          icon: Icons.numbers,
                          color: Colors.teal,
                          decimals: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
        prefixIcon: Icon(icon, color: color, size: 20),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: color.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildMealTypeAndDate() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveFoodLog,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.green,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Save Food Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

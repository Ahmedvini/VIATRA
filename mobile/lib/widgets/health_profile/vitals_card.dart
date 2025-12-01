import 'package:flutter/material.dart';
import '../../models/health_profile_model.dart';

class VitalsCard extends StatelessWidget {

  const VitalsCard({
    super.key,
    required this.healthProfile,
  });
  final HealthProfile healthProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bmi = healthProfile.calculateBMI();
    final bmiCategory = healthProfile.getBMICategory();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Vitals',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVitalItem(
                    context,
                    icon: Icons.height,
                    label: 'Height',
                    value: healthProfile.height != null
                        ? '${healthProfile.height!.toStringAsFixed(1)} cm'
                        : 'Not set',
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVitalItem(
                    context,
                    icon: Icons.monitor_weight,
                    label: 'Weight',
                    value: healthProfile.weight != null
                        ? '${healthProfile.weight!.toStringAsFixed(1)} kg'
                        : 'Not set',
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (bmi != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBMIColor(bmiCategory, colorScheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getBMIColor(bmiCategory, colorScheme).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: _getBMIColor(bmiCategory, colorScheme),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BMI',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            bmi.toStringAsFixed(1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        bmiCategory,
                        style: TextStyle(
                          color: _getBMIColor(bmiCategory, colorScheme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          _getBMIColor(bmiCategory, colorScheme).withOpacity(0.2),
                      side: BorderSide(
                        color: _getBMIColor(bmiCategory, colorScheme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'Normal':
        return Colors.green;
      case 'Underweight':
        return Colors.blue;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return colorScheme.onSurface;
    }
  }
}

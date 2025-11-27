import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/health_profile_provider.dart';
import '../../models/health_profile_model.dart';
import '../../widgets/health_profile/vitals_card.dart';
import '../../widgets/health_profile/chronic_condition_tile.dart';
import '../../widgets/health_profile/allergy_tile.dart';

class HealthProfileViewScreen extends StatefulWidget {
  const HealthProfileViewScreen({Key? key}) : super(key: key);

  @override
  State<HealthProfileViewScreen> createState() => _HealthProfileViewScreenState();
}

class _HealthProfileViewScreenState extends State<HealthProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProfileProvider>().loadHealthProfile();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<HealthProfileProvider>().loadHealthProfile(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        actions: [
          Consumer<HealthProfileProvider>(
            builder: (context, provider, _) {
              if (provider.hasProfile) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/health-profile/edit'),
                  tooltip: 'Edit Profile',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<HealthProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasProfile) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == HealthProfileState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Failed to load health profile',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasProfile) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 80, color: colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  Text(
                    'No Health Profile',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your health profile to track your\nvitals, conditions, and allergies',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/health-profile/edit'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Health Profile'),
                  ),
                ],
              ),
            );
          }

          final profile = provider.healthProfile!;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vitals Card
                  VitalsCard(healthProfile: profile),
                  const SizedBox(height: 16),

                  // Blood Type Card
                  if (profile.bloodType != null) ...[
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.bloodtype, color: colorScheme.primary),
                        title: const Text('Blood Type'),
                        trailing: Chip(
                          label: Text(profile.bloodType!),
                          backgroundColor: colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Chronic Conditions Section
                  _buildSectionHeader(
                    context,
                    'Chronic Conditions',
                    Icons.medical_information,
                    onAdd: () => context.push('/health-profile/chronic-condition/add'),
                  ),
                  const SizedBox(height: 8),
                  if (profile.chronicConditions == null || profile.chronicConditions!.isEmpty)
                    _buildEmptyState(context, 'No chronic conditions recorded')
                  else
                    ...profile.chronicConditions!.map((condition) =>
                        ChronicConditionTile(
                          condition: condition,
                          onDelete: () => _deleteChronicCondition(context, condition['name']),
                        )),
                  const SizedBox(height: 16),

                  // Allergies Section
                  _buildSectionHeader(
                    context,
                    'Allergies',
                    Icons.warning_amber,
                    onAdd: () => context.push('/health-profile/allergy/add'),
                  ),
                  const SizedBox(height: 8),
                  if (profile.allergies == null || profile.allergies!.isEmpty)
                    _buildEmptyState(context, 'No allergies recorded')
                  else
                    ...profile.allergies!.map((allergy) => AllergyTile(
                          allergy: allergy,
                          onDelete: () => _deleteAllergy(context, allergy['allergen']),
                        )),
                  const SizedBox(height: 16),

                  // Current Medications Section
                  if (profile.medications != null && profile.medications!.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Current Medications', Icons.medication),
                    const SizedBox(height: 8),
                    ...profile.medications!.map((med) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(med),
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Lifestyle Section
                  // Lifestyle data not included in base model yet
                  
                  // Emergency Contact Section
                  if (profile.emergencyContact != null) ...[
                    _buildSectionHeader(context, 'Emergency Contact', Icons.contact_phone),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(profile.emergencyContact!['name'] ?? 'N/A'),
                        subtitle: Text(
                          '${profile.emergencyContact!['relationship'] ?? ''}\n${profile.emergencyContact!['phone'] ?? ''}'
                              .trim(),
                        ),
                        trailing: profile.emergencyContact!['phone'] != null
                            ? IconButton(
                                icon: const Icon(Icons.phone),
                                onPressed: () {
                                  // TODO: Implement phone call
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Insurance Section - not included in base model
                  
                  // Notes Section
                  if (profile.notes != null && profile.notes!.isNotEmpty) ...[
                    _buildSectionHeader(context, 'Notes', Icons.note),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(profile.notes!),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<HealthProfileProvider>(
        builder: (context, provider, _) {
          if (!provider.hasProfile) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _showQuickActions(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onAdd,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
            tooltip: 'Add',
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.medical_information),
              title: const Text('Add Chronic Condition'),
              onTap: () {
                Navigator.pop(context);
                context.push('/health-profile/chronic-condition/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: const Text('Add Allergy'),
              onTap: () {
                Navigator.pop(context);
                context.push('/health-profile/allergy/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/health-profile/edit');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteChronicCondition(BuildContext context, String conditionName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content: const Text('Are you sure you want to delete this chronic condition?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<HealthProfileProvider>().removeChronicCondition(conditionName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chronic condition deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete condition: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllergy(BuildContext context, String allergen) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Allergy'),
        content: Text('Are you sure you want to delete the allergy to $allergen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<HealthProfileProvider>().removeAllergy(allergen);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Allergy deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete allergy: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

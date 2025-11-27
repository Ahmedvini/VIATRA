import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';

/// Reusable role switcher widget
class RoleSwitcherWidget extends StatelessWidget {

  const RoleSwitcherWidget({
    super.key,
    required this.availableRoles,
    required this.activeRole,
    required this.onRoleChanged,
  });
  final List<UserRole> availableRoles;
  final UserRole activeRole;
  final Function(UserRole) onRoleChanged;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch Role',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableRoles.map((role) {
                final isActive = role == activeRole;
                return _buildRoleChip(context, role, isActive);
              }).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildRoleChip(BuildContext context, UserRole role, bool isActive) {
    final icon = _getRoleIcon(role);
    final label = _getRoleLabel(role);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        selected: isActive,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          if (!isActive) {
            onRoleChanged(role);
          }
        },
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.hospital:
        return Icons.local_hospital;
      case UserRole.pharmacy:
        return Icons.local_pharmacy;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.hospital:
        return 'Hospital';
      case UserRole.pharmacy:
        return 'Pharmacy';
    }
  }
}

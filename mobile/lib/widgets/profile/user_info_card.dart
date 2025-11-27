import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';

/// User information card widget
class UserInfoCard extends StatelessWidget {

  const UserInfoCard({
    super.key,
    required this.user,
    this.onEditPressed,
    this.activeRole,
  });
  final User user;
  final VoidCallback? onEditPressed;
  final UserRole? activeRole;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    color: AppTheme.primaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Profile avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                _getInitials(user.fullName),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Full name
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Role badge
            _buildRoleBadge(activeRole ?? user.role),
            const SizedBox(height: 16),
            
            // Email
            _buildInfoRow(Icons.email, user.email),
            const SizedBox(height: 8),
            
            // Phone
            _buildInfoRow(Icons.phone, user.phone),
            const SizedBox(height: 8),
            
            // Email verification status
            _buildVerificationStatus(user.emailVerified),
          ],
        ),
      ),
    );

  Widget _buildRoleBadge(UserRole role) {
    Color badgeColor;
    String roleText;
    
    switch (role) {
      case UserRole.patient:
        badgeColor = Colors.blue;
        roleText = 'Patient';
        break;
      case UserRole.doctor:
        badgeColor = Colors.green;
        roleText = 'Doctor';
        break;
      case UserRole.hospital:
        badgeColor = Colors.orange;
        roleText = 'Hospital';
        break;
      case UserRole.pharmacy:
        badgeColor = Colors.purple;
        roleText = 'Pharmacy';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        roleText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) => Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );

  Widget _buildVerificationStatus(bool isVerified) => Row(
      children: [
        Icon(
          isVerified ? Icons.verified : Icons.warning,
          size: 20,
          color: isVerified ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isVerified ? 'Email Verified' : 'Email Not Verified',
            style: TextStyle(
              fontSize: 14,
              color: isVerified ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}

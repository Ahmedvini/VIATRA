import 'package:flutter/material.dart';
import 'admin_user_status_list_screen.dart';

class AdminUsersListScreen extends StatelessWidget {
  final String userRole;
  final String title;

  const AdminUsersListScreen({
    super.key,
    required this.userRole,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final roleTitle = userRole == 'patient' ? 'Patients' : 'Doctors';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Status',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Pending Users Card
            _buildStatusCard(
              context,
              title: 'Pending $roleTitle',
              subtitle: 'Review and authorize new $roleTitle',
              icon: Icons.hourglass_empty,
              color: Colors.orange,
              count: null, // TODO: Add count from API
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUserStatusListScreen(
                      userRole: userRole,
                      status: 'pending',
                      title: 'Pending $roleTitle',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Active Users Card
            _buildStatusCard(
              context,
              title: 'Active $roleTitle',
              subtitle: 'Manage active $roleTitle',
              icon: Icons.check_circle,
              color: Colors.green,
              count: null, // TODO: Add count from API
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUserStatusListScreen(
                      userRole: userRole,
                      status: 'active',
                      title: 'Active $roleTitle',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Deactivated Users Card
            _buildStatusCard(
              context,
              title: 'Deactivated $roleTitle',
              subtitle: 'View and manage deactivated $roleTitle',
              icon: Icons.block,
              color: Colors.red,
              count: null, // TODO: Add count from API
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUserStatusListScreen(
                      userRole: userRole,
                      status: 'deactivated',
                      title: 'Deactivated $roleTitle',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int? count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (count != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count users',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

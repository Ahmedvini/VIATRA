import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import 'admin_user_detail_screen.dart';

class AdminUserStatusListScreen extends StatefulWidget {
  final String userRole;
  final String status;
  final String title;

  const AdminUserStatusListScreen({
    super.key,
    required this.userRole,
    required this.status,
    required this.title,
  });

  @override
  State<AdminUserStatusListScreen> createState() =>
      _AdminUserStatusListScreenState();
}

class _AdminUserStatusListScreenState extends State<AdminUserStatusListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    final adminProvider = context.read<AdminProvider>();
    await adminProvider.loadUsers(widget.userRole, widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 2,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final users = adminProvider.users;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no ${widget.status} ${widget.userRole}s at this time.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(context, user);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AdminUser user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Navigate to detail screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserDetailScreen(
                userId: user.id,
                userStatus: widget.status,
              ),
            ),
          );
          
          // Reload if action was taken
          if (result == true) {
            _loadUsers();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getStatusColor(widget.status),
                    child: Text(
                      user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (user.phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  _buildStatusBadge(widget.status),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Additional Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    icon: Icons.badge,
                    label: user.role.toUpperCase(),
                    color: user.role == 'doctor' ? Colors.blue : Colors.purple,
                  ),
                  _buildInfoChip(
                    icon: Icons.description,
                    label: '${user.verifications.length} docs',
                    color: Colors.orange,
                  ),
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(user.createdAt),
                    color: Colors.grey,
                  ),
                ],
              ),
              
              // Role-specific info
              if (user.doctorProfile != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Specialty: ${user.doctorProfile!.specialty ?? 'Not specified'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (user.doctorProfile!.licenseNumber != null)
                  Text(
                    'License: ${user.doctorProfile!.licenseNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'active':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Active';
        break;
      case 'deactivated':
        icon = Icons.block;
        color = Colors.red;
        label = 'Deactivated';
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'deactivated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}

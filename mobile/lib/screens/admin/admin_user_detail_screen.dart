import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import '../../models/verification_model.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  final String userStatus;

  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    required this.userStatus,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetails();
    });
  }

  Future<void> _loadUserDetails() async {
    final adminProvider = context.read<AdminProvider>();
    await adminProvider.loadUserDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
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
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading user details',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(adminProvider.error!,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = adminProvider.selectedUser;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header Card
                _buildUserHeaderCard(user),
                const SizedBox(height: 16),

                // Profile Details Card
                _buildProfileCard(user),
                const SizedBox(height: 16),

                // Documents Card
                _buildDocumentsCard(user),
                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(context, user),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeaderCard(AdminUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getStatusColor(widget.userStatus),
              child: Text(
                user.firstName[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.role.toUpperCase(),
              style: TextStyle(
                color: user.role == 'doctor' ? Colors.blue : Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusBadge(widget.userStatus),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', user.email),
            if (user.phone != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'Phone', user.phone!),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Registered',
              _formatDateTime(user.createdAt),
            ),
            if (user.lastLogin != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.login,
                'Last Login',
                _formatDateTime(user.lastLogin!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AdminUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (user.doctorProfile != null)
              _buildDoctorProfile(user.doctorProfile!)
            else if (user.patientProfile != null)
              _buildPatientProfile(user.patientProfile!)
            else
              const Text('No profile information available'),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfile(DoctorProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Title', profile.title ?? 'Not specified'),
        _buildDetailRow('Specialty', profile.specialty ?? 'Not specified'),
        _buildDetailRow('License Number', profile.licenseNumber ?? 'Not specified'),
        _buildDetailRow('Education', profile.education ?? 'Not specified'),
        _buildDetailRow('Experience', '${profile.experience ?? 0} years'),
        _buildDetailRow(
          'Consultation Fee',
          profile.consultationFee != null
              ? '\$${profile.consultationFee!.toStringAsFixed(2)}'
              : 'Not specified',
        ),
        if (profile.bio != null) ...[
          const SizedBox(height: 12),
          const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile.bio!),
        ],
      ],
    );
  }

  Widget _buildPatientProfile(PatientProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Date of Birth',
          profile.dateOfBirth != null
              ? DateFormat('MMM dd, yyyy').format(profile.dateOfBirth!)
              : 'Not specified',
        ),
        _buildDetailRow('Gender', profile.gender ?? 'Not specified'),
        _buildDetailRow('Blood Type', profile.bloodType ?? 'Not specified'),
        _buildDetailRow('Address', profile.address ?? 'Not specified'),
        _buildDetailRow('City', profile.city ?? 'Not specified'),
        _buildDetailRow('State', profile.state ?? 'Not specified'),
        _buildDetailRow('Country', profile.country ?? 'Not specified'),
      ],
    );
  }

  Widget _buildDocumentsCard(AdminUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Documents',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user.verifications.length} documents',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.verifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No documents uploaded'),
                ),
              )
            else
              ...user.verifications.map((doc) => _buildDocumentItem(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(Verification doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                doc.documentUrl?.endsWith('.pdf') == true
                    ? Icons.picture_as_pdf
                    : Icons.image,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDocumentType(doc.documentType),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      doc.documentUrl?.split('/').last ?? 'No filename',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildDocumentStatusBadge(doc.status),
            ],
          ),
          if (doc.documentUrl != null) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _viewDocument(doc.documentUrl!),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Document'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ],
          if (doc.comments != null && doc.comments!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: doc.isRejected ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    doc.isRejected ? Icons.error : Icons.info,
                    color: doc.isRejected ? Colors.red : Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc.comments!,
                      style: TextStyle(
                        color: doc.isRejected ? Colors.red : Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdminUser user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.userStatus == 'pending') ...[
              ElevatedButton.icon(
                onPressed: () => _authorizeUser(context, user),
                icon: const Icon(Icons.check_circle),
                label: const Text('Authorize User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _rejectUser(context, user),
                icon: const Icon(Icons.cancel),
                label: const Text('Reject User'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else if (widget.userStatus == 'active') ...[
              OutlinedButton.icon(
                onPressed: () => _deactivateUser(context, user),
                icon: const Icon(Icons.block),
                label: const Text('Deactivate User'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _deleteUser(context, user),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete User'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else if (widget.userStatus == 'deactivated') ...[
              ElevatedButton.icon(
                onPressed: () => _activateUser(context, user),
                icon: const Icon(Icons.check_circle),
                label: const Text('Activate User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _deleteUser(context, user),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete User'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Action Methods
  Future<void> _authorizeUser(BuildContext context, AdminUser user) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Authorize User',
      'Are you sure you want to authorize ${user.fullName}? This will approve all documents and activate their account.',
      confirmText: 'Authorize',
      confirmColor: Colors.green,
    );

    if (confirmed != true) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.authorizeUser(
      user.id,
      notes: 'Authorized by admin',
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been authorized'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate action taken
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to authorize user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectUser(BuildContext context, AdminUser user) async {
    final reason = await _showReasonDialog(
      context,
      'Reject User',
      'Please provide a reason for rejecting ${user.fullName}:',
    );

    if (reason == null || reason.isEmpty) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.rejectUser(
      user.id,
      reason,
      notes: 'Rejected by admin',
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to reject user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _activateUser(BuildContext context, AdminUser user) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Activate User',
      'Are you sure you want to activate ${user.fullName}?',
      confirmText: 'Activate',
      confirmColor: Colors.green,
    );

    if (confirmed != true) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.activateUser(
      user.id,
      notes: 'Reactivated by admin',
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been activated'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to activate user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deactivateUser(BuildContext context, AdminUser user) async {
    final reason = await _showReasonDialog(
      context,
      'Deactivate User',
      'Please provide a reason for deactivating ${user.fullName}:',
    );

    if (reason == null || reason.isEmpty) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.deactivateUser(
      user.id,
      reason,
      notes: 'Deactivated by admin',
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been deactivated'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to deactivate user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(BuildContext context, AdminUser user) async {
    final reason = await _showReasonDialog(
      context,
      'Delete User',
      'Please provide a reason for permanently deleting ${user.fullName}.\n\n⚠️ This action cannot be undone!',
      hintText: 'Reason for deletion...',
    );

    if (reason == null || reason.isEmpty) return;

    // Second confirmation for delete
    final confirmed = await _showConfirmDialog(
      context,
      'Confirm Deletion',
      'Are you absolutely sure you want to permanently delete ${user.fullName}? This action cannot be undone.',
      confirmText: 'Delete Permanently',
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.deleteUser(user.id, reason);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been deleted'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.error ?? 'Failed to delete user'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewDocument(String url) async {
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open document: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper Methods
  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<String?> _showReasonDialog(
    BuildContext context,
    String title,
    String message, {
    String hintText = 'Enter reason...',
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Submit'),
          ),
        ],
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
        label = 'Pending Review';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusBadge(VerificationStatus status) {
    Color color;
    String label;

    switch (status) {
      case VerificationStatus.approved:
        color = Colors.green;
        label = 'Verified';
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case VerificationStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case VerificationStatus.notSubmitted:
        color = Colors.grey;
        label = 'Not Submitted';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  String _formatDocumentType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

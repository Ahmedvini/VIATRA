import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });
  final String appointmentId;

  @override
  _AppointmentDetailScreenState createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isLoading = true;
  Appointment? _appointment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      final appointment = await provider.fetchAppointmentById(widget.appointmentId);
      
      if (mounted) {
        setState(() {
          _appointment = appointment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Ask for cancellation reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        var inputReason = '';
        return AlertDialog(
          title: const Text('Reason for Cancellation'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Optional: Provide a reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => inputReason = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, inputReason),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (reason == null) return;

    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      await provider.cancelAppointment(
        widget.appointmentId,
        reason.isNotEmpty ? reason : 'No reason provided',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAppointment();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rescheduling feature coming soon!'),
      ),
    );
    // TODO: Implement reschedule flow
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _appointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading appointment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAppointment,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final appointment = _appointment!;
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(appointment.scheduledStart);
    final formattedStartTime = DateFormat('h:mm a').format(appointment.scheduledStart);
    final formattedEndTime = DateFormat('h:mm a').format(appointment.scheduledEnd);
    final canCancel = appointment.canBeCancelled;
    final canReschedule = appointment.canBeRescheduled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        elevation: 0,
        actions: [
          if (canCancel || canReschedule)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _cancelAppointment();
                } else if (value == 'reschedule') {
                  _rescheduleAppointment();
                }
              },
              itemBuilder: (context) => [
                if (canReschedule)
                  const PopupMenuItem(
                    value: 'reschedule',
                    child: ListTile(
                      leading: Icon(Icons.edit_calendar),
                      title: Text('Reschedule'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (canCancel)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('Cancel', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.statusLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (appointment.urgent) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Doctor Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          appointment.doctorName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment.specialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Appointment Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    Icons.medical_services,
                    'Type',
                    appointment.appointmentType.replaceAll('_', ' ').toUpperCase(),
                  ),
                  const Divider(height: 24),
                  _buildInfoTile(
                    Icons.calendar_today,
                    'Date',
                    formattedDate,
                  ),
                  const Divider(height: 24),
                  _buildInfoTile(
                    Icons.access_time,
                    'Time',
                    '$formattedStartTime - $formattedEndTime',
                  ),
                  const Divider(height: 24),
                  _buildInfoTile(
                    Icons.timelapse,
                    'Duration',
                    '${appointment.duration} minutes',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visit Details
            ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reason for Visit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment.reasonForVisit,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (appointment.chiefComplaint != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Chief Complaint',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appointment.chiefComplaint!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

            // Cancellation Info
            if (appointment.status == 'cancelled') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Text(
                            'Cancelled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        ],
                      ),
                      if (appointment.cancelledAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Cancelled on ${DateFormat('MMM d, yyyy h:mm a').format(appointment.cancelledAt!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                      if (appointment.cancellationReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reason: ${appointment.cancellationReason}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (canCancel || canReschedule)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (canReschedule)
                      ElevatedButton.icon(
                        onPressed: _rescheduleAppointment,
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Reschedule Appointment'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (canCancel) ...[
                      if (canReschedule) const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _cancelAppointment,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancel Appointment',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

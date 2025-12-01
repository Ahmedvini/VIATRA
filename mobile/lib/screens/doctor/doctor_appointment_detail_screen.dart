import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/doctor/appointment_action_buttons.dart';

class DoctorAppointmentDetailScreen extends StatefulWidget {

  const DoctorAppointmentDetailScreen({
    required this.appointmentId, super.key,
  });
  final String appointmentId;

  @override
  State<DoctorAppointmentDetailScreen> createState() => _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState extends State<DoctorAppointmentDetailScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      provider.loadAppointmentById(widget.appointmentId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(String appointmentId) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.acceptAppointment(appointmentId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Appointment accepted successfully' : provider.errorMessage ?? 'Failed to accept appointment'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        provider.loadAppointmentById(appointmentId);
      }
    }
  }

  Future<void> _handleReschedule(String appointmentId, DateTime start, DateTime end) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.rescheduleAppointment(appointmentId, start, end);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Appointment rescheduled successfully' : provider.errorMessage ?? 'Failed to reschedule appointment'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        provider.loadAppointmentById(appointmentId);
      }
    }
  }

  Future<void> _handleCancel(String appointmentId, String reason) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.cancelAppointment(appointmentId, reason);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Appointment cancelled successfully' : provider.errorMessage ?? 'Failed to cancel appointment'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        provider.loadAppointmentById(appointmentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentAppointment == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError || provider.currentAppointment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Appointment not found',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAppointmentById(widget.appointmentId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final appointment = provider.currentAppointment!;
          _notesController.text = appointment.notes ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: appointment.patient?['profileImage'] != null
                                  ? NetworkImage(appointment.patient!['profileImage'] as String)
                                  : null,
                              child: appointment.patient?['profileImage'] == null
                                  ? Text(
                                      ((appointment.patient?['firstName'] as String?) ?? 'P')[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${appointment.patient?['firstName'] ?? ''} ${appointment.patient?['lastName'] ?? ''}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (appointment.patient?['email'] != null)
                                    Text(
                                      appointment.patient!['email'] as String,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  if (appointment.patient?['phone'] != null)
                                    Text(
                                      appointment.patient!['phone'] as String,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Appointment Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(context, 'Type', appointment.appointmentType.toUpperCase(), appointment.typeIcon),
                        _buildDetailRow(
                          context,
                          'Date',
                          DateFormat('EEEE, MMMM d, yyyy').format(appointment.scheduledStart),
                          Icons.calendar_today,
                        ),
                        _buildDetailRow(
                          context,
                          'Time',
                          '${DateFormat('h:mm a').format(appointment.scheduledStart)} - ${DateFormat('h:mm a').format(appointment.scheduledEnd)}',
                          Icons.access_time,
                        ),
                        _buildDetailRow(
                          context,
                          'Duration',
                          '${appointment.scheduledEnd.difference(appointment.scheduledStart).inMinutes} minutes',
                          Icons.timer,
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Text('Status: ', style: Theme.of(context).textTheme.bodyLarge),
                            Chip(
                              label: Text(
                                appointment.statusLabel,
                                style: TextStyle(
                                  color: appointment.statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: appointment.statusColor.withOpacity(0.1),
                            ),
                          ],
                        ),
                        if (appointment.urgent)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Chip(
                              label: Text(
                                'URGENT',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (appointment.reasonForVisit.isNotEmpty) ...[
                          Text('Reason for Visit:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(appointment.reasonForVisit, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                        if (appointment.chiefComplaint != null && appointment.chiefComplaint!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Chief Complaint:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(appointment.chiefComplaint!, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Notes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notesController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Add consultation notes...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final notes = _notesController.text;
                              final success = await provider.updateAppointment(
                                appointment.id,
                                {'notes': notes},
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Notes saved' : 'Failed to save notes'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Save Notes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Space for action buttons
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.currentAppointment == null) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: AppointmentActionButtons(
              appointment: provider.currentAppointment!,
              onAccept: _handleAccept,
              onReschedule: _handleReschedule,
              onCancel: _handleCancel,
            ),
          );
        },
      ),
    );

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

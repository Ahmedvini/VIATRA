import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../common/custom_button.dart';

class AppointmentActionButtons extends StatefulWidget {

  const AppointmentActionButtons({
    required this.appointment, required this.onAccept, required this.onReschedule, required this.onCancel, super.key,
  });
  final Appointment appointment;
  final Function(String appointmentId) onAccept;
  final Function(String appointmentId, DateTime start, DateTime end) onReschedule;
  final Function(String appointmentId, String reason) onCancel;

  @override
  State<AppointmentActionButtons> createState() => _AppointmentActionButtonsState();
}

class _AppointmentActionButtonsState extends State<AppointmentActionButtons> {
  bool _isAccepting = false;
  bool _isRescheduling = false;
  bool _isCancelling = false;

  bool get _isAnyActionInProgress => _isAccepting || _isRescheduling || _isCancelling;

  Future<void> _handleAccept() async {
    setState(() => _isAccepting = true);
    try {
      await widget.onAccept(widget.appointment.id);
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _handleReschedule() async {
    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: widget.appointment.scheduledStart,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    // Show time picker for start time
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.appointment.scheduledStart),
    );

    if (startTime == null || !mounted) return;

    // Show time picker for end time
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.appointment.scheduledEnd),
    );

    if (endTime == null || !mounted) return;

    // Combine date and time
    final newStart = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final newEnd = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    // Validate times
    if (newEnd.isBefore(newStart) || newEnd.difference(newStart).inMinutes < 15) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid time selection. End time must be at least 15 minutes after start time.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Confirm reschedule
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reschedule'),
        content: Text(
          'Reschedule appointment to:\n${DateFormat('EEEE, MMMM d, yyyy').format(newStart)}\n${DateFormat('h:mm a').format(newStart)} - ${DateFormat('h:mm a').format(newEnd)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isRescheduling = true);
    try {
      await widget.onReschedule(widget.appointment.id, newStart, newEnd);
    } finally {
      if (mounted) {
        setState(() => _isRescheduling = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Cancellation reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for cancellation'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, reasonController.text.trim());
            },
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await widget.onCancel(widget.appointment.id, result);
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.appointment.status == 'scheduled') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnyActionInProgress ? null : _handleAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isAccepting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Accept'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.appointment.canBeRescheduled) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isAnyActionInProgress ? null : _handleReschedule,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: _isRescheduling
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reschedule'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.appointment.canBeCancelled)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isAnyActionInProgress ? null : _handleCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: _isCancelling
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cancel'),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        if (widget.appointment.status == 'scheduled') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _isAnyActionInProgress ? null : _handleAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isAccepting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Accept'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.appointment.canBeRescheduled) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _isAnyActionInProgress ? null : _handleReschedule,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: _isRescheduling
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reschedule'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.appointment.canBeCancelled)
          Expanded(
            child: TextButton(
              onPressed: _isAnyActionInProgress ? null : _handleCancel,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: _isCancelling
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cancel'),
            ),
          ),
      ],
    );
  }
}

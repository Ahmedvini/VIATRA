import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import 'appointment_detail_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {

  const BookingConfirmationScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.appointmentType,
    required this.selectedDate,
    required this.selectedSlot,
    required this.reasonForVisit,
    required this.chiefComplaint,
    required this.urgent,
  });
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String appointmentType;
  final DateTime selectedDate;
  final TimeSlot selectedSlot;
  final String reasonForVisit;
  final String chiefComplaint;
  final bool urgent;

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isBooking = false;

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    try {
      final provider = Provider.of<AppointmentProvider>(context, listen: false);
      
      final appointment = await provider.bookAppointment(
        doctorId: widget.doctorId,
        appointmentType: widget.appointmentType,
        scheduledStart: widget.selectedSlot.start,
        scheduledEnd: widget.selectedSlot.end,
        reasonForVisit: widget.reasonForVisit,
        chiefComplaint: widget.chiefComplaint.isNotEmpty ? widget.chiefComplaint : null,
        urgent: widget.urgent,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appointment detail screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
              appointmentId: appointment.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(widget.selectedDate);
    final formattedStartTime = DateFormat('h:mm a').format(widget.selectedSlot.start);
    final formattedEndTime = DateFormat('h:mm a').format(widget.selectedSlot.end);
    final duration = widget.selectedSlot.end.difference(widget.selectedSlot.start).inMinutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Review Your Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please confirm the details below',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Doctor Info
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
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.doctorName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
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
                              widget.doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.specialty,
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

            // Appointment Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.medical_services,
                    'Type',
                    widget.appointmentType.replaceAll('_', ' ').toUpperCase(),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    formattedDate,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.access_time,
                    'Time',
                    '$formattedStartTime - $formattedEndTime',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    Icons.timelapse,
                    'Duration',
                    '$duration minutes',
                  ),
                  if (widget.urgent) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.priority_high,
                      'Priority',
                      'URGENT',
                      valueColor: Colors.red,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visit Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Information',
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
                          widget.reasonForVisit,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (widget.chiefComplaint.isNotEmpty) ...[
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
                            widget.chiefComplaint,
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

            // Important Notice
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Appointments can be cancelled at least 2 hours before the scheduled time.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirm Appointment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isBooking ? null : () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) => Row(
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
}

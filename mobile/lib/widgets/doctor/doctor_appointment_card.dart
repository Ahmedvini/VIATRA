import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';

class DoctorAppointmentCard extends StatelessWidget {

  const DoctorAppointmentCard({
    required this.appointment, super.key,
    this.onTap,
  });
  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final patient = appointment.patient;
    final patientName = patient != null
        ? '${patient['firstName'] ?? patient['first_name'] ?? ''} ${patient['lastName'] ?? patient['last_name'] ?? ''}'.trim()
        : 'Unknown Patient';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: 'Appointment with $patientName on ${DateFormat('MMM d, h:mm a').format(appointment.scheduledStart)}, status: ${appointment.statusLabel}',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left Section: Time and Date
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(appointment.scheduledStart),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d').format(appointment.scheduledStart),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        appointment.typeIcon,
                        size: 20,
                        color: _getTypeColor(appointment.appointmentType),
                      ),
                    ],
                  ),
                ),

                // Middle Section: Patient Info and Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patientName,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (appointment.urgent)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.reasonForVisit,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appointment.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appointment.statusLabel,
                            style: TextStyle(
                              color: appointment.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Section: Chevron
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'telehealth':
        return Colors.blue;
      case 'in_person':
        return Colors.green;
      case 'phone':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

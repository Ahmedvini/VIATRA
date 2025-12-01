import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIcon != null)
              customIcon!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            const SizedBox(height: 24),
            Text(
              title ?? 'No Data',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyAppointmentsWidget extends StatelessWidget {

  const EmptyAppointmentsWidget({
    super.key,
    this.isUpcoming = true,
    this.onBookAppointment,
  });
  final bool isUpcoming;
  final VoidCallback? onBookAppointment;

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: isUpcoming ? 'No Upcoming Appointments' : 'No Past Appointments',
      message: isUpcoming ? 'Book an appointment to get started' : null,
      actionLabel: isUpcoming ? 'Book Appointment' : null,
      onAction: onBookAppointment,
    );
}

class EmptySearchWidget extends StatelessWidget {

  const EmptySearchWidget({
    super.key,
    this.onClearSearch,
  });
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Doctors Found',
      message: 'Try adjusting your search filters',
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
}

class EmptyHealthDataWidget extends StatelessWidget {

  const EmptyHealthDataWidget({
    required this.type, super.key,
    this.onAdd,
  });
  final String type; // 'conditions', 'allergies', 'medications'
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;

    switch (type) {
      case 'conditions':
        title = 'No Chronic Conditions';
        icon = Icons.medical_information_outlined;
        break;
      case 'allergies':
        title = 'No Allergies';
        icon = Icons.warning_amber_outlined;
        break;
      case 'medications':
        title = 'No Medications';
        icon = Icons.medication_outlined;
        break;
      default:
        title = 'No Data';
        icon = Icons.inbox_outlined;
    }

    return EmptyStateWidget(
      icon: icon,
      title: title,
      actionLabel: onAdd != null ? 'Add' : null,
      onAction: onAdd,
    );
  }
}

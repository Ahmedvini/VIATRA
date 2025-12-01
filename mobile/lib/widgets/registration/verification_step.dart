import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/verification_model.dart';
import 'verification_status_card.dart';

class VerificationStep extends StatelessWidget {

  const VerificationStep({
    super.key,
    required this.userRole,
    required this.verifications,
    this.onRefresh,
  });
  final UserRole userRole;
  final List<Verification> verifications;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Pending',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your account is currently under review. We will notify you once verification is complete.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          VerificationStatusCard(
            key: const Key('verification_status_card'),
            verifications: verifications,
            userRole: userRole == UserRole.doctor ? 'doctor' : 'patient',
            onRefresh: onRefresh,
          ),
        ],
      ),
    );
  }
}

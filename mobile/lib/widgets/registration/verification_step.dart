import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../models/verification_model.dart';
import 'verification_status_card.dart';

class VerificationStep extends StatelessWidget {

  const VerificationStep({
    Key? key,
    required this.userRole,
    required this.verifications,
    this.onRefresh,
  }) : super(key: key);
  final UserRole userRole;
  final List<Verification> verifications;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.verificationPending,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.verificationPendingMessage,
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
